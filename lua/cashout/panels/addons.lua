Cashout.AddonCache = Cashout.AddonCache or {}

local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrW() - 512, ScrH() - 256)
    self:SetTitle("Addons")
    self:SetIcon("icon16/plugin.png")

    self:Center()
    self:MakePopup()

    self.btnMaxim:SetVisible(false)
    self.btnMinim:SetVisible(false)

    self.Tabs = self:Add("DPropertySheet")
    self.Tabs:Dock(FILL)

    self.Subscribed = vgui.Create("EditablePanel")
    self.Tabs:AddSheet("Subscribed", self.Subscribed, "icon16/tick.png")

    self.Workshop = vgui.Create("DButton", self.Tabs.tabScroller)
    self.Workshop:SetText("Open Workshop")
    self.Workshop:SetIcon("vgui/resource/icon_steam")
    self.Workshop:SetWide(108)
    self.Workshop:SetTall(24)
    self.Workshop:SetContentAlignment(4)
    function self.Workshop.PerformLayout(s, w, h) s.m_Image:SetPos(4, (h - s.m_Image:GetTall()) / 2) s:SetTextInset(24, 0) DLabel.PerformLayout(s, w, h) end
    function self.Workshop.DoClick() gui.OpenURL("http://steamcommunity.com/app/4000/workshop/") end

    function self.Tabs.tabScroller.PerformLayout(s)
        local w, h = s:GetSize()

        s.pnlCanvas:SetTall( h )

        local x = 0

        for k, v in pairs( s.Panels ) do
            if not IsValid(v) then continue end
            if not v:IsVisible() then continue end

            v:SetPos( x, 0 )
            v:SetTall( h )
            if ( v.ApplySchemeSettings ) then v:ApplySchemeSettings() end

            x = x + v:GetWide() - s.m_iOverlap

        end

        s.pnlCanvas:SetWide( x + s.m_iOverlap )

        if ( w < s.pnlCanvas:GetWide() ) then
            s.OffsetX = math.Clamp( s.OffsetX, 0, s.pnlCanvas:GetWide() - s:GetWide() )
        else
            s.OffsetX = 0
        end

        s.pnlCanvas.x = s.OffsetX * -1

        self.Workshop:SetPos(s:GetWide() - self.Workshop:GetWide(), 0)

        s.btnLeft:SetSize( 15, 15 )
        s.btnLeft:AlignLeft( 4 )
        s.btnLeft:AlignBottom( 5 )

        s.btnRight:SetSize( 15, 15 )
        s.btnRight:AlignRight( 4 )
        s.btnRight:AlignBottom( 5 )
        s.btnRight:SetPos(s.btnRight.x - self.Workshop:GetWide(), s.btnRight.y)

        s.btnLeft:SetVisible( s.pnlCanvas.x < 0 )
        s.btnRight:SetVisible( s.pnlCanvas.x + s.pnlCanvas:GetWide() > s:GetWide() )

    end

    self.Subscribed.Footer = vgui.Create("DPanel", self.Subscribed)
    self.Subscribed.Footer:Dock(BOTTOM)
    self.Subscribed.Footer:SetTall(32)
    self.Subscribed.Footer:DockMargin(4,4,4,4)

    self.Subscribed.List = vgui.Create("DScrollPanel", self.Subscribed)
    self.Subscribed.List:Dock(FILL)
    self.Subscribed.List:DockMargin(4,4,4,4)

    self.Subscribed.EnableAll = vgui.Create("DButton", self.Subscribed.Footer)
    self.Subscribed.EnableAll:SetText("#addons.enableall")
    self.Subscribed.EnableAll:SetIcon("icon16/tick.png")
    self.Subscribed.EnableAll:Dock(LEFT)
    self.Subscribed.EnableAll:SetTall(24)
    self.Subscribed.EnableAll:SetWide(128)
    self.Subscribed.EnableAll:DockMargin(4,4,4,4)
    function self.Subscribed.EnableAll.DoClick(btn)
        for k,v in next,engine.GetAddons() do
            steamworks.SetShouldMountAddon(v.wsid or v.file,true)
        end
        steamworks.ApplyAddons()

        self.Subscribed.List:Clear()
        self:RefreshLocalAddons()
    end

    self.Subscribed.DisableAll = vgui.Create("DButton", self.Subscribed.Footer)
    self.Subscribed.DisableAll:SetText("#addons.disableall")
    self.Subscribed.DisableAll:SetIcon("icon16/cross.png")
    self.Subscribed.DisableAll:Dock(LEFT)
    self.Subscribed.DisableAll:SetTall(24)
    self.Subscribed.DisableAll:SetWide(128)
    self.Subscribed.DisableAll:DockMargin(4,4,4,4)
    function self.Subscribed.DisableAll.DoClick(btn)
        for k,v in next,engine.GetAddons() do
            steamworks.SetShouldMountAddon(v.wsid or v.file,false)
        end
        steamworks.ApplyAddons()

        self.Subscribed.List:Clear()
        self:RefreshLocalAddons()
    end

    self.Subscribed.Refresh = vgui.Create("DButton", self.Subscribed.Footer)
    self.Subscribed.Refresh:SetText("Refresh")
    self.Subscribed.Refresh:SetIcon("icon16/arrow_refresh.png")
    self.Subscribed.Refresh:Dock(RIGHT)
    self.Subscribed.Refresh:SetTall(24)
    self.Subscribed.Refresh:SetWide(128)
    self.Subscribed.Refresh:DockMargin(4,4,4,4)
    function self.Subscribed.Refresh.DoClick(btn)
        self.Subscribed.List:Clear()
        self:RefreshLocalAddons()
    end

    self:RefreshLocalAddons()

    ----

    self.Popular = vgui.Create("EditablePanel")
    self.Tabs:AddSheet("Popular", self.Popular, "icon16/chart_bar.png")
    self.Popular.List = vgui.Create("DScrollPanel", self.Popular)
    self.Popular.List:Dock(FILL)
    self.Popular.List:DockMargin(4,4,4,4)

    self.Popular.Footer = vgui.Create("EditablePanel", self.Popular)
    self.Popular.Footer:Dock(BOTTOM)
    self.Popular.Footer:SetTall(32)
    self.Popular.Footer:DockMargin(4,4,4,4)

    self.Popular.Refresh = vgui.Create("DButton", self.Popular.Footer)
    self.Popular.Refresh:SetText("Refresh")
    self.Popular.Refresh:SetIcon("icon16/arrow_refresh.png")
    self.Popular.Refresh:Dock(RIGHT)
    self.Popular.Refresh:SetTall(24)
    self.Popular.Refresh:SetWide(128)
    self.Popular.Refresh:DockMargin(4,4,4,4)
    function self.Popular.Refresh.DoClick(btn)
        self.Popular.List:Clear()
        self:GetAddonList(self.Popular.List, "popular")
    end

    ----

    self.Top = vgui.Create("EditablePanel")
    self.Tabs:AddSheet("Top", self.Top, "icon16/arrow_up.png")
    self.Top.List = vgui.Create("DScrollPanel", self.Top)
    self.Top.List:Dock(FILL)
    self.Top.List:DockMargin(4,4,4,4)

    self.Top.Footer = vgui.Create("EditablePanel", self.Top)
    self.Top.Footer:Dock(BOTTOM)
    self.Top.Footer:SetTall(32)
    self.Top.Footer:DockMargin(4,4,4,4)

    self.Top.Refresh = vgui.Create("DButton", self.Top.Footer)
    self.Top.Refresh:SetText("Refresh")
    self.Top.Refresh:SetIcon("icon16/arrow_refresh.png")
    self.Top.Refresh:Dock(RIGHT)
    self.Top.Refresh:SetTall(24)
    self.Top.Refresh:SetWide(128)
    self.Top.Refresh:DockMargin(4,4,4,4)
    function self.Top.Refresh.DoClick(btn)
        self.Top.List:Clear()
        self:GetAddonList(self.Top.List, "top")
    end

    ----

    self.Latest = vgui.Create("EditablePanel")
    self.Tabs:AddSheet("Latest", self.Latest, "icon16/new.png")
    self.Latest.List = vgui.Create("DScrollPanel", self.Latest)
    self.Latest.List:Dock(FILL)
    self.Latest.List:DockMargin(4,4,4,4)

    self.Latest.Footer = vgui.Create("EditablePanel", self.Latest)
    self.Latest.Footer:Dock(BOTTOM)
    self.Latest.Footer:SetTall(32)
    self.Latest.Footer:DockMargin(4,4,4,4)

    self.Latest.Refresh = vgui.Create("DButton", self.Latest.Footer)
    self.Latest.Refresh:SetText("Refresh")
    self.Latest.Refresh:SetIcon("icon16/arrow_refresh.png")
    self.Latest.Refresh:Dock(RIGHT)
    self.Latest.Refresh:SetTall(24)
    self.Latest.Refresh:SetWide(128)
    self.Latest.Refresh:DockMargin(4,4,4,4)
    function self.Latest.Refresh.DoClick(btn)
        self.Latest.List:Clear()
        self:GetAddonList(self.Latest.List, "latest")
    end

    ----

    self.Following = vgui.Create("EditablePanel")
    self.Tabs:AddSheet("Following", self.Following, "icon16/find.png")
    self.Following.List = vgui.Create("DScrollPanel", self.Following)
    self.Following.List:Dock(FILL)
    self.Following.List:DockMargin(4,4,4,4)

    self.Following.Footer = vgui.Create("EditablePanel", self.Following)
    self.Following.Footer:Dock(BOTTOM)
    self.Following.Footer:SetTall(32)
    self.Following.Footer:DockMargin(4,4,4,4)

    self.Following.Refresh = vgui.Create("DButton", self.Following.Footer)
    self.Following.Refresh:SetText("Refresh")
    self.Following.Refresh:SetIcon("icon16/arrow_refresh.png")
    self.Following.Refresh:Dock(RIGHT)
    self.Following.Refresh:SetTall(24)
    self.Following.Refresh:SetWide(128)
    self.Following.Refresh:DockMargin(4,4,4,4)
    function self.Following.Refresh.DoClick(btn)
        self.Following.List:Clear()
        self:GetAddonList(self.Following.List, "following")
    end

    ----

    self.Favorites = vgui.Create("EditablePanel")
    self.Tabs:AddSheet("Favorites", self.Favorites, "icon16/star.png")
    self.Favorites.List = vgui.Create("DScrollPanel", self.Favorites)
    self.Favorites.List:Dock(FILL)
    self.Favorites.List:DockMargin(4,4,4,4)

    self.Favorites.Footer = vgui.Create("EditablePanel", self.Favorites)
    self.Favorites.Footer:Dock(BOTTOM)
    self.Favorites.Footer:SetTall(32)
    self.Favorites.Footer:DockMargin(4,4,4,4)

    self.Favorites.Refresh = vgui.Create("DButton", self.Favorites.Footer)
    self.Favorites.Refresh:SetText("Refresh")
    self.Favorites.Refresh:SetIcon("icon16/arrow_refresh.png")
    self.Favorites.Refresh:Dock(RIGHT)
    self.Favorites.Refresh:SetTall(24)
    self.Favorites.Refresh:SetWide(128)
    self.Favorites.Refresh:DockMargin(4,4,4,4)
    function self.Favorites.Refresh.DoClick(btn)
        self.Favorites.List:Clear()
        self:GetAddonList(self.Favorites.List, "favorites")
    end

    ----

    self.FriendFavorites = vgui.Create("EditablePanel")
    local tab = self.Tabs:AddSheet("Friend Favorites", self.FriendFavorites, "icon16/star.png")
    tab.Tab.SubImage = vgui.Create("DImage", tab.Tab.Image)
    tab.Tab.SubImage:SetImage("icon16/group.png")
    tab.Tab.SubImage:SetSize(12, 12)
    local w, h = tab.Tab.Image:GetSize()
    tab.Tab.SubImage:SetPos(w - 12, h - 12)
    self.FriendFavorites.List = vgui.Create("DScrollPanel", self.FriendFavorites)
    self.FriendFavorites.List:Dock(FILL)
    self.FriendFavorites.List:DockMargin(4,4,4,4)

    self.FriendFavorites.Footer = vgui.Create("EditablePanel", self.FriendFavorites)
    self.FriendFavorites.Footer:Dock(BOTTOM)
    self.FriendFavorites.Footer:SetTall(32)
    self.FriendFavorites.Footer:DockMargin(4,4,4,4)

    self.FriendFavorites.Refresh = vgui.Create("DButton", self.FriendFavorites.Footer)
    self.FriendFavorites.Refresh:SetText("Refresh")
    self.FriendFavorites.Refresh:SetIcon("icon16/arrow_refresh.png")
    self.FriendFavorites.Refresh:Dock(RIGHT)
    self.FriendFavorites.Refresh:SetTall(24)
    self.FriendFavorites.Refresh:SetWide(128)
    self.FriendFavorites.Refresh:DockMargin(4,4,4,4)
    function self.FriendFavorites.Refresh.DoClick(btn)
        self.FriendFavorites.List:Clear()
        self:GetAddonList(self.FriendFavorites.List, "friendfav")
    end

    ----

    self.Friends = vgui.Create("EditablePanel")
    self.Tabs:AddSheet("Friends", self.Friends, "icon16/group.png")
    self.Friends.List = vgui.Create("DScrollPanel", self.Friends)
    self.Friends.List:Dock(FILL)
    self.Friends.List:DockMargin(4,4,4,4)

    self.Friends.Footer = vgui.Create("EditablePanel", self.Friends)
    self.Friends.Footer:Dock(BOTTOM)
    self.Friends.Footer:SetTall(32)
    self.Friends.Footer:DockMargin(4,4,4,4)

    self.Friends.Refresh = vgui.Create("DButton", self.Friends.Footer)
    self.Friends.Refresh:SetText("Refresh")
    self.Friends.Refresh:SetIcon("icon16/arrow_refresh.png")
    self.Friends.Refresh:Dock(RIGHT)
    self.Friends.Refresh:SetTall(24)
    self.Friends.Refresh:SetWide(128)
    self.Friends.Refresh:DockMargin(4,4,4,4)
    function self.Friends.Refresh.DoClick(btn)
        self.Friends.List:Clear()
        self:GetAddonList(self.Friends.List, "friends")
    end

    ----

    self.Tabs.OnActiveTabChanged = function(s, old, new)
        local pnl = new:GetPanel()
        if pnl == self.Subscribed then
            self.Subscribed.List:Clear()
            self:RefreshLocalAddons()
        elseif pnl == self.Popular then
            self.Popular.List:Clear()
            self:GetAddonList(self.Popular.List, "popular")
        elseif pnl == self.Top then
            self.Top.List:Clear()
            self:GetAddonList(self.Top.List, "top")
        elseif pnl == self.Latest then
            self.Latest.List:Clear()
            self:GetAddonList(self.Latest.List, "latest")
        elseif pnl == self.Following then
            self.Following.List:Clear()
            self:GetAddonList(self.Following.List, "following")
        elseif pnl == self.Favorites then
            self.Favorites.List:Clear()
            self:GetAddonList(self.Favorites.List, "favorites")
        elseif pnl == self.FriendFavorites then
            self.FriendFavorites.List:Clear()
            self:GetAddonList(self.FriendFavorites.List, "friendfav")
        elseif pnl == self.Friends then
            self.Friends.List:Clear()
            self:GetAddonList(self.Friends.List, "friends")
        end
    end
