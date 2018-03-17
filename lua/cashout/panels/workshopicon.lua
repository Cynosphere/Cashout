PANEL.Base = "DPanel"

function PANEL:Init()
	self:SetSize( 72, 72 )
	self.Size = 72
end

function PANEL:Paint()
	if ( !self.Material ) then return end

	DisableClipping( true )

    if ( self.Material ) then
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial( self.Material )
        surface.DrawTexturedRect(0, 0, self.Size, self.Size)
    end

	DisableClipping( false )
end


function PANEL:Charging( id, iImageID )
	self.Material = nil

	steamworks.Download( iImageID, false, function( name )

		if ( name == nil ) then return end
		if ( !IsValid( self ) ) then return end

		self.Material = AddonMaterial( name )

	end)
end