rain.clothings = {}
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
--	for _, Outfits in pairs(self:GetOutfits())
end

-- this is called by the inventory item when a player wants to wear an outfit
function pmeta:WearOutfit(objItem)
	local objClothing = objItem:GetClothing() -- returns a string specifying the clothing of clothing

	local tClothingData = self:GetCharacter():GetAppearanceData("Clothing", {})
	tClothingData[objClothing:GetUniqueID()] = true
	self:GetCharacter():SetAppearanceData(Clothings, tClothingData)
	self:UpdateAppearance()

	objClothing:OnWear()

	-- call event
	self:OnWearOutfit()
end

-- this is called every time that the player wears or removes clothing
function pmeta:UpdateAppearance()

	self:OnAppearanceUpdated()
end

-- this is called by the inventory item when a player wants to remove an outfit
function pmeta:RemoveOutfit(objItem)
	local objClothing = objItem:GetClothing()

	local tClothingData = self:GetCharacter():GetAppearanceData("Clothing", {})
	tClothingData[objClothing:GetUniqueID()] = nil
	self:GetCharacter():SetAppearanceData(Clothings, tClothingData)
	self:UpdateAppearance()

	-- call event
	self:OnRemoveOutfit()
end

-- overridable event for when you put a clothing on
function pmeta:OnWearOutfit(bSuccess, objItem)

end

-- override event for when you remove a clothing
function pmeta:OnRemoveOutfit(bSuccess, objItem)

end

-- overridable event for when a player updates their appearance
function pmeta:UpdateAppearance()

end

function pmeta:GetOutfits()
	return self.Outfits or {}
end

-- Get the damage multiplier per bone
function rain.clothings.GetDamageMultiplier(sBone)
	return rain.cfg.dammul[sBone]
end

local clothing_base = {}

-- Damage Resistance
clothing_base.DR = 0.0 -- overall DR of the clothing, this is added to protected bones DR value
clothing_base.UseDR = false

-- Damage Threshold
clothing_base.DT = 0.0 -- overall DT of the clothing, this is added to protected bones DT value
clothing_base.UseDT = false

-- Clothing Health
clothing_base.Health = 1.0

clothing_base.ApplyDamageToClothing = true

clothing_base.DamageToClothingHealthRatio = 0.5

-- List of DMG Enumerations that the clothing protects against, it uses a small struct that contains the DMG Enum and a DT and a DR value for it, the DR and DT values will be optimized away if the clothing is set to not use them.
-- The entire list can be found here: http:--wiki.garrysmod.com/page/Enums/DMG
-- NEVER make a clothing protect against generic damage, it will make it so players gain DR/DT from random shit!

-- Bones that are protected by the clothing
clothing_base.ProtectedAreas = {}

function clothing_base:AddProtectedBone(sBone, nDTValue, nDRValue, tDamageTypes)
	tDamageTypes = tDamageTypes or {DMG_BULLET, DMG_BUCKSHOT} -- defaults to protecting from gunfire only

	if self:GetUseDR() and self:GetUseDT() then
		self.ProtectedAreas[sBone] = {DamageTypes = tDamageTypes, DT = nDTValue, DR = nDRValue}
	elseif self:GetUseDR() and !self:GetUseDT() then
		self.ProtectedAreas[sBone] = {DamageTypes = tDamageTypes, DR = nDRValue}
	elseif self:GetUseDT() and !self:GetUseDT() then
		self.ProtectedAreas[sBone] = {DamageTypes = tDamageTypes, DT = nDTValue}
	end
end

function clothing_base:RemoveProtectedBone(sBone)
	self.ProtectedAreas[sBone] = nil
end

function clothing_base:BoneIsProtected(sBone)
	for bone, _ in pairs(ProtectedAreas) do
		if bone == sBone then
			return true
		end
	end

	return false
end

-- called whenever a clothing takes damage, only lowers the clothing health by default.
function clothing_base:OnDamageTaken(sBone, objDamageInfo)
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

	local nNewDamage = nDamageAmount

	if self:BoneIsProtected(sBone) then
		local nDamage, nDR, nDT, tDamageTypes = self:GetBoneProtectionData(sBone)

		if tDamageTypes[enumDamageType] then
			if self:GetUseDR() and self:GetUseDT() then
				nNewDamage = self:GetDamageThreshold(nDamageAmount, nDT, nDR)
			elseif self:GetUseDR() and !self:GetUseDT() then
				nNewDamage = self:GetDamageResistance(nDamage, nDR)
			elseif self:GetUseDT() and !self:GetUseDR() then
				nNewDamage = self:GetDamageThreshold(nDamageAmount, nDT)
			else
				nNewDamage = self:GetDamageResistance(nDamageAmount, nDR)
			end
		end
	end

	if self:GetClothingTakesDamage() then
		local nHealth = self:GetClothingHealth() * 100

		self:SetClothingHealth(math.clamp(nHealth - nNewDamage, 0, 1) / 100)
	end
end

function clothing_base:GetClothingDamageRatio()
	return clothing_base.DamageToClothingHealthRatio
end

function clothing_base:GetClothingTakesDamage()
	return clothing_base.ApplyDamageToClothing
end

function clothing_base:GetDamageResistance(nDamage, nDR)
	return nDamage * math.min(nDR, 0.85)
end

function clothing_base:GetDamageThreshold(nDamage, nDT, nDR)
	local nDR = nDR or 0.0

	return math.max(nDamage - nDT, self:GetDamageResistance(nDamage, nDR) * 0.2)
end

-- event for when the clothing is removed
function clothing_base:OnRemove()

end

-- event for when the clothing is worn
function clothing_base:OnWear()

end

-- returns the new players model, this should only be used for clothings that override everything, returns false
function clothing_base:GetPlayerModel()
	return self.OverrideModel or false
end

function clothing_base:SetOverrideModel(sModel)
	self.OverrideModel = sModel
end

function clothing_base:RemoveOverrideModel()
	self.OverrideModel = nil
end

function clothing_base:GetDamageThreshold()
	return self.DT
end

function clothing_base:SetDamageThreshold(nNewDamageThreshold)
	self.DT = nNewDamageThreshold
end

function clothing_base:SetDamageResistance(nNewDamageResistance)
	if nNewDamageResistance > 1.0 then
		nNewDamageResistance = nNewDamageResistance / 100.0
	end

	self.DR = nNewDamageResistance
end

function clothing_base:GetDamageResistance()
--	return self.DR = 0.0
end

function clothing_base:GetClothingHealth()
	return self.Health or 1.0
end

function clothing_base:SetClothingHealth(nNewHealth)
	self.Health = nNewHealth
end

function clothing_base:SetUseDT(bNewDT)
	self.UseDT = bNewDT
end

function clothing_base:GetUseDT()
	return self.UseDT
end

function clothing_base:SetUseDR(bNewDT)
	self.UseDR = bNewDT
end

function clothing_base:GetUseDR()
	return self.UseDR
end

clothing_base.__index = clothing_base