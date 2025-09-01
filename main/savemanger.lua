local httpService = game:GetService('HttpService')

local SaveManager = {} do
    SaveManager.Folder = 'linorialibsettings'
    SaveManager.Ignore = {}
    SaveManager.Parser = {
        Toggle = {
            Save = function(idx, object)
                return { type = 'Toggle', idx = idx, value = object.Value }
            end,
            Load = function(idx, data)
                if Toggles[idx] then
                    Toggles[idx]:SetValue(data.value)
                end
            end,
        },
        Slider = {
            Save = function(idx, object)
                return { type = 'Slider', idx = idx, value = tostring(object.Value) }
            end,
            Load = function(idx, data)
                if Options[idx] then
                    Options[idx]:SetValue(data.value)
                end
            end,
        },
        Dropdown = {
            Save = function(idx, object)
                return { type = 'Dropdown', idx = idx, value = object.Value, multi = object.Multi }
            end,
            Load = function(idx, data)
                if Options[idx] then
                    Options[idx]:SetValue(data.value)
                end
            end,
        },
        ColorPicker = {
            Save = function(idx, object)
                return { type = 'ColorPicker', idx = idx, value = object.Value:ToHex(), transparency = object.Transparency }
            end,
            Load = function(idx, data)
                if Options[idx] then
                    Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
                end
            end,
        },
        KeyPicker = {
            Save = function(idx, object)
                return { type = 'KeyPicker', idx = idx, mode = object.Mode, key = object.Value }
            end,
            Load = function(idx, data)
                if Options[idx] then
                    Options[idx]:SetValue({data.key, data.mode})
                    if Options[idx].UpdateListener then
                        Options[idx]:UpdateListener()
                    elseif Options[idx].Rebind then
                        Options[idx]:Rebind()
                    end
                end
            end,
        },
        Input = {
            Save = function(idx, object)
                return { type = 'Input', idx = idx, text = object.Value }
            end,
            Load = function(idx, data)
                if Options[idx] and type(data.text) == 'string' then
                    Options[idx]:SetValue(data.text)
                end
            end,
        },
    }

    function SaveManager:SetIgnoreIndexes(list)
        for _, key in next, list do
            self.Ignore[key] = true
        end
    end

    function SaveManager:SetFolder(folder)
        self.Folder = folder
        self:BuildFolderTree()
    end

    function SaveManager:Save(name)
        if not name then
            return false, 'no config file is selected'
        end
        local fullPath = self.Folder .. '/settings/' .. name .. '.json'
        local data = { objects = {} }

        for idx, toggle in next, Toggles do
            if self.Ignore[idx] then continue end
            table.insert(data.objects, self.Parser[toggle.Type].Save(idx, toggle))
        end

        for idx, option in next, Options do
            if not self.Parser[option.Type] then continue end
            if self.Ignore[idx] then continue end
            table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
        end

        local success, encoded = pcall(httpService.JSONEncode, httpService, data)
        if not success then return false, 'failed to encode data' end
        writefile(fullPath, encoded)
        return true
    end

    function SaveManager:Load(name)
        if not name then
            return false, 'no config file is selected'
        end
        local file = self.Folder .. '/settings/' .. name .. '.json'
        if not isfile(file) then return false, 'invalid file' end

        local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
        if not success then return false, 'decode error' end

        for _, option in next, decoded.objects do
            if self.Parser[option.type] then
                self.Parser[option.type].Load(option.idx, option)
            end
        end
        return true
    end

    function SaveManager:IgnoreThemeSettings()
        self:SetIgnoreIndexes({
            "backgroundcolor", "maincolor", "accentcolor", "outlinecolor", "fontcolor",
            "thememanager_themelist", "thememanager_customthemelist", "thememanager_customthemename"
        })
    end

    function SaveManager:BuildFolderTree()
        local paths = { self.Folder, self.Folder .. '/themes', self.Folder .. '/settings' }
        for i = 1, #paths do
            if not isfolder(paths[i]) then
                makefolder(paths[i])
            end
        end
    end

    function SaveManager:RefreshConfigList()
        local list = listfiles(self.Folder .. '/settings')
        local out = {}
        for i = 1, #list do
            local file = list[i]
            if file:sub(-5) == '.json' then
                local pos = file:find('.json', 1, true)
                local startPos = pos
                local char = file:sub(pos, pos)
                while char ~= '/' and char ~= '\\' and char ~= '' do
                    pos = pos - 1
                    char = file:sub(pos, pos)
                end
                if char == '/' or char == '\\' then
                    table.insert(out, file:sub(pos + 1, startPos - 1))
                end
            end
        end
        return out
    end

    function SaveManager:SetLibrary(library)
        self.Library = library
    end

    function SaveManager:LoadAutoloadConfig()
        if isfile(self.Folder .. '/settings/autoload.txt') then
            local name = readfile(self.Folder .. '/settings/autoload.txt')
            local success, err = self:Load(name)
            if not success then
                return self.Library:Notify('failed to load autoload config: ' .. err)
            end
            self.Library:Notify(string.format('auto loaded config %q', name))
        end
    end

    function SaveManager:BuildConfigSection(tab)
        assert(self.Library, 'must set SaveManager.Library')
        local section = tab:AddRightGroupbox('configuration')

        section:AddDropdown('savemanager_configlist', { Text = 'config list', Values = self:RefreshConfigList(), AllowNull = true })
        section:AddInput('savemanager_configname', { Text = 'config name' })
        section:AddDivider()

        section:AddButton('create config', function()
            local name = Options.savemanager_configname.Value
            if name:gsub(' ', '') == '' then
                return self.Library:Notify('invalid config name (empty)', 2)
            end
            local success, err = self:Save(name)
            if not success then
                return self.Library:Notify('failed to save config: ' .. err)
            end
            self.Library:Notify(string.format('created config %q', name))
            Options.savemanager_configlist.Values = self:RefreshConfigList()
            Options.savemanager_configlist:SetValues()
            Options.savemanager_configlist:SetValue(nil)
        end):AddButton('load config', function()
            local name = Options.savemanager_configlist.Value
            local success, err = self:Load(name)
            if not success then
                return self.Library:Notify('failed to load config: ' .. err)
            end
            self.Library:Notify(string.format('loaded config %q', name))
        end)

        section:AddButton('overwrite config', function()
            local name = Options.savemanager_configlist.Value
            local success, err = self:Save(name)
            if not success then
                return self.Library:Notify('failed to overwrite config: ' .. err)
            end
            self.Library:Notify(string.format('overwrote config %q', name))
        end)

        section:AddButton('autoload config', function()
            local name = Options.savemanager_configlist.Value
            writefile(self.Folder .. '/settings/autoload.txt', name)
            SaveManager.AutoloadLabel:SetText('current autoload config: ' .. name)
            self.Library:Notify(string.format('set %q to auto load', name))
        end)

        section:AddButton('refresh config list', function()
            Options.savemanager_configlist.Values = self:RefreshConfigList()
            Options.savemanager_configlist:SetValues()
            Options.savemanager_configlist:SetValue(nil)
        end)

        SaveManager.AutoloadLabel = section:AddLabel('current autoload config: none', true)
        if isfile(self.Folder .. '/settings/autoload.txt') then
            local name = readfile(self.Folder .. '/settings/autoload.txt')
            SaveManager.AutoloadLabel:SetText('current autoload config: ' .. name)
        end

        SaveManager:SetIgnoreIndexes({ 'savemanager_configlist', 'savemanager_configname' })
    end

    SaveManager:BuildFolderTree()
end

return SaveManager
