-- hook.cc / ui/controls/label.lua

return function(hook_cc)
    local Drawing = hook_cc.Drawing

    local Label = {}

    function Label:Create(text, position, size, color)
        local label = Drawing:Create("Text", {
            Text = text,
            Position = position,
            Size = size or 13,
            Color = color or Color3.fromRGB(255, 255, 255),
            Outline = true,
            ZIndex = 3,
            Visible = true
        })

        function label:Destroy()
            label:Remove()
        end

        return label
    end

    hook_cc.Label = Label
end
