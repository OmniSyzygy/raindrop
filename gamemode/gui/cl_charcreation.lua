local VIEW_FULL = 0;
local VIEW_FACE = 1;
local VIEW_WEAPON = 2;

local colorBlack = Color(50, 50, 50, 250);
local lightWhite = Color(150, 150, 150, 100);
local colorWhite = Color(255, 255, 255, 255);

local panelBackMat = Material("stalker/ui_hint_wnd.png");

local categoryButton = Material("stalker/ui_category_button.png");
local categoryHighlight = Material("stalker/ui_category_button_highlight.png");
local categoryHover = Material("stalker/ui_category_button_hover.png");

local endButton = Material("stalker/ui_category_end.png");
local endHighlight = Material("stalker/ui_category_end_highlight.png");
local endHover = Material("stalker/ui_category_end_hover.png");

local buttonMat = Material("stalker/ui_button.png");
local buttonDownMat = Material("stalker/ui_button_down.png");

local backMat = Material("stalker/ui_staff_background.png");
local foreMat = Material("stalker/ui_ingame2_back_02.png");

local scrollBackMat = Material("stalker/ui_scroll_back.png");
local scrollUpMat = Material("stalker/ui_scroll_up.png");
local scrollDownMat = Material("stalker/ui_scroll_down.png");
local scrollBarMat = Material("stalker/ui_scroll_box.png");

local PANEL = {};

function PANEL:Init()
	self:SetModel("models/player/kleiner.mdl");
	self:SetView(VIEW_FULL);
end;

local viewCheck = {
	[VIEW_FACE] = function(panel)
		local ent = panel:GetEntity();
		local headPos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Head1"));		

		panel:LerpSetCamPos(headPos - Vector(-25, 0, 0));
		panel:LerpSetLookAt(headPos);
	end,
	[VIEW_FULL] = function(panel)
		panel:LerpSetCamPos(Vector(70, 70, 60));
		panel:LerpSetLookAt(Vector(0, 0, 35));
	end,
	[VIEW_WEAPON] = function(panel)
		local ent = panel:GetEntity();
		local bonePos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_R_Hand"));

		if (IsValid(panel.weaponEnt)) then
			bonePos = panel.weaponEnt:GetPos();
		end;

		panel:LerpSetCamPos(bonePos - Vector(-40, 15, 5));
		panel:LerpSetLookAt(bonePos);
	end
};

function PANEL:SetView(nView)
	local check = viewCheck[nView];

	if (check) then
		timer.Simple(0.3, function()
			check(self);
		end);
	end;
end;

function PANEL:DebugAttachmentList()
	timer.Simple(1, function()
		PrintTable(self:GetEntity():GetAttachments());
	end);
end;

function PANEL:DebugSequenceList()
	PrintTable(self:GetEntity():GetSequenceList());
end;

function PANEL:DebugFlexList()
	local ent = self:GetEntity();

	for i = 0, ent:GetFlexNum() - 1 do
		print(i, ent:GetFlexName(i), ent:GetFlexBounds(i));
	end;
end;

function PANEL:DebugBoneList()
	timer.Simple(1, function()
		local ent = self:GetEntity();

		for i = 0, ent:GetBoneCount() do
			print(i, ent:GetBoneName(tonumber(i)));
		end;
	end);
end;

function PANEL:SetAnimation(anim)
	if (!anim) then return; end;

	local ent = self:GetEntity();

	if (IsValid(ent)) then
		local seq = -1;

		--If it's a string then it's probably a sequence, and if it's a number, it's probably an ACT_Enum.
		if (isstring(anim)) then
			seq = ent:LookupSequence(anim);
		elseif (isnumber(anim)) then
			seq = ent:SelectWeightedSequence(anim);
		end;

		-- We do this check so our client doesn't crash if we supply an anim the model doesn't have.
		if (seq and seq >= 0) then
			ent:SetSequence(seq);
		end;
	end;
end;

function PANEL:OnMousePressed(key)
	if (key == MOUSE_LEFT) then
		self.bDragging = true;
	end;
end;

--[[ 
	Local variables needed for lerp.
--]]
local posLerpStart;
local posLerpProgress;
local posLerpTarget;
local posLerpOrigin;

local lookLerpStart;
local lookLerpProgress;
local lookLerpTarget;
local lookLerpOrigin;

local lerpDuration = 0.2;

function PANEL:LerpSetCamPos(vPos)
	posLerpStart = CurTime();
	posLerpProgress = 0;
	posLerpTarget = vPos;
	posLerpOrigin = self:GetCamPos();
end;

function PANEL:LerpSetLookAt(vPos)
	lookLerpStart = CurTime();
	lookLerpProgress = 0;
	lookLerpTarget = vPos;
	lookLerpOrigin = self:GetLookAt();
