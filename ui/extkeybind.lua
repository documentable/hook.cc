-- hook.cc / ui/extkeybind.lua

return function(hook_cc)
    local Drawing = hook_cc.Drawing
    local Input = hook_cc.Input
    local Runtime = hook_cc.Runtime
    local Dropdown = hook_cc.Dropdown

    local ExtKeybind = {}

    local keybindModes = {
        "Hold",
        "Toggle",
        "Always On",
        "Off on Hold"
    }

    function ExtKeybind:AttachTo(targetControl, position, currentMode, onSelect)
        if not targetControl then return end

        local dropdown = Dropdown:Create("Mode", position, 140, keybindModes, currentMode or "Hold", function(mode)
            if typeof(targetControl.SetMode) == "function" then
                targetControl:SetMode(mode)
            end
            if typeof(onSelect) == "function" then
                pcall(onSelect, mode)
            end
        end)

        targetControl.__extModeDropdown = dropdown
        return dropdown
    end

    hook_cc.ExtKeybind = ExtKeybind
end
