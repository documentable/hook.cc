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


local author = "documentable" -- and zeze
local repo = "hook.cc"
local branch = "main"

local function fetchModule(path)
	local url = ("https://raw.githubusercontent.com/%s/%s/%s/%s.lua"):format(author, repo, branch, path)
	return loadstring(game:HttpGet(url, true), path)()
end

local hook_cc = {}

-- Core modules
fetchModule("core/init")(hook_cc)
fetchModule("core/keycodes")(hook_cc)
fetchModule("core/config")(hook_cc)
fetchModule("core/dependencies")(hook_cc)

-- UI modules
fetchModule("ui/init")(hook_cc)
fetchModule("ui/notify")(hook_cc)
fetchModule("ui/extkeybind")(hook_cc)
fetchModule("ui/dropdown")(hook_cc)
fetchModule("ui/scroll")(hook_cc)

-- UI control modules
fetchModule("ui/controls/button")(hook_cc)
fetchModule("ui/controls/toggle")(hook_cc)
fetchModule("ui/controls/slider")(hook_cc)
fetchModule("ui/controls/keybind")(hook_cc)
fetchModule("ui/controls/colorpicker")(hook_cc)
fetchModule("ui/controls/label")(hook_cc)
fetchModule("ui/controls/dropdown")(hook_cc)

_G.hook_cc = hook_cc
return hook_cc
