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