local PANEL = {}

function PANEL:Init()
    self:SetSize(384, 384)

    self:SetTitle("Quick Connect Editor")
    self:SetIcon("icon16/star.png")
    self:Center()
    self:MakePopup()

    self.btnMaxim:SetVisible(false)
    self.btnMinim:SetVisible(false)

    self.List = self:Add("DListView")
    self.List:Dock(FILL)
    self.List:AddColumn("Name")
    self.List:AddColumn("IP")

    for ip, name in pairs(Cashout.Favorites) do
        self.List:AddLine(name, ip)
    end

    self.List.OnRowRightClick = function(s, index, line)
        local name, ip = line:GetColumnText(1), line:GetColumnText(2)

        local m = DermaMenu()
        m:AddOption("Change IP", function()
            Derma_StringRequest("Change IP - " .. name, "Enter new IP", ip, function(new)
                Cashout.ChangeServerIP(ip, new)
                line:SetColumnText(2, new)
            end)
        end):SetIcon("icon16/server_edit.png")
        m:AddOption("Rename", function()
            Derma_StringRequest("Change Name - " .. ip, "Enter new name", name, function(new)
                Cashout.ChangeServerName(ip, new)
                line:SetColumnText(1, new)
            end)
        end):SetIcon("icon16/textfield_rename.png")
        m:AddOption("Remove", function()
            Derma_Query("Are you sure you want to remove this server from Quick Connect?\n(You can always readd it back.)", "Remove from Quick Connect", "Yes", function()
                Cashout.RemoveServerFromFavorites(ip)
                s:RemoveLine(index)
            end, "No")
        end):SetIcon("icon16/cross.png")
        m:Open()
    end

    self.AddManual = self:Add("DButton")
    self.AddManual:Dock(BOTTOM)
    self.AddManual:SetText("Add Server Manually")
    self.AddManual.DoClick = function(s)
        Derma_StringRequest("New Server", "Enter name", "", function(name)
            Derma_StringRequest("New Server", "Enter IP", "", function(ip)
                Cashout.AddServerToFavorites(name, ip)
                self.List:AddLine(name, ip)
            end)
        end)
    end
end

vgui.Register("CashoutQuickConnectEditor", PANEL, "DFrame")

function CashoutOpenQuickConnectEditor()
    if IsValid(_G.QuickConnectEditor) then
        _G.QuickConnectEditor:Remove()
    end

    _G.QuickConnectEditor = vgui.Create("CashoutQuickConnectEditor")
end