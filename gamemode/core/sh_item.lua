--[[
	Filename: sh_item.lua
--]]

rain.item = rain.item or {}
rain.itembuffer = rain.itembuffer or {} -- this is where all base items are stored
rain.itemindex = rain.itemindex or {} -- this is where all current and unique items are stored
rain.itemsavequeue = {} -- this is the item save queue

itemdirectory = "raindrop/gamemode/raindrop/items"

local item_meta = {}

-- tier enums

TIER_WORN = 1 -- (White)
TIER_STANDARD = 2 -- (Green)
TIER_SPECIALIZED = 3 -- (Blue)
TIER_SUPERIOR = 4 -- (Purple)
TIER_HIGHEND = 5 -- (Gold)
TIER_GEARSET = 6 -- (Turqoise)

-- WoW style tier enums that go off of color (I do prefer using these)

TIER_WHITE = 1
TIER_GREEN = 2
TIER_BLUE = 3
TIER_PURPLE = 4
TIER_GOLD = 5
TIER_SET = 6


function item_meta:GetID()
	return self.id or 0
end

function item_meta:Save()
	table.insert(rain.itemsavequeue, self:GetID())
end

local pm = FindMetaTable("Player")
function pm:Sync(tVarArgs)
	if (CL) then -- this function called clientside syncs the item info on the client itself
		net.Start("nRequestItemBuffer")
		net.SendToServer()
	else

	end
end

if (SV) then
util.AddNetworkString("nReceiveItemBuffer")
	util.AddNetworkString("nRequestItemBuffer")
		util.AddNetworkString("nReceiveItemIndex")
		
		function rain:SendItemBuffer(pClient)
			net.Start("nReceiveItemBuffer")
			net.Send(pClient)

			net.Start("nReceiveItemIndex")
			net.WriteTable( rain.itemindex )
			net.Send(pClient)
		end

else
	net.Receive("nReceiveItemBuffer", function(len, ply)
	--rain.itembuffer = net.ReadTable()
	rain.item.loadbaseitems()
		PrintTable(rain.itembuffer)
	end)
	net.Receive("nReceiveItemIndex", function(len, ply)
	rain.itemindex = net.ReadTable()
		for k, v in pairs(rain.itemindex) do
			
		end
	end)
end

function item_meta:SyncMetaData(tVarArgs)
	if (CL) then

	else

	end
end

function item_meta:GetSeed()
	if self.randseed then
		return self.randseed
	else
		self.randseed = math.random() + (self:GetID() * 100)
	end
end

function item_meta:SetBase()

end

function item_meta:GetBase()

end

function item_meta:SetOwningEntity(eOwningEntity)
	self.owningentity = eOwningEntity
end

function item_meta:GetOwningEntity()
	return self.owningentity or false
end

function item_meta:GetInWorld()
	return self.inworld
end

function item_meta:SetInWorld(bNewInWorld)
	self.inworld = bNewInWorld
end

function item_meta:SetDropSound(sNewSound)
	self.dropsound = Sound(sNewDropSoundPath)
end

function item_meta:GetDropSound()
	return self.dropsound or Sound(rain.cfg.items.dropsound)
end

function item_meta:SetPickupSound(sNewSound)
	self.pickupsound = Sound(sNewSound)
end 

function item_meta:GetPickupSound()
	return self.pickupsound or Sound(rain.cfg.items.dropsound)
end

function item_meta:SetUseSound(sNewSound)
	self.usesound = sNewSound
end

function item_meta:GetUseSound(sNewSound)
	return self.usesound or Sound(rain.cfg.items.usesound)
end

function item_meta:SetMoveSound(sNewSound)
	self.movesound = sNewSound
end

function item_meta:GetMoveSound()
	return self.movesound or Sound(rain.cfg.items.movesound)
end

function item_meta:SetModel(sNewModelPath)
	self.model = Model(sNewModelPath)
end

function item_meta:GetModel()
	return self.model or "models/props_junk/watermelon01.mdl"
end

function item_meta:SetWeight(nWeight)
	self.weight = nWeight
end

function item_meta:GetWeight()
	return self.weight or 1
end

function item_meta:SetDescription(sNewDescription)
	self.description = sNewDescription
end

function item_meta:GetDescription()
	return self.description or "Item description not loaded."
end

function item_meta:SetName(sNewName)
	self.Name = sNewName
end

function item_meta:GetName()
	return self.Name or "Item name not loaded."
end

function item_meta:GetItemSize()
return self.SizeX, self.SizeY
end

function item_meta:GetSizeX()
	return self.SizeX or 1
end

function item_meta:GetSizeY()
	return self.SizeY or 1
end

function item_meta:GetIconX()
	return self.IconX or 1
end

function item_meta:GetIconY()
	return self.IconX or 1
end

