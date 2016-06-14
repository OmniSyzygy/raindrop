surface.CreateFont("RD.SettingsFont", {
	font = "Constantia",
	size = 25,
	weight = 0
})

local backMat = Material("stalker/ui_options_background.png");
local panelMat = Material("stalker/ui_hint_wnd.png");

local categoryButton = Material("stalker/ui_category_button.png");
local categoryHighlight = Material("stalker/ui_category_button_highlight.png");
local categoryHover = Material("stalker/ui_category_button_hover.png");

local endButton = Material("stalker/ui_category_end.png");
local endHighlight = Material("stalker/ui_category_end_highlight.png");
local endHover = Material("stalker/ui_category_end_hover.png");

local comboBack = Material("stalker/ui_combobox_back.png");
local comboOptions = Material("stalker/ui_combobox_options_back.png");
local comboArrow = Material("stalker/ui_combobox_arrow.png");

local lightGray = Color(200, 200, 200, 255);
local colorGray = Color(150, 150, 150, 255);

local PANEL = {}

function PANEL:Init()
	local scrW, scrH = ScrW(), ScrH();

	self:SetSize(scrW, scrH);

	local optionMenu = vgui.Create("DPanel", self);

	optionMenu:SetPos(scrW * 0.46, scrH * 0.35);
	optionMenu:SetSize(scrW * 0.4, scrH * 0.6);

	function optionMenu:Paint(w, h)
		surface.SetDrawColor(255, 255, 255, 255);
		surface.SetMaterial(panelMat);
		surface.DrawTexturedRect(0, 0, w, h);
	end;

	local cancelButton = vgui.Create("RD_CreationImageButton", optionMenu);

	cancelButton:SetPos(optionMenu:GetWide() * 0.5 - cancelButton:GetWide() * 0.5, optionMenu:GetTall() * 0.94);
	cancelButton:SetText("Close");

	cancelButton.DoClick = function()
		rain.MainMenuUI:Remove();
		rain.MainMenuUI = vgui.Create("RD_MainMenu");
		rain.MainMenuUI:MakePopup();
	end;

	local activeButtons = {
		{
			name = "Theme",
			menu = "RD_ThemeSettings"
		},
		{
			name = "Sound",
			menu = "RD_SoundSettings"
		}
	};

	local offset = optionMenu:GetWide() * 0.075;
	local buttonWidth = optionMenu:GetWide() * 0.3;
	local listAmount = #activeButtons;
	local width = (buttonWidth * listAmount) - (offset * (listAmount - 1));
	local middle = (optionMenu:GetWide() * 0.5) - (width * 0.5);
	local x = middle;

	for k, v in ipairs(activeButtons) do
		if (!v.callback or (v.callback and v.callback(optionMenu))) then
			local button = vgui.Create("RD_MenuButton", optionMenu);
			local isEnd = (k == #activeButtons);

			button:SetSize(buttonWidth, optionMenu:GetTall() * 0.1);
			button:SetPos(x, optionMenu:GetTall() * 0.05);
			button:SetText(v.name);
			button:SetTextColor(lightGray);
			button:SetFont("RD.CategoryButtonFont");

			function button:Paint(w, h)
				if (optionMenu.activeMenu and optionMenu.activeMenu:GetName() == v.menu) then
					surface.SetDrawColor(255, 255, 255, 255);

					if (isEnd) then
						surface.SetMaterial(endHighlight);
					else
						surface.SetMaterial(categoryHighlight);
					end;

					surface.DrawTexturedRect(0, 0, w, h);
				elseif (self:IsHovered()) then
					surface.SetDrawColor(255, 255, 255, 255);

					if (isEnd) then
						surface.SetMaterial(endHover);
					else
						surface.SetMaterial(categoryHover);
					end;

					surface.DrawTexturedRect(0, 0, w, h);
				end;
			
				surface.SetDrawColor(255, 255, 255, 255);

				if (isEnd) then
					surface.SetMaterial(endButton);
				else
					surface.SetMaterial(categoryButton);
				end;

				surface.DrawTexturedRect(0, 0, w, h);
			end;

			if (v.menu != optionMenu.activeMenu) then
				function button:DoClick()
					if (v.menu and v.menu != "") then
						local lastMenu;

						if (optionMenu.activeMenu) then
							lastMenu = optionMenu.activeMenu:GetName();

							optionMenu.activeMenu:Remove();
							optionMenu.activeMenu = nil;
						end;

						if (!optionMenu.activeMenu and lastMenu != v.menu) then
							optionMenu.activeMenu = vgui.Create(v.menu, optionMenu);
							optionMenu.activeMenu:SetPos(optionMenu:GetWide() * 0.05, optionMenu:GetTall() * 0.17);
						end;
					end;
				end;

				-- Default the menu to the first menu so that there isn't a blank panel when it opens.
				if (k == 1) then
					button:DoClick();
				end;
			end;

			x = x + (buttonWidth - offset);
		end;
	end;
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(255, 255, 255, 255);
	surface.SetMaterial(backMat);
	surface.DrawTexturedRect(0, 0, w, h);
end

vgui.Register("RD_SettingsMenu", PANEL, "EditablePanel");

local PANEL = {};

function PANEL:Init()
	local parent = self:GetParent():GetParent();

	self.text = "";
	self:SetSize(parent:GetWide(), parent:GetTall() * 0.055);

	self.comboBox = vgui.Create("DComboBox", self);
	self.comboBox:SetSize(self:GetWide() * 0.5, self:GetTall());
	self.comboBox:SetPos(self:GetWide() * 0.4, self:GetTall() * 0.5 - self.comboBox:GetTall() * 0.5);
	self.comboBox:SetTextColor(colorGray);

	function self.comboBox:Paint(w, h)
		surface.SetDrawColor(255, 255, 255, 255);
		surface.SetMaterial(comboBack);
		surface.DrawTexturedRect(0, 0, w, h);

		local arrow = self.DropButton;

		surface.SetDrawColor(255, 255, 255, 255);
		surface.SetMaterial(comboArrow);
		surface.DrawTexturedRect(w - arrow:GetWide(), 0, arrow:GetWide(), h);
	end;

	function self.comboBox.DropButton:Paint(w, h)
	end;
end;

function PANEL:GetComboBox()
	return self.comboBox;
end;

function PANEL:SetText(sText)
	self.text = sText;
end;

function PANEL:Paint(w, h)
	draw.SimpleText(self.text, "RD.SettingsFont", self:GetWide() * 0.35, self:GetTall() * 0.5, colorGray, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER);
end;

vgui.Register("RD_ComboBoxSetting", PANEL, "DPanel");

local themeSettings = {
	{
		name = "Menu Style",
		settingType = "RD_ComboBoxSetting",
		callback = function(panel, choices)
			panel = panel:GetComboBox();

			for k, v in pairs(choices) do
				panel:AddChoice(k);

				if (v == GetConVar("RD_STALKER_MENUTYPE"):GetInt()) then
					panel:SetText(k);
				end;
			end;

			function panel:OnSelect(index, value)
				return GetConVar("RD_STALKER_MENUTYPE"):SetInt(choices[value]);
			end;
		end,
		choices = {
			["Clear Sky"] = MENU_CLEARSKY,
			["Call of Pripyat"] = MENU_CALLOFPRIPYAT
		}
	}
};

local PANEL = {};

function PANEL:Init()
	local parent = self:GetParent();
	local buttons = {};
	local y = 0;

	self:SetSize(parent:GetWide() * 0.90, parent:GetTall() * 0.75);

	for k, v in pairs(themeSettings) do
		local setting = vgui.Create(v.settingType, self);

		if (v.callback) then
			v.callback(setting, v.choices);
		end;

		if (v.name) then
			setting:SetText(v.name);
		end;

		setting:SetPos(0, y);

		y = y + setting:GetTall() * 1.6;

		buttons[#buttons + 1] = setting;
	end;
end;

function PANEL:Paint(w, h)
end;

vgui.Register("RD_ThemeSettings", PANEL, "DScrollPanel");

--[[
local soundSettings = {
	{
		name = "Enable music",
		settingType = "RD_CheckBoxSetting",
		callback = function(panel, choices)
			panel = panel:GetComboBox();

			for k, v in pairs(choices) do
				panel:AddChoice(k);

				if (v == GetConVar("RD_STALKER_MENUTYPE"):GetInt()) then
					panel:SetText(k);
				end;
			end;

			function panel:OnSelect(index, value)
				return GetConVar("RD_STALKER_MENUTYPE"):SetInt(choices[value]);
			end;
		end,
		choices = {
			["Clear Sky"] = MENU_CLEARSKY,
			["Call of Pripyat"] = MENU_CALLOFPRIPYAT
		}
	}
};
--]]

local PANEL = {};

function PANEL:Init()
end;

function PANEL:Paint(w, h)
end;

vgui.Register("RD_SoundSettings", PANEL, "DScrollPanel");