end

function PANEL:RefreshLocalAddons()
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
        self:CreateAddonInfo(self.Subscribed.List, data)
    end

    self.workshopInfoFinished = false
end

local addonLists = {
    popular = {
        type = "trending",
        days = 7
    },
    top = {
        type = "popular",
        days = -1
    },
    latest = {
        type = "latest",
        days = 1
    },
    following = {
        type = "followed",
        days = -1
    },
    favorites = {
        type = "favorite",
        days = -1
    },
    friendfav = {
        type = "friend_favs",
        days = -1
    },
    friends = {
        type = "friends",
        days = -1
    },
}
function PANEL:GetAddonList(parent, type)
    local params = addonLists[type]
    steamworks.GetList(params.type, {"Addon"}, 0, 50, params.days, "0", function(data)
        for _, wsid in ipairs(data.results) do
            self:CreateAddonInfo(parent, {
                subscribed = steamworks.IsSubscribed(wsid),
                wsid = wsid
            })
        end

        self.workshopInfoFinished = false
    end)
end

local LINK_COLOR = Color(68, 151, 206)
local function isURL(str)
    local patterns = {
        "https?://[^%s%\"%>%<]+",
        "ftp://[^%s%\"%>%<]+",
        "steam://[^%s%\"%>%<]+",
        "www%.[^%s%\"]+%.[^%s%\"]+",
    }

    for _, pattern in ipairs(patterns) do
        local start_pos, end_pos = str:find(pattern, 1, false)
        if start_pos then
            return start_pos, end_pos
        end
    end

    return false
