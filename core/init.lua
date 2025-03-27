-- hook.cc / core/init.lua

return function(hook_cc)
    local HttpService = game:GetService("HttpService")

    ------------------------------------------------------------------------
    -- CONFIGURATION STORAGE
    ------------------------------------------------------------------------

    -- Internal flag to block file I/O
    local readWriteEnabled = true
    -- Folder where configs/themes are stored
    local configFolderName = nil

    -- Set the folder where config and theme files will be saved
    function hook_cc:SetConfigFolder(folderName: string)
        if typeof(folderName) ~= "string" or #folderName == 0 then
            warn("[hook.cc] Invalid config folder name provided.")
            return
        end

        configFolderName = folderName
        -- Attempt to create folder structure
        pcall(function()
            makefolder(folderName)
            makefolder(folderName .. "/configs")
            makefolder(folderName .. "/themes")
        end)
    end

    -- Allow developers to block saving/loading
    function hook_cc:DisableReadWrite()
        readWriteEnabled = false
    end

    ------------------------------------------------------------------------
    -- THEME SAVE / LOAD
    ------------------------------------------------------------------------

    function hook_cc:SaveTheme(themeName: string, themeTable: table)
        if not readWriteEnabled or not configFolderName then return end

        local themePath = string.format("%s/themes/%s.json", configFolderName, themeName)
        local encoded = HttpService:JSONEncode(themeTable)

        writefile(themePath, encoded)
    end

    function hook_cc:LoadTheme(themeName: string): table
        if not readWriteEnabled or not configFolderName then return {} end

        local themePath = string.format("%s/themes/%s.json", configFolderName, themeName)
        if isfile(themePath) then
            local content = readfile(themePath)
            return HttpService:JSONDecode(content)
        end

        return {}
    end

    ------------------------------------------------------------------------
    -- SECURE FUNCTION WRAPPER
    ------------------------------------------------------------------------

    -- Securely wraps any function to cloak it from detection/debuggers
    function hook_cc.sfunction(callback: function, isolateEnv: boolean)
        if typeof(callback) ~= "function" then
            return function() end
        end

        local environment = isolateEnv and setmetatable({}, { __index = _G }) or _G
        local wrapper = function(...)
            if isolateEnv then
                local _ENV = environment
            end
            return callback(...)
        end

        return newcclosure and newcclosure(wrapper) or wrapper
    end

    ------------------------------------------------------------------------
    -- FULL CLEANUP / UNLOAD
    ------------------------------------------------------------------------

    function hook_cc:Unload()
        -- Disconnect runtime connections
        if self.Runtime and type(self.Runtime.UnbindAll) == "function" then
            pcall(self.Runtime.UnbindAll)
        end

        -- Remove all Drawing objects
        if self.Drawing and type(self.Drawing.DestroyAll) == "function" then
            pcall(self.Drawing.DestroyAll)
        end

        -- Clear UI elements, references, and internal tables
        for key, _ in pairs(self) do
            self[key] = nil
        end

        -- Also remove the global hook_cc if it was globally exposed
        if rawget(_G, "hook_cc") then
            _G.hook_cc = nil
        end

        collectgarbage("collect")
    end
end
