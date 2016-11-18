--[[
	Filename: sh_inventory.lua
	Notes: I put comments to generally describe what each function does, feel free to modify stuff to your needs but bear in mind that I did some networking
	that would be considered unorthodox in source, traditionally that is. It was inspired by the networking in UE4 which is called replication. Essentially
	the server replicates what the client does on the client based on net messages sent to the client from the server, this allows for easier prediction. 
	Most if not all functions are shared but with minor branches for client/server within each branch, this is for convience. If you have difficulty understanding
	what's in this file then just trace the functions and you'll see what's going on.

	So far though, the result is clean networking that is very well predicted. So that's good.
--]]

	SLOT_QUICKUSE = 0
	SLOT_GEAR = 1
	SLOT_ARTIFACT = 2
	SLOT_GUN = 3
	SLOT_DETECTOR = 4

--[[
	Don't mind me, just set up some enums for use later, mostly util functions below.
--]]

--[[
	Function: Net Replicate
	Purpose: Replicates a net message that has already been started, based on the Authority it either goes from server to client or client to server
--]]

function net.Replicate(Authority, Received)
	if (!Received) then
		if (CLIENT) then
			net.SendToServer()
		else
			net.Send(Authority)
		end
	end
end

local meta = FindMetaTable( "Player" )

--[[
	Function: Create Inventory
	Purpose: Creates an Inventory table and returns it, the inventory will have a grid based on the dimensions specified.
--]]

local function CreateInventory(width, height)
	local inventory = {}

	for i = 1, width do
		inventory[i] = {}

		for i2 = 1, height do
			inventory[i][i2] = {}
		end
	end

	return inventory
end

--[[
	Function: Get Inventory Size
	Purpose: Returns the size of the inventory table handed to the function.
--]]

local function GetInventorySize(Inventory)
	local width, height = #Inventory, #Inventory[1]

	return width, height
end

--[[
	Function: Get Item Size
	Purpose: Gets the size of an item based on the ItemID Provided (convience function tbh)
--]]

local function GetItemSize(ItemID)
	local ItemTable = GAMEMODE:GetItemByID(ItemID)

	return ItemTable.SizeX, ItemTable.SizeY
end

--[[
	Function: Build Trace Table
	Purpose: Returns a table that can be used to see if an item can fit in an applicable spot or not
--]]

local function BuildTraceTable(Inventory)
	local width, height = GetInventorySize(Inventory)
	local TraceTable = CreateInventory(width, height)

	for x = 1, width do 
		for y = 1, height do 
			if (Inventory[x][y].ID) then
				local ItemTable = GAMEMODE:GetItemByID(Inventory[x][y].ID)
				for i = x, (x + (ItemTable.SizeX - 1)) do
					for i2 = y, (y + (ItemTable.SizeY - 1)) do
						TraceTable[i][i2] = "OCCUPIED"
					end
				end
			end
		end
	end

	return TraceTable
end

--[[
	-------------------------------------------------------------------------------------
	--------------------------------Networking-------------------------------------------
	-------------------------------------------------------------------------------------
--]]
if (SV) then
	util.AddNetworkString("nLoadInventory")
end


if (CLIENT) then


	local function nLoadInventory()
		local inv = net.ReadString()
		LocalPlayer().Inventory = pon.decode(inv)
	end
	net.Receive("nLoadInventory", nLoadInventory)

	local function nGiveItem()
		local ItemID = net.ReadString()
		local n = net.ReadFloat()
		local d = net.ReadTable()

		LocalPlayer():GiveItem(ItemID, n, d)
	end
	net.Receive("nGiveItem", nGiveItem)

	local function nRemoveItem()
		local pos = net.ReadVector()
		LocalPlayer():RemoveItem(pos.x, pos.y)
	end
	net.Receive("nRemoveItem", nRemoveItem)

	local function nTooHeavy()
		GAMEMODE:AddChat(Color(200,0,0,255), "CombineControl.ChatNormal", "That's too heavy for you to carry.", {CB_ALL, CB_IC})
	end
	net.Receive("nTooHeavy", nTooHeavy)

	local function nOpenContainer()
		local container = net.ReadEntity()
		local inventory = net.ReadTable()
		container.Inventory = inventory
		LocalPlayer():OpenContainer(container)
	end
	net.Receive("nOpenContainer", nOpenContainer)

	local function nSetQuickSlot()
		local slot, itemid = net.ReadInt(3), net.ReadString()
		LocalPlayer():SetQuickSlot(slot, itemid, true)
	end
	net.Receive("nSetQuickSlot", nSetQuickSlot)

	local function nResetQuickSlot()
		local slot = net.ReadInt(3)
		LocalPlayer():ResetQuickSlot(slot, true)
	end
	net.Receive("nResetQuickSlot", nResetQuickSlot)

	local function nSetArtifactSlot()
		local slot, itemid = net.ReadInt(4), net.ReadString()
		LocalPlayer():SetArtifactSlot(slot, itemid, true)
	end
	net.Receive("nSetArtifactSlot", nSetArtifactSlot)

	local function nResetArtifactSlot()
		local slot = net.ReadInt(4)
		LocalPlayer():ResetArtifactSlot(slot, true)
	end
	net.Receive("nResetArtifactSlot", nResetArtifactSlot)

	local function nSetGearSlot()
		local slot, itemid = net.ReadInt(3), net.ReadString()
		LocalPlayer():SetGearSlot(slot, itemid, true)
	end
	net.Receive("nSetGearSlot", nSetGearSlot)

	local function nResetGearSlot()
		local slot, itemid = net.ReadInt(3)
		LocalPlayer():ResetGearSlot(slot, true)
	end
	net.Receive("nResetGearSlot", nResetGearSlot)

	local function nSetArtifactDetector()
		local itemid = net.ReadString()
		LocalPlayer():SetArtifactDetector(itemid, true)
	end
	net.Receive("nSetArtifactDetector", nSetArtifactDetector)

	local function nResetArtifactDetector()
		local itemid = net.ReadString()
		LocalPlayer():ResetArtifactDetector(true)
	end
	net.Receive("nResetArtifactDetector", nResetArtifactDetector)

	local function nEquipArtifactFrom()
		local PosX = net.ReadInt(5)
		local PosY = net.ReadInt(5)
		local Slot = net.ReadInt(4)

		LocalPlayer():EquipArtifactFrom(PosX, PosY, Slot, true)
	end
	net.Receive("nEquipArtifactFrom", nEquipArtifactFrom)

	local function nRemoveArtifactFrom()
		local pos = net.ReadInt(4)
		LocalPlayer():RemoveArtifactFrom(pos, true)
	end
	net.Receive("nRemoveArtifactFrom", nRemoveArtifactFrom)

	local function nEquipWeaponFrom()
		local PosX = net.ReadInt(5)
		local PosY = net.ReadInt(5)
		local Slot = net.ReadInt(4)

		LocalPlayer():EquipWeaponFrom(PosX, PosY, Slot, true)
	end
	net.Receive("nEquipWeaponFrom", nEquipWeaponFrom)

	local function nRemoveWeaponFrom()
		local pos = net.ReadInt(4)
		LocalPlayer():RemoveWeaponFrom(pos, true)
	end
	net.Receive("nRemoveWeaponFrom", nRemoveWeaponFrom)

