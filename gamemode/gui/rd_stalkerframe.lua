PANEL = {}

function PANEL:Init()

	self:MakePopup()
	self:SetSize(962,1080)
	self:Center()

	self.InvPanel = vgui.Create("DPanel", self)
	self.InvPanel:SetPos(514, 162)
	self.InvPanel:SetSize(420, 840)
	self.InvPanel.Paint = function(p, w, h)
		return
	end

	self.iconsize = 420 / 7

	self.Inventory = CreateInventoryUI(LocalPlayer().Inventory, LocalPlayer(), self.iconsize)
	self.Inventory:SetParent(self.InvPanel)

	surface.CreateFont("NameFont", {
		font = "Constantia",
		size = 24,
		weight = 200
	})

	surface.CreateFont("TitleFont", {
		font = "Constantia",
		size = 18,
		weight = 200
	})

	surface.CreateFont("CashFont", {
		font = "Constantia",
		size = 26,
		weight = 200
	})

	surface.CreateFont("FKeyFont", {
		font = "Constantia",
		size = 20,
		weight = 200
	})

	self.Rank = self.Rank or "Free Stalker"

	self.WeaponPanel = {}

	for i = 0, 1 do 
		self.WeaponPanel[i + 1] = vgui.Create("CCStalkerItemHolder", self)
		self.WeaponPanel[i + 1]:SetPos(16 + (i * 314), 16)
		self.WeaponPanel[i + 1]:SetSize(132, 520)
		self.WeaponPanel[i + 1]:SetSlotType(SLOT_GUN)
		self.WeaponPanel[i + 1]:SetSlot(i + 1)
	end

	self.GearPanel = {}

	for i = 0, 1 do
		self.GearPanel[i + 1] = vgui.Create("CCStalkerItemHolder", self)
		self.GearPanel[i + 1]:SetPos(166, 16 + (i * 170))
		self.GearPanel[i + 1]:SetSize(148, 156 + (i * 100))
		self.GearPanel[i + 1]:SetSlotType(SLOT_GEAR)
		self.GearPanel[i + 1]:SetSlot(i + 3)
	end

	self.ArtifactDetectorPanel = vgui.Create("CCStalkerItemHolder", self)
	self.ArtifactDetectorPanel:SetPos(166, 460)
	self.ArtifactDetectorPanel:SetSize(150, 80)
	self.ArtifactDetectorPanel:SetSlotType(SLOT_DETECTOR)
	self.ArtifactDetectorPanel:SetSlot(1)

	self.F = {}

	for i = 1, 4 do
		self.F[i] = vgui.Create("CCStalkerItemHolder", self)
		self.F[i]:SetSize(108, 96)
		self.F[i]:SetPos(14 + ((i - 1) * (6 + 108)), 552)
		self.F[i]:SetSlot(i)
		self.F[i]:SetSlotType(SLOT_QUICKUSE)
		self.F[i]:UpdateSlot()
	end

	self.ArtifactPanel = {}

	for i = 1, 5 do
		self.ArtifactPanel[i] = vgui.Create("CCStalkerItemHolder", self)
		self.ArtifactPanel[i]:SetSize(82, 82)
		self.ArtifactPanel[i]:SetPos(15 + ((i - 1) * (10 + 82)), 660)
		self.ArtifactPanel[i]:SetSlotType(SLOT_ARTIFACT)
		self.ArtifactPanel[i]:SetSlot(i)
		self.ArtifactPanel[i]:UpdateSlot()
	end

	-- progress bars --

	local postable = {}
	postable[1] = {x = 200, y = 166}
	postable[2] = {x = 200, y = 434}
	postable[3] = {x = 42, y = 531}
	postable[4] = {x = 358, y = 531}

	self.GearDamage = {}

	for i = 1, 2 do
		self.GearDamage[i] = vgui.Create("CCStalkerProgressBar", self)
		self.GearDamage[i]:SetPos(postable[i].x, postable[i].y)
		self.GearDamage[i]:SetSize(82,6)
		self.GearDamage[i]:SetProgress(1)
		self.GearDamage[i]:SetColor(Color(0,255,0,255))
		self.GearPanel[i]:SetUseCondition(true)
		self.GearPanel[i]:SetCondition(0)
		self.GearPanel[i]:SetConditionPanel(self.GearDamage[i])
		self.GearPanel[i]:UpdateSlot()
	end

	self.GunDamage = {}

	for i = 3, 4 do
		self.GunDamage[i - 2] = vgui.Create("CCStalkerProgressBar", self)
		self.GunDamage[i - 2]:SetPos(postable[i].x, postable[i].y)
		self.GunDamage[i - 2]:SetSize(82,6)
		self.GunDamage[i - 2]:SetProgress(1)
		self.GunDamage[i - 2]:SetColor(Color(0,255,0,255))
		self.WeaponPanel[i - 2]:SetUseCondition(true)
		self.WeaponPanel[i - 2]:SetCondition(0)
		self.WeaponPanel[i - 2]:SetConditionPanel(self.GunDamage[i - 2])
		self.WeaponPanel[i - 2]:UpdateSlot()
	end

	self.HealthProgress = vgui.Create("CCStalkerProgressBar", self)
	self.HealthProgress:SetPos(18,800)
	self.HealthProgress:SetSize(304,24)
	self.HealthProgress.TickSpacing = 6
	self.HealthProgress.TickWidth = 3
	self.HealthProgress:SetProgress(1)
	self.HealthProgress:SetColor(Color(90,15,20,255))


	for i = 0, 3 do
		self.DamageProgress = vgui.Create("CCStalkerProgressBar", self)
		self.DamageProgress:SetPos(54,859 + (i * 39.5))
		self.DamageProgress:SetSize(175,26)
		self.DamageProgress.TickSpacing = 5
		self.DamageProgress.TickWidth = 2
		self.DamageProgress:SetProgress(math.random())
		self.DamageProgress:SetColor(Color(160,160,180,255))
		self.DamageProgress.HideBackground = true
	end

	for i = 0, 3 do
		self.DamageProgress = vgui.Create("CCStalkerProgressBar", self)
		self.DamageProgress:SetPos(281,859 + (i * 39.5))
		self.DamageProgress:SetSize(175,26)
		self.DamageProgress.TickSpacing = 5
		self.DamageProgress.TickWidth = 2
		self.DamageProgress:SetProgress(math.random())
		self.DamageProgress:SetColor(Color(160,160,180,255))
		self.DamageProgress.HideBackground = true
	end

	self.CharacterIcon = vgui.Create("CCStalkerCharIcon", self)
	self.CharacterIcon:SetPos(778, 14)
	self.CharacterIcon:SetSize(168, 121)
	self.CharacterIcon:SetCoords(2, 10)

