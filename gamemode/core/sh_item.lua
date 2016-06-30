--[[
	Filename: sh_item.lua
--]]

rain.item = {}
rain.itembuffer = {} -- this is where all base items are stored
rain.itemindex = {} -- this is where all current and unique items are stored
rain.itemsavequeue = {} -- this is the item save queue

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

function item_meta:Sync(tVarArgs)
	if (CL) then -- this function called clientside syncs the item info on the client itself

	else

	end
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
	self.itemname = sNewName
end

function item_meta:GetName()
	return self.itemname or "Item name not loaded."
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

function rain.item.getmeta()
	return RAIN_ITEMMETA
end

function rain.item.destroyitembyid(nItemID)
	rain.itemindex[nItemID] = nil
	-- do mysql removal here
end

function rain.item.loaddefaultitems()

end

function rain.item.loaditems()
	-- load items from mysql then insert them into the index, the item bases must be loaded first.
end

function rain.item.get(nItemID)
	return rain.item.itemin[nItemID]
end

function rain.item.saveitems()
	for _, ItemID in pairs(rain.itemsavequeue) do
		rain.item.get(ItemID):Save()
	end
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

-- constructs and returns a new item object

function rain.item:New(sItemBase)
	local itemObj = {}
	return itemObj
end

local rainchar = rain.character.getmeta()

function rainchar:DropItem(objItem)

end

function rainchar:AddItem(objItem)

end

function rainchar:CreateAndAddItem(objItem)

end