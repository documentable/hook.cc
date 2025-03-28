-- hook.cc / core/dependencies.lua

return function(hook_cc)
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")

    ------------------------------------------------------------------------
    -- DRAWING WRAPPER
    ------------------------------------------------------------------------

    local DrawingWrapper = {}
    DrawingWrapper._objects = {}

    function DrawingWrapper:Create(string, table)
        local success, object = pcall(Drawing.new, class)
        if not success then
            hook_cc:Log("Invalid Drawing type: " .. tostring(class), Color3.fromRGB(255, 100, 100))
            return nil
        end

        if typeof(properties) == "table" then
            for key, value in pairs(properties) do
                pcall(function() object[key] = value end)
            end
        end

        table.insert(self._objects, object)
        return object
    end

    function DrawingWrapper:DestroyAll()
        for _, object in ipairs(self._objects) do
            pcall(function() object:Remove() end)
        end
        table.clear(self._objects)
    end

    hook_cc.Drawing = DrawingWrapper

    ------------------------------------------------------------------------
    -- INPUT TRACKER
    ------------------------------------------------------------------------

    local Input = {}

    function Input:GetMousePosition()
        return UserInputService:GetMouseLocation()
    end

    function Input:IsKeyDown(keycode)
        return UserInputService:IsKeyDown(keycode)
    end

    function Input:GetMouseDelta()
        return UserInputService:GetMouseDelta()
    end

    function Input:IsComboPressed(key)
        for _, key in ipairs(keys) do
            if not UserInputService:IsKeyDown(key) then
                return false
            end
        end
        return true
    end

    hook_cc.Input = Input

    ------------------------------------------------------------------------
    -- RUNTIME TRACKING
    ------------------------------------------------------------------------

    local Runtime = {}
    Runtime._connections = {}

    function Runtime:TrackConnection(RBXScriptConnection)
        if typeof(connection) == "Instance" or typeof(connection) == "RBXScriptConnection" then
            table.insert(self._connections, connection)
        end
    end

    function Runtime:BindStep(callback)
        local conn = RunService.RenderStepped:Connect(callback)
        self:TrackConnection(conn)
        return conn
    end

    function Runtime:UnbindAll()
        for _, conn in ipairs(self._connections) do
            pcall(function() conn:Disconnect() end)
        end
        table.clear(self._connections)
    end

    hook_cc.Runtime = Runtime

    ------------------------------------------------------------------------
    -- UTILITY FUNCTIONS
    ------------------------------------------------------------------------

    local Utils = {}

    function Utils.Clamp(val, min, max)
        return math.max(min, math.min(val, max))
    end

    function Utils.Lerp(a, b, t)
        return a + (b - a) * t
    end

    function Utils.ColorToRGB(c: Color3)
        return math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255)
    end
    
    function Utils.RGB(speed)
        speed = speed or 1
        local t = tick() * speed
        local r = math.sin(t) * 127 + 128
        local g = math.sin(t + 2) * 127 + 128
        local b = math.sin(t + 4) * 127 + 128
        return Color3.fromRGB(r, g, b)
    end

    hook_cc.Utils = Utils
end