end;

function PANEL:Think()
	local curTime = CurTime();
	local ent = self:GetEntity();

	if (self.bDragging) then
		if (!input.IsMouseDown(MOUSE_LEFT)) then
			self.lastMouseX = nil;
			self.bDragging = false;

			return;
		end;	

		if (IsValid(ent)) then
			local mouseX, mouseY = input.GetCursorPos();

			if (!self.lastMouseX) then
				self.lastMouseX = mouseX;
			end;

			local mouseXDiff = mouseX - self.lastMouseX;
			local entAngles = ent:GetAngles();

			ent:SetAngles(entAngles + Angle(0, mouseXDiff, 0));

			self.lastMouseX = mouseX;
		end;
	end;

	if (posLerpTarget) then
		local fraction = (curTime - posLerpStart) / lerpDuration;

		if !(fraction >= 1) then
			self:SetCamPos(LerpVector(fraction, posLerpOrigin, posLerpTarget));
		else
			posLerpTarget = nil;
		end;
	end;

	if (lookLerpTarget) then
		local fraction = (curTime - lookLerpStart) / lerpDuration;

		if !(fraction >= 1) then
			self:SetLookAt(LerpVector(fraction, lookLerpOrigin, lookLerpTarget));
		else
			lookLerpTarget = nil;
		end;
	end;
end;

function PANEL:SetActiveModel(sPath)
	local parent = self:GetParent();

	self:GetEntity():SetModel(sPath);
--	self:DebugSequenceList();
	self:DebugFlexList()
	self:SetAnimation(ACT_IDLE);

	parent.creationData.model = sPath;
	parent.creationData.gender = parent.selectedGender;
end;

function PANEL:SetHeldWeapon(model)
	if (IsValid(self.weaponEnt)) then
		self.weaponEnt:Remove();
	end;

	if (model and model != "") then
		local ent = self:GetEntity();

		if (IsValid(ent)) then
			self.weaponEnt = ClientsideModel(model, RENDERGROUP_OPAQUE);

			if (IsValid(self.weaponEnt)) then
				self.weaponEnt:SetParent(ent, ent:LookupAttachment("anim_attachment_RH"));
				self.weaponEnt:SetNoDraw(true);
				self.weaponEnt:SetIK(false);
			end;
		end;
	end;
end;

function PANEL:PostDrawModel(ent)
	if (IsValid(self.weaponEnt)) then
		self.weaponEnt:DrawModel();
	end;
end;

function PANEL:LayoutEntity(ent)
	self:RunAnimation();
end;

vgui.Register("RD_CreationModelPanel", PANEL, "DModelPanel");

local PANEL = {};

function PANEL:Init()
	local scrW, scrH = ScrW(), ScrH();
	local parent = self:GetParent();

	self:SetSize(scrW * 0.30, scrH * 0.5);
	self:SetPos(scrW * 0.05, scrH * 0.1);

	parent.modelPanel:SetView(VIEW_FULL);

	self.scrollPanel = vgui.Create("DScrollPanel", self);
	self.scrollPanel:SetSize(self:GetWide() * 0.98, self:GetTall() * 0.7);
	self.scrollPanel:SetPos(self:GetWide() * 0.01, self:GetTall() * 0.2);

	local scrollBar = self.scrollPanel:GetVBar();

	function scrollBar:Paint(w, h)
		surface.SetDrawColor(255, 255, 255, 255);
		surface.SetMaterial(scrollBackMat);
		surface.DrawTexturedRect(0, 0, w, h);
	end;

	function scrollBar.btnUp:Paint(w, h)
		surface.SetDrawColor(255, 255, 255, 255);
		surface.SetMaterial(scrollUpMat);
		surface.DrawTexturedRect(0, 0, w, h);
	end;

	function scrollBar.btnDown:Paint(w, h)
		surface.SetDrawColor(255, 255, 255, 255);
		surface.SetMaterial(scrollDownMat);
		surface.DrawTexturedRect(0, 0, w, h);
	end;

	function scrollBar.btnGrip:Paint(w, h)
		surface.SetDrawColor(255, 255, 255, 255);
		surface.SetMaterial(scrollBarMat);
		surface.DrawTexturedRect(0, 0, w, h);
	end;

	self.modelList = vgui.Create("DIconLayout", self.scrollPanel);
	self.modelList:SetPos(self.scrollPanel:GetWide() * 0.08, 0);
	self.modelList:SetSize(self.scrollPanel:GetWide() * 0.9, self.scrollPanel:GetTall());
	self.modelList:SetSpaceX(self.scrollPanel:GetWide() * 0.03);
	self.modelList:SetSpaceY(self.scrollPanel:GetTall() * 0.03);

	parent.selectedGender = parent.creationData.gender;

	function self.modelList:AddModel(sPath)
		local spawnIcon = vgui.Create("SpawnIcon");

		spawnIcon:SetModel(sPath);
		spawnIcon.model = sPath;

		function spawnIcon:DoClick()
			parent.modelPanel:SetActiveModel(sPath);
		end;

		function spawnIcon:PaintOver(w, h)
			if (spawnIcon.model == parent.creationData.model) then
				draw.RoundedBox(10, 0, 0, w, h, lightWhite);
			end;
		end;

		self:Add(spawnIcon);
	end;

	function self.modelList:RefreshList()
		for k, v in pairs(self:GetChildren()) do
			v:Remove();
		end;

		local gender = parent.selectedGender or parent.creationData.gender;

		for i = 1, 7 do
			self:AddModel("models/Humans/Group01/"..gender.."_0"..i..".mdl");
		end;
	end;

	self.modelList:RefreshList();
	self.genderButtons = {};

	local genders = {
		"male",
		"female"
	};

	for k, v in ipairs(genders) do
		local button = vgui.Create("DImageButton", self);

		local offset = self:GetWide() * 0.2;

		button:SetSize(125, 30);
		button:SetPos((button:GetWide() * (k - 1)) + (offset * (k - 1)) + self:GetWide() * 0.18, self:GetTall() * 0.935);
		button:SetText(string.upper(v));
		button:SetTextColor(colorWhite);

		if (v == parent.creationData.gender) then
			button.image = buttonDownMat;
		else
			button.image = buttonMat;
		end;		

		function button:Paint(w, h)
			if (self.image) then
				surface.SetDrawColor(255, 255, 255, 255);
				surface.SetMaterial(self.image);
				surface.DrawTexturedRect(0, 0, w, h);
			end;
		end;

		function button:DoClick()
			parent:SetGender(v);
		end;

		self.genderButtons[v] = button;
	end;
