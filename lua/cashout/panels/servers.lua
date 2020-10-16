local STOPLOADING = false
local SERVERSLOADED = 0
local ServerList = {}

local function CreateInfoBox(pnl, data)
    local InfoBox = vgui.Create("DFrame")
    InfoBox:SetSize(384, 448)
    InfoBox:Center()
    InfoBox:MakePopup()
    InfoBox:SetTitle("Server Info - " .. data.name)
    InfoBox:DockPadding(8, 28, 8, 8)
    local Name = vgui.Create("DLabel", InfoBox)
    Name:SetText("Name: " .. data.name)
    Name:Dock(TOP)
    local IP = vgui.Create("DLabel", InfoBox)
    IP:SetText("IP: " .. data.ip)
    IP:Dock(TOP)
    local Gamemode = vgui.Create("DLabel", InfoBox)
    Gamemode:SetText(("Gamemode: %s (%s)"):format(data.desc, data.gamemode))
    Gamemode:Dock(TOP)
    local Map = vgui.Create("DLabel", InfoBox)
    Map:SetText("Map: " .. data.map)
    Map:Dock(TOP)
    local Players = vgui.Create("DLabel", InfoBox)
    Players:SetText(("Players: %d/%d"):format(data.players, data.maxplayers))
    Players:Dock(TOP)
    local Ping = vgui.Create("DLabel", InfoBox)
    Ping:SetText("Ping: " .. data.ping)
    Ping:Dock(TOP)
    local PList = vgui.Create("DListView", InfoBox)
    PList:Dock(FILL)
    PList:AddColumn("Name")
    PList:AddColumn("Score")
    PList:AddColumn("Time")

    serverlist.PlayerList(data.ip, function(plys)
        for _, d in next, plys do
            local time = string.FormattedTime(d.time)
            local name = d.name
            local score = d.score
            local tstr = (time.h and time.h .. "h ") .. (time.m and time.m .. "m ") .. (time.s .. "s")
            PList:AddLine(name, score, tstr)
        end
    end)

    PList:SortByColumn(2)
    local Buttons = vgui.Create("EditablePanel", InfoBox)
    Buttons:Dock(BOTTOM)
    Buttons:SetTall(32)
    Buttons:DockPadding(4, 4, 4, 4)
    Buttons.btnClose = vgui.Create("DButton", Buttons)
    Buttons.btnClose:SetText("Close")
    Buttons.btnClose:Dock(RIGHT)
    Buttons.btnClose:SetWide(96)
    Buttons.btnClose:DockPadding(4, 4, 4, 4)
    Buttons.btnClose:DockMargin(8, 0, 0, 0)

    Buttons.btnClose.DoClick = function()
        InfoBox:Close()
    end

    Buttons.btnJoin = vgui.Create("DButton", Buttons)
    Buttons.btnJoin:SetText("Connect")
    Buttons.btnJoin:Dock(RIGHT)
    Buttons.btnJoin:SetWide(96)
    Buttons.btnJoin:DockPadding(4, 4, 4, 4)

    Buttons.btnJoin.DoClick = function()
        if data.pass then
            Derma_StringRequest("Password", data.name .. " requires a password.", GetConVar("password"):GetString(), function(text)
                RunConsoleCommand("password", text)
                JoinServer(data.ip)
                InfoBox:Close()

                if IsValid(pnl) then
                    pnl:Close()
                end
            end)
        else
            JoinServer(data.ip)
            InfoBox:Close()

            if IsValid(pnl) then
                pnl:Close()
            end
        end
    end
end

