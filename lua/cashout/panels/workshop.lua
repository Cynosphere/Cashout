PANEL.Base = "DPanel"

local pnlRocket = vgui.RegisterFile("workshopicon.lua")

surface.CreateFont( "CashoutWS", {
	font		= Roboto,
	size		= 24,
	weight		= 500
})

AccessorFunc( PANEL, "m_bDrawProgress", "DrawProgress", FORCE_BOOL )

function PANEL:Init()
	self.Label = "Updating Subscriptions..."

    self.ProgressLabel = ""
    self.TotalsLabel = ""

	self:SetDrawProgress( false )

	self.Progress = 0
	self.TotalProgress = 0
end

function PANEL:PerformLayout()
	self:SetSize( 400, 80 )
	self:Center()
	self:AlignBottom( 16 )
end

function PANEL:Spawn()
	self:PerformLayout()
end

function PANEL:PrepareDownloading( id, title, iSize )
	if self.Rocket then self.Rocket:Remove() end

	self.Rocket = self:Add( pnlRocket )
	self.Rocket:Dock( LEFT )
	self.Rocket:MoveToBack()
	self.Rocket:DockMargin(12,4,4,4)
end

function PANEL:StartDownloading( id, iImageID, title, iSize )
	self.Label = "Downloading \"" .. title .. "\""

	self.Rocket:Charging( id, iImageID )
	self:SetDrawProgress( true )

	self:UpdateProgress( 0, iSize )
end

function PANEL:FinishedDownloading( id, title )
	self.Progress = 0
end

function PANEL:Paint(width,height)
    local w = (self:GetWide() - 64 - 64 - 25)
    local x = 80

	draw.RoundedBox( 4, 0, 0, width, height, Color(0,0,0,128) )
    draw.RoundedBoxEx(4, 0, 0, 8, height, Color(0,192,0), true, false, true, false)

    draw.SimpleText(self.Label, "CashoutWS", ((x+32)+w/2)+1, 9, Color(0,0,0,200), 1)
    draw.SimpleText(self.Label, "CashoutWS", (x+32)+w/2, 8, Color(255,255,255), 1)

	if self:GetDrawProgress() then
		draw.RoundedBox(4, x+32, 36, w, 20, Color( 0, 0, 0, 200 ) )
		draw.RoundedBox(4, x+32, 36, w * math.Clamp( self.Progress, 0.05, 1 ), 20, Color(0,192,0))

        draw.SimpleText(self.ProgressLabel, "DermaDefault", (x+32)+w/2+2, 38+1, Color(0,0,0,200), 1)
        draw.SimpleText(self.ProgressLabel, "DermaDefault", (x+32)+w/2, 38, Color(255,255,255), 1)

        draw.SimpleText(self.TotalsLabel, "DermaDefault", ((x+32)+w/2)+1, 61, Color(0,0,0,200), 1)
        draw.SimpleText(self.TotalsLabel, "DermaDefault", ((x+32)+w/2), 60, Color(255,255,255), 1)
	end
end

function PANEL:UpdateProgress( downloaded, expected )
	self.Progress = downloaded / expected

	if ( self.Progress > 0 ) then
		self.ProgressLabel = Format( "%.0f%%", (self.Progress) * 100 ) .. " of " .. string.NiceSize( expected )
	else
		self.ProgressLabel = string.NiceSize( expected )
	end
end

function PANEL:ExtractProgress( title, percent )
	self.Label = "Extracting \"" .. title .. "\""
	self.Progress = percent / 100

	if ( self.Progress > 0 ) then
		self.ProgressLabel = Format( "%.0f%%", percent )
	else
		self.ProgressLabel = "0%"
	end
end

function PANEL:UpdateTotalProgress( completed, iTotal )
	self.TotalsLabel = "Addon " .. completed .. " of " .. iTotal
	self.TotalProgress = completed / iTotal
end

function PANEL:SubscriptionsProgress( iCurrent, iTotal )
	self.Label = "Fetching Subscriptions..."
	self:SetDrawProgress( true )

	self.Progress = iCurrent / iTotal

	self.ProgressLabel = iCurrent .. " of " .. iTotal
end
