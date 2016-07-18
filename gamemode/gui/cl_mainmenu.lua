MENU_CLEARSKY = 1;
MENU_CALLOFPRIPYAT = 2;

surface.CreateFont("TitleFont", {
	font = "GraffitiOne",
	size = 92,
	weight = 600
})

surface.CreateFont("TitleFontBlur", {
	font = "GraffitiOne",
	size = 92,
	weight = 600,
	blursize = 7.5,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

CreateClientConVar("RD_STALKER_MENUTYPE", MENU_CALLOFPRIPYAT);

local mainMenuType;

-- Precached Materials
local backMat = Material("stalker/ui_mainmenu_background.png");
local selectMat = Material("stalker/ui_selector2.png");

-- Precached Colors
local colorWhite = Color(255, 255, 255);
local colorBlack = Color(0, 0, 0);
local colorGray = Color(100, 100, 100);

local colorText = colorBlack;

-- Selector Interpolation Variables
local lerpDuration = 0.2;
local lerpTarget;
local lerpOrigin;
local lerpStart;

-- Selector Dimension Variables.
local selectorY;
local selectorH;
local selectorOffset;

local PANEL = {}

function PANEL:Init()
	local scrW, scrH = ScrW(), ScrH();

	mainMenuType = GetConVar("RD_STALKER_MENUTYPE"):GetInt();

	-- Incase the convar returns something other than a number.
	if (mainMenuType <= 0 or mainMenuType > 2) then
		mainMenuType = MENU_CALLOFPRIPYAT;
	end;

	rain.sound:PlayMenuMusic();

	self:SetSize(scrW, scrH);

	selectorH = scrH * 0.06;
	selectorOffset = selectorH * 0.2;
	selectorY = scrH * 0.560 - selectorOffset;

	local buttonW, buttonH = scrW * 0.2, scrH * 0.035;
	local buttonX, buttonY = (scrW * 0.241) - (buttonW * 0.5), scrH * 0.559;
	local buttonOffset = scrH * 0.0448;

	if (mainMenuType == 2) then
		selectorY = scrH * 0.43 - selectorOffset;
		selectorH = scrH * 0.08;
		selectorOffset = selectorH * 0.28;

		buttonX, buttonY = (scrW * 0.185) - (buttonW * 0.5), scrH * 0.44;
		buttonOffset = scrH * 0.05;

		colorText = colorWhite;
		backMat = Material("stalker/ui_mainmenu_background2.png");
		selectMat = Material("stalker/selector.png");
	elseif (mainMenuType == 1) then
		colorText = colorBlack;
		backMat = Material("stalker/ui_mainmenu_background.png");
		selectMat = Material("stalker/ui_selector2.png");
	end;

	local newchar = vgui.Create("RD_MenuButton", self)
--	newchar:Dock(TOP)
	newchar:SetSize(buttonW, buttonH);
	newchar:SetPos(buttonX, buttonY);
	newchar:SetTextColor(colorText);
	newchar:SetText("Create Character")
	newchar.DoClick = function()
		self:CloseMenu();

		rain.MainMenuUI = vgui.Create("RD_CharCreation");
		rain.MainMenuUI:MakePopup();
	end

	function newchar:Think()
		if (self:IsHovered() and selectorY != self.y - selectorOffset and lerpTarget != self.y - selectorOffset) then
			PANEL:SetSelectorY(self.y);
		end;
	end

	buttonY = buttonY + buttonOffset;

	local loadchar = vgui.Create("RD_MenuButton", self)
	loadchar:SetSize(buttonW, buttonH);
	loadchar:SetPos(buttonX, buttonY);

	loadchar:SetText("Load Character")
	loadchar.DoClick = function()
		self:CloseMenu()

		rain.MainMenuUI = vgui.Create("RD_Charselect")
		rain.MainMenuUI:MakePopup()
	end

	function loadchar:Think()
		local chars = rain.pdata.getcharacters();

		if (!chars or #chars == 0) then
			loadchar:SetTextColor(colorGray);
			loadchar:SetDisabled(true);
		elseif (rain.pdata.canloadcharacters()) then
			loadchar:SetTextColor(colorText);
			loadchar:SetDisabled(false);
		end;

		if (self:IsHovered() and selectorY != self.y - selectorOffset and lerpTarget != self.y - selectorOffset) then
			PANEL:SetSelectorY(self.y);
		end;
	end

	buttonY = buttonY + buttonOffset;

	local deletechar = vgui.Create("RD_MenuButton", self)
	deletechar:SetSize(buttonW, buttonH);
	deletechar:SetPos(buttonX, buttonY);

	deletechar:SetText("Delete Character")
	deletechar.DoClick = function()
		self:CloseMenu();

		rain.MainMenuUI = vgui.Create("RD_CharDelete");
		rain.MainMenuUI:MakePopup();
	end

	function deletechar:Think()
		local chars = rain.pdata.getcharacters();
		
		if (!chars or #chars == 0) then
			deletechar:SetTextColor(colorGray);
			deletechar:SetDisabled(true);
		elseif (rain.pdata.canloadcharacters()) then
			deletechar:SetTextColor(colorText);
			deletechar:SetDisabled(false);
		end;

		if (self:IsHovered() and selectorY != self.y - selectorOffset and lerpTarget != self.y - selectorOffset) then
			PANEL:SetSelectorY(self.y);
		end;
	end

	buttonY = buttonY + buttonOffset;
--[[
	local changetheme = vgui.Create("RD_MenuButton", self)
	changetheme:SetSize(buttonW, buttonH);
	changetheme:SetPos(buttonX, buttonY);
	changetheme:SetTextColor(colorText);

	--local mainMenuType = MENU_CALLOFPRIPYAT;
	--local mainMenuType = MENU_CLEARSKY;

	if (mainMenuType == MENU_CALLOFPRIPYAT) then
		changetheme:SetText("Use Clear Sky UI");
	elseif (mainMenuType == MENU_CLEARSKY) then
		changetheme:SetText("Use Call of Pripyat UI");
	end;

	changetheme.DoClick = function()
		mainMenuType = mainMenuType + 1;

		if (mainMenuType >= 3) then
			mainMenuType = 1;
		end;

		self:CloseMenu();

		rain.MainMenuUI = vgui.Create("RD_MainMenu");
		rain.MainMenuUI:MakePopup();
	end

	function changetheme:Think()
		if (self:IsHovered() and selectorY != self.y - selectorOffset and lerpTarget != self.y - selectorOffset) then
			PANEL:SetSelectorY(self.y);
		end;
	end

	buttonY = buttonY + buttonOffset;
--]]
	local setting = vgui.Create("RD_MenuButton", self)
	setting:SetSize(buttonW, buttonH);
	setting:SetPos(buttonX, buttonY);
	setting:SetTextColor(colorText);
	setting:SetText("Settings")
	setting.DoClick = function()
		self:CloseMenu();

		rain.MainMenuUI = vgui.Create("RD_SettingsMenu");
		rain.MainMenuUI:MakePopup();
	end

	function setting:Think()
		if (self:IsHovered() and selectorY != self.y - selectorOffset and lerpTarget != self.y - selectorOffset) then
			PANEL:SetSelectorY(self.y);
		end;
	end

	buttonY = buttonY + buttonOffset;

	local exit = vgui.Create("RD_MenuButton", self)
	exit:SetSize(buttonW, buttonH);
	exit:SetPos(buttonX, buttonY);
	exit:SetTextColor(colorText);
	exit:SetText("Disconnect")
	exit.DoClick = function()
		RunConsoleCommand("disconnect")
	end

	function exit:Think()
		if (self:IsHovered() and selectorY != self.y - selectorOffset and lerpTarget != self.y - selectorOffset) then
			PANEL:SetSelectorY(self.y);
		end;
	end
	
	buttonY = buttonY + buttonOffset;

	--[[
	local quit = vgui.Create("RD_MenuButton", self)
	quit:SetSize(buttonW, buttonH);
	quit:SetPos(buttonX, buttonY);
	quit:SetTextColor(colorText);
	quit:SetText("Exit to Desktop")
	quit.DoClick = function()
		RunConsoleCommand("quit")
	end

	function quit:Think()
		if (self:IsHovered() and selectorY != self.y - selectorOffset and lerpTarget != self.y - selectorOffset) then
			PANEL:SetSelectorY(self.y);
		end;
	end
	--]]
end

function PANEL:SetSelectorY(y)
	if (selectorOffset and isnumber(selectorOffset)) then
		lerpTarget = y - selectorOffset;
		lerpOrigin = selectorY or ScrH() * 0.560;
		lerpStart = CurTime();
	end;
end;

function PANEL:Think()
	if (lerpTarget) then
		local fraction = (CurTime() - lerpStart) / lerpDuration;

		if (fraction <= 1) then
			selectorY = COSerp(fraction, lerpOrigin, lerpTarget);
		else
			lerpTarget = nil;
		end;
	end;
end;

function PANEL:Paint(w, h)
	surface.SetDrawColor(255, 255, 255, 255);
	surface.SetMaterial(backMat);
	surface.DrawTexturedRect(0, 0, w, h);
end

function PANEL:PaintOver(w, h)
	local scrW, scrH = ScrW(), ScrH();

	-- Draw the selector.
	local selectW = scrW * 0.27;
	local selectX = (scrW * 0.241) - (selectW * 0.5);

	if (mainMenuType == 2) then
		selectW = scrW * 0.265
		selectX = (scrW * 0.1815) - (selectW * 0.5);
	end;

	surface.SetDrawColor(255, 255, 255, 255);
	surface.SetMaterial(selectMat);
	surface.DrawTexturedRect(selectX, selectorY, selectW, selectorH);
end;

function PANEL:CloseMenu()
	self:Remove()
end

derma.DefineControl("RD_MainMenu", "", PANEL, "DPanel")