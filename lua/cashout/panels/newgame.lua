local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrW()-492,ScrH()-256)
    self:SetTitle("New Game")
    self:SetIcon("icon16/world_add.png")

    self:Center()
    self:MakePopup()

    self.SelectedMap = ""

    self.Side = vgui.Create("DScrollPanel",self)
    self.Side:Dock(LEFT)
    self.Side:SetWide(192)
    self.Side:DockMargin(4,4,4,4)
    self.Side:SetPaintBackground(true)

    self.Categories = {}

    self.List = vgui.Create("DScrollPanel",self)
    self.List:Dock(FILL)
    self.List:DockMargin(4,4,4,4)
    self.List:SetPaintBackground(true)

    self.MapList = vgui.Create("DIconLayout",self.List)
    self.MapList:SetSpaceX(4)
    self.MapList:SetSpaceY(4)
    self.MapList:SetBorder(4)
    self.MapList:Dock(FILL)
    self.MapList:SetTall(10000)
    self.List:AddItem(self.MapList)

    self.Settings = vgui.Create("DScrollPanel",self)
    self.Settings:Dock(RIGHT)
    self.Settings:SetWide(234)
    self.Settings:DockMargin(4,4,4,4)
    self.Settings:DockPadding(4,4,4,4)
    self.Settings:SetPaintBackground(true)

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

    self:SetupCategories()
    self:SetupMaps("Sandbox")
    self:SetupSettings()
end

