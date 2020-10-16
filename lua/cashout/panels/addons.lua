local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrW() - 512, ScrH() - 256)
    self:SetTitle("Addons")
    self:SetIcon("icon16/plugin.png")

    self:Center()
    self:MakePopup()

    self.Side = vgui.Create("DPanel",self)
    self.Side:Dock(LEFT)
    self.Side:SetWide(192)
    self.Side:DockMargin(4,4,4,4)

    self.List = vgui.Create("DScrollPanel",self)
    self.List:Dock(FILL)
    self.List:DockMargin(4,4,4,4)

    self.btnMaxim:SetVisible(false)
    self.btnMinim:SetVisible(false)
    self.btnClose.alpha = 128

    self.lblTitle.UpdateColors = function(s)
        s:SetColor(Color(255,255,255))
    end

    --[[function self.btnClose:Paint(w,h)
        self.alpha = Lerp(0.05,self.alpha,self.Hovered and 255 or 128)
        draw.RoundedBox(0,0,2,w,20,Color(244,67,54,self.alpha))
        draw.SimpleText("r", "Marlett", w/2, h/2, Color(255,255,255,self.alpha), 1, 1)
    end--]]

    self.EnableAll = vgui.Create("DButton",self.Side)
    self.EnableAll:SetText("#addons.enableall")
    self.EnableAll:SetIcon("icon16/tick.png")
    self.EnableAll:Dock(TOP)
    self.EnableAll:SetTall(24)
    self.EnableAll:DockMargin(4,4,4,4)
    function self.EnableAll.DoClick(btn)
        for k,v in next,engine.GetAddons() do
            steamworks.SetShouldMountAddon(v.wsid or v.file,true)
        end
        steamworks.ApplyAddons()

        self.List:Clear()
        self:RefreshWS()
    end

    self.DisableAll = vgui.Create("DButton",self.Side)
    self.DisableAll:SetText("#addons.disableall")
    self.DisableAll:SetIcon("icon16/cross.png")
    self.DisableAll:Dock(TOP)
    self.DisableAll:SetTall(24)
    self.DisableAll:DockMargin(4,4,4,4)
    function self.DisableAll.DoClick(btn)
        for k,v in next,engine.GetAddons() do
            steamworks.SetShouldMountAddon(v.wsid or v.file,false)
        end
        steamworks.ApplyAddons()

        self.List:Clear()
        self:RefreshWS()
    end

    self.Workshop = vgui.Create("DButton",self.Side)
    self.Workshop:SetText("Open Workshop")
    self.Workshop:SetIcon("vgui/resource/icon_steam")
    self.Workshop:Dock(TOP)
    self.Workshop:SetTall(24)
    self.Workshop:DockMargin(4,4,4,4)
    function self.Workshop.DoClick(btn) gui.OpenURL("http://steamcommunity.com/app/4000/workshop/") end

    self:RefreshWS()
end

function PANEL:RefreshWS()
    local addons = engine.GetAddons()
    table.sort(addons, function(a,b)
        if a.mounted == b.mounted then
            if a.title and b.title then
                return a.title < b.title
            end
        else
            return (a.mounted and 0 or 1) < (b.mounted and 0 or 1)
        end
    end)
    for _, data in ipairs(addons) do
        self:CreateAddonInfo(data)
    end

    self.addonCount = #addons
end

local queue = {}
local processed = {}
local iconThread
local function processIconQueue(pnl)
    if table.Count(processed) == pnl.addonCount then
        coroutine.yield()
        pnl.iconsFinished = true
        table.Empty(queue)
        table.Empty(processed)
        return
    end

    for i, data in ipairs(queue) do
        if processed[data.wsid] then continue end
        steamworks.FileInfo(data.wsid, function(res)
            steamworks.Download(res.previewid, true, function(f)
                if IsValid(data.panel) then
                    data.panel:SetMaterial(AddonMaterial(f))
                end
                processed[data.wsid] = true
            end)
        end)

        coroutine.wait(FrameTime())
    end