end

local parseURL
parseURL = function(pnl, str)
    local sStartPos, sEndPos = str:find("%<url%|(.-)%|(.-)%>", 1, false)
    local sURL, sText = str:match("%<url%|(.-)%|(.-)%>")

    if sStartPos then
        pnl:AppendText(str:sub(1, sStartPos - 1))

        local lastColor = pnl:GetLastColorChange()

        pnl:InsertColorChange(LINK_COLOR)
        pnl:InsertClickableTextStart(sURL)
        pnl:AppendText(sText)
        pnl:InsertClickableTextEnd()

        pnl:InsertColorChange(lastColor)

        parseURL(pnl, str:sub(sEndPos + 1))
        return
    end

    local startPos, endPos = isURL(str)
    if not startPos then
        pnl:AppendText(str)
    else
        local url = str:sub(startPos, endPos)
        pnl:AppendText(str:sub(1, startPos - 1))

        local lastColor = pnl:GetLastColorChange()

        pnl:InsertColorChange(LINK_COLOR)
        pnl:InsertClickableTextStart(url)
        pnl:AppendText(url)
        pnl:InsertClickableTextEnd()

        pnl:InsertColorChange(lastColor)

        parseURL(pnl, str:sub(endPos + 1))
    end
end

local function parseDescription(pnl, desc)
    desc = desc:gsub("%[url=(.-)%](.-)%[/url%]", function(m1, m2) return Format("<url|%s|%s>", m1, m2) end):gsub("%[/?.-%]", "")
    local lines = string.Explode("\n", desc)
    for _, line in ipairs(lines) do
        line = line:Trim():Trim("\t")
        if line == "" then continue end

        parseURL(pnl, line .. "\n")
    end
