-- hook.cc / ui/controls/toggle.lua

return function(hook_cc)
    local Drawing = hook_cc.Drawing
    local Input = hook_cc.Input
    local Runtime = hook_cc.Runtime

    local Toggle = {}

    function Toggle:Create(label, position, default, callback)
        local state = {
            Label = label,
            Value = default or false,
            Callback = callback or function() end,
            Position = position,
            Size = Vector2.new(12, 12),
            Hovered = false
        }

        state.Box = Drawing:Create("Square", {
            Position = state.Position,
            Size = state.Size,
            Color = state.Value and Color3.fromRGB(106, 106, 255) or Color3.fromRGB(30, 30, 30),
            Filled = true,
            ZIndex = 3,
            Visible = true
        })

        state.Text = Drawing:Create("Text", {
            Text = label,
            Size = 13,
            Position = state.Position + Vector2.new(18, -1),
            Color = Color3.fromRGB(255, 255, 255),
            Outline = true,
            ZIndex = 4,
            Visible = true
        })

        function state:Set(value)
            state.Value = value
            state.Box.Color = value and Color3.fromRGB(106, 106, 255) or Color3.fromRGB(30, 30, 30)
            pcall(state.Callback, value)
        end

        function state:Get()
            return state.Value
        end

        Runtime:TrackConnection(game:GetService("UserInputService").InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mouse = Input:GetMousePosition()
                local within = (
                    mouse.X >= state.Position.X and mouse.X <= (state.Position.X + state.Size.X) and
                    mouse.Y >= state.Position.Y and mouse.Y <= (state.Position.Y + state.Size.Y)
                )
                if within then
                    state:Set(not state.Value)
                end
            end
        end))

        function state:Destroy()
            state.Box:Remove()
            state.Text:Remove()
        end

        return state
    end

    hook_cc.Toggle = Toggle
end