elseif (SERVER) then

	local function nEquipWeaponFrom(len, ply)
		local PosX = net.ReadInt(5)
		local PosY = net.ReadInt(5)
		local Slot = net.ReadInt(4)

		ply:EquipWeaponFrom(PosX, PosY, Slot, true)
	end
	net.Receive("nEquipWeaponFrom", nEquipWeaponFrom)

	local function nRemoveWeaponFrom(len, ply)
		local pos = net.ReadInt(4)
		ply:RemoveWeaponFrom(pos, true)
	end
	net.Receive("nRemoveWeaponFrom", nRemoveWeaponFrom)

	local function nEquipArtifactFrom(len, ply)
		local PosX = net.ReadInt(5)
		local PosY = net.ReadInt(5)
		local Slot = net.ReadInt(4)

		ply:EquipArtifactFrom(PosX, PosY, Slot, true)
	end
	net.Receive("nEquipArtifactFrom", nEquipArtifactFrom)

	local function nRemoveArtifactFrom(len, ply)
		local pos = net.ReadInt(4)
		ply:RemoveArtifactFrom(pos, true)
	end
	net.Receive("nRemoveArtifactFrom", nRemoveArtifactFrom)

	local function nDropItem(len, ply)
		local pos = net.ReadVector()
		ply:DropItem(pos.x, pos.y)
	end
	net.Receive("nDropItem", nDropItem)

	local function nSetQuickSlot(len, ply)
		local slot, itemid = net.ReadInt(3), net.ReadString()
		ply:SetQuickSlot(slot, itemid, true)
	end
	net.Receive("nSetQuickSlot", nSetQuickSlot)

	local function nResetQuickSlot(len, ply)
		local slot = net.ReadInt(3)
		ply:ResetQuickSlot(slot, true)
	end
	net.Receive("nResetQuickSlot", nResetQuickSlot)

	local function nSetArtifactSlot(len, ply)
		local slot, itemid = net.ReadInt(4), net.ReadString()
		ply:SetArtifactSlot(slot, itemid, true)
	end
	net.Receive("nSetArtifactSlot", nSetArtifactSlot)

	local function nResetArtifactSlot(len, ply)
		local slot = net.ReadInt(4)
		ply:ResetArtifactSlot(slot, true)
	end
	net.Receive("nResetArtifactSlot", nResetArtifactSlot)

	local function nSetGearSlot(len, ply)
		local slot, itemid = net.ReadInt(3), net.ReadString()
		ply:SetGearSlot(slot, itemid, true)
	end
	net.Receive("nSetGearSlot", nSetGearSlot)

	local function nResetGearSlot(len, ply)
		local slot, itemid = net.ReadInt(3)
		ply:ResetGearSlot(slot, true)
	end
	net.Receive("nResetGearSlot", nResetGearSlot)

	local function nSetArtifactDetector(len, ply)
		local itemid = net.ReadString()
		ply:SetArtifactDetector(itemid, true)
	end
	net.Receive("nSetArtifactDetector", nSetArtifactDetector)

	local function nResetArtifactDetector(len, ply)
		local itemid = net.ReadString()
		ply:ResetArtifactDetector(true)
	end
	net.Receive("nResetArtifactDetector", nResetArtifactDetector)

	local function nUseItem(len, ply)
		local pos = net.ReadVector()
		ply:UseItem(pos.x, pos.y)
	end
	net.Receive("nUseItem", nUseItem)

	local function nMoveItemFromTo(len, ply)
		local pos = net.ReadVector()
		local pos2 = net.ReadFloat()

		ply:MoveItemFromTo(pos.x, pos.y, pos.z, pos2)
	end
	net.Receive("nMoveItemFromTo", nMoveItemFromTo)

	local function nOpenContainer(len, ply)
		local container = net.ReadEntity()

		net.Start("nOpenContainer")
			net.WriteEntity(container)
			net.WriteTable(container.Inventory)
		net.Send(ply)
	end
	net.Receive("nOpenContainer", nOpenContainer)

	local function nContainerItemTransfer(len, ply)
		local pos1 = net.ReadVector()
		local pos2 = net.ReadFloat()
		local cont = net.ReadEntity()
		local from = net.ReadBool()

		ply:TransferItem(pos1.x, pos1.y, pos1.z, pos2, cont, from)
	end
	net.Receive("nContainerItemTransfer", nContainerItemTransfer)

	local function nMoveItemFromToContainer(len, ply)
		local pos1 = net.ReadVector()
		local pos2 = net.ReadFloat()
		local cont = net.ReadEntity()

		ply:MoveItemFromToContainer(pos1.x, pos1.y, pos1.z, pos2, cont)
	end
	net.Receive("nMoveItemFromToContainer", nMoveItemFromToContainer)

