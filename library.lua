-- hook.cc / library.lua
--[[
                                                                
                                                                
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


local author = "documentable
local repo = "hook.cc"
local branch = "main"

local function fetchModule(path)
	local url = ("https://raw.githubusercontent.com/%s/%s/%s/%s.lua"):format(author, repo, branch, path)
	return loadstring(game:HttpGet(url, true), path .. ".lua")()
end

local hook_cc = {}

fetchModule("core/init")(hook_cc)
fetchModule("core/keycodes")(hook_cc)
fetchModule("core/dependencies")(hook_cc)
fetchModule("core/config")(hook_cc)

fetchModule("ui/init")(hook_cc) 
fetchModule("ui/extkeybind")(hook_cc)
fetchModule("notify")(hook_cc) -- optional; only if you include this module

_G.hook_cc = hook_cc
return hook_cc