end

local queue = {}
local processed = {}
local workshopThread
local function processWorkshopQueue(pnl)
    if #queue > 0 and table.Count(processed) == #queue then
        coroutine.yield()
        pnl.workshopInfoFinished = true
        table.Empty(queue)
        table.Empty(processed)
        return
    end

    for i, data in ipairs(queue) do
        if processed[data.wsid] then continue end
        local cache = Cashout.AddonCache[data.wsid]
        if cache and IsValid(data.panel) then
            if IsValid(data.panel.name) then
                data.panel.name:SetText(cache.title)
                data.panel.name:SizeToContents()
                data.panel.author:SetPos(data.panel.name:GetWide() + 8, data.panel.name:GetTall() - 18)
            end
            if IsValid(data.panel.img) and cache.previewImage then
                data.panel.img:SetMaterial(cache.previewImage)
            end
            if IsValid(data.panel.author) and cache.ownerName then
                data.panel.author:SetText("By " .. cache.ownerName)
                data.panel.author:SizeToContents()
            end
            if IsValid(data.panel.desc) then
                parseDescription(data.panel.desc, cache.description)
            end
        else
            steamworks.FileInfo(data.wsid, function(res)
                Cashout.AddonCache[data.wsid] = res
                cache = Cashout.AddonCache[data.wsid]

                if IsValid(data.panel.name) then
                    data.panel.name:SetText(cache.title)
                    data.panel.name:SizeToContents()
                    data.panel.author:SetPos(data.panel.name:GetWide() + 8, data.panel.name:GetTall() - 18)
                end

                if IsValid(data.panel.desc) then
                    parseDescription(data.panel.desc, cache.description)
                end

                steamworks.RequestPlayerInfo(res.owner, function(name)
                    cache.ownerName = name
                    if IsValid(data.panel) and IsValid(data.panel.author) then
                        data.panel.author:SetText("By " .. name)
                        data.panel.author:SizeToContents()
                    end
                end)
                steamworks.Download(res.previewid, true, function(f)
                    cache.previewImage = AddonMaterial(f)
                    if IsValid(data.panel.img) then
                        data.panel.img:SetMaterial(cache.previewImage)
                    end
                end)
            end)
        end

        processed[data.wsid] = true
        coroutine.wait(FrameTime())
    end