end

--[[
	-------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------
--]]

if (CLIENT) then

	local CurrentTooltip = CurrentTooltip or nil
	local ToolTipTimer = CurTime()

	--[[
		Function: UpdateToolTipTime
		Purpose: Called when the cursor is hovered over something wanting to draw a tooltip.
	--]]

	function UpdateToolTipTime()
		ToolTipTimer = CurTime() + 0.1
	end

	--[[
		Function: ToolTipCheck
		Purpose: Called every tick if a tooltip has been drawn. It will make sure that the mouse is hovered over something and remove the tooltip if not.
	--]]

	local function ToolTipCheck()
		if (ToolTipTimer < CurTime()) then
			RemoveToolTip()
			hook.Remove("Think", "ToolTipCheck")
		else
			UpdateToolTip()
		end
	end

	--[[
		Function: UpdateToolTip
		Purpose: Updates a ToolTip using a specified cursor position.
	--]]

	function UpdateToolTip(pIconPanel)
		if (CurrentTooltip and (CurrentTooltip:IsValid())) then
			if (pIconPanel) then
				CurrentTooltip:SetTitle(pIconPanel:GetTooltipTitle() or "ERROR")
				CurrentTooltip:SetDesc(pIconPanel:GetTooltipDesc() or "ERROR")
			end
			ToolTipToCursor()
		end
	end

	--[[
		Function: SetupToolTip
		Purpose: Used to setup the VGUI element of the tooltip
	--]]

	function SetupToolTip(pIconPanel)
		UpdateToolTipTime()
		hook.Add("Think", "ToolTipCheck", ToolTipCheck)
		CurrentTooltip = vgui.Create("CCStalkerToolTip")
		CurrentTooltip:SetTitle(pIconPanel:GetTooltipTitle() or "ERROR")
		CurrentTooltip:SetDesc(pIconPanel:GetTooltipDesc() or "ERROR")
		ToolTipToCursor()
	end

	--[[
		Function: RemoveToolTip
		Purpose: Removes the ToolTip
	--]]

	function RemoveToolTip()
		if (CurrentTooltip and CurrentTooltip:IsValid()) then
			CurrentTooltip:Remove()
		end
	end

	--[[
		Function: DrawToolTip
		Purpose: Draws a ToolTip using a specified cursor position.
	--]]

	function DrawToolTip(pIconPanel)
		if (!CurrentTooltip) then
			SetupToolTip(pIconPanel)
		elseif (!CurrentTooltip:IsValid()) then
			SetupToolTip(pIconPanel)
		else
			UpdateToolTip(pIconPanel)
		end
	end

	--[[
		Function: ToolTipToCursor
		Purpose: Brings the tooltip to the cursor
	--]]

	function ToolTipToCursor()
		local x, y = input.GetCursorPos()
		local TTw, TTh = CurrentTooltip:GetSize()

		if (x + TTw > ScrW()) then
			x = x - TTw
		end

		if (y + TTh > ScrH()) then
			y = y - TTh
		end

		CurrentTooltip:SetPos(x+4, y+4)
		CurrentTooltip:MakePopup()
	end

	--[[
		Function: Create Inventory UI
		Purpose: Returns a DPanel that draws the specified inventory, the owner handles transfering items between containers
	--]]

	function CreateInventoryUI(Inventory, Owner, GridSize)
		local width, height = GetInventorySize(Inventory)
		local GridSize = GridSize or 50

		local InventoryPanel = vgui.Create("DPanel")
		InventoryPanel:SetSize(GridSize * width, GridSize * height)
		InventoryPanel.Grid = CreateInventory(width, height)
		InventoryPanel.Paint = function(p, w, h)
			--surface.SetDrawColor(0, 0, 0, 50)
			--surface.DrawRect(0,0,w,h)

			surface.SetDrawColor(255,255,255,10)

			-- draw the grid

			for i = 0, width  do
				surface.DrawRect(i * GridSize, 0, 1, h) -- draw collums
			end

			for i = 0, height do
				surface.DrawRect(0, i * GridSize, w, 1) -- draw rows
			end

			surface.DrawRect(0, h-1, w, 1) -- draw missing data
			surface.DrawRect(w-1, 0, 1, h)

		end

		for x = 1, width do 
			for y = 1, height do 
				InventoryPanel.Grid[x][y] = vgui.Create("DPanel", InventoryPanel)
				InventoryPanel.Grid[x][y]:SetPos((x - 1) * GridSize, (y - 1) * GridSize)
				InventoryPanel.Grid[x][y]:SetSize(GridSize, GridSize)
				InventoryPanel.Grid[x][y].Paint = function(p, w, h)
					if (p.HoveredItem) then
						surface.SetDrawColor(220,220,220,25)
						surface.DrawRect(0,0,p:GetWide(),p:GetTall())
					end

					p.HoveredItem = false
				end
				InventoryPanel.Grid[x][y]:Receiver("InvItem", function(p, items, dropped)
					local item = items[1]

					-- code branches off a bit and has different handles for a player transfering items around his own inventory versus a container
					if (Owner and Owner == LocalPlayer()) then -- this branch of code is used when manipulating items within a players inventory
						if (item.Owner:GetClass() == "cc_container") then -- this is when the item is in a container and being transfered to the player
							if (LocalPlayer():CanTransferItem(x, y, item.ItemID, Owner, true)) then
								local ItemTable = GAMEMODE:GetItemByID(item.ItemID)
	
								for i = x,  (x + (ItemTable.SizeX - 1)) do
									for i2 = y, (y + (ItemTable.SizeY - 1)) do
										InventoryPanel.Grid[i][i2].HoveredItem = true
									end
								end
	
								if (dropped) then
									LocalPlayer():TransferItem(item.Coords[1], item.Coords[2], x, y, item.Owner, true)
									LocalPlayer():RefreshInventoryPanel()
									LocalPlayer():RefreshContainerPanel(item.Owner)
								end
							end
						elseif (item.Owner == LocalPlayer()) then -- the item being dragged is within the players inventory and the inventory is the players inventory
							if (LocalPlayer():ItemCanFit(x, y, item.ItemID)) then
								local ItemTable = GAMEMODE:GetItemByID(item.ItemID)
		
								for i = x,  (x + (ItemTable.SizeX - 1)) do
									for i2 = y, (y + (ItemTable.SizeY - 1)) do
										InventoryPanel.Grid[i][i2].HoveredItem = true
									end
								end
		
								if (dropped) then
									LocalPlayer():MoveItemFromTo(item.Coords[1], item.Coords[2], x, y)
									LocalPlayer():RefreshInventoryPanel()
								end
							end
						end
					end

					if (Owner and Owner:GetClass() == "cc_container") then -- this branch of code is used when manipulating items within a container
						if (item.Owner:GetClass() == "cc_container") then -- transfering within a container
							if (LocalPlayer():ItemCanFitContainer(x, y, item.ItemID, Owner)) then
								local ItemTable = GAMEMODE:GetItemByID(item.ItemID)
	
								for i = x,  (x + (ItemTable.SizeX - 1)) do
									for i2 = y, (y + (ItemTable.SizeY - 1)) do
										InventoryPanel.Grid[i][i2].HoveredItem = true
									end
								end

								if (dropped) then
									LocalPlayer():MoveItemFromToContainer(item.Coords[1], item.Coords[2], x, y, Owner)
									LocalPlayer():RefreshContainerPanel(Owner)
								end
							end
						elseif (item.Owner == LocalPlayer()) then -- transfering from player inventory to the container inventory
							if (LocalPlayer():CanTransferItem(x, y, item.ItemID, Owner)) then
								local ItemTable = GAMEMODE:GetItemByID(item.ItemID)
	
								for i = x,  (x + (ItemTable.SizeX - 1)) do
									for i2 = y, (y + (ItemTable.SizeY - 1)) do
										InventoryPanel.Grid[i][i2].HoveredItem = true
									end
								end
	
								if (dropped) then
									LocalPlayer():TransferItem(item.Coords[1], item.Coords[2], x, y, Owner, false)
									LocalPlayer():RefreshInventoryPanel()
									LocalPlayer():RefreshContainerPanel(Owner)
								end
							end
						end
					end
				end)
			end
		end

		for x = 1, width do 
			for y = 1, height do 
				if (Inventory[x][y].ID) then
					local ItemTable = GAMEMODE:GetItemByID(Inventory[x][y].ID)
					local InvObject = vgui.Create("CCStalkerIcon", InventoryPanel)
					InvObject:SetCoords(ItemTable.IconX,ItemTable.IconX + ItemTable.SizeX, ItemTable.IconY,ItemTable.IconY + ItemTable.SizeY)
					InvObject:SetSize(ItemTable.SizeX * GridSize, ItemTable.SizeY * GridSize)
					InvObject:SetPos((x - 1) * GridSize, (y - 1) * GridSize)
					InvObject:SetTooltipTitle(ItemTable.Name)
					InvObject:SetTooltipDesc(ItemTable.Description)
					--InvObject:SetTooltip(ItemTable.Name)
					InvObject:Droppable("InvItem")
					InvObject.Owner = Owner
					InvObject.Coords = {x, y}
					InvObject.ItemID = Inventory[x][y].ID
					InvObject.DoClick = function()
						if (Owner == LocalPlayer()) then
							LocalPlayer():UseItem(x, y)
							LocalPlayer():RefreshInventoryPanel()
						end
					end
					InvObject.DoRightClick = function()
						if (Owner == LocalPlayer()) then
							LocalPlayer():DropItem(x, y)
							LocalPlayer():RefreshInventoryPanel()
						end
					end
				end
			end
		end

		return InventoryPanel
	end

	function meta:OpenContainer(Container)
		self:OpenInventory()
		self.ContainerFrame = vgui.Create("DFrame")
		self.ContainerFrame.ItemPanel = CreateInventoryUI(Container.Inventory, Container)
		self.ContainerFrame.ItemPanel:SetParent(self.ContainerFrame)
		self.ContainerFrame.ItemPanel:SetPos(0, 24)
		local SizeX, SizeY = self.ContainerFrame.ItemPanel:GetSize()
		self.ContainerFrame:SetSize(SizeX, SizeY + 24)
		self.ContainerFrame:MakePopup()
		self.ContainerFrame:SetTitle(GAMEMODE.Containers[Container:GetModel()].name)
		local PosX, PosY = self.InventoryFrame:GetPos()
		self.ContainerFrame:SetPos(PosX * 1.95, PosY)
	end

	function meta:OpenInventory()
		self.InventoryFrame = vgui.Create("DFrame")
		self.InventoryFrame.ItemPanel = CreateInventoryUI(LocalPlayer().Inventory, LocalPlayer())
		self.InventoryFrame.ItemPanel:SetParent(self.InventoryFrame)
		local SizeX, SizeY = self.InventoryFrame.ItemPanel:GetSize()
		self.InventoryFrame:SetSize(SizeX, SizeY + 24)
		self.InventoryFrame.ItemPanel:SetPos(0, 24)
		self.InventoryFrame:Center()
		self.InventoryFrame:MakePopup()
		self.InventoryFrame:SetTitle("Inventory")
	end

	function meta:RefreshInventoryPanel()
		self.StalkerFrame:Refresh()
	end

	function meta:RefreshContainerPanel(Container)
		if (self.ContainerFrame and IsValid(self.ContainerFrame)) then
			self.ContainerFrame.ItemPanel:Remove()
			self.ContainerFrame.ItemPanel = CreateInventoryUI(Container.Inventory, Container)
			self.ContainerFrame.ItemPanel:SetParent(self.ContainerFrame)
			self.ContainerFrame.ItemPanel:SetPos(0, 24)
		end
	end

	function meta:OpenStalkerInv()
		self.StalkerFrame = vgui.Create("CCStalkerFrame")
		self.StalkerFrame:SetPlayer(true)
	end

	concommand.Add("cc_dev_openinventory", function()
	LocalPlayer():LoadItemsFromString("")
		LocalPlayer():OpenInventory()
	end)

	concommand.Add("cc_dev_stalkertest", function()
	LocalPlayer():LoadItemsFromString("")
		LocalPlayer():OpenStalkerInv()
	end)

