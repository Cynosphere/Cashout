g_ServerName = ""
g_MapName    = ""
g_ServerURL  = ""
g_MaxPlayers = ""
g_SteamID    = ""

_G.co_loadinfo = {name="",map="",gm=""}

local PANEL = {}

function PANEL:Init()
    self:SetSize( 1,1 )
    self:SetPopupStayAtBack(true)
    self:MoveToBack()
    self:SetVisible(false)
end

function PANEL:PerformLayout()
    self:SetSize( 1,1 )
    self:SetPopupStayAtBack(true)
    self:MoveToBack()
end

function PANEL:Paint() end

function PANEL:OnActivate()
    g_ServerName	= ""
    g_MapName		= ""
    g_ServerURL		= ""
    g_MaxPlayers	= ""
    g_SteamID		= ""
end

function PANEL:OnDeactivate()

end

function PANEL:Think()

end

function PANEL:StatusChanged( strStatus )
	print("> ",strStatus)
end

function PANEL:CheckForStatusChanges()
	local str = GetLoadStatus()
	if ( !str ) then return end

	str = string.Trim( str )
	str = string.Trim( str, "\n" )
	str = string.Trim( str, "\t" )

	str = string.gsub( str, ".bz2", "" )
	str = string.gsub( str, ".ztmp", "" )
	str = string.gsub( str, "\\", "/" )

	if ( self.OldStatus && self.OldStatus == str ) then return end

	self.OldStatus = str
	self:StatusChanged( str )
end

local factor = vgui.RegisterTable( PANEL, "EditablePanel" )


local pnl = nil

function GetLoadPanel()
	print"GetLoadPanel"

	if ( !IsValid( pnl ) ) then
		pnl = vgui.CreateFromTable( factor )
	end

	return pnl

end

function UpdateLoadPanel( strJavascript )
	print("UpdateLoadPanel",strJavascript)
end

function GameDetails( servername, serverurl, mapname, maxplayers, steamid, gm )
	if ( engine.IsPlayingDemo() ) then return end

	MsgN( "servername ",servername )
	MsgN( "serverurl ",serverurl )

	serverurl = serverurl:Replace( "%s", steamid )
	serverurl = serverurl:Replace( "%m", mapname )

	g_ServerName	= servername
	g_MapName		= mapname
	g_ServerURL		= serverurl
	g_MaxPlayers	= maxplayers
	g_SteamID		= steamid
	g_GameMode		= gm

	MsgN( "gamemode ",gm )
	MsgN( "mapname ",mapname )
	MsgN( "maxplayers ",maxplayers )
	MsgN( "steamid ",steamid )

	_G.co_loadinfo.name = servername
	_G.co_loadinfo.map = mapname
	_G.co_loadinfo.gm = gm
end