end;

function PANEL:Paint(w, h)
	surface.SetDrawColor(255, 255, 255, 255);
	surface.SetMaterial(panelBackMat);
	surface.DrawTexturedRect(0, 0, w, h);
end;

vgui.Register("RD_CreationBody", PANEL, "DPanel");

local PANEL = {};

function PANEL:Init()
	local scrW, scrH = ScrW(), ScrH();
	local parent = self:GetParent();

	self:SetSize(scrH * 0.25, scrH * 0.25);
	self:SetPos(scrW * 0.1, scrH * 0.3);

	parent.modelPanel:SetView(VIEW_FACE);
end;

function PANEL:Paint(w, h)
	draw.RoundedBox(20, 0, 0, w, h, colorBlack);
end;

vgui.Register("RD_CreationFace", PANEL, "DPanel");

local PANEL = {};

function PANEL:Init()
	local scrW, scrH = ScrW(), ScrH();
	local parent = self:GetParent();

	self:SetSize(scrH * 0.25, scrH * 0.25);
	self:SetPos(scrW * 0.1, scrH * 0.3);

	parent.modelPanel:SetHeldWeapon("models/weapons/w_rif_ak47.mdl");
	parent.modelPanel:SetAnimation("Idle_Relaxed_AR2_2");
	parent.modelPanel:SetView(VIEW_WEAPON);
end;

function PANEL:OnRemove()
	local parent = self:GetParent();

	if (IsValid(parent)) then
		parent.modelPanel:SetHeldWeapon();
		parent.modelPanel:SetAnimation(ACT_IDLE);
	end;
end;

function PANEL:Paint(w, h)
	draw.RoundedBox(20, 0, 0, w, h, colorBlack);
end;

vgui.Register("RD_CreationGear", PANEL, "DPanel");

local PANEL = {};

function PANEL:Init()
	local scrW, scrH = ScrW(), ScrH();
	local parent = self:GetParent();

	self:SetSize(scrH * 0.25, scrH * 0.25);
	self:SetPos(scrW * 0.1, scrH * 0.3);

	parent.modelPanel:SetView(VIEW_FULL);
end;

function PANEL:Paint(w, h)
	draw.RoundedBox(20, 0, 0, w, h, colorBlack);
end;

vgui.Register("RD_CreationInfo", PANEL, "DPanel");

local PANEL = {};

function PANEL:Init()
	local scrW, scrH = ScrW(), ScrH();
	local parent = self:GetParent();

	self:SetSize(scrH * 0.25, scrH * 0.25);
	self:SetPos(scrW * 0.1, scrH * 0.3);

	parent.modelPanel:SetView(VIEW_FULL);
end;

function PANEL:Paint(w, h)
	draw.RoundedBox(20, 0, 0, w, h, colorBlack);