end

--[[
	Function: Load Items From String
	Purpose: Loads the players item from the database. Should be used on the server-side.
--]]

function meta:LoadItemsFromString( str )
print("loading items from string maybe")
	meta:SetupInventory(5, 5)

	local SaveData = {}
if str ~= nil then
	if string.len(str) > 0 then
		SaveData = pon.decode(str)
	end
end
self.Inventory = SaveData
	if SERVER then
		net.Start("nLoadInventory")
		net.WriteString(pon.encode(self.Inventory))
		net.Send(self)
	end
end

--[[
	Gear slot accessors, these are simply for ease of use and clean code and so they can be replicated from client -> server when a client changes stuff.
--]]

--[[
	Function: Set Quick SLot
	Purpose: Sets a quick slot for the player to be able to do stuff with
--]]

function meta:SetQuickSlot(nSlot, sItemID, bReceived)
	self.Inventory.QuickUse[nSlot] = sItemID
	net.Start("nSetQuickSlot")
	net.WriteInt(nSlot, 3)
	net.WriteString(sItemID)
	net.Replicate(self, bReceived)
end

--[[
	Function: Reset Quick Slot
	Purpose: Sets a quick slot to be a table again
--]]

function meta:ResetQuickSlot(nSlot, bReceived)
	self.Inventory.QuickUse[nSlot] = {}

	net.Start("nResetQuickSlot")
	net.WriteInt(nSlot, 3)
	net.Replicate(self, bReceived)
