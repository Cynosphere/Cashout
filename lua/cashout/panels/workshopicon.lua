PANEL.Base = "DPanel"

function PANEL:Init()
    self:SetSize(64, 64)
    self.Size = 64
end

function PANEL:Paint()
    if not self.Material then return end

    DisableClipping(true)

    if self.Material then
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial( self.Material )
        surface.DrawTexturedRect(0, 0, self.Size, self.Size)
    end

    DisableClipping(false)
end


function PANEL:Charging(id, iImageID)
    self.Material = nil

    steamworks.Download(iImageID, false, function(name)
        if name == nil then return end
        if not IsValid(self) then return end

        self.Material = AddonMaterial(name)
    end)
end