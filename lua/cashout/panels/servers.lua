local STOPLOADING = false
local SERVERSLOADED = 0

local ServerList = {}

function ServerList:Init()
    self.ServerBrowser = {}

    --[[self.Categories = {}
    self.List = vgui.Create("DCategoryList", self)
    self.List:Dock(FILL)--]]

    self.QueryType = ""

    self.LoadButton = vgui.Create("DButton", self)
    self.LoadButton:Dock(TOP)
    self.LoadButton:SetTall(32)
    self.LoadButton:DockMargin(0, 0, 0, 4)
    self.LoadButton:SetText("Load Servers (may lag)")
    self.LoadButton.DoClick = function(s)
        STOPLOADING = false
        self:Query(self.QueryType)
    end

    self.ServerList = vgui.Create("DListView", self)
    self.ServerList:Dock(FILL)
    local pass = self.ServerList:AddColumn(" ")
    pass:SetFixedWidth(16)
    self.ServerList:AddColumn("Name")
    local map = self.ServerList:AddColumn("Map")
    map:SetFixedWidth(192)
    local gm = self.ServerList:AddColumn("Gamemode")
    gm:SetFixedWidth(128)
    local plys = self.ServerList:AddColumn("Players")
    plys:SetFixedWidth(40)
    local ping = self.ServerList:AddColumn("Ping")
    ping:SetFixedWidth(32)
    local ip = self.ServerList:AddColumn("IP")
    ip:SetFixedWidth(128)

    self.ServerList.OnRowSelected = function(s,i,line)
        if IsValid(self.SelectedServer) and line == self.SelectedServer then return end
        if ispanel(self.SelectedServer) then self.SelectedServer:SetSelected(false) end
        self.SelectedServer = line
    end
    self.ServerList.DoDoubleClick = function(s,i,line)
        JoinServer(line.data.ip)
        if IsValid(self.ServerBrowser) then self.ServerBrowser:Close() end
    end

    self.Controls = vgui.Create("DPanel", self)
    self.Controls:Dock(BOTTOM)
    self.Controls:SetTall(32)
    self.Controls:DockMargin(0,4,0,0)
    self.Controls:DockPadding(4,4,4,4)

    self.Controls.HideEmpty = vgui.Create("DCheckBoxLabel", self.Controls)
    self.Controls.HideEmpty:Dock(LEFT)
    self.Controls.HideEmpty:SetChecked(false)
    self.Controls.HideEmpty:SetText("Hide Empty?")
    self.Controls.HideEmpty:SetDark(true)
    self.Controls.HideEmpty:SizeToContents()
    self.Controls.HideEmpty:DockMargin(0, 0, 16, 0)

    self.Controls.Limit = vgui.Create("DNumSlider", self.Controls)
    self.Controls.Limit:SetText("Server Display Limit")
    self.Controls.Limit:Dock(LEFT)
    self.Controls.Limit:SetMin(200)
    self.Controls.Limit:SetMax(5000)
    self.Controls.Limit:SetDecimals(0)
    self.Controls.Limit:SetValue(5000)
    self.Controls.Limit:SetDark(true)
    self.Controls.Limit:SetWide(256)

    self.Controls.Reload = vgui.Create("DButton", self.Controls)
    self.Controls.Reload:Dock(RIGHT)
    self.Controls.Reload:SetWide(96)
    self.Controls.Reload:SetText("Refresh")
    self.Controls.Reload.DoClick = function(s)
        STOPLOADING = true
        if IsValid(self.SelectedServer) then self.SelectedServer:SetSelected(false) self.SelectedServer = {} end
        self.ServerList:Clear()
        STOPLOADING = false
        self:Query(self.QueryType)
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

    self.SelectedServer = {}
end

function ServerList:AddCategory(id,name)
    self.Categories[id] = self.List:Add(name.." ("..id..")")
    self.Categories[id].InitialName = name
    self.Categories[id]:SetExpanded(false)
    self.Categories[id].ServerList = vgui.Create("DListView", self.Categories[id])
    self.Categories[id].ServerList:Dock(FILL)
    self.Categories[id].ServerList:DisableScrollbar()
    local pass = self.Categories[id].ServerList:AddColumn(" ")
    pass:SetFixedWidth(16)
    self.Categories[id].ServerList:AddColumn("Name")
    local map = self.Categories[id].ServerList:AddColumn("Map")
    map:SetFixedWidth(192)
    local gm = self.Categories[id].ServerList:AddColumn("Gamemode")
    gm:SetFixedWidth(128)
    local plys = self.Categories[id].ServerList:AddColumn("Players")
    plys:SetFixedWidth(40)
    local ping = self.Categories[id].ServerList:AddColumn("Ping")
    ping:SetFixedWidth(32)
    local ip = self.Categories[id].ServerList:AddColumn("IP")
    ip:SetFixedWidth(128)

    self.Categories[id].OnToggle = function(s) s.ServerList:SizeToContents() end
    self.Categories[id].ServerList.OnRowSelected = function(s,i,line)
        if ispanel(self.SelectedServer) then self.SelectedServer:SetSelected(false) end
        self.SelectedServer = line
    end
    self.Categories[id].ServerList.DoDoubleClick = function(s,i,line)
        JoinServer(line.data.ip)
        if IsValid(self.ServerBrowser) then self.ServerBrowser:Close() end
    end
