local pcount = 0

--TODO: add config menu and loading for this
--Format: filename = true
disabled = {}

for _,f in pairs(file.Find("lua/cashout/plugins/*","GAME")) do
    if disabled[f:gsub(".lua","")] then continue end
    include("cashout/plugins/"..f)
    pcount=pcount+1
end

print("[Cashout] Loaded "..pcount.." plugins.")