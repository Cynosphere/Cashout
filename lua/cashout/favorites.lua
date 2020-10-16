-- quick join/pseudo-favorites system for quicker server joining

Cashout.Favorites = util.JSONToTable(cookie.GetString("cashout_favorites", "{}"))

function Cashout.AddServerToFavorites(name, ip)
    Cashout.Favorites[ip] = name
    cookie.Set("cashout_favorites", util.TableToJSON(Cashout.Favorites))
end

function Cashout.RemoveServerFromFavorites(ip)
    Cashout.Favorites[ip] = nil
    cookie.Set("cashout_favorites", util.TableToJSON(Cashout.Favorites))
end

function Cashout.ChangeServerIP(old, new)
    local name = Cashout.Favorites[old]
    Cashout.Favorites[new] = name
    Cashout.Favorites[old] = nil
    cookie.Set("cashout_favorites", util.TableToJSON(Cashout.Favorites))
end

function Cashout.ChangeServerName(ip, name)
    Cashout.Favorites[ip] = name
    cookie.Set("cashout_favorites", util.TableToJSON(Cashout.Favorites))
end