-- menu_plugins compatability layer
menup = {
    options = {}
}

menup.include = function(path)
    return include("menu_plugins/" .. path)
end

function menup.options.addOption(...)
    Cashout.Plugins:AddOption(...)
end

function menup.options.setOption(...)
    Cashout.Plugins:SetOption(...)
end

function menup.options.getOption(...)
    return Cashout.Plugins:GetOption(...)
end

for _, f in pairs(file.Find("lua/menu_plugins/*.lua", "MOD")) do
    if f == "init.lua" then continue end

    Cashout.Plugins.Loaded[f:gsub("%.lua$", "")] = true
    menup.include(f)
end

hook.Add("DrawOverlay", "MenuVGUIReady", function()
    hook.Run("MenuVGUIReady")
    hook.Remove("DrawOverlay", "MenuVGUIReady")
end)