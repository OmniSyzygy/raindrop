--[[
	Filename: sh_luastructs.lua
	Notes: I'm too used to C++ and I hate having to constantly do type checking bullshit.
--]]

rain.structs = {} -- table containing all structs

--[[
	Function: RegisterStruct
	Purpose: These are registered here as a generic struct, the purpose of the struct is to make it so that there is always a set default value.
--]]

function rain:RegisterStruct(sUniqueIdentifier, tStruct)
	self.structs[sUniqueIdentifier] = tStruct
end

--[[
	Function: GetStruct
	Purpose: Gets a structured table from the master table.
--]]

function rain:GetStruct(sUniqueIdentifier)
	local ret = {}
	ret = table.Copy(self.structs[sUniqueIdentifier])
	return ret
end