end;

vgui.Register("RD_CreationFinish", PANEL, "DPanel");

local buttonList = {
	{
		menu = "RD_CreationBody",
		name = "Body",
		icon = ""
	},
	{
		menu = "RD_CreationFace",
		name = "Face",
		icon = ""
	},
	{
		menu = "RD_CreationGear",
		name = "Gear",
		icon = ""
	},
	{
		menu = "RD_CreationInfo",
		name = "Info",
		icon = ""
	},
	{
		menu = "RD_CreationFinish",
		name = "Finish",
		icon = ""
	}
};

local PANEL = {};

function PANEL:Init()
	local scrW, scrH = ScrW(), ScrH();
	local parent = self:GetParent();

	self:SetSize(scrW * 0.50, scrH * 0.075);

	local offset = 0;

	for k, v in ipairs(buttonList) do
		local button = vgui.Create("RD_MenuButton", self);
		local isEnd = (k == #buttonList);

		button:SetSize(self:GetWide() * 0.25, self:GetTall() * 0.9);
		button:SetPos(self:GetWide() * 0.01 + offset, self:GetTall() * 0.5 - button:GetTall() * 0.5);
		button:SetText(v.name);

		function button:Paint(w, h)
			if (parent.activeMenu and parent.activeMenu:GetName() == v.menu) then
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

		function button:DoClick()
			if (v.menu and v.menu != "") then
				local lastMenu;

				if (parent.activeMenu) then
					lastMenu = parent.activeMenu:GetName();

					parent.activeMenu:Remove();
					parent.activeMenu = nil;
				end;

				if (!parent.activeMenu and lastMenu != v.menu) then
					parent.activeMenu = vgui.Create(v.menu, parent);
				end;
			end;
		end;

		offset = offset + button:GetWide() - (self:GetWide() * 0.06);
	end;

	self:SetSize(self:GetWide() * 0.08 + offset, self:GetTall())
end;

function PANEL:Paint(w, h)
	surface.SetDrawColor(255, 255, 255, 255);
	surface.SetMaterial(panelBackMat);
	surface.DrawTexturedRect(0, 0, w, h);
end;

vgui.Register("RD_CreationMenuPanel", PANEL, "DPanel");

local PANEL = {};

function PANEL:Init()
	local scrW, scrH = ScrW(), ScrH();

	self.creationData = {
		name = "",
		gender = "male",
		model = "",
		physDesc = "",
		data = {}
	};

	self:SetSize(scrW, scrH + 22);

	self.modelPanel = vgui.Create("RD_CreationModelPanel", self);
	self.modelPanel:SetPos(0, 0);
	self.modelPanel:SetSize(scrW, scrH);

	self.menuPanel = vgui.Create("RD_CreationMenuPanel", self);
	self.menuPanel:SetPos(scrW * 0.5 - self.menuPanel:GetWide() * 0.5, scrH * 0.85);
end;

function PANEL:SetGender(sGender)
	self.selectedGender = sGender;

	if (self.activeMenu.modelList) then
		self.activeMenu.modelList:RefreshList();
	end;

	local buttons = self.activeMenu.genderButtons;

	if (buttons) then
		for k, v in pairs(buttons) do
			if (string.lower(v:GetText()) == sGender) then
				v.image = buttonDownMat;
			else
				v.image = buttonMat;
			end;
		end;
	end;
end;

function PANEL:Paint(w, h)
	surface.SetDrawColor(255, 255, 255, 255);
	surface.SetMaterial(backMat);
	surface.DrawTexturedRect(0, 0, w, h);

	surface.SetDrawColor(255, 255, 255, 255);
	surface.SetMaterial(foreMat);
	surface.DrawTexturedRect(0, 0, w, h);
end;

vgui.Register("RD_CharCreation", PANEL, "DPanel");

concommand.Add("testcharcreate", function()
	if (rain.MainMenuUI) then
		rain.MainMenuUI:Remove();
		rain.MainMenuUI = nil;	
	end;

	if (TESTUI) then
		TESTUI:Remove();
		TESTUI = nil;
	end;

	TESTUI = vgui.Create("RD_CharCreation");
	TESTUI:MakePopup();
end);

concommand.Add("testcharremove", function()
	if (rain.MainMenuUI) then
		rain.MainMenuUI:Remove();
		rain.MainMenuUI = nil;	
	end;

	if (TESTUI) then
		TESTUI:Remove();
		TESTUI = nil;
	end;
end);

concommand.Add("testmainmenu", function()
	if (TESTUI) then
		TESTUI:Remove();
		TESTUI = nil;
	end;

	TESTUI = vgui.Create("RD_MainMenu");
	TESTUI:MakePopup();
end);