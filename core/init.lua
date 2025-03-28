-- hook.cc / core/init.lua

return function(hook_cc)
    ------------------------------------------------------------------------
    -- SECURE FUNCTION WRAPPER
    ------------------------------------------------------------------------

function hook_cc.sfunction(callback, isolateEnv)
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
    -- SECURE LOGGING (ROUTES TO NOTIFY SYSTEM)
    ------------------------------------------------------------------------

    function hook_cc:Log(string, Color3?)
        if typeof(message) ~= "string" then return end
        color = color or Color3.fromRGB(200, 200, 200)

        if self.Notify and typeof(self.Notify) == "function" then
            self:Notify(message, 3, color)
        end
    end

    ------------------------------------------------------------------------
    -- FULL CLEANUP / UNLOAD
    ------------------------------------------------------------------------

    function hook_cc:Unload()
        if self.Runtime and typeof(self.Runtime.UnbindAll) == "function" then
            pcall(self.Runtime.UnbindAll)
        end

        if self.Drawing and typeof(self.Drawing.DestroyAll) == "function" then
            pcall(self.Drawing.DestroyAll)
        end

        for key, _ in pairs(self) do
            self[key] = nil
        end

        if rawget(_G, "hook_cc") then
            _G.hook_cc = nil
        end

        collectgarbage("collect")
    end
end
