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

function PANEL:RefreshDownloadables()

	self.Downloadables = GetDownloadables()
	if ( !self.Downloadables ) then return end

	local iDownloading = 0
	local iFileCount = 0
	for k, v in pairs( self.Downloadables ) do

		v = string.gsub( v, ".bz2", "" )
		v = string.gsub( v, ".ztmp", "" )
		v = string.gsub( v, "\\", "/" )

		iDownloading = iDownloading + self:FileNeedsDownload( v )
		iFileCount = iFileCount + 1

	end

	if ( iDownloading == 0 ) then return end


	hook.Run("LoadingStatus", "Files Needed: "..iDownloading)
	hook.Run("LoadingStatus", "Total Files: "..iFileCount)
	--self:RunJavascript( "if ( window.SetFilesNeeded ) SetFilesNeeded( " .. iDownloading .. ")" );
	--self:RunJavascript( "if ( window.SetFilesTotal ) SetFilesTotal( " .. iFileCount .. ")" );

end

function PANEL:FileNeedsDownload( filename )

	local iReturn = 0
	local bExists = file.Exists( filename, "GAME" )
	if ( bExists ) then	return 0 end

	return 1

end

--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:CheckDownloadTables()

	local NumDownloadables = NumDownloadables()
	if ( !NumDownloadables ) then return end

	if ( self.NumDownloadables && NumDownloadables == self.NumDownloadables ) then return end

	self.NumDownloadables = NumDownloadables
	self:RefreshDownloadables()

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

	--MsgN( "servername ",servername )
	--MsgN( "serverurl ",serverurl )

	hook.Run("LoadingStatus", "Name: "..servername)
	hook.Run("LoadingStatus", "Loading URL: "..serverurl)

	serverurl = serverurl:Replace( "%s", steamid )
	serverurl = serverurl:Replace( "%m", mapname )

	g_ServerName	= servername
	g_MapName		= mapname
	g_ServerURL		= serverurl
	g_MaxPlayers	= maxplayers
	g_SteamID		= steamid
	g_GameMode		= gm

	--MsgN( "gamemode ",gm )
	--MsgN( "mapname ",mapname )
	--MsgN( "maxplayers ",maxplayers )
	--MsgN( "steamid ",steamid )

	hook.Run("LoadingStatus", "Gamemode: "..gm)
	hook.Run("LoadingStatus", "Map: "..mapname)
	hook.Run("LoadingStatus", "Max Players: "..maxplayers)

	_G.co_loadinfo.name = servername
	_G.co_loadinfo.map = mapname
	_G.co_loadinfo.gm = gm
end