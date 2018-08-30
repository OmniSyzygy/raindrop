
local rainclient = FindMetaTable("Player")

--[[
	Name: Get RP Name
	Category: PlayerMeta
	Desc: Returns the players RP name, this is a detour function
--]]

function rainclient:GetRPName()
	return self:GetVisibleRPName()
end

--[[
	Name: Get Visible RP Name
	Category: PlayerMeta
	Desc: Returns the players RP name by grabbing their character name, this can be modified for stuff like disguises later on.
--]]

function rainclient:GetVisibleRPName(bForceRet)
	if self.character then
		return self.character:GetName()
	elseif (!bForceRet) then
		return "Unknwon"
	elseif (bForceRet) then
		return self:Nick()
	end
end

--[[
	Name: Get Character
	Category: PlayerMeta
	Desc: Returns the players current character, returns false if no character is found
--]]

function rainclient:GetCharacter()
	if self.character then
		return self.character
	end

	return false
end

-- # Returns a good position in front of the player for an entity.
-- # Nutscript
function rainclient:GetItemDropPos()
	-- Start a trace.
	local data = {}
		data.start = self:GetShootPos()
		data.endpos = self:GetShootPos() + self:GetAimVector()*86
		data.filter = self
	local trace = util.TraceLine(data)
		data.start = trace.HitPos
		data.endpos = data.start + trace.HitNormal*46
		data.filter = {}
	trace = util.TraceLine(data)

	return trace.HitPos
end