end

function PANEL:Refresh()
	self.Inventory:Remove()
	self.Inventory = CreateInventoryUI(LocalPlayer().Inventory, LocalPlayer(), self.iconsize)
	self.Inventory:SetParent(self.InvPanel)
end

local menumat = Material("stalker/ui_actor_menu.png", "noclamp")

function PANEL:Paint(w, h)

	surface.SetMaterial(menumat)
	surface.SetDrawColor(Color(255,255,255,255))
	-- surface.DrawTexturedRectUV( number x, number y, number width, number height, number startU, number startV, number endU, number endV ) 
	surface.DrawTexturedRectUV(0, 0, w, h, 1/3, 0, 3/3, 9/12)

	draw.DrawText(LocalPlayer():VisibleRPName(), "NameFont", 506 + 1, 32 + 1, Color(0,0,0,255), TEXT_ALIGN_LEFT) 
	draw.DrawText(LocalPlayer():VisibleRPName(), "NameFont", 506, 32, Color(190,175,160,255), TEXT_ALIGN_LEFT) 
	draw.DrawText(self.Rank, "TitleFont", 506 + 1, 54 + 1, Color(0,0,0,255), TEXT_ALIGN_LEFT) 
	draw.DrawText(self.Rank, "TitleFont", 506, 54, Color(150,150,150,255), TEXT_ALIGN_LEFT) 

	draw.DrawText(LocalPlayer():Money().." RU", "CashFont", 764 + 1, 106 + 1, Color(0,0,0,255), TEXT_ALIGN_RIGHT) 
	draw.DrawText(LocalPlayer():Money().." RU", "CashFont", 764 , 106, Color(255,255,255,255), TEXT_ALIGN_RIGHT) 

	draw.DrawText("Total weight: "..LocalPlayer():InventoryWeight().." kg (max "..LocalPlayer():InventoryMaxWeight().." kg)", "TitleFont", 930 + 1, 1035 + 1, Color(0,0,0,255), TEXT_ALIGN_RIGHT) 
	draw.DrawText("Total weight: "..LocalPlayer():InventoryWeight().." kg (max "..LocalPlayer():InventoryMaxWeight().." kg)", "TitleFont", 930, 1035, Color(150,150,150,255), TEXT_ALIGN_RIGHT) 
	draw.DrawText(LocalPlayer():InventoryWeight().." kg", "TitleFont", 847, 1035, Color(255,255,255,255), TEXT_ALIGN_RIGHT) 

	surface.SetFont("FKeyFont")

	for i = 1, 0, -1 do 
		if (i == 1) then -- :^)
			surface.SetTextColor(0,0,0,255)
		else
			surface.SetTextColor(255,255,255,255)
		end
		surface.SetTextPos(16 + i, 628)
		surface.DrawText("F1")
	
		surface.SetTextPos(130 + i, 628)
		surface.DrawText("F2")
	
		surface.SetTextPos(244 + i, 628)
		surface.DrawText("F3")
	
		surface.SetTextPos(359 + i, 628)
		surface.DrawText("F4")
	end

	return true
end

derma.DefineControl( "CCStalkerFrame", "", PANEL, "DFrame" )