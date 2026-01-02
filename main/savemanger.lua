local cloneref = cloneref or clonereference or function(x) return x end
local httpService = cloneref(game:GetService("HttpService"))

local isfolder = isfolder
local isfile = isfile
local listfiles = listfiles
local makefolder = makefolder
local writefile = writefile
local readfile = readfile
local delfile = delfile

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

local SaveManager = {}

SaveManager.Folder = clean_name(game.Name)
SaveManager.SubFolder = ""
SaveManager.Ignore = {}
SaveManager.Library = nil

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
            return { type = "KeyPicker", idx = idx, key = obj.Value, mode = obj.Mode }
        end,
        Load = function(idx, data)
            local obj = SaveManager.Library.Options[idx]
            if obj then
                obj:SetValue({ data.key, data.mode })
            end
        end
    },
    Input = {
        Save = function(idx, obj)
            return { type = "Input", idx = idx, text = obj.Value }
        end,
        Load = function(idx, data)
            local obj = SaveManager.Library.Options[idx]
            if obj then
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

function SaveManager:SetFolder(folder)
    self.Folder = clean_name(folder)
    self:BuildFolderTree()
end

function SaveManager:SetSubFolder(folder)
    self.SubFolder = clean_name(folder)
    self:BuildFolderTree()
end

function SaveManager:BuildFolderTree()
    self.Folder = clean_name(self.Folder)

    safe_makefolder(self.Folder)
    safe_makefolder(self.Folder .. "/themes")
    safe_makefolder(self.Folder .. "/settings")

    if self.SubFolder ~= "" then
        self.SubFolder = clean_name(self.SubFolder)
        safe_makefolder(self.Folder .. "/settings/" .. self.SubFolder)
    end
end

function SaveManager:Save(name)
    if not name then return false, "no config name" end
    name = clean_name(name)

    self:BuildFolderTree()

    local path = self.Folder .. "/settings/" .. name .. ".json"
    if self.SubFolder ~= "" then
        path = self.Folder .. "/settings/" .. self.SubFolder .. "/" .. name .. ".json"
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

    local ok, encoded = pcall(httpService.JSONEncode, httpService, data)
    if not ok then return false, "encode failed" end

    writefile(path, encoded)
    return true
end

function SaveManager:Load(name)
    if not name then return false, "no config name" end
    name = clean_name(name)

    local path = self.Folder .. "/settings/" .. name .. ".json"
    if self.SubFolder ~= "" then
        path = self.Folder .. "/settings/" .. self.SubFolder .. "/" .. name .. ".json"
    end

    if not isfile(path) then return false, "file missing" end

    local ok, decoded = pcall(httpService.JSONDecode, httpService, readfile(path))
    if not ok then return false, "decode failed" end

    for i = 1, #decoded.objects do
        local obj = decoded.objects[i]
        if obj.type and self.Parser[obj.type] then
            task.spawn(self.Parser[obj.type].Load, obj.idx, obj)
        end
    end

    return true
end

function SaveManager:Delete(name)
    if not name then return false end
    name = clean_name(name)

    local path = self.Folder .. "/settings/" .. name .. ".json"
    if self.SubFolder ~= "" then
        path = self.Folder .. "/settings/" .. self.SubFolder .. "/" .. name .. ".json"
    end

    if not isfile(path) then return false end
    pcall(delfile, path)
    return true
end

function SaveManager:RefreshConfigList()
    self:BuildFolderTree()

    local folder = self.Folder .. "/settings"
    if self.SubFolder ~= "" then
        folder = self.Folder .. "/settings/" .. self.SubFolder
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

return SaveManager
