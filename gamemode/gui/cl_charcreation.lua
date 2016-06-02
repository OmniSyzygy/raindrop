local VIEW_FULL = 0;
local VIEW_FACE = 1;
local VIEW_WEAPON = 2;

local colorBlack = Color(50, 50, 50, 250);
local lightWhite = Color(150, 150, 150, 100);
local colorWhite = Color(255, 255, 255, 255);
local colorGray = Color(170, 170, 170, 255);
local lightGray = Color(200, 200, 200, 255);

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

local textEntryMat = Material("stalker/ui_textentry.png");

local scrollBackMat = Material("stalker/ui_scroll_back.png");
local scrollUpMat = Material("stalker/ui_scroll_up.png");
local scrollDownMat = Material("stalker/ui_scroll_down.png");
local scrollBarMat = Material("stalker/ui_scroll_box.png");

local cancelButtonMat = Material("stalker/ui_button_cancel.png");
local cancelButtonDownMat = Material("stalker/ui_button_cancel_down.png");

local modelBlacklist = {
	testrig = true,
	exo_bronia = true,
	stalker_neutral_6 = true,
	stalker_neutral_7 = true
};

local availableModels = {};
local files, directories = file.Find( "models/cakez/rxstalker/stalker_neutral/*.mdl", "GAME");

for k, v in pairs(files) do
	local canAdd = true;

	for k2, v2 in pairs(modelBlacklist) do
		if (string.find(v, k2)) then
			canAdd = false;

			break;
		end;
	end;

	if (canAdd) then
		table.insert(availableModels, "models/cakez/rxstalker/stalker_neutral/"..v);
	end;
end;

--[[
for i = 1, 18 do
	local number = i;

	if (number < 10) then
		number = "0"..number;
	end;

	table.insert(availableModels, "models/tnb/citizens/male_"..number..".mdl");
end;
--]]

local PANEL = {};

function PANEL:Init()
	self:SetSize(125, 30);
	self:SetTextColor(colorGray);
	self.image = buttonMat;
	self.downImage = buttonDownMat;
end;

function PANEL:Paint(w, h)
	if (self.image) then
		surface.SetDrawColor(255, 255, 255, 255);
		surface.SetMaterial(self.image);

		if (self:IsHovered() and input.IsMouseDown(MOUSE_LEFT)) then
			surface.SetMaterial(self.downImage);
		end;

		surface.DrawTexturedRect(0, 0, w, h);
	end;
end;

vgui.Register("RD_CreationImageButton", PANEL, "DImageButton");

local PANEL = {};

function PANEL:Init()
	self:SetActiveModel(table.Random(availableModels));
	self:SetView(VIEW_FULL, true);
end;

local viewCheck = {
	[VIEW_FACE] = function(panel, bNoLerp)
		local ent = panel:GetEntity();
		local headPos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Head1"));		

		if (!bNoLerp) then
			panel:LerpSetCamPos(headPos - Vector(-25, 0, 0));
			panel:LerpSetLookAt(headPos);
		else
			panel:SetCamPos(headPos - Vector(-25, 0, 0));
			panel:SetLookAt(headPos);
		end;
	end,
	[VIEW_FULL] = function(panel, bNoLerp)
		if (!bNoLerp) then
			panel:LerpSetCamPos(Vector(70, 70, 60));
			panel:LerpSetLookAt(Vector(0, 0, 35));
		else
			panel:SetCamPos(Vector(70, 70, 60));
			panel:SetLookAt(Vector(0, 0, 35));
		end;
	end,
	[VIEW_WEAPON] = function(panel, bNoLerp)
		local ent = panel:GetEntity();
		local bonePos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_R_Hand"));

		if (IsValid(panel.weaponEnt)) then
			bonePos = panel.weaponEnt:GetPos();
		end;

		if (!bNoLerp) then
			panel:LerpSetCamPos(bonePos - Vector(-40, 15, 5));
			panel:LerpSetLookAt(bonePos);
		else
			panel:SetCamPos(bonePos - Vector(-40, 15, 5));
			panel:SetLookAt(bonePos);
		end;
	end
};

function PANEL:SetView(nView)
	local check = viewCheck[nView];

	if (check) then
	--	timer.Simple(0.3, function()
			check(self);
	--	end);
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