function ServerList:Init()
    self.ServerBrowser = {}
    self.QueryType = ""
    self.CookiePrefix = "cashout_srv"
    self.LoadButton = vgui.Create("DButton", self)
    self.LoadButton:Dock(TOP)
    self.LoadButton:SetTall(32)
    self.LoadButton:DockMargin(0, 0, 0, 4)
    self.LoadButton:SetText("Load Servers (may lag)")

    self.LoadButton.DoClick = function(s)
        STOPLOADING = false
        self:Query()
    end

    self.ServerList = vgui.Create("DListView", self)
    self.ServerList:Dock(FILL)
    local pass = self.ServerList:AddColumn(" ")
    pass:SetFixedWidth(16)
    pass.oDC = pass.DoClick

    pass.DoClick = function(s)
        self.ServerList.ToSortBy = s:GetColumnID()

        return s.oDC
    end

    self.ServerList:AddColumn("Name")
    local gm = self.ServerList:AddColumn("Gamemode")
    gm:SetFixedWidth(128)
    gm.oDC = gm.DoClick

    gm.DoClick = function(s)
        self.ServerList.ToSortBy = s:GetColumnID()

        return s:oDC()
    end

    local plys = self.ServerList:AddColumn("Players")
    plys:SetFixedWidth(48)
    plys.oDC = plys.DoClick

    plys.DoClick = function(s)
        self.ServerList.ToSortBy = s:GetColumnID()

        return s:oDC()
    end

    local map = self.ServerList:AddColumn("Map")
    map:SetFixedWidth(192)
    map.oDC = map.DoClick

    map.DoClick = function(s)
        self.ServerList.ToSortBy = s:GetColumnID()

        return s:oDC()
    end

    local ping = self.ServerList:AddColumn("Ping")
    ping:SetFixedWidth(32)
    ping.oDC = ping.DoClick

    ping.DoClick = function(s)
        self.ServerList.ToSortBy = s:GetColumnID()

        return s:oDC()
    end

    local ip = self.ServerList:AddColumn("IP")
    ip:SetFixedWidth(128)
    ip.oDC = ip.DoClick

    ip.DoClick = function(s)
        self.ServerList.ToSortBy = s:GetColumnID()

        return s:oDC()
    end

    self.ServerList.ToSortBy = ping:GetColumnID()

    self.ServerList.OnRowSelected = function(s, i, line)
        if IsValid(self.SelectedServer) and line == self.SelectedServer then
            return
        end

        if ispanel(self.SelectedServer) then
            self.SelectedServer:SetSelected(false)
        end

        self.SelectedServer = line
    end

    self.ServerList.DoDoubleClick = function(s, i, line)
        if line.data.pass then
            Derma_StringRequest("Password", line.data.name .. " requires a password.", GetConVar("password"):GetString(), function(text)
                RunConsoleCommand("password", text)
                JoinServer(line.data.ip)

                if IsValid(self.ServerBrowser) then
                    self.ServerBrowser:Close()
                end
            end)
        else
            JoinServer(line.data.ip)

            if IsValid(self.ServerBrowser) then
                self.ServerBrowser:Close()
            end
        end
    end

    self.ServerList.OnRowRightClick = function(s, i, line)
        local m = DermaMenu()

        m:AddOption("Join Server", function()
            s.DoDoubleClick(s, i, line)
        end):SetIcon("icon16/server_" .. (line.data.pass and "key" or "go") .. ".png")

        m:AddOption("Server Info", function()
            CreateInfoBox(self.ServerBrowser, line.data)
        end):SetIcon("icon16/server_chart.png")

        m:AddSpacer()

        if self.QueryType == "favorite" then
            m:AddOption("Remove from favorites", function()
                serverlist.RemoveServerFromFavorites(line.data.ip)
                local pnl = self
                STOPLOADING = true

                if IsValid(pnl.SelectedServer) then
                    pnl.SelectedServer:SetSelected(false)
                    pnl.SelectedServer = {}
                end

                pnl.ServerList:Clear()
                STOPLOADING = false
                pnl:Query(pnl.QueryType)
            end):SetIcon("icon16/award_star_delete.png")

            if not Cashout.Favorites[line.data.ip] then
                m:AddOption("Add to Quick Connect", function()
                    Derma_StringRequest("Add to Quick Connect", "Enter a name to remember this server by", line.data.name, function(str)
                        Cashout.AddServerToFavorites(str, line.data.ip)
                    end)
                end):SetIcon("icon16/star.png")
            else
                m:AddOption("Remove from Quick Connect", function()
                    Derma_Query("Are you sure you want to remove this server from Quick Connect?\n(You can always readd it back.)", "Remove from Quick Connect", "Yes", function()
                        Cashout.RemoveServerFromFavorites(line.data.ip)
                    end, "No")
                end):SetIcon("icon16/delete.png")
            end
        else
            m:AddOption("Add to favorites", function()
                serverlist.AddServerToFavorites(line.data.ip)
            end):SetIcon("icon16/award_star_add.png")
        end

        m:Open()
    end

    self.Controls = vgui.Create("DPanel", self)
    self.Controls:Dock(BOTTOM)
    self.Controls:SetTall(32)
    self.Controls:DockMargin(0, 4, 0, 0)
    self.Controls:DockPadding(4, 4, 4, 4)
    self.Controls.HideEmpty = vgui.Create("DCheckBoxLabel", self.Controls)
    self.Controls.HideEmpty:Dock(LEFT)
    self.Controls.HideEmpty:SetChecked(cookie.GetNumber(self.CookiePrefix .. "_hideempty", 0))
    self.Controls.HideEmpty:SetText("Hide Empty?")
    self.Controls.HideEmpty:SetDark(true)
    self.Controls.HideEmpty:SizeToContents()
    self.Controls.HideEmpty:DockMargin(0, 0, 16, 0)

    self.Controls.HideEmpty.OnChange = function(s, val)
        cookie.Set(self.CookiePrefix .. "_hideempty", val == true and 1 or 0)
    end

    self.Controls.HideEmpty.PerformLayout = function(s)
        local x = s.m_iIndent or 0
        s.Button:SetSize(15, 15)
        s.Button:SetPos(x, math.floor((s:GetTall() - s.Button:GetTall()) / 2))
        s.Label:SizeToContents()
        s.Label:SetPos(x + s.Button:GetWide() + 9, math.floor((s:GetTall() - s.Label:GetTall()) / 2))
    end

    self.Controls.HideFull = vgui.Create("DCheckBoxLabel", self.Controls)
    self.Controls.HideFull:Dock(LEFT)
    self.Controls.HideFull:SetChecked(cookie.GetNumber(self.CookiePrefix .. "_hidefull", 0))
    self.Controls.HideFull:SetText("Hide Full?")
    self.Controls.HideFull:SetDark(true)
    self.Controls.HideFull:SizeToContents()
    self.Controls.HideFull:DockMargin(0, 0, 16, 0)

    self.Controls.HideFull.OnChange = function(s, val)
        cookie.Set(self.CookiePrefix .. "_hidefull", val == true and 1 or 0)
    end

    self.Controls.HideFull.PerformLayout = function(s)
        local x = s.m_iIndent or 0
        s.Button:SetSize(15, 15)
        s.Button:SetPos(x, math.floor((s:GetTall() - s.Button:GetTall()) / 2))
        s.Label:SizeToContents()
        s.Label:SetPos(x + s.Button:GetWide() + 9, math.floor((s:GetTall() - s.Label:GetTall()) / 2))
    end

    self.Controls.HidePW = vgui.Create("DCheckBoxLabel", self.Controls)
    self.Controls.HidePW:Dock(LEFT)
    self.Controls.HidePW:SetChecked(cookie.GetNumber(self.CookiePrefix .. "_hidepw", 0))
    self.Controls.HidePW:SetText("Hide Passworded?")
    self.Controls.HidePW:SetDark(true)
    self.Controls.HidePW:SizeToContents()
    self.Controls.HidePW:DockMargin(0, 0, 16, 0)

    self.Controls.HidePW.OnChange = function(s, val)
        cookie.Set(self.CookiePrefix .. "_hidepw", val == true and 1 or 0)
    end

    self.Controls.HidePW.PerformLayout = function(s)
        local x = s.m_iIndent or 0
        s.Button:SetSize(15, 15)
        s.Button:SetPos(x, math.floor((s:GetTall() - s.Button:GetTall()) / 2))
        s.Label:SizeToContents()
        s.Label:SetPos(x + s.Button:GetWide() + 9, math.floor((s:GetTall() - s.Label:GetTall()) / 2))
    end

    self.Controls.Limit = vgui.Create("DNumSlider", self.Controls)
    self.Controls.Limit:SetText("Server Display Limit")
    self.Controls.Limit:Dock(LEFT)
    self.Controls.Limit:SetMin(200)
    self.Controls.Limit:SetMax(5000)
    self.Controls.Limit:SetDecimals(0)
    self.Controls.Limit:SetValue(cookie.GetNumber(self.CookiePrefix .. "_limit", 5000))
    self.Controls.Limit:SetDark(true)
    self.Controls.Limit:SetWide(256)

    self.Controls.Limit.OnValueChanged = function(s, val)
        cookie.Set(self.CookiePrefix .. "_limit", math.Clamp(val, 200, 5000))
    end

    self.Controls.Reload = vgui.Create("DButton", self.Controls)
    self.Controls.Reload:Dock(RIGHT)
    self.Controls.Reload:SetWide(96)
    self.Controls.Reload:SetText("Refresh")

    self.Controls.Reload.DoClick = function(s)
        local pnl = self
        STOPLOADING = true

        if IsValid(pnl.SelectedServer) then
            pnl.SelectedServer:SetSelected(false)
            pnl.SelectedServer = {}
        end

        pnl.ServerList:Clear()
        STOPLOADING = false
        pnl:Query(pnl.QueryType)
    end

    self.Controls.StopLoad = vgui.Create("DButton", self.Controls)
    self.Controls.StopLoad:Dock(RIGHT)
    self.Controls.StopLoad:DockMargin(0, 0, 8, 0)
    self.Controls.StopLoad:SetWide(96)
    self.Controls.StopLoad:SetText("Stop Loading")
    self.Controls.StopLoad:SetDisabled(true)

    self.Controls.StopLoad.DoClick = function(s)
        STOPLOADING = true
    end

    self.Controls.StopLoad.Think = function(s)
        s:SetDisabled(STOPLOADING)
    end

    self.Controls.AddCurrent = vgui.Create("DButton", self.Controls)
    self.Controls.AddCurrent:Dock(RIGHT)
    self.Controls.AddCurrent:DockMargin(0, 0, 8, 0)
    self.Controls.AddCurrent:SetWide(164)
    self.Controls.AddCurrent:SetText("Add Current Server To Favorites")
    self.Controls.AddCurrent:SetDisabled(true)

    self.Controls.AddCurrent.DoClick = function(s)
        serverlist.AddCurrentServerToFavorites()
    end

    self.Controls.AddCurrent.Think = function(s)
        s:SetDisabled(not IsInGame())
    end

    self.SelectedServer = {}
