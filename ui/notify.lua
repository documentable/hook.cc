-- hook.cc / ui/notify.lua

return function(hook_cc)
    local Drawing = hook_cc.Drawing
    local Runtime = hook_cc.Runtime

    local Notification = {}
    local active = {}
    local padding = 6
    local lineHeight = 18
    local maxWidth = 280
    local duration = 3

    function hook_cc:Log(text, color)
        local message = tostring(text)
        local textColor = color or Color3.fromRGB(255, 255, 255)

        local yOffset = (#active * (lineHeight + padding)) + padding
        local pos = Vector2.new(workspace.CurrentCamera.ViewportSize.X - maxWidth - padding, padding + yOffset)

        local bg = Drawing:Create("Square", {
            Position = pos,
            Size = Vector2.new(maxWidth, lineHeight),
            Color = Color3.fromRGB(20, 20, 20),
            Transparency = 0.85,
            Filled = true,
            ZIndex = 10,
            Visible = true
        })

        local label = Drawing:Create("Text", {
            Text = message,
            Size = 13,
            Color = textColor,
            Outline = true,
            Position = pos + Vector2.new(6, 1),
            ZIndex = 11,
            Visible = true
        })

        local note = {
            Box = bg,
            Text = label
        }

        table.insert(active, note)

        task.delay(duration, function()
            for i, n in ipairs(active) do
                if n == note then
                    table.remove(active, i)
                    break
                end
            end
            bg:Remove()
            label:Remove()
        end)
    end

    hook_cc.Notify = Notification
end
