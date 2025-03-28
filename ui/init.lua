-- hook.cc / ui/init.lua

return function(hook_cc)
    local Drawing = hook_cc.Drawing
    local Input = hook_cc.Input
    local Utils = hook_cc.Utils
    local Runtime = hook_cc.Runtime
    local KeyCodes = hook_cc.KeyCodes

    local Button = hook_cc.Button
    local Toggle = hook_cc.Toggle
    local Slider = hook_cc.Slider
    local Keybind = hook_cc.Keybind
    local Label = hook_cc.Label
    local ColorPicker = hook_cc.ColorPicker
    local Dropdown = hook_cc.Dropdown
    local Scroll = hook_cc.Scroll

    hook_cc.__controls = hook_cc.__controls or {}

    hook_cc.Theme = hook_cc.Theme or {
        Background = Color3.fromRGB(15, 15, 15),
        Border = Color3.fromRGB(40, 0, 70),
        Accent = Color3.fromRGB(160, 80, 255),
        Text = Color3.fromRGB(240, 240, 255)
    }

    function hook_cc:CreateWindow(opts)
        opts = opts or {}
        local window = {}

        window.Title = opts.Title or "hook.cc"
        window.Size = opts.Size or Vector2.new(500, 400)
        window.Position = opts.Position or Vector2.new(100, 100)
        window.Theme = opts.Theme or hook_cc.Theme

        window.Visible = true
        window.Tabs = {}
        window.ActiveTab = nil

        window.Frame = Drawing:Create("Square", {
            Size = window.Size,
            Position = window.Position,
            Color = window.Theme.Background,
            Filled = true,
            Transparency = 0,
            Visible = true,
            ZIndex = 1
        })

        window.TitleLabel = Drawing:Create("Text", {
            Text = window.Title,
            Position = window.Position + Vector2.new(10, -20),
            Size = 14,
            Color = window.Theme.Text,
            Outline = true,
            Transparency = 0,
            Visible = true,
            ZIndex = 2
        })

        local animAlpha = 0
        Runtime:BindStep(function(delta)
            if window.Visible then
                animAlpha = math.min(1, animAlpha + delta * 5)
            else
                animAlpha = math.max(0, animAlpha - delta * 5)
            end
            window.Frame.Transparency = 0.05 + 0.85 * animAlpha
            window.TitleLabel.Transparency = animAlpha
        end)

        local dragging = false
        local dragOffset = Vector2.new()

        Runtime:TrackConnection(Input.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mouse = Input:GetMousePosition()
                local bounds = window.Position + Vector2.new(0, -24)
                if mouse.X >= bounds.X and mouse.X <= bounds.X + window.Size.X and
                   mouse.Y >= bounds.Y and mouse.Y <= bounds.Y + 24 then
                    dragging = true
                    dragOffset = mouse - window.Position
                end
            end
        end))

        Runtime:TrackConnection(Input.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end))

        Runtime:BindStep(function()
            if dragging then
                local mouse = Input:GetMousePosition()
                window.Position = mouse - dragOffset
                window.Frame.Position = window.Position
                window.TitleLabel.Position = window.Position + Vector2.new(10, -20)
                for _, tab in pairs(window.Tabs) do
                    if tab.ScrollFrame then
                        tab.ScrollFrame.Bounds.Position = window.Position + Vector2.new(10, 40)
                    end
                end
            end
        end)

        function window:CreateTab(name)
            local tab = { Name = name, Controls = {} }
            tab.ScrollFrame = Scroll:Create({
                Position = window.Position + Vector2.new(10, 40),
                Size = Vector2.new(window.Size.X - 20, window.Size.Y - 50)
            })

            function tab:AddControl(drawObj, id, methods)
                tab.ScrollFrame:AddElement(drawObj, #tab.Controls * 26)
                tab.Controls[#tab.Controls + 1] = drawObj
                if id then
                    hook_cc.__controls[id] = methods
                end
            end

            tab.AddButton = function(...) local obj = Button:Create(...) tab:AddControl(obj) end
            tab.AddToggle = function(...) local obj = Toggle:Create(...) tab:AddControl(obj) end
            tab.AddSlider = function(...) local obj = Slider:Create(...) tab:AddControl(obj) end
            tab.AddKeybind = function(...) local obj = Keybind:Create(...) tab:AddControl(obj) end
            tab.AddColorPicker = function(...) local obj = ColorPicker:Create(...) tab:AddControl(obj) end
            tab.AddDropdown = function(...) local obj = Dropdown:Create(...) tab:AddControl(obj) end
            tab.AddLabel = function(...) local obj = Label:Create(...) tab:AddControl(obj) end

            window.Tabs[#window.Tabs + 1] = tab
            if not window.ActiveTab then window.ActiveTab = tab end
            return tab
        end

        Runtime:TrackConnection(Input.InputBegan:Connect(function(input)
            if input.KeyCode == KeyCodes.RightShift then
                window.Visible = not window.Visible
            end
        end))

        return window
    end
end
