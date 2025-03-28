-- hook.cc / core/drawing.lua

return function(hook_cc)
    hook_cc.Runtime.TrackedDrawings = hook_cc.Runtime.TrackedDrawings or {}

    hook_cc.Drawing = {
        Create = function(type, props)
            local obj = Drawing.new(type)
            for k, v in pairs(props or {}) do
                obj[k] = v
            end
            table.insert(hook_cc.Runtime.TrackedDrawings, obj)
            return obj
        end
    }
end
