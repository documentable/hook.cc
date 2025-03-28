-- hook.cc / core/config.lua

return function(hook_cc)
    local HttpService = game:GetService("HttpService")

    ------------------------------------------------------------------------
    -- UTILITY: DYNAMIC FOLDERED PATHS
    ------------------------------------------------------------------------

function hook_cc:SetConfigFolder(folderName)
    if typeof(folderName) ~= "string" or #folderName == 0 then
        self:Log("Invalid config folder name", Color3.fromRGB(255, 100, 100))
        return
    end

    self._configFolder = folderName

    pcall(function()
        if not isfolder(folderName) then makefolder(folderName) end
        if not isfolder(folderName .. "/configs") then makefolder(folderName .. "/configs") end
        if not isfolder(folderName .. "/themes") then makefolder(folderName .. "/themes") end
    end)

    self:Log("Config folder set to '" .. folderName .. "'", Color3.fromRGB(106, 255, 106))
    end

    local function buildPaths(folder)
        return {
            configFolder = folder,
            configPath = folder .. "/configs/",
            themePath = folder .. "/themes/"
        }
    end

    local function ensureFolders(paths)
        if not isfolder(paths.configFolder) then makefolder(paths.configFolder) end
        if not isfolder(paths.configPath) then makefolder(paths.configPath) end
        if not isfolder(paths.themePath) then makefolder(paths.themePath) end
    end

    local function listFiles(folder)
        local found = {}
        if isfolder(folder) then
            for _, file in ipairs(listfiles(folder)) do
                local name = file:match(".+/(.+)%.json$")
                if name then table.insert(found, name) end
            end
        end
        return found
    end

    ------------------------------------------------------------------------
    -- EXPORT / IMPORT SETTINGS
    ------------------------------------------------------------------------

    function hook_cc:ExportSettings()
        local config = {}

        if not self.__controls then return config end
        for id, control in pairs(self.__controls) do
            local value = control.GetValue and control:GetValue()
            if value ~= nil then
                config[id] = value
            end
        end

        return config
    end

    function hook_cc:ImportSettings(data)
        if not self.__controls then return end
        for id, value in pairs(data) do
            local control = self.__controls[id]
            if control and control.SetValue then
                pcall(function()
                    control:SetValue(value)
                end)
            end
        end
    end

    function hook_cc:ExportTheme()
        local theme = {}

        if not self.Theme or type(self.Theme) ~= "table" then return theme end
        for k, v in pairs(self.Theme) do
            if typeof(v) == "Color3" then
                theme[k] = {
                    r = math.floor(v.R * 255),
                    g = math.floor(v.G * 255),
                    b = math.floor(v.B * 255)
                }
            else
                theme[k] = v
            end
        end

        return theme
    end

    function hook_cc:ImportTheme(data)
        if not self.Theme or type(data) ~= "table" then return end
        for k, v in pairs(data) do
            if type(v) == "table" and v.r and v.g and v.b then
                self.Theme[k] = Color3.fromRGB(v.r, v.g, v.b)
            else
                self.Theme[k] = v
            end
        end

        self:Log("Theme applied.", Color3.fromRGB(106, 106, 255))
    end

    ------------------------------------------------------------------------
    -- CREATE CONFIG TAB (MODULAR)
    ------------------------------------------------------------------------

    function hook_cc:CreateConfigTab(string, window)
        if typeof(folderName) ~= "string" or #folderName == 0 then
            self:Log("Invalid config folder name", Color3.fromRGB(255, 100, 100))
            return
        end
        if not window or typeof(window.CreateTab) ~= "function" then return end

        local paths = buildPaths(folderName)
        ensureFolders(paths)

        local tab = window:CreateTab("Config")

        tab:AddButton("Refresh Config List", function()
            local all = listFiles(paths.configPath)
            self:Log("Configs: " .. table.concat(all, ", "))
        end)

        tab:AddTextbox("Config Name", "", function(text)
            hook_cc.CurrentConfigName = text
        end)

        tab:AddButton("Save Config", function()
            if not hook_cc.CurrentConfigName then return end
            local data = hook_cc:ExportSettings()
            local json = HttpService:JSONEncode(data)
            writefile(paths.configPath .. hook_cc.CurrentConfigName .. ".json", json)
            self:Log("Saved config: " .. hook_cc.CurrentConfigName)
        end)

        tab:AddButton("Load Config", function()
            if not hook_cc.CurrentConfigName then return end
            local path = paths.configPath .. hook_cc.CurrentConfigName .. ".json"
            if not isfile(path) then return end
            local content = readfile(path)
            local data = HttpService:JSONDecode(content)
            hook_cc:ImportSettings(data)
            self:Log("Loaded config: " .. hook_cc.CurrentConfigName)
        end)

        tab:AddTextbox("Theme Name", "", function(text)
            hook_cc.CurrentThemeName = text
        end)

        tab:AddButton("Save Theme", function()
            if not hook_cc.CurrentThemeName then return end
            local theme = hook_cc:ExportTheme()
            local encoded = HttpService:JSONEncode(theme)
            writefile(paths.themePath .. hook_cc.CurrentThemeName .. ".json", encoded)
            self:Log("Saved theme: " .. hook_cc.CurrentThemeName)
        end)

        tab:AddButton("Load Theme", function()
            if not hook_cc.CurrentThemeName then return end
            local path = paths.themePath .. hook_cc.CurrentThemeName .. ".json"
            if not isfile(path) then return end
            local content = readfile(path)
            local data = HttpService:JSONDecode(content)
            hook_cc:ImportTheme(data)
            self:Log("Loaded theme: " .. hook_cc.CurrentThemeName)
        end)

        self:Log("Config tab initialized.", Color3.fromRGB(106, 255, 106))
    end
end
