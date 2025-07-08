-- Improved SaveManager to fix unexpected config behavior
local HttpService = game:GetService("HttpService")

local SaveManager = {
	Folder = "LinoriaLibSettings",
	Ignore = {},
	Parser = {},
	Library = nil
}

SaveManager.Parser = {
	Toggle = {
		Save = function(idx, obj) return {type = "Toggle", idx = idx, value = obj.Value} end,
		Load = function(idx, data) if Toggles[idx] then Toggles[idx]:SetValue(data.value) end end
	},
	Slider = {
		Save = function(idx, obj) return {type = "Slider", idx = idx, value = obj.Value} end,
		Load = function(idx, data) if Options[idx] then Options[idx]:SetValue(data.value) end end
	},
	Dropdown = {
		Save = function(idx, obj) return {type = "Dropdown", idx = idx, value = obj.Value, multi = obj.Multi} end,
		Load = function(idx, data) if Options[idx] then Options[idx]:SetValue(data.value) end end
	},
	ColorPicker = {
		Save = function(idx, obj) return {type = "ColorPicker", idx = idx, value = obj.Value:ToHex(), transparency = obj.Transparency} end,
		Load = function(idx, data) if Options[idx] then Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency) end end
	},
	KeyPicker = {
		Save = function(idx, obj) return {type = "KeyPicker", idx = idx, key = obj.Value, mode = obj.Mode} end,
		Load = function(idx, data) if Options[idx] then Options[idx]:SetValue({data.key, data.mode}) end end
	},
	Input = {
		Save = function(idx, obj) return {type = "Input", idx = idx, text = obj.Value} end,
		Load = function(idx, data) if Options[idx] and typeof(data.text) == "string" then Options[idx]:SetValue(data.text) end end
	},
}

function SaveManager:SetIgnoreIndexes(list)
	for _, key in ipairs(list) do self.Ignore[key] = true end
end

function SaveManager:SetFolder(folder)
	self.Folder = folder
	self:BuildFolderTree()
end

function SaveManager:BuildFolderTree()
	for _, path in ipairs({self.Folder, self.Folder .. "/themes", self.Folder .. "/settings"}) do
		if not isfolder(path) then pcall(makefolder, path) end
	end
end

function SaveManager:Save(name)
	if not name or name == "" then return false, "No config file name provided" end
	local path = self.Folder .. "/settings/" .. name .. ".json"
	local data = {objects = {}}

	for idx, toggle in pairs(Toggles) do
		if not self.Ignore[idx] and self.Parser[toggle.Type] then
			table.insert(data.objects, self.Parser[toggle.Type].Save(idx, toggle))
		end
	end

	for idx, opt in pairs(Options) do
		if not self.Ignore[idx] and self.Parser[opt.Type] then
			table.insert(data.objects, self.Parser[opt.Type].Save(idx, opt))
		end
	end

	local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
	if not success then return false, "Failed to encode config" end

	pcall(writefile, path, encoded)
	return true
end

function SaveManager:Load(name)
	if not name or name == "" then return false, "No config name provided" end
	local path = self.Folder .. "/settings/" .. name .. ".json"
	if not isfile(path) then return false, "Config file not found" end

	local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(path))
	if not success then return false, "Failed to decode config" end

	for _, obj in ipairs(decoded.objects or {}) do
		if self.Parser[obj.type] then
			pcall(self.Parser[obj.type].Load, obj.idx, obj)
		end
	end
	return true
end

function SaveManager:RefreshConfigList()
	local files = listfiles(self.Folder .. "/settings")
	local result = {}
	for _, file in ipairs(files) do
		if file:sub(-5) == ".json" then
			table.insert(result, file:match("([^/\\]+)%.json$"))
		end
	end
	return result
end

function SaveManager:LoadAutoloadConfig()
	local path = self.Folder .. "/settings/autoload.txt"
	if isfile(path) then
		local name = readfile(path)
		local ok, err = self:Load(name)
		if not ok then return self.Library:Notify("Autoload failed: " .. err) end
		self.Library:Notify("Autoloaded config: " .. name)
	end
end

function SaveManager:SetLibrary(lib)
	self.Library = lib
end

function SaveManager:BuildConfigSection(tab)
	assert(self.Library, "SaveManager.Library is required")
	local section = tab:AddRightGroupbox("Configuration")

	section:AddDropdown("SaveManager_ConfigList", {Text = "Config List", Values = self:RefreshConfigList(), AllowNull = true})
	section:AddInput("SaveManager_ConfigName", {Text = "Config Name"})
	section:AddDivider()

	section:AddButton("Create Config", function()
		local name = Options.SaveManager_ConfigName.Value
		if name:gsub(" ","") == "" then return self.Library:Notify("Empty config name", 2) end
		local ok, err = self:Save(name)
		if not ok then return self.Library:Notify("Save failed: " .. err) end
		self.Library:Notify("Saved config: " .. name)
		Options.SaveManager_ConfigList.Values = self:RefreshConfigList()
		Options.SaveManager_ConfigList:SetValues()
		Options.SaveManager_ConfigList:SetValue(nil)
	end)

	section:AddButton("Load Config", function()
		local name = Options.SaveManager_ConfigList.Value
		local ok, err = self:Load(name)
		if not ok then return self.Library:Notify("Load failed: " .. err) end
		self.Library:Notify("Loaded config: " .. name)
	end)

	section:AddButton("Overwrite Config", function()
		local name = Options.SaveManager_ConfigList.Value
		local ok, err = self:Save(name)
		if not ok then return self.Library:Notify("Overwrite failed: " .. err) end
		self.Library:Notify("Overwrote config: " .. name)
	end)

	section:AddButton("Set Autoload", function()
		local name = Options.SaveManager_ConfigList.Value
		writefile(self.Folder .. "/settings/autoload.txt", name)
		self.AutoloadLabel:SetText("Current autoload config: " .. name)
		self.Library:Notify("Autoload set to: " .. name)
	end)

	section:AddButton("Refresh List", function()
		Options.SaveManager_ConfigList.Values = self:RefreshConfigList()
		Options.SaveManager_ConfigList:SetValues()
		Options.SaveManager_ConfigList:SetValue(nil)
	end)

	self.AutoloadLabel = section:AddLabel("Current autoload config: none", true)
	if isfile(self.Folder .. "/settings/autoload.txt") then
		self.AutoloadLabel:SetText("Current autoload config: " .. readfile(self.Folder .. "/settings/autoload.txt"))
	end

	self:SetIgnoreIndexes({"SaveManager_ConfigList", "SaveManager_ConfigName"})
end

SaveManager:BuildFolderTree()
return SaveManager