end

function PANEL:Think()
    if not workshopThread or not coroutine.resume(workshopThread) and not self.workshopInfoFinished then
        workshopThread = coroutine.create(processWorkshopQueue)
        coroutine.resume(workshopThread, self)
    end
end

function PANEL:QueueWorkshopInfo(pnl, wsid)
    queue[#queue + 1] = {
        wsid = wsid,
        panel = pnl,
    }
end

function PANEL:CreateAddonInfo(parent, data)
    local pnl = vgui.Create("DPanel")
    pnl:SetTall(128)
    pnl:Dock(TOP)
    pnl:DockMargin(0,0,4,4)
    if data.subscribed then
        pnl:SetBackgroundColor(data.subscribed and Color(128,192,128) or Color(255,255,255))
    else
        pnl:SetBackgroundColor(data.mounted and Color(128,192,128) or Color(255,255,255))
    end
    self:QueueWorkshopInfo(pnl, data.wsid)

    pnl.img = vgui.Create("DImage", pnl)
    pnl.img:Dock(LEFT)
    pnl.img:SetWide(128)
    pnl.img:SetTall(128)
    pnl.img:SetImage("gui/noicon.png")

    pnl.btns = vgui.Create("EditablePanel", pnl)
    pnl.btns:Dock(RIGHT)
    pnl.btns:SetWide(128)

    pnl.ws = vgui.Create("DButton", pnl.btns)
    pnl.ws:Dock(TOP)
    pnl.ws:DockMargin(4,4,4,4)
    pnl.ws:SetTall(24)
    pnl.ws:SetIcon("vgui/resource/icon_steam")
    pnl.ws:SetText("Workshop")
    pnl.ws.DoClick = function()
        gui.OpenURL("http://steamcommunity.com/sharedfiles/filedetails/?id=" .. data.wsid)
    end

    pnl.rem = vgui.Create("DButton", pnl.btns)
    pnl.rem:SetTall(24)
    pnl.rem:Dock(BOTTOM)
    pnl.rem:DockMargin(4,4,4,4)
    if data.subscribed ~= nil then
        if data.subscribed then
            pnl.rem:SetIcon("icon16/delete.png")
            pnl.rem:SetText("Unsubscribe")
        else
            pnl.rem:SetIcon("icon16/add.png")
            pnl.rem:SetText("Subscribe")
        end
    else
        pnl.rem:SetIcon("icon16/delete.png")
        pnl.rem:SetText("Unsubscribe")
    end
    pnl.rem.DoClick = function(s)
        if data.file then
            print("Unsubscribe", data.wsid)
            steamworks.Unsubscribe(data.wsid)
            pnl:Remove()
            parent:PerformLayout()
        elseif data.subscribed ~= nil then
            if data.subscribed then
                steamworks.Unsubscribe(data.wsid)
                data.subscribed = false
                s:SetIcon("icon16/add.png")
                s:SetText("Subscribe")
            else
                steamworks.Subscribe(data.wsid)
                data.subscribed = true
                s:SetIcon("icon16/delete.png")
                s:SetText("Unsubscribe")
            end
            pnl:SetBackgroundColor(data.subscribed and Color(128,192,128) or Color(255,255,255))
        end
    end

    if data.file then
        pnl.mnt = vgui.Create("DButton", pnl.btns)
        pnl.mnt:SetTall(32)
        pnl.mnt:Dock(BOTTOM)
        pnl.mnt:DockMargin(4,4,4,4)
        pnl.mnt:SetIcon(data.mounted and "icon16/cross.png" or "icon16/tick.png")
        pnl.mnt:SetText(data.mounted and "Disable" or "Enable")
        pnl.mnt.DoClick = function(s)
            print("[Addon Mount]", data.file, not data.mounted)
            local old = steamworks.ShouldMountAddon(data.wsid)
            steamworks.SetShouldMountAddon(data.wsid, not data.mounted)
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
    end

    pnl.header = vgui.Create("EditablePanel", pnl)
    pnl.header:Dock(TOP)
    pnl.header:SetTall(32)

    pnl.name = vgui.Create("DLabel", pnl.header)
    pnl.name:SetText(data.title or data.file or data.wsid)
    pnl.name:SetFont("DermaLarge")
    pnl.name:SetDark(true)
    pnl.name:Dock(LEFT)
    pnl.name:SizeToContents()
    pnl.name:DockMargin(2,0,0,0)

    pnl.author = vgui.Create("DLabel", pnl.header)
    pnl.author:SetText("")
    pnl.author:SetFont("DermaDefault")
    pnl.author:SetDark(true)
    pnl.author:SetPos(pnl.name:GetWide() + 8, pnl.name:GetTall() - 18)
    pnl.author:SetContentAlignment(7)
    pnl.author:SizeToContents()

    pnl.desc = vgui.Create("RichText", pnl)
    pnl.desc:Dock(FILL)
    pnl.desc.PerformLayout = function(s)
        s:SetFontInternal("DermaDefault")
        s:SetUnderlineFont("DermaDefault")
        s:SetFGColor(s:GetSkin().Colours.Label.Dark)
    end

    local last_color = pnl.desc:GetSkin().Colours.Label.Dark
    local old_insert_color_change = pnl.desc.InsertColorChange
    pnl.desc.InsertColorChange = function(s, r, g, b, a)
        last_color = istable(r) and Color(r.r, r.g, r.b) or Color(r, g, b)
        old_insert_color_change(s, last_color.r, last_color.g, last_color.b, last_color.a)
    end

    pnl.desc.GetLastColorChange = function(s) return last_color end

    parent:Add(pnl)
end

vgui.Register( "CashoutAddons", PANEL, "DFrame" )

function CashoutAddons()
    if IsValid(_G.AddonsMenu) then _G.AddonsMenu:Remove() end
    _G.AddonsMenu = vgui.Create("CashoutAddons")
end