end

function ServerList:SetQueryType(qtype)
    self.QueryType = qtype
    self.CookiePrefix = "cashout_srv_" .. qtype
    self.Controls.HideEmpty:SetChecked(cookie.GetNumber(self.CookiePrefix .. "_hideempty", 0))

    self.Controls.HideEmpty.OnChange = function(s, val)
        cookie.Set(self.CookiePrefix .. "_hideempty", val == true and 1 or 0)
    end

    self.Controls.HideFull:SetChecked(cookie.GetNumber(self.CookiePrefix .. "_hidefull", 0))

    self.Controls.HideFull.OnChange = function(s, val)
        cookie.Set(self.CookiePrefix .. "_hidefull", val == true and 1 or 0)
    end

    self.Controls.HidePW:SetChecked(cookie.GetNumber(self.CookiePrefix .. "_hidepw", 0))

    self.Controls.HidePW.OnChange = function(s, val)
        cookie.Set(self.CookiePrefix .. "_hidepw", val == true and 1 or 0)
    end

    self.Controls.Limit:SetValue(cookie.GetNumber(self.CookiePrefix .. "_limit", 5000))

    self.Controls.Limit.OnValueChanged = function(s, val)
        cookie.Set(self.CookiePrefix .. "_limit", math.Clamp(val, 200, 5000))
    end
