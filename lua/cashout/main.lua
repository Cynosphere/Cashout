include("background.lua")
include("panels/mounts.lua")
include("panels/newgame.lua")
include("panels/addons.lua")
include("panels/servers.lua")

surface.CreateFont("Cashout_GModLogo",{
	font = "Coolvetica",
	size = 48,
	weight = 400
})

if IsValid(_G.mainMenu) then mainMenu:Remove() end

_G.mainMenu = vgui.Create("cashout_background")
_G.mainMenu:SetKeyboardInputEnabled(true)
_G.mainMenu:SetMouseInputEnabled(true)
_G.mainMenu:ScreenshotScan("backgrounds/")

local _,dir = file.Find("gamemodes/*","GAME")
for k, v in pairs(dir) do
    if v == "base" then continue end
    _G.mainMenu:ScreenshotScan( "gamemodes/"..v.."/backgrounds/" )
end

local mmPaint = mainMenu.Paint

function mainMenu:Paint(w,h)
    mmPaint(self,w,h)

    draw.SimpleText("Cashout v"..CASHOUT_VERSION, "BudgetLabel", ScrW()-2, 72, Color(255,255,255), 2)
    draw.SimpleText(("Garry's Mod %s%s"):format(VERSIONSTR,(BRANCH ~= "unknown" and " ["..BRANCH.."]" or "")), "BudgetLabel", ScrW()-2, 58, Color(255,255,255), 2)
end

local nav = vgui.Create("EditablePanel", mainMenu)
nav:Dock(TOP)
nav:SetTall(56)

function nav:Paint(w,h)
    draw.RoundedBox(0,0,0,w,h,Color(0,0,0,200))
end

local logo = vgui.Create("EditablePanel", nav)
logo:Dock(LEFT)
logo:DockMargin(50,0,50,0)
surface.SetFont("Cashout_GModLogo")
logo:SetWide(62+surface.GetTextSize("garry's mod"))

function logo:Paint(w,h)
    draw.RoundedBox(4,4,4,48,48,Color(18,149,241))
    draw.SimpleText("g", "Cashout_GModLogo", 48/2+4, 48/2, Color(255,255,255), 1, 1)
    draw.SimpleText("garry's mod", "Cashout_GModLogo", 58, h/2-2, Color(255,255,255), TEXT_ALIGN_LEFT, 1)
end

local btnPlay = vgui.Create("DButton", nav)
btnPlay:Dock(LEFT)
btnPlay:SetWide(192)
btnPlay:SetText("")
btnPlay.alpha = 128

function btnPlay:Paint(w,h)
    self.alpha = Lerp(0.05,self.alpha,self.Hovered and 128 or 0)
    draw.RoundedBox(0,0,0,w,h,Color(0,128,255,self.alpha))
    draw.SimpleText("Play", "DermaLarge", w/2, h/2, Color(255,255,255,self.alpha+127), 1, 1)

    surface.SetDrawColor(Color(255,255,255,self.alpha+127))
    surface.DrawLine(0, 0, 0, h)
    surface.DrawLine(1, 0, 1, h)
    surface.DrawLine(w-1, 0, w-1, h)
end

function btnPlay:DoClick()
    local dmenu = DermaMenu()
    dmenu:AddOption("Singleplayer",function() CashoutNewGame() end):SetIcon("icon16/world_add.png")
    dmenu:AddOption("Multiplayer",function() CashoutServers() end):SetIcon("icon16/group.png")
    dmenu:AddOption("Valve Browser",function() RunGameUICommand("openserverbrowser") end):SetIcon("icon16/server_database.png")
    dmenu:Open()
    surface.SetFont("Cashout_GModLogo")
    dmenu:SetPos(62+surface.GetTextSize("garry's mod")+100,56)
    dmenu:SetWide(192)
end

local btnAddons = vgui.Create("DButton", nav)
btnAddons:Dock(LEFT)
btnAddons:SetWide(192)
btnAddons:SetText("")
btnAddons.alpha = 128

