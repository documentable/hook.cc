-- hook.cc / ui/dropdown.lua

return function(hook_cc)
    local Drawing = hook_cc.Drawing
    local Input = hook_cc.Input
    local Runtime = hook_cc.Runtime

    local Dropdown = {}

    function Dropdown:Create(label, position, width, options, default, callback)
        local state = {
            Label = label,
            Options = options or {},
            Selected = default or options[1],
            Callback = callback or function() end,
            Position = position,
            Width = width or 160,
            Height = 20,
            Open = false,
            Buttons = {}
        }

        state.Box = Drawing:Create("Square", {
            Size = Vector2.new(state.Width, state.Height),
            Position = state.Position,
            Color = Color3.fromRGB(40, 40, 40),
            Filled = true,
            ZIndex = 3,
            Visible = true
        })

        state.Text = Drawing:Create("Text", {
            Text = label .. ": " .. tostring(state.Selected),
            Position = state.Position + Vector2.new(6, 2),
            Size = 13,
            Color = Color3.fromRGB(255, 255, 255),
            Outline = true,
            ZIndex = 4,
            Visible = true
        })

        function state:Set(value)
            state.Selected = value
            state.Text.Text = label .. ": " .. tostring(state.Selected)
            pcall(state.Callback, value)
        end

        function state:Get()
            return state.Selected
        end

        function state:Destroy()
            state.Box:Remove()
            state.Text:Remove()
            for _, b in ipairs(state.Buttons) do
                b.Text:Remove()
                b.Hitbox:Remove()
            end
        end

        function state:Toggle()
            state.Open = not state.Open

            for _, b in ipairs(state.Buttons) do
                b.Text:Remove()
                b.Hitbox:Remove()
            end
            state.Buttons = {}

            if state.Open then
                for i, option in ipairs(state.Options) do
                    local posY = state.Position.Y + state.Height + (i - 1) * state.Height
                    local btn = {
                        Text = Drawing:Create("Text", {
                            Text = tostring(option),
                            Position = Vector2.new(state.Position.X + 6, posY + 2),
                            Size = 13,
                            Color = Color3.fromRGB(255, 255, 255),
                            Outline = true,
                            ZIndex = 5,
                            Visible = true
                        }),
                        Hitbox = Drawing:Create("Square", {
                            Position = Vector2.new(state.Position.X, posY),
                            Size = Vector2.new(state.Width, state.Height),
                            Color = Color3.fromRGB(30, 30, 30),
                            Filled = true,
                            ZIndex = 4,
                            Visible = true
                        })
                    }

                    table.insert(state.Buttons, btn)

                    Runtime:TrackConnection(game:GetService("UserInputService").InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            local mouse = Input:GetMousePosition()
                            if mouse.X >= btn.Hitbox.Position.X and mouse.X <= btn.Hitbox.Position.X + btn.Hitbox.Size.X and
                               mouse.Y >= btn.Hitbox.Position.Y and mouse.Y <= btn.Hitbox.Position.Y + btn.Hitbox.Size.Y then
                                state:Set(option)
                                state:Toggle()
                            end
                        end
                    end))
                end
            end
        end
    
        Runtime:TrackConnection(game:GetService("UserInputService").InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mouse = Input:GetMousePosition()
                if mouse.X >= state.Position.X and mouse.X <= state.Position.X + state.Width and
                   mouse.Y >= state.Position.Y and mouse.Y <= state.Position.Y + state.Height then
                    state:Toggle()
                end
            end
        end))

        return state
    end

    hook_cc.Dropdown = Dropdown
end