end

function ServerList:AddServer(data)
    if not IsValid(self) then
        return
    end

    local line = self.ServerList:AddLine(data.pass and "P" or "", data.name, data.desc, data.players .. "/" .. data.maxplayers, data.map, data.ping, data.ip)
    line.data = data
    line:SetSortValue(4, line.data.players)
end

function ServerList:Query()
    if IsValid(self.LoadButton) then
        self.LoadButton:Remove()
    end

    serverlist.Query({
        Type = self.QueryType,
        Callback = function(ping, name, desc, map, players, maxplayers, bots, pass, lastplayed, ip, gamemode, wsid)
            if not IsValid(self) then
                return false
            end

            if SERVERSLOADED == cookie.GetNumber(self.CookiePrefix .. "_limit", 5000) then
                STOPLOADING = true
            end

            if STOPLOADING then
                return false
            end

            if players == 0 and tobool(cookie.GetNumber(self.CookiePrefix .. "_hideempty", 0)) then
                return
            end

            if players == maxplayers and tobool(cookie.GetNumber(self.CookiePrefix .. "_hidefull", 0)) then
                return
            end

            if pass and tobool(cookie.GetNumber(self.CookiePrefix .. "_hidepw", 0)) then
                return
            end

            local data = {
                ping = ping,
                name = name,
                desc = desc,
                map = map,
                players = players,
                maxplayers = maxplayers,
                bots = bots,
                pass = pass,
                lastplayed = lastplayed,
                ip = ip,
                gamemode = gamemode,
                wsid = wsid
            }

            self:AddServer(data)
            SERVERSLOADED = SERVERSLOADED + 1
        end,
        Finished = function()
            STOPLOADING = true
        end
    })
