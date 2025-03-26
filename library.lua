--// hook.cc library

local hook_cc = {}
local uis = game:GetService("UserInputService")

local objects = {}
local activeTab = nil
local currentKeybind = nil
local dragging = false
local dragOffset = Vector2.new(0, 0)
local mouse = uis:GetMouseLocation
local runtimeConnections = {}

local jsonEncode = function(t)
    local HttpService = game:GetService("HttpService")
    return HttpService:JSONEncode(t)
end
local jsonDecode = function(s)
    local HttpService = game:GetService("HttpService")
    return HttpService:JSONDecode(s)
end

function hook_cc.sfunction(callbackFunction, isolateEnvironment)
    local env = isolateEnvironment and setmetatable({}, { __index = _G }) or _G
    local wrapped = function(...)
        if isolateEnvironment then
            local _ENV = env
        end
        return callbackFunction(...)
    end
    if newcclosure then
        wrapped = newcclosure(wrapped)
    end
    return wrapped
end

local function newText(text, size, pos, color)
    local drawingText = Drawing.new("Text")
    drawingText.Text = text
    drawingText.Size = size or 13
    drawingText.Position = pos or Vector2.new(100, 100)
    drawingText.Color = color or Color3.new(1, 1, 1)
    drawingText.Outline = true
    drawingText.Center = false
    drawingText.Visible = true

    function drawingText:SetText(newText) drawingText.Text = newText end
    function drawingText:SetColor(newColor) drawingText.Color = newColor end
    function drawingText:SetVisible(state) drawingText.Visible = state end

    table.insert(objects, drawingText)
    return drawingText
end

local function newSquare(size, pos, color, transparency)
    local drawingSquare = Drawing.new("Square")
    drawingSquare.Size = size or Vector2.new(100, 20)
    drawingSquare.Position = pos or Vector2.new(100, 100)
    drawingSquare.Color = color or Color3.new(0.2, 0.2, 0.2)
    drawingSquare.Transparency = transparency or 1
    drawingSquare.Filled = true
    drawingSquare.Visible = true

    function drawingSquare:SetColor(c) drawingSquare.Color = c end
    function drawingSquare:SetVisible(v) drawingSquare.Visible = v end

    table.insert(objects, drawingSquare)
    return drawingSquare
end

function hook_cc:Unload()
    for _, obj in ipairs(objects) do
        pcall(function() obj:Remove() end)
    end
    for _, conn in ipairs(runtimeConnections) do
        pcall(function() conn:Disconnect() end)
    end
    objects = {}
    activeTab = nil
    currentKeybind = nil
    dragging = false
    dragOffset = nil
    if rawget(_G, "hook_cc") then
        _G.hook_cc = nil
    end
end

function hook_cc:CreateWindow(config)
    local title = config.Title or "hook.cc UI"
    local tabs = {}
    local currentY = 80
    local baseX = 80

    local frame = newSquare(Vector2.new(300, 350), Vector2.new(baseX, currentY - 60), Color3.fromRGB(25, 25, 25), 1)
    local titleText = newText(title, 16, Vector2.new(baseX + 10, currentY - 55), Color3.fromRGB(200, 200, 255))

    local windowAPI = {}

    table.insert(runtimeConnections, uis.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local m = uis:GetMouseLocation()
            if m.X >= frame.Position.X and m.X <= frame.Position.X + frame.Size.X and m.Y >= frame.Position.Y and m.Y <= frame.Position.Y + 30 then
                dragging = true
                dragOffset = m - frame.Position
            end
        end
    end))

    table.insert(runtimeConnections, uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))

    table.insert(runtimeConnections, game:GetService("RunService").RenderStepped:Connect(function()
        if dragging then
            local m = uis:GetMouseLocation()
            frame.Position = m - dragOffset
            titleText.Position = frame.Position + Vector2.new(10, 5)
        end
    end))

    function windowAPI:CreateTab(tabName)
        local tabButton = newText("[ " .. tabName .. " ]", 13, Vector2.new(baseX, currentY), Color3.new(1, 1, 1))
        currentY = currentY + 20
        local tabElements = {}

        local tabAPI = {}

        function tabAPI:SetActive()
            if activeTab then
                for _, obj in pairs(activeTab) do obj:SetVisible(false) end
            end
            for _, obj in pairs(tabElements) do obj:SetVisible(true) end
            activeTab = tabElements
        end

        function tabAPI:AddLabel(labelText)
            local label = newText(labelText, 13, Vector2.new(baseX + 20, currentY), Color3.new(1, 1, 1))
            table.insert(tabElements, label)
            currentY = currentY + 18
            return label
        end

        function tabAPI:AddButton(buttonText, callback)
            local buttonBackground = newSquare(Vector2.new(120, 20), Vector2.new(baseX + 20, currentY), Color3.fromRGB(35, 35, 35))
            local buttonLabel = newText(buttonText, 13, Vector2.new(baseX + 25, currentY + 2), Color3.new(1,1,1))
            table.insert(tabElements, buttonBackground)
            table.insert(tabElements, buttonLabel)
            currentY = currentY + 25

            table.insert(runtimeConnections, uis.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mousePos = uis:GetMouseLocation()
                    if mousePos.X >= buttonBackground.Position.X and mousePos.X <= buttonBackground.Position.X + buttonBackground.Size.X and mousePos.Y >= buttonBackground.Position.Y and mousePos.Y <= buttonBackground.Position.Y + buttonBackground.Size.Y then
                        pcall(callback)
                    end
                end
            end))

            return buttonLabel
        end

        return tabAPI
    end

    return windowAPI
end

_G.hook_cc = hook_cc
return hook_cc
