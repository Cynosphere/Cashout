g_ServerName = g_ServerName or ""
g_MapName    = g_MapName    or ""
g_ServerURL  = g_ServerURL  or ""
g_MaxPlayers = g_MaxPlayers or ""
g_SteamID    = g_SteamID    or ""

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


	hook.Run("LoadingStatus", "Files Needed: " .. iDownloading)
	hook.Run("LoadingStatus", "Total Files: " .. iFileCount)
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

function GameDetails( servername, serverurl, mapname, maxplayers, steamid, gm, ... )
	if ( engine.IsPlayingDemo() ) then return end

	hook.Run("LoadingStatus", "Name: " .. servername)
	hook.Run("LoadingStatus", "Loading URL: " .. serverurl)

	serverurl = serverurl:Replace( "%s", steamid )
	serverurl = serverurl:Replace( "%m", mapname )

	if servername ~= "" then
		g_ServerName = servername
	end
	if mapname ~= "" then
		g_MapName = mapname
	end
	if serverurl ~= "" then
		g_ServerURL = serverurl
	end
	if maxplayers ~= "" then
		g_MaxPlayers = maxplayers
	end
	if steamid ~= "" then
		g_SteamID = steamid
	end
	if gm ~= "" then
		g_GameMode = gm
	end

	hook.Run("LoadingStatus", "Gamemode: " .. gm)
	hook.Run("LoadingStatus", "Map: " .. mapname)
	hook.Run("LoadingStatus", "Max Players: " .. maxplayers)
end