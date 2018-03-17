local developer = GetConVar("developer")
_G.DEVELOPER = developer:GetBool()

function IsDeveloper(n)
    return developer:GetInt() >= (n or 1)
end

local function lua_run_menu(_,_,_,code)
	local func = CompileString(code,"",false)
	if isstring(func) then
		Msg"Invalid syntax> "print(func)
		return
	end
	MsgN("> ",code)
	xpcall(func,function(err)
		print(debug.traceback(err))
	end)
end
concommand.Add("lua_run_menu",lua_run_menu)

function gamemenucommand(str)
	RunGameUICommand(str)
end

local function FindInTable( tab, find, parents, depth )

	depth = depth or 0
	parents = parents or ""

	if ( !istable( tab ) ) then return end
	if ( depth > 3 ) then return end
	depth = depth + 1

	for k, v in pairs ( tab ) do

		if ( type(k) == "string" ) then

			if ( k && k:lower():find( find:lower() ) ) then

				Msg("\t", parents, k, " - (", type(v), " - ", v, ")\n")

			end

			-- Recurse
			if ( istable(v) &&
				k != "_R" &&
				k != "_E" &&
				k != "_G" &&
				k != "_M" &&
				k != "_LOADED" &&
				k != "__index" ) then

				local NewParents = parents .. k .. ".";
				FindInTable( v, find, NewParents, depth )

			end

		end

	end

end


--[[---------------------------------------------------------
   Name:	Find
-----------------------------------------------------------]]
local function Find( ply, command, arguments )

	if ( IsValid(ply) && ply:IsPlayer() && !ply:IsAdmin() ) then return end
	if ( !arguments[1] ) then return end

	Msg("Finding '", arguments[1], "':\n\n")

	FindInTable( _G, arguments[1] )
	FindInTable( debug.getregistry(), arguments[1] )

	Msg("\n\n")

end

concommand.Add( "lua_find_menu", Find, nil, "", { FCVAR_DONTRECORD } )