end

ServerList = vgui.RegisterTable(ServerList, "EditablePanel")
local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrW() - 512, ScrH() - 256)
    self:SetTitle("Server Browser")
    self:SetIcon("icon16/server.png")
    self:Center()
    self:MakePopup()
    self.btnMaxim:SetVisible(false)
    self.btnMinim:SetVisible(false)
    self.Tabs = vgui.Create("DPropertySheet", self)
    self.Tabs:Dock(FILL)
    self.Global = vgui.CreateFromTable(ServerList, self)
    self.Global:SetQueryType("internet")
    self.Global.ServerBrowser = self
    self.Tabs:AddSheet("Global", self.Global, "icon16/world.png")
    self.Favorites = vgui.CreateFromTable(ServerList, self)
    self.Favorites:SetQueryType("favorite")
    self.Favorites.ServerBrowser = self
    self.Tabs:AddSheet("Favorites", self.Favorites, "icon16/star.png")
    self.History = vgui.CreateFromTable(ServerList, self)
    self.History:SetQueryType("history")
    self.History.ServerBrowser = self
    self.Tabs:AddSheet("History", self.History, "icon16/time.png")
    self.Local = vgui.CreateFromTable(ServerList, self)
    self.Local:SetQueryType("lan")
    self.Local.ServerBrowser = self
    self.Tabs:AddSheet("Local", self.Local, "icon16/computer_link.png")

    timer.Simple(0.2, function()
        self.Favorites:Query()
        self.Local:Query()
    end)
end

--[[function PANEL:Paint(w,h)
    draw.RoundedBox(0,0,0,w,h,Color(0,0,0,240))
    draw.RoundedBox(0,0,0,w,24,Color(0,128,0))
end--]]
vgui.Register("CashoutServers", PANEL, "DFrame")

function CashoutServers()
    if IsValid(_G.ServerBrowser) then
        _G.ServerBrowser:Remove()
    end

    _G.ServerBrowser = vgui.Create("CashoutServers")
end