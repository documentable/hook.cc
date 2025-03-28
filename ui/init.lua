-- hook.cc / ui/init.lua (full implementation restored)

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
    local mouse = game:GetService("UserInputService")

    -- Default Theme
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
        window.TabDirection = opts.TabDirection or "Left"

        window.Visible = true
        window.Tabs = {}
        window.ActiveTab = nil
        window.TabButtons = {}
        window.Tooltips = {}

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

        local tooltip = Drawing:Create("Text", {
            Text = "",
            Size = 13,
            Color = window.Theme.Text,
            Outline = true,
            Visible = false,
            ZIndex = 99
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
            tooltip.Transparency = animAlpha

            if window.ActiveTab then
                window.ActiveTab.Fade = math.min((window.ActiveTab.Fade or 0) + delta * 4, 1)
                for _, ctrl in ipairs(window.ActiveTab.Controls) do
                    if ctrl.Transparency then
                        ctrl.Transparency = window.ActiveTab.Fade
                    end
                end
            end
        end)

        local dragging = false
        local dragOffset = Vector2.new()

        Runtime:TrackConnection(Input.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local m = Input:GetMousePosition()
                if m.X >= window.Position.X and m.X <= window.Position.X + window.Size.X and
                   m.Y >= window.Position.Y - 24 and m.Y <= window.Position.Y then
                    dragging = true
                    dragOffset = m - window.Position
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
                local m = Input:GetMousePosition()
                window.Position = m - dragOffset
                window.Frame.Position = window.Position
                window.TitleLabel.Position = window.Position + Vector2.new(10, -20)
                for i, btn in pairs(window.TabButtons) do
                    local offset = Vector2.new(0, (i - 1) * 24 + 10)
                    if window.TabDirection == "Top" then
                        offset = Vector2.new((i - 1) * 100 + 10, 10)
                    elseif window.TabDirection == "Right" then
                        offset = Vector2.new(window.Size.X - 90, (i - 1) * 24 + 10)
                    elseif window.TabDirection == "Bottom" then
                        offset = Vector2.new((i - 1) * 100 + 10, window.Size.Y - 30)
                    end
                    btn.Text.Position = window.Position + offset
                end
                if window.ActiveTab and window.ActiveTab.ScrollFrame then
                    local offset = Vector2.new(10, 40)
                    if window.TabDirection == "Left" then offset = Vector2.new(100, 10) end
                    window.ActiveTab.ScrollFrame.Bounds.Position = window.Position + offset
                end
            end

            tooltip.Visible = false
            for _, tip in ipairs(window.Tooltips) do
                local m = Input:GetMousePosition()
                if m.X >= tip.Hit.X and m.X <= tip.Hit.X + tip.Hit.W and
                   m.Y >= tip.Hit.Y and m.Y <= tip.Hit.Y + tip.Hit.H then
                    tooltip.Text = tip.Text
                    tooltip.Position = m + Vector2.new(12, 8)
                    tooltip.Visible = true
                end
            end
        end)

        function window:CreateTab(name, icon)
            local tab = { Name = name, Icon = icon or "", Controls = {}, Fade = 0 }
            local offset = Vector2.new(10, 40)
            if window.TabDirection == "Left" then offset = Vector2.new(100, 10) end

            tab.ScrollFrame = Scroll:Create({
                Position = window.Position + offset,
                Size = Vector2.new(window.Size.X - (offset.X + 10), window.Size.Y - (offset.Y + 10))
            })

            local idx = #window.Tabs + 1
            local label = icon and (icon .. " " .. name) or name
            local tabText = Drawing:Create("Text", {
                Text = label,
                Size = 13,
                Outline = true,
                Color = window.Theme.Text,
                Position = window.Position + Vector2.new(10, 10 + (idx - 1) * 24),
                ZIndex = 5,
                Visible = true
            })
            window.TabButtons[idx] = { Text = tabText, Tab = tab }

            Runtime:TrackConnection(Input.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local m = Input:GetMousePosition()
                    if m.X >= tabText.Position.X and m.X <= tabText.Position.X + 100 and
                       m.Y >= tabText.Position.Y and m.Y <= tabText.Position.Y + 20 then
                        tab.Fade = 0
                        window.ActiveTab = tab
                    end
                end
            end))

            function tab:AddControl(drawObj, id, methods, tooltipText)
                local offsetY = #tab.Controls * 26
                tab.ScrollFrame:AddElement(drawObj, offsetY)
                tab.Controls[#tab.Controls + 1] = drawObj
                if tooltipText then
                    local pos = window.Position + offset + Vector2.new(0, offsetY)
                    table.insert(window.Tooltips, {
                        Hit = { X = pos.X, Y = pos.Y, W = 200, H = 22 },
                        Text = tooltipText
                    })
                end
                if id then
                    hook_cc.__controls[id] = methods
                end
            end

            tab.AddButton = function(...) local o = Button:Create(...) tab:AddControl(o, nil, {}, select(3, ...)) end
            tab.AddToggle = function(...) local o = Toggle:Create(...) tab:AddControl(o, nil, { GetValue = o.Get, SetValue = o.Set }, select(3, ...)) end
            tab.AddSlider = function(...) local o = Slider:Create(...) tab:AddControl(o, nil, { GetValue = o.Get, SetValue = o.Set }, select(6, ...)) end
            tab.AddKeybind = function(...) local o = Keybind:Create(...) tab:AddControl(o, nil, { GetValue = o.Get, SetValue = o.SetCombo }, select(3, ...)) end
            tab.AddColorPicker = function(...) local o = ColorPicker:Create(...) tab:AddControl(o, nil, { GetValue = o.Get, SetValue = o.Set }, select(3, ...)) end
            tab.AddDropdown = function(...) local o = Dropdown:Create(...) tab:AddControl(o, nil, { GetValue = o.Get, SetValue = o.Set }, select(4, ...)) end
            tab.AddLabel = function(...) local o = Label:Create(...) tab:AddControl(o) end

            window.Tabs[idx] = tab
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
