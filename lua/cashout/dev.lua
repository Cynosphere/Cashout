local developer = GetConVar("developer")
_G.DEVELOPER = developer:GetBool()

function IsDeveloper(n)
    return developer:GetInt() >= (n or 1)
end

local function lua_run_menu(_, _, _, code)
    local func = CompileString(code, "", false)

    if isstring(func) then
        Msg"Invalid syntax> "
        print(func)

        return
    end

    MsgN("> ", code)

    xpcall(func, function(err)
        print(debug.traceback(err))
    end)
end

concommand.Add("lua_run_menu", lua_run_menu)

function gamemenucommand(str)
    RunGameUICommand(str)
end

local function FindInTable(tab, find, parents, depth)
    depth = depth or 0
    parents = parents or ""

    if (not istable(tab)) then
        return
    end

    if (depth > 3) then
        return
    end

    depth = depth + 1

    for k, v in pairs(tab) do
        if (type(k) == "string") then
            if (k and k:lower():find(find:lower())) then
                Msg("\t", parents, k, " - (", type(v), " - ", v, ")\n")
            end

            -- Recurse
            if (istable(v) and k ~= "_R" and k ~= "_E" and k ~= "_G" and k ~= "_M" and k ~= "_LOADED" and k ~= "__index") then
                local NewParents = parents .. k .. "."
                FindInTable(v, find, NewParents, depth)
            end
        end
    end
end

--[[---------------------------------------------------------
   Name:	Find
-----------------------------------------------------------]]
local function Find(ply, command, arguments)
    if (IsValid(ply) and ply:IsPlayer() and not ply:IsAdmin()) then
        return
    end

    if (not arguments[1]) then
        return
    end

    Msg("Finding '", arguments[1], "':\n\n")
    FindInTable(_G, arguments[1])
    FindInTable(debug.getregistry(), arguments[1])
    Msg("\n\n")
end

concommand.Add("lua_find_menu", Find, nil, "", {FCVAR_DONTRECORD})

hook.Add("MenuStart", "Cashout", function()
    print"MenuStart"
end)

hook.Add("ConsoleVisible", "Cashout", function(is)
    print(is and '<console on>' or '<console off>')
end)

hook.Add("InGame", "Cashout", function(is)
    print(is and "InGame" or "Out of game")
end)

hook.Add("LoadingStatus", "Cashout", function(status)
    print("LoadingStatus", status)
end)

local isingame = IsInGame()
local wasingame = false
local status = GetLoadStatus()
local console

hook.Add("Think", "Cashout", function()
    local is = IsInGame()

    if is ~= isingame then
        isingame = is
        wasingame = wasingame or isingame
        hook.Call("InGame", nil, isingame)
    end

    local s = GetLoadStatus()

    if s ~= status then
        status = s
        hook.Call("LoadingStatus", nil, status)
    end

    local s = gui.IsConsoleVisible()

    if s ~= console then
        console = s
        hook.Call("ConsoleVisible", nil, console)
    end
end)

function WasInGame()
    return wasingame
end

local games = engine.GetGames()
local addons = engine.GetAddons()

hook.Add("GameContentChanged", "Cashout", function()
    local games_new = engine.GetGames()
    local _ = games
    games = games_new
    local games = _
    local addons_new = engine.GetAddons()
    local _ = addons
    addons = addons_new
    local addons = _
    local wasmount = false
    local wasaddon = false

    for k, new in next, games_new do
        local old = games[k]
        assert(old.depot == new.depot)

        if old.mounted ~= new.mounted then
            print("MOUNT", new.title, new.mounted and "MOUNTED" or "UNMOUNTED")
            wasmount = true
        end
    end

    for k, new in next, addons_new do
        local old

        for k, v in next, addons do
            if v.file == new.file then
                old = v
                break
            end
        end

        if not old then
            print("Added ", new.mounted and "(M)" or "   ", '\t', new.title)
            wasaddon = true
            continue
        end

        assert(old.depot == new.depot)

        if old.mounted ~= new.mounted then
            print("MOUNT", new.title, "\t", new.mounted and "MOUNTED" or "UNMOUNTED")
            wasaddon = true
        end
    end

    for k, old in next, addons do
        local new

        for k, v in next, addons_new do
            if v.file == old.file then
                new = v
                break
            end
        end

        if not new then
            MsgN("Removed ", old.title)
            nothing = false
            continue
        end
    end

    hook.Call("GameContentsChanged", nil, wasmount, wasaddon)
end)

function UpdateLanguages()
    local f = file.Find("resource/localization/*.png", "MOD")
end

--
-- Called from the engine any time the language changes
--
function LanguageChanged(lang)
    print("LanguageChanged", lang)
end

hook.Add("GameContentChanged", "RefreshMainMenu", function() end)
--print("GameContentChanged")
--pnlMainMenu = vgui.Create( "MainMenuPanel" )
--"UpdateVersion( '"..VERSIONSTR.."', '"..BRANCH.."' )" )
local language = GetConVarString("gmod_language")

--LanguageChanged( language )
--hook.Run( "GameContentChanged" )
--[[	serverlist.PlayerList( serverip, function( tbl )
		local json = util.TableToJSON( tbl );
		pnlMainMenu:Call( "SetPlayerList( '"..serverip.."', "..json..")" );
	end )
--]]
SelectGamemode = function(g)
    RunConsoleCommand("gamemode", g)
end

function SetMounted(game, yesno)
    engine.SetMounted(game.depot, yesno == nil or yesno)
end

SelectLanguage = function(lang)
    RunConsoleCommand("gmod_language", lang)
end

function SearchWorkshop(str)
    str = string.JavascriptSafe(str)
    str = "http://steamcommunity.com/workshop/browse?searchtext=" .. str .. "&childpublishedfileid=0&section=items&appid=4000&browsesort=trend&requiredtags[]=-1"
    gui.OpenURL(str)
end

function CompileFile(path)
    local f = file.Open(path, 'rb', 'LuaMenu')

    if not f then
        ErrorNoHalt("Could not open: " .. path .. '\n')

        return
    end

    local str = f:Read(f:Size())
    f:Close()
    local func = CompileString(str, '@' .. path, false)

    if isstring(func) then
        error(func)
    else
        return func
    end
end