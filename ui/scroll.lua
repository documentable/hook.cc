-- hook.cc / ui/scroll.lua

return function(hook_cc)
    local Drawing = hook_cc.Drawing
    local Input = hook_cc.Input
    local Runtime = hook_cc.Runtime

    local Scroll = {}

    function Scroll:Create(bounds)
        local container = {
            Bounds = bounds,
            Offset = 0,
            ScrollSpeed = 12,
            Children = {}
        }

        -- Create visual clipping mask
        container.__clipFrame = Drawing:Create("Square", {
            Position = bounds.Position,
            Size = bounds.Size,
            Color = Color3.new(0, 0, 0),
            Transparency = 1,
            Visible = false -- for debugging
        })

        function container:AddElement(drawObject, yPosition)
            drawObject.Position = bounds.Position + Vector2.new(0, yPosition - container.Offset)
            table.insert(container.Children, drawObject)
        end

        function container:SetOffset(offset)
            container.Offset = math.clamp(offset, 0, container:GetMaxOffset())
            for i, drawObject in ipairs(container.Children) do
                drawObject.Position = Vector2.new(
                    drawObject.Position.X,
                    bounds.Position.Y + (drawObject.Position.Y - bounds.Position.Y) - offset
                )
            end
        end

        function container:GetMaxOffset()
            local bottom = 0
            for _, obj in ipairs(container.Children) do
                local objBottom = obj.Position.Y + (obj.Size and obj.Size.Y or 0)
                if objBottom > bottom then bottom = objBottom end
            end
            return math.max(0, bottom - bounds.Size.Y)
        end

        Runtime:TrackConnection(game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseWheel then
                local mouse = Input:GetMousePosition()
                if mouse.X >= bounds.Position.X and mouse.X <= bounds.Position.X + bounds.Size.X and
                   mouse.Y >= bounds.Position.Y and mouse.Y <= bounds.Position.Y + bounds.Size.Y then
                    container:SetOffset(container.Offset - input.Position.Z * container.ScrollSpeed)
                end
            end
        end))

        return container
    end

    hook_cc.Scroll = Scroll
end
