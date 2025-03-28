-- hook.cc / library.lua
local author = "documentable" -- and zeze
local repo = "hook.cc"
local branch = "main"
local hook_cc = _G.hook_cc or {}
_G.hook_cc = hook_cc

local HttpService = game:GetService("HttpService")
local loadedModules = {}

local modulePaths = {
    "core/init",
    "core/keycodes",
    "core/config",
    "core/dependencies",
    "core/drawing",

    "ui/controls/button",
    "ui/controls/toggle",
    "ui/controls/slider",
    "ui/controls/keybind",
    "ui/controls/colorpicker",
    "ui/controls/label",

    "ui/notify",
    "ui/dropdown",
    "ui/extkeybind",
    "ui/dropdown",
    "ui/scroll",
    "ui/init"
}

for _, path in ipairs(modulePaths) do
    local url = ("https://raw.githubusercontent.com/%s/%s/refs/heads/%s/%s.lua"):format(author, repo, branch, path)
    local success, source = pcall(function() return game:HttpGetAsync(url) end)
    if success and type(source) == "string" then
        local chunk, err = loadstring(source, path .. ".lua")
        if chunk then
            table.insert(loadedModules, { path = path, run = chunk })
        else
            warn("[hook.cc] Failed to compile:", path, err)
        end
    else
        warn("[hook.cc] Failed to fetch:", path, source)
    end
end

for _, mod in ipairs(loadedModules) do
    local ok, err = pcall(mod.run, hook_cc)
    if not ok then
        warn("[hook.cc] Error executing module:", mod.path, err)
    end
end

return hook_cc
