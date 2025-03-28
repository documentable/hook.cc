-- hook.cc / ui/controls/keybind.lua

return function(hook_cc)
    local Drawing = hook_cc.Drawing
    local Input = hook_cc.Input
    local Runtime = hook_cc.Runtime
    local ExtKeybind = hook_cc.ExtKeybind
    local KeyCodes = hook_cc.KeyCodes

    local Keybind = {}

    function Keybind:Create(label, position, defaultCombo, callback)
        local state = {
            Label = label,
            KeyCombo = defaultCombo or { Enum.KeyCode.X },
            Callback = callback or function() end,
            Position = position,
            Size = Vector2.new(140, 20),
            Listening = false,
            Mode = "Hold"
        }

        state.Box = Drawing:Create("Square", {
            Position = state.Position,
            Size = state.Size,
            Color = Color3.fromRGB(30, 30, 30),
            Filled = true,
            ZIndex = 3,
            Visible = true
        })

        state.Text = Drawing:Create("Text", {
            Text = label .. ": [" .. table.concat(state.KeyCombo, " + ") .. "]",
            Size = 13,
            Position = state.Position + Vector2.new(6, 2),
            Color = Color3.fromRGB(255, 255, 255),
            Outline = true,
            ZIndex = 4,
            Visible = true
        })

        function state:SetCombo(combo)
            state.KeyCombo = combo
            state.Text.Text = state.Label .. ": [" .. table.concat(combo, " + ") .. "]"
        end

        function state:SetMode(mode)
            state.Mode = mode
        end

        Runtime:TrackConnection(game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
            local mouse = Input:GetMousePosition()
            local inside = (
                mouse.X >= state.Position.X and mouse.X <= state.Position.X + state.Size.X and
                mouse.Y >= state.Position.Y and mouse.Y <= state.Position.Y + state.Size.Y
            )

            if input.UserInputType == Enum.UserInputType.MouseButton2 and inside then
                ExtKeybind:AttachTo(state, state.Position + Vector2.new(0, state.Size.Y + 4), state.Mode, function(mode)
                    state.Mode = mode
                end)
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 and inside then
                state.Listening = true
                state.Text.Text = state.Label .. ": [ ... ]"
            elseif input.UserInputType == Enum.UserInputType.Keyboard and state.Listening then
                state:SetCombo({ input.KeyCode.Name })
                state.Listening = false
                pcall(state.Callback, state.KeyCombo)
            end
        end))

        function state:Get()
            return state.KeyCombo
        end

        function state:Destroy()
            state.Box:Remove()
            state.Text:Remove()
        end

        return state
    end

    hook_cc.Keybind = Keybind
end