function btnAddons:Paint(w,h)
    self.alpha = Lerp(0.05,self.alpha,self.Hovered and 128 or 0)
    draw.RoundedBox(0,0,0,w,h,Color(0,192,0,self.alpha))
    draw.SimpleText("Addons", "DermaLarge", w/2, h/2, Color(255,255,255,self.alpha+127), 1, 1)

    surface.SetDrawColor(Color(255,255,255,self.alpha+127))
    surface.DrawLine(0, 0, 0, h)
    surface.DrawLine(w-1, 0, w-1, h)
end

function btnAddons:DoClick() CashoutAddons() end

local btnOptions = vgui.Create("DButton", nav)
btnOptions:Dock(LEFT)
btnOptions:SetWide(192)
btnOptions:SetText("")
btnOptions.alpha = 128

function btnOptions:Paint(w,h)
    self.alpha = Lerp(0.05,self.alpha,self.Hovered and 128 or 0)
    draw.RoundedBox(0,0,0,w,h,Color(255,192,0,self.alpha))
    draw.SimpleText("Options", "DermaLarge", w/2, h/2, Color(255,255,255,self.alpha+127), 1, 1)

    surface.SetDrawColor(Color(255,255,255,self.alpha+127))
    surface.DrawLine(0, 0, 0, h)
    surface.DrawLine(w-1, 0, w-1, h)
end

function btnOptions:DoClick()
    local dmenu = DermaMenu()
    dmenu:AddOption("Game Settings",function() RunGameUICommand("openoptionsdialog") end):SetIcon("icon16/wrench.png")
    dmenu:AddOption("#mounted_games",function() CashoutOpenMounts() end):SetIcon("icon16/controller.png")
    dmenu:Open()
    surface.SetFont("Cashout_GModLogo")
    dmenu:SetPos(62+surface.GetTextSize("garry's mod")+100+(192*2),56)
    dmenu:SetWide(192)
end

local exit = vgui.Create("DButton", nav)
exit:Dock(RIGHT)
exit:SetWide(56)
exit:SetText("")
exit.alpha = 128

function exit:Paint(w,h)
    self.alpha = Lerp(0.05,self.alpha,self.Hovered and 255 or 128)
    draw.RoundedBox(0,0,0,w,h,Color(244,67,54,self.alpha))
    draw.SimpleText("X", "DermaLarge", w/2, h/2, Color(255,255,255,self.alpha), 1, 1)
end

function exit:DoClick() RunGameUICommand("quitnoconfirm") end

local btnDisconenct = vgui.Create("DButton", nav)
btnDisconenct:Dock(RIGHT)
btnDisconenct:SetWide(192)
btnDisconenct:SetText("")
btnDisconenct.alpha = 128

function btnDisconenct:Paint(w,h)
    self.alpha = Lerp(0.05,self.alpha,self.Hovered and 128 or 0)
    draw.RoundedBox(0,0,0,w,h,Color(0,128,255,self.alpha))
    draw.SimpleText("Disconnect", "DermaLarge", w/2, h/2, Color(255,255,255,self.alpha+127), 1, 1)

    surface.SetDrawColor(Color(255,255,255,self.alpha+127))
    surface.DrawLine(0, 0, 0, h)
    surface.DrawLine(w-1, 0, w-1, h)
end

function mainMenu:Think()
    if IsInGame() then
        btnDisconenct:SetVisible(true)
    else
        btnDisconenct:SetVisible(false)
    end
end

function btnDisconenct:DoClick() RunGameUICommand("disconnect") end

local loadingbar = vgui.Create("EditablePanel", mainMenu)
loadingbar:Dock(BOTTOM)
loadingbar:SetTall(32)

local x = 0
function loadingbar:Paint(w,h)
    if not GetLoadStatus() then return end
    draw.RoundedBox(0, 0, 0, w, h, Color(64,64,64))
    draw.RoundedBox(4, x, 0, 128, h, Color(0,192,0))

    x=x+1
    if x > ScrW() then x = -128 end

    draw.SimpleText(GetLoadStatus() or "", "ChatFont", w/2, h/2, Color(255,255,255), 1, 1)

    DisableClipping(true)
        draw.SimpleText("Files Remaining: "..(GetDownloadables() and #GetDownloadables() or 0),"ChatFont",2,-18,Color(255,255,255))
    DisableClipping(false)
end