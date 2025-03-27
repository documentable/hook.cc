-- hook.cc / core/keycodes.lua

return function(hook_cc)

    local keyMap = {}

    for _, key in ipairs(Enum.KeyCode:GetEnumItems()) do
        keyMap[key.Name] = key
    end

    ------------------------------------------------------------------------
    -- COMMON ALIASES
    ------------------------------------------------------------------------

    keyMap.Enter     = Enum.KeyCode.Return
    keyMap.RCtrl     = Enum.KeyCode.RightControl
    keyMap.LCtrl     = Enum.KeyCode.LeftControl
    keyMap.RShift    = Enum.KeyCode.RightShift
    keyMap.LShift    = Enum.KeyCode.LeftShift
    keyMap.Alt       = Enum.KeyCode.LeftAlt
    keyMap.Esc       = Enum.KeyCode.Escape
    keyMap.Backspace = Enum.KeyCode.Backspace

    ------------------------------------------------------------------------
    -- DEFAULT LOOKUP FALLBACK
    ------------------------------------------------------------------------

    setmetatable(keyMap, {
        __index = function(_, key)
            return Enum.KeyCode[key] or Enum.KeyCode.Unknown
        end
    })

    hook_cc.KeyCodes = keyMap
end