end

--[[
	Function: Get Quick Slot
	Purpose: Gets the item id stored in the quick slot
--]]

function meta:GetQuickSlot(nSlot, bReceived)
	if (!self.Inventory) then
		return false
	end

	if (type(self.Inventory.QuickUse[nSlot]) == "string") then
		return self.Inventory.QuickUse[nSlot]
	else
		return false
	end
end

--[[
	Function: Set Artifact SLot
	Purpose: Sets the artifact in the specified slot.
--]]

function meta:SetArtifactSlot(nSlot, sItemID, bReceived)
	local ItemTable = GAMEMODE:GetItemByID(sItemID)

	if (ItemTable) then
		if (ItemTable.IsArtifact) then
			self.Inventory.Artifacts[nSlot] = sItemID

			net.Start("nSetArtifactSlot")
			net.WriteInt(nSlot, 4)
			net.WriteString(sItemID)
			net.Replicate(self, bReceived)
		end
	end
end

--[[
	Function: Reset Artifact Slot
	Purpose: Sets a quick slot to be a table again
--]]

function meta:ResetArtifactSlot(nSlot, bReceived)
	self.Inventory.Artifacts[nSlot] = {}

	net.Start("nResetArtifactSlot")
	net.WriteInt(nSlot, 4)
	net.Replicate(self, bReceived)
end

--[[
	Function: Get Artifact Slot
	Purpose: Gets the item id stored in the quick slot
--]]

function meta:GetArtifactSlot(nSlot)
	if (!self.Inventory) then
		return false
	end

	if (type(self.Inventory.Artifacts[nSlot]) == "string") then
		return self.Inventory.Artifacts[nSlot]
	else
		return false
	end
end

--[[
	Function: Set Gear Slot
	Purpose: Sets a quick slot for the player to be able to do stuff with
--]]

function meta:SetGearSlot(nSlot, sItemID, bReceived)
	self.Inventory.Gear[nSlot] = sItemID

	net.Start("nSetGearSlot")
	net.WriteInt(nSlot, 3)
	net.WriteString(sItemID)
	net.Replicate(self, bReceived)
end

--[[
	Function: Reset Gear Slot
	Purpose: Sets a quick slot to be a table again
--]]

function meta:ResetGearSlot(nSlot, bReceived)
	self.Inventory.Gear[nSlot] = {}

	net.Start("nResetGearSlot")
	net.WriteInt(nSlot, 3)
	net.Replicate(self, bReceived)
end

--[[
	Function: Get Gear Slot
	Purpose: Gets the item id stored in the quick slot
--]]

function meta:GetGearSlot(nSlot)
	if (!self.Inventory) then
		return false
	end

	if (type(self.Inventory.Gear[nSlot]) == "string") then
		return self.Inventory.Gear[nSlot]
	else
		return false
	end
end

--[[
	Function: Set Artifact Detector
	Purpose: Sets the artifact detector thing slot on the inventory
--]]

function meta:SetArtifactDetector(sItemID, bReceived)
	self.Inventory.ArtifactDetector = sItemID

	net.Start("nSetArtifactDetector")
	net.WriteString(sItemID)
	net.Replicate(self, bReceived)
end

--[[
	Function: Reset Artifact Detector
	Purpose: Sets a quick slot to be a table again
--]]

function meta:ResetArtifactDetector(bReceived)
	self.Inventory.ArtifactDetector = {}

	net.Start("nResetArtifactDetector")
	net.Replicate(self, bReceived)
end

--[[
	Function: Get Artifact Detector
	Purpose: Gets the item id stored in the artifact detector slot
--]]

function meta:GetArtifactDetector()
	if (!self.Inventory) then
		return false
	end

	if (type(self.Inventory.Detector) == "string") then
		return self.Inventory.Detector
	else
		return false
	end
end

--[[
	End of gear accessors
--]]

--[[
	Function: Equip Artifact From
	Purpose: Equips an artifact from a given slot to a given slot
--]]

