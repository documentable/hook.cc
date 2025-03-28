-- hook.cc / ui/controls/slider.lua

return function(hook_cc)
    local Drawing = hook_cc.Drawing
    local Input = hook_cc.Input
    local Runtime = hook_cc.Runtime
    local Utils = hook_cc.Utils

    local Slider = {}

    function Slider:Create(label, position, min, max, default, step, callback)
        local state = {
            Label = label,
            Min = min,
            Max = max,
            Value = default or min,
            Step = step or 1,
            Callback = callback or function() end,
            Position = position,
            Size = Vector2.new(150, 6),
            Dragging = false
        }

        local function clampValue(val)
            return math.clamp(Utils.Clamp(math.floor(val / state.Step + 0.5) * state.Step, state.Min, state.Max), state.Min, state.Max)
        end

        -- Track
        state.Track = Drawing:Create("Square", {
            Position = state.Position,
            Size = state.Size,
            Color = Color3.fromRGB(40, 40, 40),
            Filled = true,
            ZIndex = 3,
            Visible = true
        })

        -- Fill
        state.Fill = Drawing:Create("Square", {
            Position = state.Position,
            Size = Vector2.new(0, state.Size.Y),
            Color = Color3.fromRGB(106, 106, 255),
            Filled = true,
            ZIndex = 4,
            Visible = true
        })

        -- Label
        state.Text = Drawing:Create("Text", {
            Text = ("%s: %d"):format(label, default),
            Position = state.Position - Vector2.new(0, 16),
            Size = 13,
            Color = Color3.fromRGB(255, 255, 255),
            Outline = true,
            ZIndex = 5,
            Visible = true
        })

        local function updateVisual()
            local percent = (state.Value - state.Min) / (state.Max - state.Min)
            state.Fill.Size = Vector2.new(state.Size.X * percent, state.Size.Y)
            state.Text.Text = ("%s: %d"):format(state.Label, state.Value)
            pcall(state.Callback, state.Value)
        end

        updateVisual()

        -- Mouse dragging logic
        Runtime:TrackConnection(game:GetService("UserInputService").InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mouse = Input:GetMousePosition()
                if mouse.X >= state.Position.X and mouse.X <= state.Position.X + state.Size.X and
                   mouse.Y >= state.Position.Y and mouse.Y <= state.Position.Y + state.Size.Y then
                    state.Dragging = true
                end
            end
        end))

        Runtime:TrackConnection(game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                state.Dragging = false
            end
        end))

        Runtime:BindStep(function()
            if state.Dragging then
                local mouse = Input:GetMousePosition()
                local percent = Utils.Clamp((mouse.X - state.Position.X) / state.Size.X, 0, 1)
                state.Value = clampValue(state.Min + (state.Max - state.Min) * percent)
                updateVisual()
            end
        end)

        function state:Set(value)
            state.Value = clampValue(value)
            updateVisual()
        end

        function state:Get()
            return state.Value
        end

        function state:Destroy()
            state.Track:Remove()
            state.Fill:Remove()
            state.Text:Remove()
        end

        return state
    end

    hook_cc.Slider = Slider
end
