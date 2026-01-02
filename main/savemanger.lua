local cloneref = cloneref or clonereference or function(x) return x end
local clonefunction = clonefunction or copyfunction or function(f) return f end

local http_service = cloneref(game:GetService("HttpService"))

local isfolder = isfolder
local isfile = isfile
local listfiles = listfiles
local makefolder = makefolder
local writefile = writefile
local readfile = readfile
local delfile = delfile

if typeof(clonefunction) == "function" then
    local isfolder_copy = clonefunction(isfolder)
    local isfile_copy = clonefunction(isfile)
    local listfiles_copy = clonefunction(listfiles)

    local ok, res = pcall(isfolder_copy, "test_" .. math.random(1e6, 9e6))
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

local function clean_name(str)
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

local SaveManager = {} do
    SaveManager.BaseFolder = "LinoriaLibSettings"
    SaveManager.GameFolder = clean_name(game.Name)
    SaveManager.SubFolder = ""
    SaveManager.Ignore = {}
    SaveManager.Library = nil
    SaveManager._resolved_folder = nil

    SaveManager.Parser = {
        Toggle = {
            Save = function(idx, o)
                return { type = "Toggle", idx = idx, value = o.Value }
            end,
            Load = function(idx, d)
                local o = SaveManager.Library.Toggles[idx]
                if o and o.Value ~= d.value then
                    o:SetValue(d.value)
                end
            end
        },
        Slider = {
            Save = function(idx, o)
                return { type = "Slider", idx = idx, value = tostring(o.Value) }
            end,
            Load = function(idx, d)
                local o = SaveManager.Library.Options[idx]
                if o then
                    o:SetValue(d.value)
                end
            end
        },
        Dropdown = {
            Save = function(idx, o)
                return { type = "Dropdown", idx = idx, value = o.Value, multi = o.Multi }
            end,
            Load = function(idx, d)
                local o = SaveManager.Library.Options[idx]
                if o then
                    o:SetValue(d.value)
                end
            end
        },
        ColorPicker = {
            Save = function(idx, o)
                return { type = "ColorPicker", idx = idx, value = o.Value:ToHex(), transparency = o.Transparency }
            end,
            Load = function(idx, d)
                local o = SaveManager.Library.Options[idx]
                if o then
                    o:SetValueRGB(Color3.fromHex(d.value), d.transparency)
                end
            end
        },
        KeyPicker = {
            Save = function(idx, o)
                return { type = "KeyPicker", idx = idx, key = o.Value, mode = o.Mode, modifiers = o.Modifiers }
            end,
            Load = function(idx, d)
                local o = SaveManager.Library.Options[idx]
                if o then
                    o:SetValue({ d.key, d.mode, d.modifiers })
                end
            end
        },
        Input = {
            Save = function(idx, o)
                return { type = "Input", idx = idx, text = o.Value }
            end,
            Load = function(idx, d)
                local o = SaveManager.Library.Options[idx]
                if o then
                    o:SetValue(d.text)
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

    function SaveManager:SetFolder(folder)
        self.GameFolder = clean_name(folder)
        self:BuildFolderTree()
    end

    function SaveManager:SetSubFolder(folder)
        self.SubFolder = clean_name(folder)
        self:BuildFolderTree()
    end

    function SaveManager:BuildFolderTree()
        local root = self.BaseFolder
        local game_folder = clean_name(self.GameFolder)
        local full_root = root .. "/" .. game_folder

        safe_makefolder(root)
        safe_makefolder(full_root)
        safe_makefolder(full_root .. "/themes")
        safe_makefolder(full_root .. "/settings")

        if self.SubFolder ~= "" then
            safe_makefolder(full_root .. "/settings/" .. clean_name(self.SubFolder))
        end

        self._resolved_folder = full_root
    end

    function SaveManager:CheckFolderTree()
        if self._resolved_folder and isfolder(self._resolved_folder) then
            return
        end
        self:BuildFolderTree()
    end

    function SaveManager:Save(name)
        if not name then return false, "no config file is selected" end
        self:CheckFolderTree()

        name = clean_name(name)
        local path = self._resolved_folder .. "/settings/" .. name .. ".json"

        if self.SubFolder ~= "" then
            path = self._resolved_folder .. "/settings/" .. clean_name(self.SubFolder) .. "/" .. name .. ".json"
        end

        local data = { objects = {} }

        for idx, t in next, self.Library.Toggles do
            if t.Type and self.Parser[t.Type] and not self.Ignore[idx] then
                data.objects[#data.objects + 1] = self.Parser[t.Type].Save(idx, t)
            end
        end

        for idx, o in next, self.Library.Options do
            if o.Type and self.Parser[o.Type] and not self.Ignore[idx] then
                data.objects[#data.objects + 1] = self.Parser[o.Type].Save(idx, o)
            end
        end

        local ok, enc = pcall(http_service.JSONEncode, http_service, data)
        if not ok then return false, "encode failed" end

        writefile(path, enc)
        return true
    end

    function SaveManager:Load(name)
        if not name then return false, "no config file is selected" end
        self:CheckFolderTree()

        name = clean_name(name)
        local path = self._resolved_folder .. "/settings/" .. name .. ".json"

        if self.SubFolder ~= "" then
            path = self._resolved_folder .. "/settings/" .. clean_name(self.SubFolder) .. "/" .. name .. ".json"
        end

        if not isfile(path) then return false, "invalid file" end

        local ok, dec = pcall(http_service.JSONDecode, http_service, readfile(path))
        if not ok then return false, "decode error" end

        for _, opt in next, dec.objects do
            if opt.type and self.Parser[opt.type] and not self.Ignore[opt.idx] then
                task.spawn(self.Parser[opt.type].Load, opt.idx, opt)
            end
        end

        return true
    end

    function SaveManager:Delete(name)
        if not name then return false end
        self:CheckFolderTree()

        name = clean_name(name)
        local path = self._resolved_folder .. "/settings/" .. name .. ".json"

        if self.SubFolder ~= "" then
            path = self._resolved_folder .. "/settings/" .. clean_name(self.SubFolder) .. "/" .. name .. ".json"
        end

        if not isfile(path) then return false end
        pcall(delfile, path)
        return true
    end

    function SaveManager:RefreshConfigList()
        self:CheckFolderTree()

        local folder = self._resolved_folder .. "/settings"
        if self.SubFolder ~= "" then
            folder = folder .. "/" .. clean_name(self.SubFolder)
        end

        local out = {}
        local files = listfiles(folder) or {}

        for i = 1, #files do
            local f = files[i]
            if f:sub(-5) == ".json" then
                out[#out + 1] = f:match("([^/\\]+)%.json$")
            end
        end

        return out
    end

    SaveManager:BuildFolderTree()
end

return SaveManager
