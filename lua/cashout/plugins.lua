Cashout.Plugins = {
    Count = 0,
    Options = {},
    MenuItems = {},
    Loaded = {},
}

function Cashout.Plugins:TestMigration(plugin, option)
    if cookie.GetString(("menup_%s_%s"):format(plugin, option), "\1") ~= "\1" then
        cookie.Set(("cashout.plugins.%s.%s"):format(plugin, option), cookie.GetString(("menup_%s_%s"):format(plugin, option), "unset"))
        cookie.Delete(("menup_%s_%s"):format(plugin, option))
    end
end

function Cashout.Plugins:AddOption(plugin, option, default)
    default = tostring(default)

    self:TestMigration(plugin, option)

    local opt = self:GetOption(plugin, option)

    self.Options[plugin] = self.Options[plugin] or {}
    self.Options[plugin][option] = opt

    if opt == "unset" then
        self:SetOption(plugin, option, default)
    end
end

function Cashout.Plugins:GetOption(plugin, option)
    if self.Options[plugin] and self.Options[plugin][option] then
        return self.Options[plugin][option]
    end

    self:TestMigration(plugin, option)

    local opt = cookie.GetString(("cashout.plugins.%s.%s"):format(plugin, option), "unset")

    self.Options[plugin] = self.Options[plugin] or {}
    self.Options[plugin][option] = opt

    return opt
end

function Cashout.Plugins:SetOption(plugin, option, value)
    value = tostring(value)

    self:TestMigration(plugin, option)

    self.Options[plugin] = self.Options[plugin] or {}
    self.Options[plugin][option] = value

    cookie.Set(("cashout.plugins.%s.%s"):format(plugin, option), value)
end

function Cashout.Plugins:AddMenuItem(plugin, name, func)
    self.MenuItems[plugin] = self.MenuItems[plugin] or {}
    self.MenuItems[plugin][name] = func
end

include("cashout/menu_plugins_compat.lua")

for _,f in pairs(file.Find("lua/cashout/plugins/*.lua", "MOD")) do
    if f == "menu_plugins.lua" then continue end

    include("cashout/plugins/" .. f)
    Cashout.Plugins.Loaded[f:gsub("%.lua$", "")] = true
    Cashout.Plugins.Count = Cashout.Plugins.Count + 1
end

print("[Cashout] Loaded " .. Cashout.Plugins.Count .. " plugins.")