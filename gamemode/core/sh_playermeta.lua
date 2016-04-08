
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

function rainclient:GetVisibleRPName()
	if self.character then
		return self.character:GetName()
	end
end