function PANEL:SetupSettings()
    local pnlHost = vgui.Create("EditablePanel",self.Settings)
    pnlHost:Dock(TOP)
    pnlHost:DockMargin(4,4,4,4)
    local lblHost = vgui.Create("DLabel",pnlHost)
    lblHost:Dock(LEFT)
    lblHost:SetText("Hostname:")
    lblHost:SizeToContents()
    lblHost:SetDark(true)
    local hostname = vgui.Create("DTextEntry",pnlHost)
    hostname:SetConVar("hostname")
    hostname:Dock(FILL)
    hostname:DockMargin(16, 0, 0, 0)
    self.Settings:Add(pnlHost)

    local pnlGM = vgui.Create("EditablePanel",self.Settings)
    pnlGM:Dock(TOP)
    pnlGM:DockMargin(4,4,4,4)
    local lblGM = vgui.Create("DLabel",pnlGM)
    lblGM:Dock(LEFT)
    lblGM:SetText("Gamemode:")
    lblGM:SizeToContents()
    lblGM:SetDark(true)
    local dropGM = vgui.Create("DComboBox",pnlGM)
    dropGM:Dock(FILL)
    dropGM:DockMargin(16, 0, 0, 0)
    for _, data in pairs(engine.GetGamemodes()) do
        if not data.menusystem then continue end
        local icon = ("gamemodes/%s/icon24.png"):format(data.name)
        local hasIcon = file.Exists(icon, "GAME")
        dropGM:AddChoice(data.title, data.name, engine.ActiveGamemode() == data.name, hasIcon and icon or "icon16/brick.png")
    end
    dropGM.OnSelect = function(s, index, text, val)
        RunConsoleCommand("gamemode", val)
    end
    -- stupid hack
    dropGM.OpenMenu = function(s, pControlOpener)
        if pControlOpener and pControlOpener == s.TextEntry then
            return
        end

        -- Don't do anything if there aren't any options..
        if ( #s.Choices == 0 ) then return end

        -- If the menu still exists and hasn't been deleted
        -- then just close it and don't open a new one.
        if ( IsValid( s.Menu ) ) then
            s.Menu:Remove()
            s.Menu = nil
        end

        s.Menu = DermaMenu( false, s )

        if ( s:GetSortItems() ) then
            local sorted = {}
            for k, v in pairs( s.Choices ) do
                local val = tostring( v ) --tonumber( v ) || v -- This would make nicer number sorting, but SortedPairsByMemberValue doesn't seem to like number-string mixing
                if ( string.len( val ) > 1 and not tonumber( val ) and val:StartWith( "#" ) ) then val = language.GetPhrase( val:sub( 2 ) ) end
                table.insert( sorted, { id = k, data = v, label = val } )
            end
            for k, v in SortedPairsByMemberValue( sorted, "label" ) do
                local option = s.Menu:AddOption( v.data, function() s:ChooseOption( v.data, v.id ) end )
                if ( s.ChoiceIcons[ v.id ] ) then
                    option:SetIcon( s.ChoiceIcons[ v.id ] )
                    option.m_Image:SetSize(16, 16) -- stupid hack
                end
            end
        else
            for k, v in pairs( s.Choices ) do
                local option = s.Menu:AddOption( v, function() s:ChooseOption( v, k ) end )
                if ( s.ChoiceIcons[ k ] ) then
                    option:SetIcon( s.ChoiceIcons[ k ] )
                    option.m_Image:SetSize(16, 16) -- stupid hack
                end
            end
        end

        local x, y = s:LocalToScreen( 0, s:GetTall() )

        s.Menu:SetMinimumWidth( s:GetWide() )
        s.Menu:Open( x, y, false, s )
    end

    local maxplayers = vgui.Create("DNumSlider",self)
    maxplayers:SetText("Max Players:")
    maxplayers:SetMin(2)
    maxplayers:SetMax(128)
    maxplayers:SetDecimals(0)
    maxplayers:SetValue(tonumber(cookie.GetNumber("cashout_maxplayers")) or 2)
    maxplayers:Dock(TOP)
    maxplayers:DockMargin(4,4,4,4)
    maxplayers:SetDark(true)
    function maxplayers:OnValueChanged(value)
        cookie.Set("cashout_maxplayers",math.Round(value))
    end
    self.Settings:Add(maxplayers)

    local lan = vgui.Create("DCheckBoxLabel",self.Settings)
    lan:Dock(TOP)
    lan:DockMargin(4,4,4,4)
    lan:SetText("LAN Only")
    lan:SetConVar("sv_lan")
    lan:SizeToContents()
    lan:SetDark(true)
    self.Settings:Add(lan)

    local p2p = vgui.Create("DCheckBoxLabel",self.Settings)
    p2p:Dock(TOP)
    p2p:DockMargin(4,4,4,4)
    p2p:SetText("P2P Enabled")
    p2p:SetConVar("p2p_enabled")
    p2p:SizeToContents()
    p2p:SetDark(true)
    self.Settings:Add(p2p)

    local p2p_fo = vgui.Create("DCheckBoxLabel",self.Settings)
    p2p_fo:Dock(TOP)
    p2p_fo:DockMargin(4,4,4,4)
    p2p_fo:SetText("P2P Friends Only")
    p2p_fo:SetConVar("p2p_friendsonly")
    p2p_fo:SizeToContents()
    p2p_fo:SetDark(true)
    self.Settings:Add(p2p_fo)

    self.sp = vgui.Create("DButton",self.Settings)
    self.sp:Dock(TOP)
    self.sp:DockMargin(4,4,4,4)
    self.sp:SetTall(32)
    self.sp:SetText("Singleplayer")
    self.Settings:Add(self.sp)

    self.sp.DoClick = function(p)
        if self.SelectedMap == "" then return end
        RunGameUICommand("disconnect")
        timer.Simple(0.1, function()
            RunConsoleCommand("hostname",hostname:GetValue())
            RunConsoleCommand("maxplayers",1)
            RunConsoleCommand("map",self.SelectedMap:Trim())

            self:Remove()
        end)
    end
    self.sp.Think = function(p) p:SetDisabled(self.SelectedMap == "" and true or false) end

    self.mp = vgui.Create("DButton",self.Settings)
    self.mp:Dock(TOP)
    self.mp:DockMargin(4,4,4,4)
    self.mp:SetTall(32)
    self.mp:SetText("Multiplayer")
    self.Settings:Add(self.mp)

    self.mp.DoClick = function(p)
        if self.SelectedMap == "" then return end
        RunGameUICommand("disconnect")
        timer.Simple(0.1, function()
            RunConsoleCommand("hostname",hostname:GetValue())
            RunConsoleCommand("maxplayers",math.Round(maxplayers:GetValue()))
            RunConsoleCommand("map",self.SelectedMap:Trim())

            self:Remove()
        end)
    end
    self.mp.Think = function(p) p:SetDisabled(self.SelectedMap == "" and true or false) end
end

function PANEL:SetupCategories()
    self.Side:Clear()

    local mlist = GetMapList()

    for k,v in SortedPairs(mlist) do
        self.Categories[k] = vgui.Create("DButton")
        local btn = self.Categories[k]
        btn:SetText(("%s (%d)"):format(k,#mlist[k]))
        btn:Dock(TOP)
        btn:DockMargin(4,4,4,4)
        btn:SetTall(32)
        btn.DoClick = function(p)
            self:SetupMaps(k)
        end

        self.Side:Add(btn)
    end
end

function PANEL:SetupMaps(cat)
    self.MapList:Clear()
    for _,v in SortedPairs(GetMapList()[cat]) do
        self.MapList:Add(self:CreateMapIcon(v))
    end
    timer.Simple(0,function()
        self.MapList:SizeToContents()
        self.List:InvalidateLayout()
        self.List:PerformLayout()
    end)
    self.List.VBar:AnimateTo( 0, 0.5, 0, 0.5 )
end

function PANEL:CreateMapIcon(name)
    local map = vgui.Create("DButton")
    map:SetSize(128,144)
    map.Paint = function() end
    map.MapName = name
    map.DoClick = function(p) self.SelectedMap = p.MapName end
    local mname = vgui.Create("EditablePanel",map)
    mname:Dock(BOTTOM)
    mname:SetTall(16)
    mname.Paint = function(p,w,h)
        draw.RoundedBox(0, 0, 0, w, h, self.SelectedMap == map.MapName and Color(255,128,0) or Color(64,64,64))
        draw.SimpleText(name, "DermaDefault", w/2, h/2, Color(255,255,255), 1, 1)
    end
    local icon = vgui.Create("DImage",map)
    icon:Dock(FILL)
    if Material("maps/thumb/"..name..".png"):IsError() then
        icon:SetImage("gui/noicon.png")
    else
        icon:SetImage("maps/thumb/"..name..".png")
    end

    return map
end

--[[function PANEL:Paint(w,h)
    draw.RoundedBox(0,0,0,w,h,Color(0,0,0,240))
    draw.RoundedBox(0,0,0,w,24,Color(0,96,192))
end--]]

vgui.Register( "CashoutNewGame", PANEL, "DFrame" )

function CashoutNewGame()
    if IsValid(_G.NewGameMenu) then _G.NewGameMenu:Remove() end
    _G.NewGameMenu = vgui.Create("CashoutNewGame")
end