-- # Micro-ops
local rain = rain

rain.factionflag = {}

local charmeta = rain.character.getmeta()

function charmeta:GetFactions(bTable)
	local flags = self:GetAdminOnlyData("factions", "")

	if !bTable then
		return flags
	end

	return string.Explode("!", flags)
end

function charmeta:IsFaction(sFaction)
	local flags = self:GetFactions(true)

	for _, flag in pairs(flags) do
		if sFaction == string.StripExtension(flag) then
			return true
		end
	end

	return false
end

function charmeta:IsRank(sFaction, sRank)
	local flags = self:GetFactions(true)
	for _, flag in pairs(flags) do
		if sFaction == string.StripExtension(flag) then
			if sRank == string.gsub( flag, "^%d+%.", "" ) then
				print("Player is in faction ID "..sFaction.." and is rank "..sRank)
				return true
			end
		end
	end
	return false
end

function charmeta:GetRank(sFaction)
	local flags = self:GetFactions(true)
	for _, flag in pairs(flags) do
		if sFaction == string.StripExtension(flag) then
				return string.gsub( flag, "^%d+%.", "" )
			end
		end
	
	return false
end

-- ! seperates each faction, that way string.Explode can split them up, then peroid is used so we can use string.StripExtension
function charmeta:JoinFaction(sNewFlag, rank)
	local flags = self:GetAdminOnlyData("factions", "")
	flags = flags.."!"..sNewFlag.."."..rank

	self:SetAdminOnlyData("factions", flags)
end

function charmeta:GiveFaction(sFlags, rank)
	local flags = string.Explode("!", sFlags)

	for _, flag in pairs(flags) do
		if !self:IsFaction(flag) then
			self:AddFaction(flag, rank)
		end
	end
end

function charmeta:ChangeRank(sFlags, rank)

end

function charmeta:RemoveFaction(sFactionToRemove)
	local currentflags = self:GetAdminOnlyData("factions", "")
	if string.len(currentflags) > 0 then
		newflags = string.Replace(currentflags, "!"..sFactionToRemove.."."..self:GetRank(sFactionToRemove), "")
	end
	
	self:SetAdminOnlyData("factions", newflags)
end