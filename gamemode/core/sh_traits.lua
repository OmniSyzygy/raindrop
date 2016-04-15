--[[
	Filename: sh_traits.lua
--]]

rain.traits = {}
rain.traitbuffer = {}

function rain.traits.playerspawn(pClient, cCharacter)
	if !cCharacter then
		return
	end

	for TraitID, _ in pairs(cCharacter:GetTraits()) do
		local trait = rain.traits.get(sTraitID)
		trait.OnSpawn(self:GetOwningClient(), self)
	end
end

function rain.traits.dodeath(pClient, cCharacter)
	if !cCharacter then
		return
	end

	for TraitID, _ in pairs(cCharacter:GetTraits()) do
		local trait = rain.traits.get(sTraitID)
		trait.OnDeath(self:GetOwningClient(), self)
	end
end

function rain.traits.get(sTraitID)
	return rain.traitbuffer[sTraitID]
end

function rain.traits.add(sTraitID, sTraitPrintName, sTraitPrintDesc, fnOnSpawn, fnOnDeath, fnOnGive, fnOnTake)
	rain.traitbuffer[sTraitID] = {
		PrintName = sTraitPrintName, 
		PrintDesc = sTraitPrintDesc, 
		OnSpawn = fnOnSpawn or function() end, 
		OnDeath = fnOnDeath or function() end, 
		OnGive = fnOnGive or function() end, 
		OnTake = fnOnTake or function() end
	}
end

local charmeta = rain.character.getmeta()

function charmeta:GetTraits()
	return self:GetAdminOnlyData("traits", {})
end

function charmeta:HasTrait(sTraitID)
	local traits = self:GetAdminOnlyData("traits", {})

	if traits[sTraitID] then
		return true
	end

	return false
end

function charmeta:GiveTrait(sTraitID. bSkipCallback)
	local traits = self:GetAdminOnlyData("traits", {})

	traits[sTraitID] = true

	self:SetAdminOnlyData("traits", traits)

	if !bSkipCallback then
		local trait = rain.traits.get(sTraitID)

		trait.OnGive(self:GetOwningClient(), self)
	end
end

function charmeta:TakeTrait(sTraitID, bSkipCallback)
	local traits = self:GetAdminOnlyData("traits", {})

	if traits[sTraitID] then
		traits[sTraitID] = nil
	end

	self:SetAdminOnlyData("traits", traits)

	if !bSkipCallback then
		local trait = rain.traits.get(sTraitID)

		trait.OnTake(self:GetOwningClient(), self)
	end
end