end

function ServerList:AddToCategory(data)
    if not IsValid(self) then return end
    if data.players == 0 and self.Controls.HideEmpty:GetChecked() then return end
    if not self.Categories[data.desc:lower()] then self:AddCategory(data.desc:lower(),data.gamemode) end
    local slist = self.Categories[data.desc:lower()].ServerList
    local line = slist:AddLine(data.pass and "P" or "",data.name,data.map,data.desc,data.players.."/"..data.maxplayers,data.ping,data.ip)
    line.data = data
    self.Categories[data.desc:lower()]:SetLabel(data.desc.." ("..data.gamemode..") - "..table.Count(slist:GetLines()).." servers")

    slist:Dock(TOP)
    slist:SizeToContents()
    slist:FixColumnsLayout()
end

function ServerList:AddServer(data)
    if not IsValid(self) then return end
    local line = self.ServerList:AddLine(data.pass and "P" or "",data.name,data.map,data.desc,data.players.."/"..data.maxplayers,data.ping,data.ip)
    line.data = data
end

function ServerList:Query(type)
    self.LoadButton:Remove()
    serverlist.Query({Type=type,Callback=function(ping,name,desc,map,players,maxplayers,bots,pass,lastplayed,ip,gamemode,wsid)
        if not IsValid(self) then return false end
        if SERVERSLOADED == self.Controls.Limit:GetValue() then STOPLOADING = true end
        if STOPLOADING then return false end
        if players == 0 and self.Controls.HideEmpty:GetChecked() then return end
        local data = {
            ping=ping,
            name=name,
            desc=desc,
            map=map,
            players=players,
            maxplayers=maxplayers,
            bots=bots,
            pass=pass,
            lastplayed=lastplayed,
            ip=ip,
            gamemode=gamemode,
            wsid=wsid
        }
        self:AddServer(data)
        SERVERSLOADED = SERVERSLOADED+1
    end,
    Finished=function()
        STOPLOADING = true
    end})
end

ServerList = vgui.RegisterTable(ServerList, "EditablePanel")

local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrW()-512,ScrH()-256)
    self:SetTitle("Server Browser")
    self:SetIcon("icon16/server.png")

    self:Center()
	self:MakePopup()

    self.btnMaxim:SetVisible(false)
    self.btnMinim:SetVisible(false)

    self.Tabs = vgui.Create("DPropertySheet",self)
    self.Tabs:Dock(FILL)

    self.Global = vgui.CreateFromTable(ServerList, self)
    self.Global.QueryType = "internet"
    self.Global.ServerBrowser = self
    self.Tabs:AddSheet("Global",self.Global,"icon16/world.png")

    self.Favorites = vgui.CreateFromTable(ServerList, self)
    self.Favorites.QueryType = "favorite"
    self.Favorites.ServerBrowser = self
    self.Tabs:AddSheet("Favorites",self.Favorites,"icon16/star.png")

    self.History = vgui.CreateFromTable(ServerList, self)
    self.History.QueryType = "history"
    self.History.ServerBrowser = self
    self.Tabs:AddSheet("History",self.History,"icon16/time.png")

    self.Local = vgui.CreateFromTable(ServerList, self)
    self.Local.QueryType = "lan"
    self.Local.ServerBrowser = self
    self.Tabs:AddSheet("Local",self.Local,"icon16/computer_link.png")

    timer.Simple(0.2,function()
        self.Favorites:Query("favorite")
        self.Local:Query("lan")
    end)
end

--[[function PANEL:Paint(w,h)
    draw.RoundedBox(0,0,0,w,h,Color(0,0,0,240))
    draw.RoundedBox(0,0,0,w,24,Color(0,128,0))
end--]]

vgui.Register( "CashoutServers", PANEL, "DFrame" )

function CashoutServers()
    if IsValid(_G.ServerBrowser) then _G.ServerBrowser:Remove() end
    _G.ServerBrowser = vgui.Create("CashoutServers")
end