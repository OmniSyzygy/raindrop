rain.suits = {}
local pmeta = FindMetaTable("Player")

-- 'enumerations' for the bones

BONE_PELVIS 		=	"ValveBiped.Bip01_Pelvis"
BONE_L_THIGH		=	"ValveBiped.Bip01_L_Thigh"
BONE_L_CALF			=	"ValveBiped.Bip01_L_Calf"
BONE_L_FOOT			=	"ValveBiped.Bip01_L_Foot"
BONE_R_THIGH		=	"ValveBiped.Bip01_R_Thigh"
BONE_R_CALF			=	"ValveBiped.Bip01_R_Calf"
BONE_R_FOOT			=	"ValveBiped.Bip01_R_Foot"
BONE_SPINE1			=	"ValveBiped.Bip01_Spine1"
BONE_SPINE2			=	"ValveBiped.Bip01_Spine2"
BONE_NECK			=	"ValveBiped.Bip01_Neck"
BONE_HEAD			=	"ValveBiped.Bip01_Head"
BONE_L_UPPERARM		=	"ValveBiped.Bip01_L_UpperArm"
BONE_L_FOREARM		=	"ValveBiped.Bip01_L_Forearm"
BONE_L_HAND			=	"ValveBiped.Bip01_L_Hand"
BONE_R_UPPERARM		=	"ValveBiped.Bip01_R_UpperArm"
BONE_R_FOREARM		=	"ValveBiped.Bip01_R_Forearm"
BONE_R_HAND			=	"ValveBiped.Bip01_R_Hand"

-- called whenever a player takes damage
function pmeta:OnDamageTaken(sBone, objDamageInfo)
	local nDamage = self:GetDamageTaken(sBone, objDamageInfo)

	return true, nDamage -- apply the damage, and specify how much
end

-- goes through the players clothing and Gets how much damage they would take
function pmeta:GetDamageTaken(sBone, objDamageInfo)
	for _, Outfits in pairs(self:GetOutfits())
end

-- this is called by the inventory item when a player wants to wear an outfit
function pmeta:WearOutfit(objItem)
	local objSuit = objItem:GetSuit() -- returns a string specifying the suit of clothing

	local tSuitData = self:GetCharacter():GetAppearanceData("Clothing", {})
	tSuitData[objSuit:GetUniqueID()] = true
	self:GetCharacter():SetAppearanceData(Suits, tSuitData)
	self:UpdateAppearance()

	objSuit:OnWear()

	-- call event
	self:OnWearOutfit()
end

-- this is called every time that the player wears or removes clothing
function pmeta:UpdateAppearance()

	self:OnAppearanceUpdated()
end

-- this is called by the inventory item when a player wants to remove an outfit
function pmeta:RemoveOutfit(objItem)
	local objSuit = objItem:GetSuit()

	local tSuitData = self:GetCharacter():GetAppearanceData("Clothing", {})
	tSuitData[objSuit:GetUniqueID()] = nil
	self:GetCharacter():SetAppearanceData(Suits, tSuitData)
	self:UpdateAppearance()

	-- call event
	self:OnRemoveOutfit()
end

-- overridable event for when you put a suit on
function pmeta:OnWearOutfit(bSuccess, objItem)

end

-- override event for when you remove a suit
function pmeta:OnRemoveOutfit(bSuccess, objItem)

end

-- overridable event for when a player updates their appearance
function pmeta:UpdateAppearance()

end

function pmeta:GetOutfits()
	return self.Outfits or {}
end

-- Get the damage multiplier per bone
function rain.suits.GetDamageMultiplier(sBone)
	return rain.cfg.dammul[sBone]
end

local outfit_base = {}

-- Damage Resistance
outfit_base.DR = 0.0 -- overall DR of the suit, this is added to protected bones DR value
outfit_base.UseDR = false

-- Damage Threshold
outfit_base.DT = 0.0 -- overall DT of the suit, this is added to protected bones DT value
outfit_base.UseDT = false

-- Suit Health
outfit_base.Health = 1.0

outfit_base.ApplyDamageToSuit = true

outfit_base.DamageToSuitHealthRatio = 0.5

