-- hook.cc / library.lua

local repo = "documentable/hook.cc" 
local branch = "main"

local function fetchModule(path)
	local url = ("https://raw.githubusercontent.com/%s/%s/%s.lua"):format(repo, branch, path)
	return loadstring(game:HttpGet(url, true), path)()
end

local hook_cc = {}

fetchModule("core/init")(hook_cc)
fetchModule("ui/main")(hook_cc)
fetchModule("controls/main")(hook_cc)

_G.hook_cc = hook_cc
return hook_cc