function item_meta:OverrideImpactSounds(bOverride, tOverrideSounds)
	self.overrideimpactsounds = bOverride
	self.newimpactsounds = tOverrideSounds
end

function item_meta:GetOverrideImpactSounds()
	if self.overrideimpactsounds then
		return self.newimpactsounds
	else
		return self.overrideimpactsounds
	end
end

function item_meta:SetMetaData(tNewMetaData)
	self.metadata = tNewMetaData
	self:SyncMetaData()
end

if (SV) then
	function item_meta:SpawnEntity(vPos, aAngs)
		if self:GetInWorld() then
			return
		end

		self:SetInWorld(true)
		local item = ents.Create("rd_item")

		item:SetModel(self:GetModel())
		item:SetPos(vPos)
		item:SetAngs(aAngs)
		item:SetItemID(self:GetItemID())
		item:Spawn()
		self:SetOwningEntity(item)
	end
end

function item_meta:New(sUniqueID, tMetaData)


--tMetaData
end

function item_meta:DestroyItem()
	if self:GetInWorld() then
		self:GetWorldEntity():Remove()
	end
end

function item_meta:SetBaseItem(sNewBase)
	self.ItemBase = sNewBase or false
end

function item_meta:GetBaseItem()
	return self.ItemBase
end

item_meta.__index = item_meta
local RAIN_ITEMMETA = item_meta

function rain.item.new(base, id, data)
	if (rain.itemindex[id] and rain.itemindex[id].base == base) then
		return rain.itemindex[id]
	end

	local stockItem = rain.itembuffer[base]

	if (stockItem) then
		local item = setmetatable({}, {__index = stockItem})
		item.id = id
		item.data = data or {}
		item.base = base

		rain.itemindex[id] = item
	if (SV) then
		local InsertObj = mysql:Insert("items")
		InsertObj:Insert("base", base)
		InsertObj:Insert("meta", pon.encode(item.data))
		InsertObj:Insert("ownerhistory", "{}")
		InsertObj:Insert("inworld", 0)
		InsertObj:Insert("worlddata", "{}")
		InsertObj:Execute()
	end
		return item
	end
end

function rain.item.getmeta()
	return RAIN_ITEMMETA
end

function rain.item.destroyitembyid(nItemID)
	rain.itemindex[nItemID] = nil
	-- do mysql removal here
end

function rain.item.loadbaseitems()
local items = file.Find(itemdirectory.."/base/*.lua", "LUA")

	for k, v in ipairs(items) do
	print(itemdirectory.."/base/"..v)
		rain.util.include(itemdirectory.."/base/"..v)
	end
	
	
end

function rain.item.loaditems()
	-- load from items mysql then insert them into the index, the item bases must be loaded first.
	if (SV) then
	local LoadObj = mysql:Select("items")
	LoadObj:Callback(function(tResult, uStatus, uLastID)
			for _, item in pairs(tResult) do
				rain.item.new(item.base, item.id, item.meta)
			end
		end)
	LoadObj:Execute()
	end
	
	if (CL) then
	for k, v in SortedPairs(item.index) do
		print(v)
		print(k)
	end
	end
end

function rain.item.get(nItemID)
	return rain.item.itemin[nItemID]
end

function rain.item.saveitems()
	for _, ItemID in pairs(rain.itemsavequeue) do
		rain.item.get(ItemID):Save()
	end
end
--credit to nutscript for the registering system
function rain.item.register(ITEM)
	local meta = RAIN_ITEMMETA
			setmetatable(ITEM, RAIN_ITEMMETA)
			ITEM.Name = ITEM.Name or "No Name Specified"
			ITEM.Description = ITEM.Description or "noDesc"
			ITEM.base = ITEM.base or "NoUniqueID"
			ITEM.IconMat = ITEM.IconMat or "materials/icon16/cancel.png"
			ITEM.hooks = ITEM.hooks or {}
			ITEM.postHooks = ITEM.postHooks or {}
			ITEM.functions = ITEM.functions or {}
			

			local oldBase = ITEM.base

			if (ITEM.base) then
				
			end

			ITEM.SizeX = ITEM.SizeX or 2
			ITEM.SizeY = ITEM.SizeY or 2
			ITEM.IconX = ITEM.IconX or 2
			ITEM.IconY = ITEM.IconY or 2
			ITEM.category = ITEM.category or "misc"
-- can make bases by replacing this V table with a new one
			(isBaseItem and rain.itembuffer or rain.itembuffer)[ITEM.base] = ITEM
print(ITEM.Name.." item base loaded.")
end

if (SV) then
	local newthink = 0
	function rain.item.think()
		if CurTime() > newthink then
			rain.item.saveitems()
			newthink = CurTime() + 3
		end
	end
end

local rainchar = rain.character.getmeta()

function rainchar:DropItem(objItem)

end

function rainchar:AddItem(objItem)

end