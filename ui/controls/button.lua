-- hook.cc / ui/controls/button.lua

return function(hook_cc)
    local Drawing = hook_cc.Drawing
    local Input = hook_cc.Input
    local Runtime = hook_cc.Runtime
    local Utils = hook_cc.Utils

    local Button = {}

    function Button:Create(label, position, size, callback)
        local state = {
            Label = label,
            Callback = callback or function() end,
            Position = position,
            Size = size or Vector2.new(150, 20),
            Hovered = false
        }

        state.Background = Drawing:Create("Square", {
            Size = state.Size,
            Position = state.Position,
            Color = Color3.fromRGB(30, 30, 30),
            Filled = true,
            ZIndex = 3,
            Visible = true
        })

        state.Text = Drawing:Create("Text", {
            Text = label,
            Size = 13,
            Color = Color3.fromRGB(255, 255, 255),
            Position = state.Position + Vector2.new(5, 2),
            Outline = true,
            ZIndex = 4,
            Visible = true
        })

        Runtime:BindStep(function()
            local mouse = Input:GetMousePosition()
            local withinX = mouse.X >= state.Position.X and mouse.X <= (state.Position.X + state.Size.X)
            local withinY = mouse.Y >= state.Position.Y and mouse.Y <= (state.Position.Y + state.Size.Y)
            local hovering = withinX and withinY

            if hovering and not state.Hovered then
                state.Background.Color = Color3.fromRGB(60, 60, 60)
                state.Hovered = true
            elseif not hovering and state.Hovered then
                state.Background.Color = Color3.fromRGB(30, 30, 30)
                state.Hovered = false
            end
        end)

        Runtime:TrackConnection(game:GetService("UserInputService").InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and state.Hovered then
                pcall(state.Callback)
            end
        end))

        function state:Destroy()
            state.Background:Remove()
            state.Text:Remove()
        end

        return state
    end

    hook_cc.Button = Button
end
