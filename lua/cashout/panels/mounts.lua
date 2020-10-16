local PANEL = {}

function PANEL:Init()
    self:SetSize(256, 384)
    self:SetTitle("#mounted_games")
    self:SetIcon("icon16/controller.png")

    self:Center()
    self:MakePopup()

    self.list = vgui.Create("DScrollPanel", self)
    self.list:Dock(FILL)

    self.btnMaxim:SetVisible(false)
    self.btnMinim:SetVisible(false)

    local games = engine.GetGames()
    table.sort(games, function(a, b)
        if a.mounted == b.mounted then
            if a.mounted then
                return a.depot < b.depot
            else
                return ((a.installed and a.owned) and 0 or 1) < ((b.installed and b.owned) and 0 or 1)
            end
        else
            return (a.mounted and 0 or 1) < (b.mounted and 0 or 1)
        end
    end)

    for _, data in ipairs(games) do
        self:AddGame(data, data.title, data.mounted, data.owned, data.installed, data.depot)
    end
end

function PANEL:AddGame(data, title, mounted, owned, installed, depot)
    local btn = vgui.Create("DCheckBoxLabel", gameslist, "gameslist_button")
    self.list:Add(btn)
    btn:SetText(title)
    btn:SetChecked(mounted)
    btn:SetBright(true)
    btn:SetDisabled(not owned or not installed)
    btn:SizeToContents()

    function btn:OnChange(val)
        engine.SetMounted(depot, val)
        btn:SetChecked(IsMounted(depot))
    end

    btn:InvalidateLayout(true)
    btn:Dock(TOP)
    btn:DockPadding(0, 0, 0, 8)
end

vgui.Register("CashoutMounts", PANEL, "DFrame")

function CashoutOpenMounts()
    if IsValid(_G.MountedGames) then
        _G.MountedGames:Remove()
    end

    _G.MountedGames = vgui.Create("CashoutMounts")
end