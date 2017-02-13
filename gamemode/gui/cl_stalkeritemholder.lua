PANEL = {}

AccessorFunc(PANEL, "m_SlotType", "SlotType",  FORCE_NUMBER)
AccessorFunc(PANEL, "m_Slot", "Slot",  FORCE_NUMBER)
AccessorFunc(PANEL, "m_UseCondition", "UseCondition",  FORCE_BOOL) -- wether or not there is a ccstalkerprogress bar reference to this file that this file should be setting progress on
AccessorFunc(PANEL, "m_Condition", "Condition",  FORCE_NUMBER)

function PANEL:Init()

	self:SetSlot(1)
	self:SetSlotType(SLOT_QUICKUSE)

	self:SetUseCondition(false)
	self:SetCondition(0)

	self:Receiver("InvItem", function(p, items, dropped)
		local item = items[1]

		if (item.Owner == LocalPlayer() and dropped) then 			
			if (self:GetSlotType() == SLOT_QUICKUSE) then
				local ItemTable = GAMEMODE:GetItemByID(item.ItemID)
				if (ItemTable.SizeX == 1) and (ItemTable.SizeY == 1) then -- only 1x1 items, mostly consumables can be quick used.
					LocalPlayer():SetQuickSlot(self:GetSlot(), item.ItemID)
					self:UpdateSlot()
				end
			elseif (self:GetSlotType() == SLOT_ARTIFACT) then
				local ItemTable = GAMEMODE:GetItemByID(item.ItemID)
				if (ItemTable.IsArtifact) then
					LocalPlayer():EquipArtifactFrom(item.Coords[1], item.Coords[2], self:GetSlot())
					LocalPlayer():RefreshInventoryPanel()
					self:UpdateSlot()
				end
			elseif (self:GetSlotType() == SLOT_GUN) then
				local ItemTable = GAMEMODE:GetItemByID(item.ItemID)
				if (ItemTable.IsWeapon) then
					LocalPlayer():EquipWeaponFrom(item.Coords[1], item.Coords[2], self:GetSlot())
					LocalPlayer():RefreshInventoryPanel()
					self:UpdateSlot()
				end
			end
		end
	end)
end

-- passes a reference to the panel that allows us to do something with condition when we change it
function PANEL:SetConditionPanel(vguiRD_StalkerProgressBar)
	self.ConditionPanel = vguiRD_StalkerProgressBar
end

-- accessor func
function PANEL:GetConditionPanel()
	return self.ConditionPanel
end

function PANEL:Think()
	self:ConditionThink() -- planning ahead and doing this segregated
end

function PANEL:ConditionThink()
	if (self:GetUseCondition()) then
		local CPanel = self:GetConditionPanel()
		CPanel:SetProgress(self:GetCondition())
	end
end

function PANEL:UpdateSlot()
	if (self:GetSlotType() == SLOT_QUICKUSE) then
		if (LocalPlayer():GetQuickSlot(self:GetSlot())) then
			local ItemTable = GAMEMODE:GetItemByID(LocalPlayer():GetQuickSlot(self:GetSlot()))
			self.ItemPanel = vgui.Create("RD_StalkerIcon", self)
			local w, h = self:GetSize()
			w = w * 0.8
			self.ItemPanel:SetSize(w, w)
			w, h = self:GetSize()
			w = (w/2) - (self.ItemPanel:GetWide()/2)
			h = (h/2) - (self.ItemPanel:GetTall()/2)
			self.ItemPanel:SetPos(w, h)
			self.ItemPanel:SetCoords(ItemTable.IconX,ItemTable.IconX + ItemTable.SizeX, ItemTable.IconY,ItemTable.IconY + ItemTable.SizeY)
			self.ItemPanel.DoRightClick = function()
				LocalPlayer():ResetQuickSlot(self:GetSlot())
				self:UpdateSlot()
			end
		elseif (self.ItemPanel and IsValid(self.ItemPanel)) then
			self.ItemPanel:Remove()
		end
	elseif (self:GetSlotType() == SLOT_ARTIFACT) then
		if (LocalPlayer():GetArtifactSlot(self:GetSlot())) then
			local ItemTable = GAMEMODE:GetItemByID(LocalPlayer():GetArtifactSlot(self:GetSlot()))
			self.ItemPanel = vgui.Create("RD_StalkerIcon", self)
			local w, h = self:GetSize()
			w = w * 0.8
			self.ItemPanel:SetSize(w, w)
			w, h = self:GetSize()
			w = (w/2) - (self.ItemPanel:GetWide()/2)
			h = (h/2) - (self.ItemPanel:GetTall()/2)
			self.ItemPanel:SetPos(w, h)
			self.ItemPanel:SetCoords(ItemTable.IconX,ItemTable.IconX + ItemTable.SizeX, ItemTable.IconY,ItemTable.IconY + ItemTable.SizeY)
			self.ItemPanel.DoRightClick = function()
				if (LocalPlayer():CanTakeItem(LocalPlayer():GetArtifactSlot(self:GetSlot()))) then
					LocalPlayer():RemoveArtifactFrom(self:GetSlot())
					LocalPlayer():RefreshInventoryPanel()
					self:UpdateSlot()
				end
			end
		elseif (self.ItemPanel and IsValid(self.ItemPanel)) then
			self.ItemPanel:Remove()
		end
	elseif (self:GetSlotType() == SLOT_GUN) then
		if (LocalPlayer():GetGearSlot(self:GetSlot())) then
			local ItemTable = GAMEMODE:GetItemByID(LocalPlayer():GetGearSlot(self:GetSlot()))
			self.ItemPanel = vgui.Create("RD_StalkerIcon", self)
			self.ItemPanel:SetRotated(true)
			local w, h = self:GetSize()
			w = w * 0.95
			self.ItemPanel:SetSize(w, w * (ItemTable.SizeX/ItemTable.SizeY))
			w, h = self:GetSize()
			w = (w/2) - (self.ItemPanel:GetWide()/2)
			h = (h/2) - (self.ItemPanel:GetTall()/2)
			self.ItemPanel:SetPos(w, h)
			self.ItemPanel:SetRotated(true)
			self.ItemPanel:SetCoords(ItemTable.IconY, ItemTable.IconY + ItemTable.SizeY, ItemTable.IconX, ItemTable.IconX + ItemTable.SizeX)
			self.ItemPanel.DoRightClick = function()
				if (LocalPlayer():CanTakeItem(LocalPlayer():GetGearSlot(self:GetSlot()))) then
					LocalPlayer():RemoveWeaponFrom(self:GetSlot())
					LocalPlayer():RefreshInventoryPanel()
					self:UpdateSlot()
				end
			end
			self:SetCondition(1)
		elseif (self.ItemPanel and IsValid(self.ItemPanel)) then
			self.ItemPanel:Remove()
			self:SetCondition(0)
		end
	end
end

function PANEL:Paint(w, h)

	return true
end

derma.DefineControl( "RD_StalkerItemHolder", "", PANEL, "DPanel" )