local pcount = 0

disabled = {
    --luaviewer = true,
    --interstate = true,
    drawboard = true,
}

for _,f in pairs(file.Find("lua/cashout/plugins/*","GAME")) do
    if disabled[f:gsub(".lua","")] then continue end
    include("cashout/plugins/" .. f)
    pcount = pcount + 1
end

print("[Cashout] Loaded " .. pcount .. " plugins.")