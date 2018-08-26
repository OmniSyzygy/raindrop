--[[
	Filename: sh_luastructs.lua
	Notes: I'm too used to C++ and I hate having to constantly do type checking bullshit.
	Now with metatables!
--]]
-- # Micro-ops
local rain = rain

rain.struct = {}
rain.structs = {} -- table containing all structs

local rain_structmeta = {s_struct = true}

--[[
	Name: Is Struct
	Category: Returns wether or not the table is a struct
	Desc: Returns true if a table is a struct
--]]

function rain_structmeta:IsStruct()
	return self.s_struct
end

--[[
	Name: Get Unique Identifier
	Category: Structs
	Purpose: Gets the unique identifier for a struct
--]]

function rain_structmeta:GetUniqueIdentifier()
	return s_uid or "_invalidstruct_"
end

--[[
	Name: Compare
	Category: Structs
	Desc: Compares a struct to another, if they have the same unique identifier and therefore are the same type of struct return true
--]]

function rain_structmeta:Compare(tTestStruct)
	if tTestStruct:IsStruct() then
		if self:GetUniqueIdentifier() == tTestStruct:GetUniqueIdentifier() then
			return true
		end
	end

	return false
end

--[[
	Name: Matches
	Category: Structs
	Desc: Gets wether or not the struct has the unique identifier in the argument
--]]

function rain_structmeta:Matches(sUniqueIdentifier)
	if (sUniqueIdentifier) then
		return self:GetUniqueIdentifier() == sUniqueIdentifier
	end

	return false
end

rain_structmeta.__index = rain_structmeta

--[[
	Function: RegisterStruct
	Purpose: These are registered here as a generic struct, the purpose of the struct is to make it so that there is always a set default value.
--]]

function rain.struct:RegisterStruct(sUniqueIdentifier, tStruct)
	tStruct.s_uid = sUniqueIdentifier
	rain.structs[sUniqueIdentifier] = tStruct
end

--[[
	Function: GetStruct
	Purpose: Gets a structured table from the master table.
--]]

function rain.struct:GetStruct(sUniqueIdentifier)
	local ret = {}
	ret = table.Copy(rain.structs[sUniqueIdentifier])
	
	if ret then
		setmetatable(ret, rain_structmeta)
		return ret
	else
		return {}
	end
end