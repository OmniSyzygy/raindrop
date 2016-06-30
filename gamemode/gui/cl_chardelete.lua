surface.CreateFont("RD.DeleteFont", {
	font = "Constantia",
	size = 30,
	weight = 0
});

local panelMat = Material("stalker/ui_hint_wnd_no_tab.png");
local confirmMat = Material("stalker/ui_button_confirm.png");
local confirmDownMat = Material("stalker/ui_button_confirm_down.png");
local cancelMat = Material("stalker/ui_button_cancel.png");
local cancelDownMat = Material("stalker/ui_button_cancel_down.png");

local colorWhite = Color(255, 255, 255, 255);

local PANEL = {}

function PANEL:Init()
	local scrW, scrH = ScrW(), ScrH();

	local topbar = vgui.Create("DPanel", self)
	local mid = vgui.Create("DPanel", self)
	local bottom = vgui.Create("DPanel", self)

	self:SetSize(scrW, scrH + 22)

	topbar:Dock(TOP)
	topbar:SetSize(scrW, scrH*0.2)
	topbar.Paint = function()
		local w, h = topbar:GetSize()
		rain.skin.paintpanel(w, h, topbar, Color(0, 0, 0, 250))
	end
	mid:Dock(TOP)
	mid:SetSize(scrW, scrH*0.7)
	mid.Paint = function()
		local w, h = mid:GetSize()
		rain.skin.paintpanel(w, h, mid, Color(0, 0, 0, 220))
	end
	bottom:Dock(TOP)
	bottom:SetSize(scrW, scrH*0.1)
	bottom.Paint = function()
		local w, h = bottom:GetSize()
		rain.skin.paintpanel(w, h, bottom, Color(0, 0, 0, 250))
	end

	local text = "CHOOSE A CHARACTER TO REMOVE"

	local gamemodetitle_bd = vgui.Create("DLabel", topbar)
	gamemodetitle_bd:Dock(FILL)
	gamemodetitle_bd:SetContentAlignment(5)
	gamemodetitle_bd:SetText(text)
	gamemodetitle_bd:SetFont("TitleFontBlur")
	gamemodetitle_bd:SetTextColor(Color(0,0,0,255))

	local gamemodetitle = vgui.Create("DLabel", topbar)
	gamemodetitle:Dock(FILL)
	gamemodetitle:SetContentAlignment(5)
	gamemodetitle:SetText(text)
	gamemodetitle:SetFont("TitleFont")

	local midbar = vgui.Create("DPanel", mid)
	midbar:SetSize(450, mid:GetTall())
	midbar:SetPos((mid:GetWide()/2) - (midbar:GetWide()/2))
	midbar.Paint = function()
		local w, h = midbar:GetSize()
		rain.skin.paintpanel(w, h, bottom, Color(0,0,0,60))
	end

	for k, character in pairs(rain.pdata.getcharacters()) do
		local charbutton = vgui.Create("RD_MenuButton", midbar)
		charbutton:Dock(TOP)
		charbutton:SetText(character.charname)
		charbutton.charID = character.id;
		charbutton.DoClick = function()
			if (self.confirm) then
				self.confirm:Remove();
			end;

			self.confirm = vgui.Create("DPanel", self);
			self.confirm:SetSize(scrW * 0.2, scrH * 0.15);
			self.confirm:SetPos((scrW * 0.5) - (self.confirm:GetWide() * 0.5), (scrH * 0.5) - (self.confirm:GetTall() * 0.5));

			function self.confirm:Paint(w, h)
				surface.SetDrawColor(colorWhite);
				surface.SetMaterial(panelMat);
				surface.DrawTexturedRect(0, 0, w, h);
				
				draw.DrawText("Delete this character?", "RD.DeleteFont", w * 0.5, h * 0.15, colorWhite, TEXT_ALIGN_CENTER);
				draw.DrawText(character.charname, "RD.DeleteFont", w * 0.5, h * 0.37, colorWhite, TEXT_ALIGN_CENTER);
			end;

			local yes = vgui.Create("RD_CreationImageButton", self.confirm);

			yes:SetSize(self.confirm:GetWide() * 0.3, self.confirm:GetTall() * 0.25);
			yes:SetPos((self.confirm:GetWide() * 0.3) - (yes:GetWide() * 0.5), (self.confirm:GetTall() * 0.9) - yes:GetTall());
			yes.image = confirmMat;
			yes.downImage = confirmDownMat;

			yes.DoClick = function()
				net.Start("rain.chardelete")
					rain.net.WriteShortInt(character.id);
				net.SendToServer();
			end;

			local no = vgui.Create("RD_CreationImageButton", self.confirm);

			no:SetSize(self.confirm:GetWide() * 0.3, self.confirm:GetTall() * 0.25);
			no:SetPos((self.confirm:GetWide() * 0.7) - (no:GetWide() * 0.5), (self.confirm:GetTall() * 0.9) - no:GetTall());
			no.image = cancelMat;
			no.downImage = cancelDownMat;

			no.DoClick = function()
				self.confirm:Remove();
				self.confirm = nil;
			end;
		end
	end

	local back = vgui.Create("RD_MenuButton", midbar)
	back:Dock(BOTTOM)
	back:SetText("Back")
	back.DoClick = function()
		self:Remove()

		rain.MainMenuUI = vgui.Create("RD_MainMenu")
		rain.MainMenuUI:MakePopup()
	end
end

function PANEL:Paint()
	DrawBlurRect(0, 0, self:GetWide(), self:GetTall(), 5, 2)
end

derma.DefineControl("RD_CharDelete", "", PANEL, "DPanel")