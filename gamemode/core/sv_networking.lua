local entityMeta = FindMetaTable("Entity")
local playerMeta = FindMetaTable("Player")

rain.netvar = rain.netvar or {}
rain.netvar.globals = rain.netvar.globals or {}

-- Check if there is an attempt to send a function. Can't send those.
local function checkBadType(name, object)
	local objectType = type(object)

	if (objectType == "function") then
		ErrorNoHalt("Net var '"..name.."' contains a bad object type!")

		return true
	elseif (objectType == "table") then
		for k, v in pairs(object) do
			-- Check both the key and the value for tables, and has recursion.
			if (checkBadType(name, k) or checkBadType(name, v)) then
				return true
			end
		end
	end
end

function setNetVar(key, value, receiver)
	if (checkBadType(key, value)) then return end
	if (getNetVar(key) == value) then return end

	rain.netvar.globals[key] = value
	netstream.Start(receiver, "gVar", key, value)
end

function playerMeta:syncVars()
	for entity, data in pairs(rain.netvar) do
		if (entity == "globals") then
			for k, v in pairs(data) do
				netstream.Start(self, "gVar", k, v)
			end
		elseif (IsValid(entity)) then
			for k, v in pairs(data) do
				netstream.Start(self, "nVar", entity:EntIndex(), k, v)
			end
		end
	end
end

function entityMeta:sendNetVar(key, receiver)
	netstream.Start(receiver, "nVar", self:EntIndex(), key, rain.netvar[self] and rain.netvar[self][key])
end

function entityMeta:clearNetVars(receiver)
	rain.netvar[self] = nil
	netstream.Start(receiver, "nDel", self:EntIndex())
end

function entityMeta:setNetVar(key, value, receiver)
	if (checkBadType(key, value)) then return end

	rain.netvar[self] = rain.netvar[self] or {}

	if (rain.netvar[self][key] != value) then
		rain.netvar[self][key] = value
	end

	self:sendNetVar(key, receiver)
end

function entityMeta:getNetVar(key, default)
	if (rain.netvar[self] and rain.netvar[self][key] != nil) then
		return rain.netvar[self][key]
	end

	return default
end

function playerMeta:setLocalVar(key, value)
	if (checkBadType(key, value)) then return end

	rain.netvar[self] = rain.netvar[self] or {}
	rain.netvar[self][key] = value

	netstream.Start(self, "nLcl", key, value)
end

playerMeta.getLocalVar = entityMeta.getNetVar

function getNetVar(key, default)
	local value = rain.netvar.globals[key]

	return value != nil and value or default
end

hook.Add("EntityRemoved", "rainCleanUp", function(entity)
	entity:clearNetVars()
end)

hook.Add("PlayerInitialSpawn", "rainSync", function(client)
	client:syncVars()
end)