function meta:EquipArtifactFrom(nPosX, nPosY, nSlot, bReceived)
	if (self.Inventory[nPosX][nPosY].ID) then
		local ItemTable = GAMEMODE:GetItemByID(self.Inventory[nPosX][nPosY].ID)
		if (ItemTable.IsArtifact) then
			if (!self:GetArtifactSlot(nSlot)) then
				self:SetArtifactSlot(nSlot, self.Inventory[nPosX][nPosY].ID, true)
				self.Inventory[nPosX][nPosY] = {}
			end
		end
	end

	if (SERVER) then
		self:SaveInventory()
	end

	net.Start("nEquipArtifactFrom")
	net.WriteInt(nPosX, 5)
	net.WriteInt(nPosY, 5)
	net.WriteInt(nSlot, 4)
	net.Replicate(self, bReceived)
end

--[[
	Function: Remove Artifact From
	Purpose: Remnoves the artifact from the specified slot and inserts it into the inventory.
--]]

function meta:RemoveArtifactFrom(nSlot, bReceived)
	local artifact = self:GetArtifactSlot(nSlot)

	if (artifact and self:CanTakeItem(artifact)) then
		self:InsertItemEasy(artifact)
		self:ResetArtifactSlot(nSlot, true)
	end

	net.Start("nRemoveArtifactFrom")
	net.WriteInt(nSlot, 4)
	net.Replicate(self, bReceived)
end

--[[
	Function: Equip Weapon From
	Purpose: Equips a weapon from the given grid space to the given slot
--]]

function meta:EquipWeaponFrom(nPosX, nPosY, nSlot, bReceived)
	if (nSlot == 1 or nSlot == 2) then
		if (self.Inventory[nPosX][nPosY].ID) then
			local ItemTable = GAMEMODE:GetItemByID(self.Inventory[nPosX][nPosY].ID)
			if (ItemTable.IsWeapon) then
				if (!self:GetGearSlot(nSlot)) then
					self:SetGearSlot(nSlot, self.Inventory[nPosX][nPosY].ID, true)
					self.Inventory[nPosX][nPosY] = {}
				end
			end
		end
	
		if (SERVER) then
			self:SaveInventory()
		end
	
		net.Start("nEquipWeaponFrom")
		net.WriteInt(nPosX, 5)
		net.WriteInt(nPosY, 5)
		net.WriteInt(nSlot, 4)
		net.Replicate(self, bReceived)
	end
end

--[[
	Function: Remove Weapon From
	Purpose: Removes a weapon from the given slot and tosses it into the inventory.
--]]

function meta:RemoveWeaponFrom(nSlot, bReceived)
	local weapon = self:GetGearSlot(nSlot)

	if (weapon and self:CanTakeItem(weapon)) then
		self:InsertItemEasy(weapon)
		self:ResetGearSlot(nSlot, true)
	end

	net.Start("nRemoveWeaponFrom")
	net.WriteInt(nSlot, 4)
	net.Replicate(self, bReceived)
end


--[[
	Function: Save Inventory
	Purpose: Saves the inventory to the MySql database
--]]

function meta:SaveInventory()
	local str = pon.encode( self.Inventory )
	self:UpdateCharacterField( "Inventory", str )
end

--[[
	Function: Can Take Item
	Purpose: Returns wether or not someone can pick up an item
--]]

function meta:CanTakeItem( ItemID )
	return self:FindSlot(ItemID)
end

--[[
	Function: Has Item
	Purpose: Returns wether or not a client has an item in their possesion based on the ItemID
--]]

function meta:HasItem(ItemID)
	local width, height = self:GetInventorySize()

	for i = 1, width do
		for i2 = 1, height do
			if (self.Inventory[i][i2].ID and self.Inventory[i][i2].ID == ItemID) then
				return true
			end
		end
	end

	return false
end

--[[
	Function: Get Inventory Item
	Purpose: Gets the position of an item based on the ItemID
--]]

function meta:GetInventoryItem(ItemID)
	local width, height = self:GetInventorySize()

	for i = 1, width do
		for i2 = 1, height do
			if (self.Inventory[i][i2].ID and self.Inventory[i][i2].ID == ItemID) then
				return i, i2
			end
		end
	end
end

--[[
	Function: Get Inventory Weight
	Purpose: Gets the total weight of all items in the inventory
--]]

function meta:InventoryWeight()
	if (!self.Inventory) then
		return 0
	end

	local SizeX, SizeY = self:GetInventorySize()
	local weight = 0

	for i = 1, SizeX do
		for i2 = 1, SizeY do
			if (self.Inventory[i][i2] and self.Inventory[i][i2].ID) then
				local ItemTable = GAMEMODE:GetItemByID(self.Inventory[i][i2].ID)
				if (ItemTable.Weight) then
					weight = weight + ItemTable.Weight
				end
			end
		end
	end

	return weight
end

--[[
	Function: Get Inventory Max Weight
	Purpose: Gets the max weight of stuff a player can have in their inventory, leaving this empty so you guys can figure out your perks and stuff you're keeping.
--]]

function meta:InventoryMaxWeight()
	return 60
end

--[[
	Function: Give Item
	Purpose: Inserts an item into a players inventory based on the ItemID
--]]

function meta:GiveItem(ItemID, n, data)
	local data = data or {}
	local ItemTable = GAMEMODE:GetItemByID(ItemID)
	local n = n or 1

	for i = 1, n do
		self:InsertItemEasy(ItemID, data)
	end

	if (SERVER) then
		self:SaveInventory()

		net.Start("nGiveItem")
			net.WriteString(ItemID)
			net.WriteFloat(n)
			net.WriteTable(data)
		net.Send(self)
	end
end

--[[
	Function: Remove Item
	Purpose: Removes an item based off the position of the item itself, this function verifies if there is an item in that position and returns true/false if the item was removed successfuly.
--]]

function meta:RemoveItem(PosX, PosY)
	self.Inventory[PosX][PosY] = {}

	if (SERVER) then
		self:SaveInventory()

		net.Start("nRemoveItem")
			net.WriteVector(Vector(PosX, PosY, 0))
		net.Send(self)
	end
end

