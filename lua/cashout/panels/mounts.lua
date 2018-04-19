local PANEL = {}

function PANEL:Init()
    self:SetSize(256,384)
    self:SetTitle("#mounted_games")
    self:SetIcon("icon16/controller.png")

    self:Center()
	self:MakePopup()

    self.list = vgui.Create("DScrollPanel",self)
    self.list:Dock(FILL)

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

    local scroll = self.list.VBar
    scroll.Paint = function() end
    local btnUp = scroll.btnUp
    local btnDn = scroll.btnDown
    local bar = scroll.btnGrip

    btnUp.alpha = 128
    btnDn.alpha = 128
    bar.alpha = 128

    --[[function btnUp:Paint(w,h)
        self.alpha = Lerp(0.05,self.alpha,self.Hovered and 255 or 128)
        draw.RoundedBox(0,0,2,w,h,Color(128,0,192,self.alpha))
        draw.SimpleText("t", "Marlett", w/2, h/2, Color(255,255,255,self.alpha), 1, 1)

        surface.SetDrawColor(Color(255,255,255))
        surface.DrawLine(0, h-1, w, h-1)
    end
    function btnDn:Paint(w,h)
        self.alpha = Lerp(0.05,self.alpha,self.Hovered and 255 or 128)
        draw.RoundedBox(0,0,2,w,h,Color(128,0,192,self.alpha))
        draw.SimpleText("u", "Marlett", w/2, h/2, Color(255,255,255,self.alpha), 1, 1)

        surface.SetDrawColor(Color(255,255,255))
        surface.DrawLine(0, 0, w, 0)
    end
    function bar:Paint(w,h)
        self.alpha = Lerp(0.05,self.alpha,self.Hovered and 255 or 128)
        draw.RoundedBox(0,0,2,w,h,Color(128,0,192,self.alpha))
    end--]]

    local t=engine.GetGames()
	table.sort(t,function(a,b)
		if a.mounted==b.mounted then
			if a.mounted then
				return a.depot<b.depot
			else
				return ((a.installed and a.owned) and 0 or 1)<((b.installed and b.owned) and 0 or 1)
			end
		else
			return  (a.mounted and 0 or 1)<(b.mounted and 0 or 1)
		end
	end)
	for _,data in next,t do
		self:AddGame(data,data.title,data.mounted,data.owned,data.installed,data.depot)
	end
end

--[[function PANEL:Paint(w,h)
    draw.RoundedBox(0,0,0,w,h,Color(0,0,0,240))
    draw.RoundedBox(0,0,0,w,24,Color(128,0,192))
end--]]

function PANEL:AddGame(data,title,mounted,owned,installed,depot)
    local btn = vgui.Create("DCheckBoxLabel",gameslist,'gameslist_button')
    self.list:Add(btn)
    btn:SetText(title)
    btn:SetChecked(mounted)
    btn:SetBright(true)
    btn:SetDisabled(not owned or not installed)
    btn:SizeToContents()
    function btn:OnChange(val)
        engine.SetMounted(depot,val)
        btn:SetChecked(IsMounted(depot))
    end

    btn:InvalidateLayout(true)
    btn:Dock(TOP)
    btn:DockPadding(0, 0, 0, 8)
end

vgui.Register( "CashoutMounts", PANEL, "DFrame" )

function CashoutOpenMounts()
    if IsValid(_G.MountedGames) then _G.MountedGames:Remove() end
    _G.MountedGames = vgui.Create("CashoutMounts")
end