-- List of DMG Enumerations that the suit protects against, it uses a small struct that contains the DMG Enum and a DT and a DR value for it, the DR and DT values will be optimized away if the suit is set to not use them.
-- The entire list can be found here: http://wiki.garrysmod.com/page/Enums/DMG
-- NEVER make a suit protect against generic damage, it will make it so players gain DR/DT from random shit!

-- Wether or not the suit protects every part of your body
outfit_base.ProtectEverything = false

-- Bones that are protected by the suit
outfit_base.ProtectedAreas = {}

function outfit_base:AddProtectedBone(sBone, nDTValue, nDRValue, tDamageTypes)
	tDamageTypes = tDamageTypes or {DMG_BULLET, DMG_BUCKSHOT} -- defaults to protecting from gunfire only

	if self:GetUseDR() and self:GetUseDT() then
		self.ProtectedAreas[sBone] = {DamageTypes = tDamageTypes, DT = nDTValue, DR = nDRValue}
	elseif self:GetUseDR() and !self:GetUseDT() then
		self.ProtectedAreas[sBone] = {DamageTypes = tDamageTypes, DR = nDRValue}
	elseif self:GetUseDT() and !self:GetUseDT() then
		self.ProtectedAreas[sBone] = {DamageTypes = tDamageTypes, DT = nDTValue}
	end
end

function outfit_base:RemoveProtectedBone(sBone)
	self.ProtectedAreas[sBone] = nil
end

function outfit_base:BoneIsProtected(sBone)
	for bone, _ in pairs(ProtectedAreas) do
		if bone == sBone then
			return true
		end
	end

	return false
end

-- called whenever a suit takes damage, only lowers the suit health by default.
function outfit_base:OnDamageTaken(sBone, objDamageInfo)
	local sBone, objDamageInfo = sBone, objDamageInfo -- make sure that these exist in memory everywhere in the function
	if type(sBone) != "string" then -- if sBone isn't passed, assign it's value to objDamageInfo and make sBone be equal to the pelvis
		objDamageInfo = sBone
		sBone = "ValveBiped.Bip01_Pelvis"
	elseif !sBone and !objDamageInfo then
		objDamageInfo = DamageInfo()
		sBone = "ValveBiped.Bip01_Pelvis"
	end

	local nDamageAmount = objDamageInfo:GetDamage()
	local enumDamageType = objDamageInfo:GetDamageType()

	local nDamageModifier = 1.0

	if self:BoneIsProtected(sBone) then
		if self:GetUseDR() and self:GetUseDT() then
			
		elseif self:GetUseDR() and !self:GetUseDT() then
			
		elseif self:GetUseDT() and !self:GetUseDT() then
			
		end
	end
end

function outfit_base:GetDamageResistance(nDamage, nDR)

end

function outfit_base:GetDamageThreshold(nDamage, nDT)

end

function outfit_base:GetDamageResistanceThreshold(nDamage, nDR, nDT)

end

-- event for when the clothing is removed
function outfit_base:OnRemove()

end

-- event for when the clothing is worn
function outfit_base:OnWear()

end

-- returns the new players model, this should only be used for suits that override everything, returns false
function outfit_base:GetPlayerModel()
	return self.OverrideModel or false
end

function outfit_base:SetOverrideModel(sModel)
	self.OverrideModel = sModel
end

function outfit_base:RemoveOverrideModel()
	self.OverrideModel = nil
end

function outfit_base:GetDamageThreshold()
	return self.DT
end

function outfit_base:SetDamageThreshold(nNewDamageThreshold)
	self.DT = nNewDamageThreshold
end

function outfit_base:SetDamageResistance(nNewDamageResistance)
	if nNewDamageResistance > 1.0 then
		nNewDamageResistance = nNewDamageResistance / 100.0
	end

	self.DR = nNewDamageResistance
end

function outfit_base:GetDamageResistance()
	return self.DR = 0.0
end

function outfit_base:GetItemHealth()
	return self.Health or 1.0
end

function outfit_base:SetItemHealth(nNewHealth)
	self.Health = nNewHealth;
end

function outfit_base:SetUseDT(bNewDT)
	self.UseDT = bNewDT
end

function outfit_base:GetUseDT()
	return self.UseDT
end

function outfit_base:SetUseDR(bNewDT)
	self.UseDR = bNewDT
end

function outfit_base:GetUseDR()
	return self.UseDR
end

outfit_base.__index = outfit_base