--local lerpDuration = 0.2;
local lerpDuration = 0.5;

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
		--	self:SetCamPos(LerpVector(fraction, posLerpOrigin, posLerpTarget));
			self:SetCamPos(COSerpVector(fraction, posLerpOrigin, posLerpTarget));
		else
			posLerpTarget = nil;
		end;
	end;

	if (lookLerpTarget) then
		local fraction = (curTime - lookLerpStart) / lerpDuration;

		if !(fraction >= 1) then
		--	self:SetLookAt(LerpVector(fraction, lookLerpOrigin, lookLerpTarget));
			self:SetLookAt(COSerpVector(fraction, lookLerpOrigin, lookLerpTarget));
		else
			lookLerpTarget = nil;
		end;
	end;
end;

function PANEL:SetActiveModel(sPath)
	local parent = self:GetParent();

	self:SetModel(sPath);
--	self:DebugSequenceList();
--	self:DebugAttachmentList();
--	self:DebugFlexList()
--	self:DebugBoneList();
	self:SetAnimation(ACT_IDLE);
	self:GetEntity():SetSkin(parent.creationData.appearance.skin);

	parent.creationData.appearance.model = sPath;
	parent.creationData.data.gender = parent.selectedGender;
end;

function PANEL:SetActiveSkin(nSkin)
	local parent = self:GetParent();

	self:SetModel(parent.creationData.appearance.model);
	self:GetEntity():SetSkin(nSkin);
	self:SetAnimation(ACT_IDLE);

	parent.creationData.appearance.skin = nSkin;
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

local bodyButtonList = {
	{
		name = "Model",
		menu = "RD_CreationBody"
	},
	{
		name = "Skin",
		menu = "RD_CreationSkinSelect",
		callback = function(panel)
			if (panel and panel:GetParent().modelPanel:GetEntity():SkinCount() > 1) then
				return true;
			end;

			return false;
		end
	}//,
	--[[
	{
		name = "Bodygroups",
		menu = "RD_CreationBodygroups",
		callback = function(panel)
			if (panel and panel:GetParent().modelPanel:GetEntity():GetNumBodyGroups() > 0) then
				return true;
			end;

			return false;
		end
	}//,
		
	{
		name = "Shape",
	--	menu = "RD_CreationBodygroups"
	}
	--]]
};

local PANEL = {};

function PANEL:Init()
	local scrW, scrH = ScrW(), ScrH();
	local parent = self:GetParent();
	local panel = self;

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

	parent.selectedGender = parent.creationData.data.gender;

	function self.modelList:AddModel(sPath)
		local spawnIcon = vgui.Create("SpawnIcon", self);

		spawnIcon:SetModel(sPath);
		spawnIcon.model = sPath;

		function spawnIcon:DoClick()
			parent.modelPanel:SetActiveModel(sPath);
			panel:RefreshCategories();
		end;

		function spawnIcon:PaintOver(w, h)
			if (spawnIcon.model == parent.creationData.appearance.model) then
				draw.RoundedBox(10, 0, 0, w, h, lightWhite);
			end;
		end;

		self:Add(spawnIcon);
	end;

	function self.modelList:RefreshList()
		for k, v in pairs(self:GetChildren()) do
			v:Remove();
		end;

		local gender = parent.selectedGender or parent.creationData.data.gender;

		for k, v in pairs(availableModels) do
			self:AddModel(v);
		end;
	end;

	self.modelList:RefreshList();
	self:RefreshCategories()
	self.genderButtons = {};

	local genders = {};

	if (TEMP_FEMALE_OPTION) then
		genders = {
			"Male",
			"Female"
		};
	end;

	for k, v in ipairs(genders) do
		local button = vgui.Create("RD_CreationImageButton", self);

		local offset = self:GetWide() * 0.2;

		button:SetPos((button:GetWide() * (k - 1)) + (offset * (k - 1)) + self:GetWide() * 0.18, self:GetTall() * 0.935);
		button:SetText(v);

		v = string.lower(v);

		if (v == parent.creationData.data.gender) then
			button.image = buttonDownMat;
		end;		

		function button:DoClick()
			parent:SetGender();
		end;

		self.genderButtons[v] = button;
	end;	
end;