--[[
	Function: Use Item
	Purpose: Calls the use function of an item based on the position of the item.
--]]

function meta:UseItem(PosX, PosY)
	if (self:PassedOut()) then 
		return
	end

	if (self:TiedUp()) then 
		return
	end

	if (SERVER) then
		GAMEMODE:LogItems( "[R] " .. self:VisibleRPName() .. "'s item " .. self.Inventory[PosX][PosY].ID .. " was removed.", self )
		self:SaveInventory()
	else
		net.Start("nUseItem")
			net.WriteVector(Vector(PosX, PosY, 0))
		net.SendToServer()
	end

	local ret = GAMEMODE:GetItemByID(self.Inventory[PosX][PosY].ID).OnPlayerUse(self.Inventory[PosX][PosY].ID, self)

	if( GAMEMODE:GetItemByID(self.Inventory[PosX][PosY].ID).DeleteOnUse and !ret ) then
		self:RemoveItem(PosX, PosY)
	end
end

--[[
	Function: Drop Item
	Purpose: Drops an item based on the coordinants fed to the function.
--]]

function meta:DropItem(PosX, PosY)
	if (self:PassedOut()) then 
		return
	end

	if (self:TiedUp()) then 
		return
	end

	if (SERVER) then
		GAMEMODE:LogItems( "[R] " .. self:VisibleRPName() .. "'s drop item " .. self.Inventory[PosX][PosY].ID .. ".", self )
		if (self.Inventory[PosX][PosY].ID) then
			local ItemID = self.Inventory[PosX][PosY].ID
			local data = self.Inventory[PosX][PosY].data
			GAMEMODE:CreateItem(self, ItemID, data)
		end
	else
		net.Start("nDropItem")
			net.WriteVector(Vector(PosX, PosY, 0))
		net.SendToServer()
	end

	self:RemoveItem(PosX, PosY)
end

--[[
	Function: Setup Inventory
	Purpose: Sets up an Inventory on a player
--]]

function meta:SetupInventory(width, height)
	self.Inventory = CreateInventory(width, height)
	self.Inventory.QuickUse = {}
	self.Inventory.QuickUse[1] = GAMEMODE.DefaultQuickUseOne or {} -- allows a config variable to be set so you can toss in default quick use slots, etc
	self.Inventory.QuickUse[2] = GAMEMODE.DefaultQuickUseTwo or {}
	self.Inventory.QuickUse[3] = GAMEMODE.DefaultQuickUseThree or {}
	self.Inventory.QuickUse[4] = GAMEMODE.DefaultQuickUseFour or {}

	self.Inventory.Artifacts = {}
	self.Inventory.Artifacts[1] = GAMEMODE.DefaultArtifactOne or {}
	self.Inventory.Artifacts[2] = GAMEMODE.DefaultArtifactTwo or {}
	self.Inventory.Artifacts[3] = GAMEMODE.DefaultArtifactThree or {}
	self.Inventory.Artifacts[4] = GAMEMODE.DefaultArtifactFour or {}
	self.Inventory.Artifacts[5] = GAMEMODE.DefaultArtifactFive or {}

	self.Inventory.Gear = {}
	self.Inventory.Gear[1] = GAMEMODE.DefaultGearOne or {} -- first two are weapon slots, last two are clothing
	self.Inventory.Gear[2] = GAMEMODE.DefaultGearTwo or {}
	self.Inventory.Gear[3] = GAMEMODE.DefaultGearThree or {}
	self.Inventory.Gear[4] = GAMEMODE.DefaultGearFour or {}

	self.Inventory.ArtifactDetector = {}
end

--[[
	Function: Insert Item At
	Purpose: Inserts an item into a clients inventory at a given position
--]]

function meta:InsertItemAt(x, y, ItemID, d)
	local d = d or {}
	self.Inventory[x][y] = {ID = ItemID, data = d}
end

--[[
	Function: Insert Item Easy
	Purpose: Easily insert an item into the grid inventory, returning a bool determining success.
--]]

function meta:InsertItemEasy(ItemID, data)
	local ItemTable = GAMEMODE:GetItemByID(ItemID)
	local SizeX, SizeY = ItemTable.SizeX, ItemTable.SizeY

	if (self:FindSlot(ItemID)) then
		local PosX, PosY = self:FindSlot(ItemID)
		self:InsertItemAt(PosX, PosY, ItemID, data)

		if (SERVER) then
			GAMEMODE:LogItems( "[G] " .. self:VisibleRPName() .. " obtained item " .. ItemID .. ".", self )
			GAMEMODE:GetItemByID( ItemID ).OnPlayerPickup( ItemID, self )
		end
	end
end

--[[
	Function: Get Inventory Size
	Purpose: Returns the size of a players inventory
--]]

function meta:GetInventorySize()
	local inventory = self.Inventory
	local width, height = #inventory, #inventory[1]

	return width, height
end

--[[
	Function: Remove By Item ID
	Purpose: Removes an item based on the unique ItemID specified
--]]

function meta:RemoveByItemID(ItemID)
	local width, height = self:GetInventorySize()

	for i = 1, width do
		for i2 = 1, height do
			if (self.Inventory[i][i2].ID and self.Inventory[i][i2].ID == ItemID) then
				self.Inventory[i][i2] = {}
				return
			end
		end
	end
end

--[[
	Function: Item Can Fit
	Purpose: Returns wether or not an item can fit based on a grid space based on the ItemID provided
--]]

function meta:ItemCanFit(PosX, PosY, ItemID)
	local width, height = self:GetInventorySize()
	local SizeX, SizeY = GetItemSize(ItemID)

	local TraceTable = BuildTraceTable(self.Inventory)

	local available = false

	if (TraceTable[PosX][PosY] != "OCCUPIED") then
		available = true
		for i = PosX, (PosX + (SizeX - 1)) do
			for i2 = PosY, (PosY + (SizeY - 1)) do
				if i > width or i2 > height then
					available = false
				elseif (TraceTable[i][i2] == "OCCUPIED") then
					available = false
				end
			end
		end
	end

	return available
