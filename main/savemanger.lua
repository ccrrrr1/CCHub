local cloneref = cloneref or clonereference or function(v) return v end
local clonefunction = clonefunction or copyfunction or function(f) return f end

local http_service = cloneref(game:GetService("HttpService"))
local isfolder, isfile, listfiles = isfolder, isfile, listfiles

local function clean_folder_name(str)
    str = tostring(str)
    str = str:gsub("[\128-\255]", "")
    str = str:gsub("[^%w%s%-_]", "")
    str = str:gsub("%s+", " ")
    str = str:gsub("^%s+", ""):gsub("%s+$", "")
    if str == "" then
        str = "Unknown"
    end
    return str
end

local function safe_makefolder(path)
    local built = ""
    for part in path:gmatch("[^/]+") do
        built = built == "" and part or built .. "/" .. part
        if not isfolder(built) then
            pcall(makefolder, built)
        end
    end
end

if typeof(clonefunction) == "function" then
    local isfolder_copy = clonefunction(isfolder)
    local isfile_copy = clonefunction(isfile)
    local listfiles_copy = clonefunction(listfiles)

    local ok, res = pcall(isfolder_copy, "test_" .. math.random(1, 1e9))
    if not ok or typeof(res) ~= "boolean" then
        isfolder = function(p)
            local s, r = pcall(isfolder_copy, p)
            return s and r or false
        end
        isfile = function(p)
            local s, r = pcall(isfile_copy, p)
            return s and r or false
        end
        listfiles = function(p)
            local s, r = pcall(listfiles_copy, p)
            return s and r or {}
        end
    end
end

local SaveManager = {}

SaveManager.BaseFolder = "V3Configs"
SaveManager.Folder = clean_folder_name(game.Name)
SaveManager.SubFolder = ""
SaveManager.Ignore = {}
SaveManager.Library = nil
SaveManager._resolved_folder = nil

SaveManager.Parser = {
    Toggle = {
        Save = function(idx, obj)
            return { type = "Toggle", idx = idx, value = obj.Value }
        end,
        Load = function(idx, data)
            local obj = SaveManager.Library.Toggles[idx]
            if obj and obj.Value ~= data.value then
                obj:SetValue(data.value)
            end
        end
    },
    Slider = {
        Save = function(idx, obj)
            return { type = "Slider", idx = idx, value = tostring(obj.Value) }
        end,
        Load = function(idx, data)
            local obj = SaveManager.Library.Options[idx]
            if obj then
                obj:SetValue(data.value)
            end
        end
    },
    Dropdown = {
        Save = function(idx, obj)
            return { type = "Dropdown", idx = idx, value = obj.Value, multi = obj.Multi }
        end,
        Load = function(idx, data)
            local obj = SaveManager.Library.Options[idx]
            if obj then
                obj:SetValue(data.value)
            end
        end
    },
    ColorPicker = {
        Save = function(idx, obj)
            return { type = "ColorPicker", idx = idx, value = obj.Value:ToHex(), transparency = obj.Transparency }
        end,
        Load = function(idx, data)
            local obj = SaveManager.Library.Options[idx]
            if obj then
                obj:SetValueRGB(Color3.fromHex(data.value), data.transparency)
            end
        end
    },
    KeyPicker = {
        Save = function(idx, obj)
            return { type = "KeyPicker", idx = idx, mode = obj.Mode, key = obj.Value, modifiers = obj.Modifiers }
        end,
        Load = function(idx, data)
            local obj = SaveManager.Library.Options[idx]
            if obj then
                obj:SetValue({ data.key, data.mode, data.modifiers })
            end
        end
    },
    Input = {
        Save = function(idx, obj)
            return { type = "Input", idx = idx, text = obj.Value }
        end,
        Load = function(idx, data)
            local obj = SaveManager.Library.Options[idx]
            if obj and type(data.text) == "string" then
                obj:SetValue(data.text)
            end
        end
    }
}

function SaveManager:SetLibrary(lib)
    self.Library = lib
end

function SaveManager:SetIgnoreIndexes(list)
    for i = 1, #list do
        self.Ignore[list[i]] = true
    end
end

function SaveManager:IgnoreThemeSettings()
    self:SetIgnoreIndexes({
        "BackgroundColor",
        "MainColor",
        "AccentColor",
        "OutlineColor",
        "FontColor",
        "ThemeManager_ThemeList",
        "ThemeManager_CustomThemeList",
        "ThemeManager_CustomThemeName",
        "VideoLink"
    })
end

function SaveManager:BuildFolderTree()
    local root = self.BaseFolder
    local game_folder = clean_folder_name(self.Folder)

    safe_makefolder(root)

    local full = root .. "/" .. game_folder
    safe_makefolder(full)
    safe_makefolder(full .. "/themes")
    safe_makefolder(full .. "/settings")

    if typeof(self.SubFolder) == "string" and self.SubFolder ~= "" then
        local sub = clean_folder_name(self.SubFolder)
        safe_makefolder(full .. "/settings/" .. sub)
    end

    self._resolved_folder = full
end

function SaveManager:CheckFolderTree()
    if self._resolved_folder and isfolder(self._resolved_folder) then return end
    self:BuildFolderTree()
end

function SaveManager:SetFolder(folder)
    self.Folder = clean_folder_name(folder)
    self:BuildFolderTree()
end

function SaveManager:SetSubFolder(folder)
    self.SubFolder = clean_folder_name(folder)
    self:BuildFolderTree()
end

function SaveManager:_settings_path()
    self:CheckFolderTree()
    if self.SubFolder ~= "" then
        return self._resolved_folder .. "/settings/" .. self.SubFolder
    end
    return self._resolved_folder .. "/settings"
end

function SaveManager:Save(name)
    if not name then return false end
    local path = self:_settings_path() .. "/" .. name .. ".json"

    local data = { objects = {} }

    for idx, obj in next, self.Library.Toggles do
        if obj.Type and self.Parser[obj.Type] and not self.Ignore[idx] then
            table.insert(data.objects, self.Parser[obj.Type].Save(idx, obj))
        end
    end

    for idx, obj in next, self.Library.Options do
        if obj.Type and self.Parser[obj.Type] and not self.Ignore[idx] then
            table.insert(data.objects, self.Parser[obj.Type].Save(idx, obj))
        end
    end

    local ok, encoded = pcall(http_service.JSONEncode, http_service, data)
    if not ok then return false end

    writefile(path, encoded)
    return true
end

function SaveManager:Load(name)
    if not name then return false end
    local path = self:_settings_path() .. "/" .. name .. ".json"
    if not isfile(path) then return false end

    local ok, decoded = pcall(http_service.JSONDecode, http_service, readfile(path))
    if not ok then return false end

    for _, opt in next, decoded.objects do
        if opt.type and self.Parser[opt.type] and not self.Ignore[opt.idx] then
            task.spawn(self.Parser[opt.type].Load, opt.idx, opt)
        end
    end

    return true
end

function SaveManager:Delete(name)
    if not name then return false end
    local path = self:_settings_path() .. "/" .. name .. ".json"
    if not isfile(path) then return false end
    return pcall(delfile, path)
end

function SaveManager:RefreshConfigList()
    local out = {}
    local path = self:_settings_path()
    local files = listfiles(path)

    for i = 1, #files do
        local f = files[i]
        if f:sub(-5) == ".json" then
            table.insert(out, f:match("([^/\\]+)%.json$"))
        end
    end

    return out
end

SaveManager:BuildFolderTree()
return SaveManager