end

function PANEL:Think()
    if not iconThread or not coroutine.resume(iconThread) and not self.iconsFinished then
        iconThread = coroutine.create(processIconQueue)
        coroutine.resume(iconThread, self)
    end
end

function PANEL:QueueWorkshopIcon(pnl, wsid)
    queue[#queue + 1] = {
        wsid = wsid,
        panel = pnl,
    }
end

function PANEL:CreateAddonInfo(data)
        local pnl = vgui.Create("DPanel")
        pnl:SetTall(128)
        pnl:Dock(TOP)
        pnl:DockMargin(0,0,4,4)
        pnl:SetBackgroundColor(data.mounted and Color(128,192,128) or Color(255,255,255))

        local img = vgui.Create("DImage",pnl)
        img:Dock(LEFT)
        img:SetWide(128)
        img:SetTall(128)
        img:SetImage("gui/noicon.png")
        self:QueueWorkshopIcon(img, data.wsid)

        local name = vgui.Create("DLabel",pnl)
        name:SetText(data.title or data.file)
        name:SetFont("DermaLarge")
        name:SetDark(true)
        name:Dock(TOP)
        name:SetTall(32)
        name:DockMargin(2,0,0,0)

        local div = vgui.Create("EditablePanel",pnl)
        div:Dock(TOP)
        div:SetTall(64)

        local mnt = vgui.Create("DButton",pnl)
        mnt:SetTall(32)
        mnt:SetWide(128)
        mnt:Dock(RIGHT)
        mnt:DockMargin(4,4,4,4)
        mnt:SetIcon(data.mounted and "icon16/cross.png" or "icon16/tick.png")
        mnt:SetText(data.mounted and "Disable" or "Enable")
        mnt.DoClick = function(s)
            print("[Addon Mount]", data.file, not data.mounted)
            local old = steamworks.ShouldMountAddon(data.wsid)
            steamworks.SetShouldMountAddon(data.wsid, not ata.mounted)
            steamworks.ApplyAddons()
            local new = steamworks.ShouldMountAddon(data.wsid)

            if old == new then
                print("Warning: ", "could not toggle", data.file)
            else
                data.mounted = new

                if new == true then
                    s:SetIcon("icon16/cross.png")
                    s:SetText("Disable")
                    pnl:SetBackgroundColor(Color(128,192,128))
                else
                    s:SetIcon("icon16/tick.png")
                    s:SetText("Enable")
                    pnl:SetBackgroundColor(Color(255,255,255))
                end
            end
        end

        local rem = vgui.Create("DButton",pnl)
        rem:SetTall(32)
        rem:SetWide(128)
        rem:Dock(RIGHT)
        rem:DockMargin(4,4,4,4)
        rem:SetIcon("icon16/delete.png")
        rem:SetText("Unsubscribe")
        rem.DoClick = function(s)
            print("Unsubscribe",data.wsid)
            steamworks.Unsubscribe(data.wsid)
            pnl:Remove()
            self.List:PerformLayout()
        end

        local ws = vgui.Create("DButton",pnl)
        ws:SetTall(32)
        ws:SetWide(128)
        ws:Dock(LEFT)
        ws:DockMargin(4,4,4,4)
        ws:SetIcon("vgui/resource/icon_steam")
        ws:SetText("Workshop")
        ws.DoClick = function(s)
            gui.OpenURL("http://steamcommunity.com/sharedfiles/filedetails/?id=" .. data.wsid)
        end
        self.List:Add(pnl)
    end

--[[function PANEL:Paint(w,h)
    draw.RoundedBox(0,0,0,w,h,Color(0,0,0,240))
    draw.RoundedBox(0,0,0,w,24,Color(0,128,0))
end--]]

vgui.Register( "CashoutAddons", PANEL, "DFrame" )

function CashoutAddons()
    if IsValid(_G.AddonsMenu) then _G.AddonsMenu:Remove() end
    _G.AddonsMenu = vgui.Create("CashoutAddons")
end