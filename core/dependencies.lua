-- hook.cc / core/dependencies.lua

return function(hook_cc)
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
  
    local DrawingWrapper = {}
    DrawingWrapper._objects = {}

    function DrawingWrapper:Create(class: string, properties: table)
        local success, object = pcall(Drawing.new, class)
        if not success then
            warn("[hook.cc] Invalid Drawing type: " .. tostring(class))
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

    local Input = {}

    function Input:GetMousePosition()
        return UserInputService:GetMouseLocation()
    end

    function Input:IsKeyDown(keycode: Enum.KeyCode)
        return UserInputService:IsKeyDown(keycode)
    end

    function Input:GetMouseDelta()
        return UserInputService:GetMouseDelta()
    end

    hook_cc.Input = Input

    local Runtime = {}
    Runtime._connections = {}

    function Runtime:TrackConnection(connection: RBXScriptConnection)
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
end
