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
		local client = LocalPlayer()

		if (IsValid(client) and item.Owner == client and dropped) then
			local ItemTable = rain:GetItemByID(item.ItemID)
			
			if (ItemTable) then
				if (self:GetSlotType() == SLOT_QUICKUSE) then
					if (ItemTable.SizeX == 1 and ItemTable.SizeY == 1 and !ItemTable.IsArtifact and !ItemTable.IsWeapon) then -- only 1x1 items, mostly consumables can be quick used.
						client:SetQuickSlot(self:GetSlot(), item.ItemID)
						self:UpdateSlot()
					end
				elseif (self:GetSlotType() == SLOT_ARTIFACT) then
					if (ItemTable.IsArtifact) then
						client:EquipArtifactFrom(item.Coords[1], item.Coords[2], self:GetSlot())
						client:RefreshInventoryPanel()
						self:UpdateSlot()
					end
				elseif (self:GetSlotType() == SLOT_GUN) then
					if (ItemTable.IsWeapon) then
						client:EquipWeaponFrom(item.Coords[1], item.Coords[2], self:GetSlot())
						client:RefreshInventoryPanel()
						self:UpdateSlot()
					end
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
	local client = LocalPlayer()
	if (!IsValid(client)) then
		return
	end
	
	if (self:GetSlotType() == SLOT_QUICKUSE) then
		if (client:GetQuickSlot(self:GetSlot())) then
			local ItemTable = rain:GetItemByID(client:GetQuickSlot(self:GetSlot()))
			self.ItemPanel = vgui.Create("RD_StalkerIcon", self)
			local w, h = self:GetSize()
			w = w * 0.8
			self.ItemPanel:SetSize(w, w)
			w, h = self:GetSize()
			w = (w/2) - (self.ItemPanel:GetWide()/2)
			h = (h/2) - (self.ItemPanel:GetTall()/2)
			self.ItemPanel:SetPos(w, h)
			self.ItemPanel:SetCoords(ItemTable.IconX,ItemTable.IconX + ItemTable.SizeX, ItemTable.IconY,ItemTable.IconY + ItemTable.SizeY, ItemTable.Model)
			self.ItemPanel.DoRightClick = function()
				client:ResetQuickSlot(self:GetSlot())
				self:UpdateSlot()
			end
		elseif (self.ItemPanel and IsValid(self.ItemPanel)) then
			self.ItemPanel:Remove()
		end
	elseif (self:GetSlotType() == SLOT_ARTIFACT) then
		if (client:GetArtifactSlot(self:GetSlot())) then
			local ItemTable = rain:GetItemByID(client:GetArtifactSlot(self:GetSlot()))
			self.ItemPanel = vgui.Create("RD_StalkerIcon", self)
			local w, h = self:GetSize()
			w = w * 0.8
			self.ItemPanel:SetSize(w, w)
			w, h = self:GetSize()
			w = (w/2) - (self.ItemPanel:GetWide()/2)
			h = (h/2) - (self.ItemPanel:GetTall()/2)
			self.ItemPanel:SetPos(w, h)
			self.ItemPanel:SetCoords(ItemTable.IconX,ItemTable.IconX + ItemTable.SizeX, ItemTable.IconY,ItemTable.IconY + ItemTable.SizeY, ItemTable.Model)
			self.ItemPanel.DoRightClick = function()
				if (client:CanTakeItem(client:GetArtifactSlot(self:GetSlot()))) then
					client:RemoveArtifactFrom(self:GetSlot())
					client:RefreshInventoryPanel()
					self:UpdateSlot()
				end
			end
		elseif (self.ItemPanel and IsValid(self.ItemPanel)) then
			self.ItemPanel:Remove()
		end
	elseif (self:GetSlotType() == SLOT_GUN) then
		if (client:GetGearSlot(self:GetSlot())) then
			local ItemTable = rain:GetItemByID(client:GetGearSlot(self:GetSlot()))
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
			self.ItemPanel:SetCoords(ItemTable.IconY, ItemTable.IconY + ItemTable.SizeY, ItemTable.IconX, ItemTable.IconX + ItemTable.SizeX, ItemTable.Model)
			self.ItemPanel.DoRightClick = function()
				if (client:CanTakeItem(client:GetGearSlot(self:GetSlot()))) then
					client:RemoveWeaponFrom(self:GetSlot())
					client:RefreshInventoryPanel()
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