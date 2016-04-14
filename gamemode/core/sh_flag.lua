--[[
	Filename: sh_flag.lua
--]]

rain.flag = {}
rain.flagbuffer = {}

function rain.flag.register(sFlag, sPrintName, sPrintDesc, fnOnSpawn, fnOnDeath)
	rain.flagbuffer[sFlag] = {
		PrintName = sPrintName, 
		PrintDesc = sPrintDesc, 
		OnSpawn = fnOnSpawn or function() 

		end, 
		OnDeath = fnOnDeath or function() 

		end
	}
end

function rain.flag.get(sFlag)
	return rain.flagbuffer[sFlag]
end

function rain.flag.playerspawn(pClient, cCharacter)
	local flags = cCharacter:GetFlags(true)

	for _, flag in pairs(flags) do
		local flagdata = rain.flag.get(flag)
		flagdata.OnSpawn(pClient, cCharacter)
	end
end

function rain.flag.dodeath(pClient, cCharacter)
	local flags = cCharacter:GetFlags(true)

	for _, flag in pairs(flags) do
		local flagdata = rain.flag.get(flag)
		flagdata.OnDeath(pClient, cCharacter)
	end
end

local charmeta = rain.character.getmeta()

function charmeta:GetFlags(bTable)
	if type(self.flags) != "string" then
		self.flags = ""
	end

	if !bTable then
		return self.flags
	end

	return string.Explode("", self.flags)
end

function charmeta:HasFlag(sFlag)
	local flags = self:GetFlags(true)

	for _, flag in pairs(flags) do
		if sFlag == flag then
			return true
		end
	end

	return false
end

function charmeta:AddFlag(sNewFlag)
	self.flags = self.flags or ""

	self.flags = self.flags..sNewFlag
end

function charmeta:GiveFlags(sFlags)
	local flags = string.Explode("", sFlags)

	for _, flag in pairs(flags) do
		if !self:HasFlag(flag) then
			self:AddFlag(flag)
		end
	end
end

function charmeta:RemoveFlags(sFlagsToRemove)
	local flags = string.Explode("", sFlagsToRemove)
	
	for _, flag in pairs(flags) do
		self.flags = string.Replace(self.flags, flag, "")
	end
end

if rain.dev then
	rain.flag.register("H", "Dev Test Flag", "testers only btw", function(pClient, cCharacter) print(pClient, cCharacter) end, function(pClient, cCharacter) print(pClient, cCharacter, "DEATH") end)
end