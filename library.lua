--[[ hook.cc / library.lua
                                                                
                                                                
  ,---,                              ,-.                        
,--.' |                          ,--/ /|                        
|  |  :       ,---.     ,---.  ,--. :/ |                        
:  :  :      '   ,'\   '   ,'\ :  : ' /                         
:  |  |,--. /   /   | /   /   ||  '  /        ,---.     ,---.   
|  :  '   |.   ; ,. :.   ; ,. :'  |  :       /     \   /     \  
|  |   /' :'   | |: :'   | |: :|  |   \     /    / '  /    / '  
'  :  | | |'   | .; :'   | .; :'  : |. \   .    ' /  .    ' /   
|  |  ' | :|   :    ||   :    ||  | ' \ \  '   ; :__ '   ; :__  
|  :  :_:,' \   \  /  \   \  / '  : |--'___'   | '.'|'   | '.'| 
|  | ,'      `----'    `----'  ;  |,'  /  .\   :    :|   :    : 
`--''                          '--'    \  ; \   \  /  \   \  /  
                                        `--" `----'    `----'   
      stream zzzzombie
]]


-- hook.cc / library.lua

local repo = "documentable/hook.cc"
local branch = "main"

local function fetchModule(path)
	local url = ("https://raw.githubusercontent.com/%s/%s/%s.lua"):format(repo, branch, path)
	local success, result = pcall(function()
		return game:HttpGet(url, true)
	end)

	if not success then
		warn("[hook.cc] Failed to fetch module: " .. path .. " | Error: " .. tostring(result))
		return function() end
	end

	local loaded, func = pcall(loadstring, result, path .. ".lua")
	if not loaded then
		warn("[hook.cc] Failed to compile: " .. path .. " | Error: " .. tostring(func))
		return function() end
	end

	return func()
end


local hook_cc = {}

fetchModule("core/init")(hook_cc)
fetchModule("core/keycodes")(hook_cc)
fetchModule("core/config")(hook_cc)
fetchModule("core/dependencies")(hook_cc)

fetchModule("ui/controls/button")(hook_cc)
fetchModule("ui/controls/toggle")(hook_cc)
fetchModule("ui/controls/slider")(hook_cc)
fetchModule("ui/controls/keybind")(hook_cc)
fetchModule("ui/controls/colorpicker")(hook_cc)
fetchModule("ui/controls/label")(hook_cc)
fetchModule("ui/controls/dropdown")(hook_cc)

fetchModule("ui/notify")(hook_cc)
fetchModule("ui/extkeybind")(hook_cc)
fetchModule("ui/dropdown")(hook_cc)
fetchModule("ui/scroll")(hook_cc)
fetchModule("ui/init")(hook_cc)

_G.hook_cc = hook_cc
return hook_cc
