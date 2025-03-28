-- hook.cc / ui/controls/colorpicker.lua

return function(hook_cc)
    local Drawing = hook_cc.Drawing
    local Input = hook_cc.Input
    local Runtime = hook_cc.Runtime

    local ColorPicker = {}

    function ColorPicker:Create(label, position, default, callback)
        local state = {
            Label = label,
            Value = default or Color3.fromRGB(255, 255, 255),
            Callback = callback or function() end,
            Position = position,
            Size = Vector2.new(18, 18),
            Open = false
        }

        -- Color preview box
        state.Box = Drawing:Create("Square", {
            Position = position,
            Size = state.Size,
            Color = state.Value,
            Filled = true,
            ZIndex = 4,
            Visible = true
        })

        -- Label
        state.Text = Drawing:Create("Text", {
            Text = label,
            Size = 13,
            Position = position + Vector2.new(state.Size.X + 6, 2),
            Color = Color3.fromRGB(255, 255, 255),
            Outline = true,
            ZIndex = 5,
            Visible = true
        })

        -- Color cycle toggle logic (simple mockup, can be replaced with hsv logic)
        Runtime:TrackConnection(game:GetService("UserInputService").InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mouse = Input:GetMousePosition()
                if mouse.X >= position.X and mouse.X <= (position.X + state.Size.X)
                and mouse.Y >= position.Y and mouse.Y <= (position.Y + state.Size.Y) then
                    -- Toggle through a few preset colors (placeholder)
                    local presets = {
                        Color3.fromRGB(106, 106, 255),
                        Color3.fromRGB(255, 100, 100),
                        Color3.fromRGB(100, 255, 100),
                        Color3.fromRGB(255, 255, 255)
                    }

                    local index = table.find(presets, state.Value) or 0
                    index = (index % #presets) + 1
                    state.Value = presets[index]
                    state.Box.Color = state.Value
                    pcall(state.Callback, state.Value)
                end
            end
        end))

        function state:Get()
            return state.Value
        end

        function state:Set(color)
            state.Value = color
            state.Box.Color = color
            pcall(state.Callback, color)
        end

        function state:Destroy()
            state.Box:Remove()
            state.Text:Remove()
        end

        return state
    end

    hook_cc.ColorPicker = ColorPicker
end