end

--[[
	Function: Item Can Fit Container
	Purpose: Returns wether or not an item can fit based on a grid space and ItemID provided within the container provided. (this is a bit of a lazy move but makes replication easier)
--]]

function meta:ItemCanFitContainer(PosX, PosY, ItemID, Container)
	local width, height = GetInventorySize(Container.Inventory)
	local SizeX, SizeY = GetItemSize(ItemID)

	local TraceTable = BuildTraceTable(Container.Inventory)

	local available = false

	if (TraceTable[PosX][PosY] != "OCCUPIED") then
		available = true
		for i = PosX, (PosX + (SizeX - 1)) do
			for i2 = PosY, (PosY + (SizeY - 1)) do
				if i > width or i2 > height then
					available = false
				elseif (TraceTable[i][i2] == "OCCUPIED") then
					available = false
				end
			end
		end
	end

	return available
end

--[[
	Function: Can Use Container
	Purpose: This is where you add restrictions as to wether or not a client can use a container, it passes the container so you can easily validate on the server if the container is locked, etc.
--]]

function meta:CanUseContainer(Container)
	return true
end

--[[
	Function: Transfer Item
	Purpose: Transfers an item to or from the specified container. For clarification if from is true you are transfering FROM a container
--]]

function meta:TransferItem(StartX, StartY, EndX, EndY, Container, From)
	if (From) then
		local Item = Container.Inventory[StartX][StartY]
	
		Container.Inventory[StartX][StartY] = {}
		self.Inventory[EndX][EndY] = Item
	else
		local Item = self.Inventory[StartX][StartY]
	
		self.Inventory[StartX][StartY] = {}
		Container.Inventory[EndX][EndY] = Item
	end

	if (SERVER) then
		self:SaveInventory()
		GAMEMODE:SaveContainer(Container)
	else
		net.Start("nContainerItemTransfer")
			net.WriteVector(Vector(StartX, StartY, EndX))
			net.WriteFloat(EndY)
			net.WriteEntity(Container)
			net.WriteBool(From or false)
		net.SendToServer()
	end
end

--[[
	Function: Can Transfer Item 
	Purpose: Returns wether or not an item can fit based on a grid space and item size provided, ItemID is used to ignore the original item. The fifth argument dictates direction, wether it is to or from the container in question.
--]]

function meta:CanTransferItem(PosX, PosY, ItemID, Container, From)
	local width, height
	if (From) then
		width, height = GetInventorySize(self.Inventory)
	else
		width, height = GetInventorySize(Container.Inventory)
	end

	local TraceTable
	if (From) then
		TraceTable = BuildTraceTable(self.Inventory)
	else
		TraceTable = BuildTraceTable(Container.Inventory)
	end

	local SizeX, SizeY = GetItemSize(ItemID)
	local available = false

	if (TraceTable[PosX][PosY] != "OCCUPIED") then
		available = true
		for i = PosX, (PosX + (SizeX - 1)) do
			for i2 = PosY, (PosY + (SizeY - 1)) do
				if i > width or i2 > height then
					available = false
				elseif (TraceTable[i][i2] == "OCCUPIED") then
					available = false
				end
			end
		end
	end

	return available
end

--[[
	Function: Move Item From To Container
	Purpose: Moves an item around inside of a container.
]]

function meta:MoveItemFromToContainer(StartX, StartY, EndX, EndY, Container)
	local Item = Container.Inventory[StartX][StartY]

	self.Inventory[StartX][StartY] = {}
	self.Inventory[EndX][EndY] = Item

	if (CLIENT) then
		net.Start("nMoveItemFromToContainer")
			net.WriteVector(Vector(StartX, StartY, EndX))
			net.WriteFloat(EndY)
			net.WriteEntity(Container)
		net.SendToServer()
	end
end

--[[
	Function: Move Item From To
	Purpose: Move an Item From a slot To a new slot
--]]

function meta:MoveItemFromTo(StartX, StartY, EndX, EndY)
	local Item = self.Inventory[StartX][StartY]

	if (SERVER) then
		if (self:ItemCanFit(EndX, EndY, Item.ID)) then
			self.Inventory[StartX][StartY] = {}
			self.Inventory[EndX][EndY] = Item

			self:SaveInventory()
		end
	else
		self.Inventory[StartX][StartY] = {}
		self.Inventory[EndX][EndY] = Item

		net.Start("nMoveItemFromTo")
			net.WriteVector(Vector(StartX, StartY, EndX))
			net.WriteFloat(EndY)
		net.SendToServer()
	end
end

--[[
	Function: Find Slot
	Purpose: Finds the next available slot in the inventory for the item size specified
--]]

function meta:FindSlot(ItemID)
	local width, height = self:GetInventorySize()
	local SizeX, SizeY = GetItemSize(ItemID)

	local TraceTable = BuildTraceTable(self.Inventory)

	for x = 1, width do
		for y = 1, height do
			if (TraceTable[x][y] != "OCCUPIED") then
				local available = true
				for i = x, (x + (SizeX - 1)) do
					for i2 = y, (y + (SizeY - 1)) do
						if i > width or i2 > height then
							available = false
						elseif (TraceTable[i][i2] == "OCCUPIED") then
							available = false
						end
					end
				end
				if (available) then
					return x, y
				end
			end
		end
	end
end

--[[
	Function: Create Container
	Purpose: Spawns a container entity, this will cause it to do an initial save to the mysql db
--]]

local offset = 0

function GM:CreateContainer(Model, Pos, Angs)
	local ContData = self.Containers[Model]
	local Container = ents.Create("cc_container")

	math.randomseed(os.time() + offset)
	Container.ContainerID = math.random(0,999999999)
	math.randomseed(os.time())
	Container.Inventory = CreateInventory(ContData.x, ContData.y)
	Container:SetModel(Model)
	Container:SetPos(Pos)
	Container:SetAngles(Angs)
	Container:Spawn()

	offset = offset + 1
end