local entityMeta = FindMetaTable("Entity")
local playerMeta = FindMetaTable("Player")

-- # Micro-ops
local rain = rain

rain.netvar = rain.netvar or {}
rain.netvar.globals = rain.netvar.globals or {}

netstream.Hook("nVar", function(index, key, value)
	rain.netvar[index] = rain.netvar[index] or {}
	rain.netvar[index][key] = value
end)

netstream.Hook("nDel", function(index)
	rain.netvar[index] = nil
end)

netstream.Hook("nLcl", function(key, value)
	rain.netvar[LocalPlayer():EntIndex()] = rain.netvar[LocalPlayer():EntIndex()] or {}
	rain.netvar[LocalPlayer():EntIndex()][key] = value
end)

netstream.Hook("gVar", function(key, value)
	rain.netvar.globals[key] = value
end)

function getNetVar(key, default)
	local value = rain.netvar.globals[key]

	return value != nil and value or default
end

function entityMeta:getNetVar(key, default)
	local index = self:EntIndex()

	if (rain.netvar[index] and rain.netvar[index][key] != nil) then
		return rain.netvar[index][key]
	end

	return default
end

playerMeta.getLocalVar = entityMeta.getNetVar