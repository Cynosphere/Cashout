local pnlWorkshop = vgui.RegisterFile("cashout/panels/workshop.lua")
local vgui_workshop = nil

hook.Add("WorkshopStart", "WorkshopStart", function()
    if IsValid(vgui_workshop) then vgui_workshop:Remove() end

    vgui_workshop = GetOverlayPanel():Add( pnlWorkshop )
end)

hook.Add("WorkshopEnd", "WorkshopEnd", function()
    if not IsValid(vgui_workshop) then return end

    vgui_workshop:Remove()
end)

hook.Add("WorkshopDownloadFile", "WorkshopDownloadFile", function( id, iImageID, title, iSize )
    if not IsValid(vgui_workshop) then
        vgui_workshop = GetOverlayPanel():Add( pnlWorkshop )
    end

    vgui_workshop:PrepareDownloading( id, title, iSize )
    vgui_workshop:StartDownloading( id, iImageID, title, iSize )
end)

hook.Add("WorkshopDownloadedFile", "WorkshopDownloadedFile", function( id, title, authorid )

    if not IsValid(vgui_workshop) then return end

    vgui_workshop:FinishedDownloading(id, title, authorid)

end)

hook.Add("WorkshopDownloadProgress", "WorkshopDownloadProgress", function( id, iImageID, title, downloaded, expected )

    if not IsValid(vgui_workshop) then
        vgui_workshop = GetOverlayPanel():Add( pnlWorkshop )
        vgui_workshop:PrepareDownloading( id, title, expected )
        vgui_workshop:StartDownloading( id, iImageID, title, expected )
    end

    vgui_workshop:UpdateProgress( downloaded, expected )

end)

hook.Add("WorkshopExtractProgress", "WorkshopExtractProgress", function( id, iImageID, title, percent )

    if not IsValid( vgui_workshop ) then
        vgui_workshop = GetOverlayPanel():Add( pnlWorkshop )
        vgui_workshop:PrepareDownloading( id, title, percent )
        vgui_workshop:StartDownloading( id, iImageID, title, percent )
    end

    vgui_workshop:ExtractProgress( title, percent )

end)

hook.Add("WorkshopDownloadTotals", "WorkshopDownloadTotals", function( iRemain, iTotal )
    if not IsValid( vgui_workshop ) then
        vgui_workshop = GetOverlayPanel():Add( pnlWorkshop )
    end

    --
    -- Finished..
    --
    if ( iRemain == iTotal ) then
        return
    end

    local completed = iTotal - iRemain

    if IsValid( vgui_workshop ) then
        vgui_workshop:UpdateTotalProgress( completed, iTotal )
    end
end)

hook.Add("WorkshopSubscriptionsProgress", "WorkshopSubscriptionsProgress", function( iCurrent, iMax )
    if not IsValid(vgui_workshop) then
        vgui_workshop = GetOverlayPanel():Add(pnlWorkshop)
    end

    vgui_workshop:SubscriptionsProgress(iCurrent, iMax)
end)