function PANEL:RefreshCategories()
	if (self.categoryButtons) then
		for k, v in pairs(self.categoryButtons) do
			v:Remove();
		end;
	end;

	self.categoryButtons = {};

	local activeButtons = {};

	for k, v in ipairs(bodyButtonList) do
		if (!v.callback or (v.callback and v.callback(self))) then
			activeButtons[#activeButtons + 1] = v;
		end;
	end;

	local parent = self:GetParent();
	local offset = self:GetWide() * 0.085;
	local buttonWidth = self:GetWide() * 0.35;
	local listAmount = #activeButtons;
	local width = (buttonWidth * listAmount) - (offset * (listAmount - 1));
	local middle = (self:GetWide() * 0.5) - (width * 0.5);
	local x = middle;	

	for k, v in ipairs(bodyButtonList) do
		if (!v.callback or (v.callback and v.callback(self))) then
			local button = vgui.Create("RD_MenuButton", self);
			local isEnd = (k == #bodyButtonList);

			button:SetSize(buttonWidth, self:GetTall() * 0.15);
			button:SetPos(x, self:GetTall() * 0.05);
			button:SetText(v.name);
			button:SetTextColor(lightGray);

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

			if (v.menu != self:GetName()) then
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
			end;

			self.categoryButtons[#self.categoryButtons + 1] = button;

			x = x + (buttonWidth - offset);
		end;
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

	function self.modelList:AddModel(sPath, nSkin)
		local spawnIcon = vgui.Create("SpawnIcon");

		spawnIcon:SetModel(sPath, nSkin);
		spawnIcon.skin = nSkin;

		function spawnIcon:DoClick()
		--	parent.creationData.appearance.skin = spawnIcon.skin;
			parent.modelPanel:SetActiveSkin(spawnIcon.skin);
		end;

		function spawnIcon:PaintOver(w, h)
			if (spawnIcon.skin == parent.creationData.appearance.skin) then
				draw.RoundedBox(10, 0, 0, w, h, lightWhite);
			end;
		end;

		self:Add(spawnIcon);
	end;

	function self.modelList:RefreshList()
		for k, v in pairs(self:GetChildren()) do
			v:Remove();
		end;

		for i = 0, parent.modelPanel:GetEntity():SkinCount() - 1 do
			self:AddModel(parent.creationData.appearance.model, i);
		end;
	end;

	self.modelList:RefreshList();
	self:RefreshCategories();
end;

function PANEL:Paint(w, h)
	surface.SetDrawColor(255, 255, 255, 255);
	surface.SetMaterial(panelBackMat);
	surface.DrawTexturedRect(0, 0, w, h);
end;

function PANEL:RefreshCategories()
	if (self.categoryButtons) then
		for k, v in pairs(self.categoryButtons) do
			v:Remove();
		end;
	end;

	self.categoryButtons = {};

	local activeButtons = {};

	for k, v in ipairs(bodyButtonList) do
		if (!v.callback or (v.callback and v.callback(self))) then
			activeButtons[#activeButtons + 1] = v;
		end;
	end;

	local parent = self:GetParent();
	local offset = self:GetWide() * 0.085;
	local buttonWidth = self:GetWide() * 0.35;
	local listAmount = #activeButtons;
	local width = (buttonWidth * listAmount) - (offset * (listAmount - 1));
	local middle = (self:GetWide() * 0.5) - (width * 0.5);
	local x = middle;	

	for k, v in ipairs(bodyButtonList) do
		if (!v.callback or (v.callback and v.callback(self))) then
			local button = vgui.Create("RD_MenuButton", self);
			local isEnd = (k == #bodyButtonList);

			button:SetSize(buttonWidth, self:GetTall() * 0.15);
			button:SetPos(x, self:GetTall() * 0.05);
			button:SetText(v.name);
			button:SetTextColor(lightGray);

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

			if (v.menu != self:GetName()) then
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
			end;

			self.categoryButtons[#self.categoryButtons + 1] = button;

			x = x + (buttonWidth - offset);
		end;
	end;
end;

vgui.Register("RD_CreationSkinSelect", PANEL, "DPanel");

local PANEL = {};

function PANEL:Init()
	local scrW, scrH = ScrW(), ScrH();
	local parent = self:GetParent();
	local panel = self;

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

	function self.modelList:AddModel(nBodygroup)
		local spawnIcon = vgui.Create("SpawnIcon", self);
		local nSkin = parent.creationData.appearance.skin;
		
//		spawnIcon:SetModel(sPath, nSkin, );
		spawnIcon.model = sPath;

		function spawnIcon:DoClick()
			parent.modelPanel:SetActiveModel(sPath);
			panel:RefreshCategories();
		end;

		function spawnIcon:PaintOver(w, h)
			if (spawnIcon.model == parent.creationData.appearance.model) then
				draw.RoundedBox(10, 0, 0, w, h, lightWhite);
			end;
		end;

		self:Add(spawnIcon);
	end;

	function self.modelList:RefreshList()
		for k, v in pairs(self:GetChildren()) do
			v:Remove();
		end;

		local tBodygroups = parent.modelPanel:GetEntity():GetBodyGroups();
	--	PrintTable(tBodygroups);

		for k, v in pairs(tBodygroups) do
			if (k != 1) then
				self:AddModel(v);
			end;
		end;
	end;

	self.modelList:RefreshList();
	self:RefreshCategories()
end;

function PANEL:GetCurrentBodygroups()
	local parentEnt = self:GetParent().modelPanel:GetEntity();
	local tBodygroups = {};

	for i = 0, parentEnt:GetNumBodyGroups() - 1 do
		table.insert(tBodygroups, parentEnt:GetBodygroup(i));
	end;

	return tBodygroups;
end;

function PANEL:BodygroupsToString(tBodygroups)
	return table.concat(tBodygroups, "");
end;

function PANEL:StringToBodygroups(sBodygroups)
	return string.Explode("", sBodygroups);
end;

function PANEL:Paint(w, h)
	surface.SetDrawColor(255, 255, 255, 255);
	surface.SetMaterial(panelBackMat);
	surface.DrawTexturedRect(0, 0, w, h);
end;

function PANEL:RefreshCategories()
	if (self.categoryButtons) then
		for k, v in pairs(self.categoryButtons) do
			v:Remove();
		end;
	end;

	self.categoryButtons = {};

	local activeButtons = {};

	for k, v in ipairs(bodyButtonList) do
		if (!v.callback or (v.callback and v.callback(self))) then
			activeButtons[#activeButtons + 1] = v;
		end;
	end;

	local parent = self:GetParent();
	local offset = self:GetWide() * 0.085;
	local buttonWidth = self:GetWide() * 0.35;
	local listAmount = #activeButtons;
	local width = (buttonWidth * listAmount) - (offset * (listAmount - 1));
	local middle = (self:GetWide() * 0.5) - (width * 0.5);
	local x = middle;	

	for k, v in ipairs(bodyButtonList) do
		if (!v.callback or (v.callback and v.callback(self))) then
			local button = vgui.Create("RD_MenuButton", self);
			local isEnd = (k == #bodyButtonList);

			button:SetSize(buttonWidth, self:GetTall() * 0.15);
			button:SetPos(x, self:GetTall() * 0.05);
			button:SetText(v.name);
			button:SetTextColor(lightGray);

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

			if (v.menu != self:GetName()) then
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
			end;

			self.categoryButtons[#self.categoryButtons + 1] = button;

			x = x + (buttonWidth - offset);
		end;
	end;
end;

vgui.Register("RD_CreationBodygroups", PANEL, "DPanel");

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

--[[
function PANEL:Init()
end;


function PANEL:Paint(w, h)
end;
--]]

vgui.Register("RD_TextEntry", PANEL, "DTextEntry");

local PANEL = {};

function PANEL:Init()
	local scrW, scrH = ScrW(), ScrH();
	local parent = self:GetParent();

	self:SetSize(scrW * 0.30, scrH * 0.35);
	self:SetPos(scrW * 0.05, scrH * 0.20);

	parent.modelPanel:SetView(VIEW_FULL);

	local nameY = self:GetTall() * 0.2;
	local charName = parent.creationData.data.Name;

	self.nameBack = vgui.Create("EditablePanel", self);
	self.nameBack:SetSize(self:GetWide() * 0.8, self:GetTall() * 0.125);
	self.nameBack:SetPos(self:GetWide() * 0.5 - self.nameBack:GetWide() * 0.5, nameY);

	function self.nameBack:Paint(w, h)
		surface.SetDrawColor(255, 255, 255, 255);
		surface.SetMaterial(textEntryMat);
		surface.DrawTexturedRect(0, 0, w, h);
	end;

	self.nameLabel = vgui.Create("DLabel", self);
	self.nameLabel:SetPos(self.nameBack.x, nameY - self:GetTall() * 0.07);
	self.nameLabel:SetFont("RD.MenuButtonFont");
	self.nameLabel:SetText("Name:");

	self.nameEntry = vgui.Create("RD_TextEntry", self);
	self.nameEntry:SetSize(self:GetWide() * 0.8, self:GetTall() * 0.125);
	self.nameEntry:SetPos(self:GetWide() * 0.5 - self.nameEntry:GetWide() * 0.5, nameY);
	self.nameEntry:SetFont("RD.MenuButtonFont");
	self.nameEntry:SetTextColor(lightGray);
	self.nameEntry:SetDrawBackground(false);
	self.nameEntry:SetUpdateOnType(true);

	if (charName and charName != "") then
		self.nameEntry:SetValue(charName);	
	end;

	function self.nameEntry:OnValueChange(newValue)
		parent.creationData.data.Name = newValue;
	end;
end;

function PANEL:Paint(w, h)
	surface.SetDrawColor(255, 255, 255, 255);
	surface.SetMaterial(panelBackMat);
	surface.DrawTexturedRect(0, 0, w, h);
end;

vgui.Register("RD_CreationInfo", PANEL, "DPanel");
--[[
local PANEL = {};

function PANEL:Init()
	local scrW, scrH = ScrW(), ScrH();
	local parent = self:GetParent();

	self:SetSize(scrW * 0.30, scrH * 0.5);
	self:SetPos(scrW * 0.65, scrH * 0.1);

	parent.modelPanel:SetView(VIEW_FULL);

	local confirmLabel = vgui.Create("DLabel", self);

	confirmLabel:SetSize(self:GetWide(), self:GetTall() * 0.9);
	confirmLabel:SetContentAlignment(5);
	confirmLabel:SetAutoStretchVertical(true);
	confirmLabel:SetFont("RD.MenuButtonFont");
	confirmLabel:SetMultiline(true);
	confirmLabel:SetText("Are you sure you want to finish creating this character?");
	confirmLabel:SetPos(self:GetWide() * 0.5 - confirmLabel:GetWide() * 0.5, self:GetTall() * 0.5, - confirmLabel:GetTall() * 0.5);

	local button = vgui.Create("RD_CreationImageButton", self);

	button:SetPos(self:GetWide() * 0.5 - button:GetWide() * 0.5, self:GetTall() * 0.935);
	button:SetText("Create");

	function button:DoClick()
		--	Add checks here for valid information being entered.
		
		net.Start("rain.charcreate")
			rain.net.WriteTable(parent.creationData);
		net.SendToServer();

		parent:Remove();

		rain.MainMenuUI = vgui.Create("RD_MainMenu");
		rain.MainMenuUI:MakePopup();
	end;
end;

function PANEL:Paint(w, h)
	surface.SetDrawColor(255, 255, 255, 255);
	surface.SetMaterial(panelBackMat);
	surface.DrawTexturedRect(0, 0, w, h);
end;

vgui.Register("RD_CreationFinish", PANEL, "DPanel");
--]]
local buttonList = {
	{
		menu = "RD_CreationBody",
		name = "Body",
		icon = ""
	},
	--[[
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
	--]]
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
		button:SetTextColor(lightGray);

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
				if (v.name == "Finish") then
					--	Add checks here for valid information being entered.
					
					net.Start("rain.charcreate")
						rain.net.WriteTable(parent.creationData);
					net.SendToServer();

					parent:Remove();

					rain.MainMenuUI = vgui.Create("RD_MainMenu");
					rain.MainMenuUI:MakePopup();
					
					return;
				end;

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
	local panel = self;

	self.creationData = {		
		appearance = {
			model = "",
			bodygroups = 0,
			skin = 0
		},
		data = {
			Name = "",
			gender = "male",
			physDesc = ""
		}
	};

	self:SetSize(scrW, scrH + 22);

	self.modelPanel = vgui.Create("RD_CreationModelPanel", self);
	self.modelPanel:SetPos(0, 0);
	self.modelPanel:SetSize(scrW, scrH);

	self.menuPanel = vgui.Create("RD_CreationMenuPanel", self);
	self.menuPanel:SetPos(scrW * 0.5 - self.menuPanel:GetWide() * 0.5, scrH * 0.85);

	self.cancelButton = vgui.Create("RD_CreationImageButton", self);

	self.cancelButton:SetPos(self:GetWide() * 0.5 - self.cancelButton:GetWide() * 0.5, self:GetTall() * 0.9035);
	self.cancelButton.image = cancelButtonMat;
	self.cancelButton.downImage = cancelButtonDownMat;

	function self.cancelButton:DoClick()
		panel:Remove();

		rain.MainMenuUI = vgui.Create("RD_MainMenu");
		rain.MainMenuUI:MakePopup();
	end;
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

vgui.Register("RD_CharCreation", PANEL, "EditablePanel");

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