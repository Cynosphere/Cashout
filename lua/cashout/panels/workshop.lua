PANEL.Base = "DPanel"

local pnlRocket = vgui.RegisterFile("workshopicon.lua")

AccessorFunc( PANEL, "m_bDrawProgress", "DrawProgress", FORCE_BOOL )

surface.CreateFont( "CashoutWS24", {
    font   = "Roboto",
    size   = 24,
    weight = 500
})
surface.CreateFont( "CashoutWS20", {
    font   = "Roboto",
    size   = 20,
    weight = 500
})

function PANEL:Init()
    self.Label = "Updating Subscriptions..."

    self.ProgressLabel = ""
    self.TotalsLabel = ""

    self:SetDrawProgress( false )

    self.Progress = 0
    self.TotalProgress = 0
end

function PANEL:Spawn()
    self:PerformLayout()
end

function PANEL:PrepareDownloading( id, title, iSize )
    if self.Rocket then self.Rocket:Remove() end

    self.Rocket = self:Add( pnlRocket )
    self.Rocket:Dock(LEFT)
    self.Rocket:MoveToBack()
    self.Rocket:DockMargin(8, 8, 8, 8)

    self:PreformLayout()
end

function PANEL:StartDownloading( id, iImageID, title, iSize )
    self.Label = ("Downloading \"%s\""):format(title)

    self.Rocket:Charging( id, iImageID )
    self:SetDrawProgress( true )

    self:UpdateProgress( 0, iSize )

    self:PreformLayout()
end

function PANEL:FinishedDownloading( id, title )
    self.Progress = 0
end

function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, Color(26, 29, 35, 128))

    surface.SetFont("CashoutWS24")
    local lw, lh = surface.GetTextSize(self.Label)
    surface.SetFont("DermaDefault")
    local pw, ph = surface.GetTextSize(self.ProgressLabel)
    surface.SetFont("CashoutWS20")
    local tw, th = surface.GetTextSize(self.TotalsLabel)

    local wnoimg = w - 24 - (h - 16)

    draw.SimpleText(self.Label, "CashoutWS24", 16 + (h - 16), 8, Color(255,255,255))

    if self:GetDrawProgress() then

        local col = HSVToColor(CurTime() * 30 % 360, 0.375, 0.75)
        local col2 = HSVToColor(CurTime() * 30 % 360, 0.5, 0.375)

        draw.RoundedBox(4, 16 + (h - 16), 12 + lh, wnoimg, 16, col2)
        draw.RoundedBox(4, 16 + (h - 16), 12 + lh, wnoimg * math.Clamp(self.Progress, 0.05, 1), 16, col)

        draw.SimpleText(self.ProgressLabel, "DermaDefault", 16 + (h - 16) + (wnoimg / 2), 12 + lh, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        draw.SimpleText(self.TotalsLabel, "CashoutWS20", 16 + (h - 16) + (wnoimg / 2), 32 + lh, Color(255, 255, 255), TEXT_ALIGN_CENTER)
    end
end

function PANEL:UpdateProgress( downloaded, expected )
    self.Progress = downloaded / expected

    if ( self.Progress > 0 ) then
        self.ProgressLabel = Format( "%.0f%%", (self.Progress) * 100 ) .. " of " .. string.NiceSize( expected )
    else
        self.ProgressLabel = string.NiceSize( expected )
    end

    self:PreformLayout()
end

function PANEL:ExtractProgress( title, percent )
    self.Label = "Extracting \"" .. title .. "\""
    self.Progress = percent / 100

    if ( self.Progress > 0 ) then
        self.ProgressLabel = Format( "%.0f%%", percent )
    else
        self.ProgressLabel = "0%"
    end

    self:PreformLayout()
end

function PANEL:UpdateTotalProgress( completed, iTotal )
    self.TotalsLabel = "Addon " .. completed .. " of " .. iTotal
    self.TotalProgress = completed / iTotal

    self:PreformLayout()
end

function PANEL:SubscriptionsProgress( iCurrent, iTotal )
    self.Label = "Fetching Subscriptions..."
    self:SetDrawProgress( true )

    self.Progress = iCurrent / iTotal

    self.ProgressLabel = iCurrent .. " of " .. iTotal

    self:PreformLayout()
end

function PANEL:PreformLayout()
    local w, h = 384, 80

    surface.SetFont("CashoutWS24")
    local lw, lh = surface.GetTextSize(self.Label)
    surface.SetFont("DermaDefault")
    local pw, ph = surface.GetTextSize(self.ProgressLabel)
    surface.SetFont("CashoutWS20")
    local tw, th = surface.GetTextSize(self.TotalsLabel)

    w = math.max(w, 16 + (h - 16) + lw + 8)
    w = math.max(w, 16 + (h - 16) + pw + 8)
    w = math.max(w, 16 + (h - 16) + tw + 8)

    self:SetSize(w, h)
    self:Center()
    self:AlignBottom(16)
end