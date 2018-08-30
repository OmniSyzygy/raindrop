-- this is a utility library, it is assumed that base functions are kept within this file. More info later.

AddCSLuaFile()

CL = CLIENT
SV = SERVER

rain.util = {}

local tAxis = {"x", "y", "z"}

function COSerp(fraction, origin, target)
	local fraction2 = (1 - math.cos(fraction * math.pi)) / 2

	return origin * (1 - fraction2) + (target * fraction2)
end

function COSerpVector(nFraction, vOrigin, vTarget)
	local vOut = Vector(0, 0, 0)
	
	for _, sAxis in ipairs(tAxis) do
		vOut[sAxis] = COSerp(nFraction, vOrigin[sAxis], vTarget[sAxis])
	end

	return vOut
end

function SLerp(nFraction, nOrigin, nTarget)
	local nFrac = (1 - math.sin(nFraction * math.pi)) / 2

	return nOrigin * (1 - nFrac) + (nTarget * nFrac)
end

function SLerpVector(nFraction, vOrigin, vTarget)
	local vOut = Vector(0, 0, 0)
	for _, sAxis in next(tAxis) do
		vOut[sAxis] = SLerp(nFraction, vOrigin[sAxis], vTarget[sAxis])
	end

	return vOut
end

function rain.util.log(sText, sTag)
	if !sTag then
		sTag = "PRINT"
	else
		sTag = string.upper(sTag)
	end

	if (SV) then
		MsgC(Color(45,137,239),"[RAIN]")
		MsgC(Color(110,110,255,255)," [SV]")
		MsgC(Color(255,0,0,255)," ["..sTag.."] ")
		MsgC(Color(110,110,255,255), sText.."\n")
	elseif (CL) then
		MsgC(Color(45,137,239),"[RAIN]")
		MsgC(Color(255,196,13)," [CL]")
		MsgC(Color(255,0,0,255)," ["..sTag.."] ")
		MsgC(Color(255,196,13), sText.."\n")
	end
end

function rain.util.rawinclude(sFilePath)
	include(sFilePath)

	if (rain.dev) then
		rain.util.log(sFilePath, "loaded file")
	end
end

function rain.util.include(sFilePath)
	if (!sFilePath) then
		error("[RAINDROP] No file name specified for including.")
	end
	
	if (!SV and string.find(sFilePath, "sv_")) then
		return
	end

	if (SV and (string.find(sFilePath, "sh_") or string.find(sFilePath, "lib_") or string.find(sFilePath, "ut_"))) then
		AddCSLuaFile(sFilePath)
	end

	if (SV and string.find(sFilePath, "cl_")) then
		AddCSLuaFile(sFilePath)

		return
	end

	rain.util.rawinclude(sFilePath)
end

function Sound(sPathToSound)
	util.PrecacheSound(sPathToSound)

	return sPathToSound
end

function rain.util.loadlibraries()
	rain.util.include("libraries/ut_loadorder.lua")
	
	for _, lib in pairs(rain.util.loadorder) do
		rain.util.include("raindrop/gamemode/libraries/"..lib..".lua")
	end
end

--[[
	Name: dir
	Purpose: sets up a directory to run FileIO library operations
--]]

function rain.util.dir(sFolderPath)
	return "raindrop/gamemode/"..sFolderPath, "LUA"
end

--[[
	Name: Load Folder
	Purpose: Loads an entire folder, including all the files properly.
--]]

function rain.util.loadfolder(sFolderPath)
	local sFolderPath = sFolderPath.."/"
	local a, b = rain.util.dir(sFolderPath)
	local files = file.Find(a.."*.lua", b)

	for _, file in pairs(files) do
		rain.util.include(sFolderPath..file)
	end
end

--[[
	Name: Load Raindrop
	Purpose: Loads the gamemode
--]]

function rain.util.loadraindrop()
	rain.util.include("ut_loadorder.lua")

	for _, folder in pairs(rain.util.loadorder) do
		rain.util.loadfolder(folder)
	end
end

if (SV) then
	function rain.util.initraindrop()
		rain.db.connect(rain.cfg.db.address, rain.cfg.db.username, rain.cfg.db.password, rain.cfg.db.database, rain.cfg.db.port)
		
		hook.Add("DatabaseConnected", "rain.DatabaseConnected", function()
			if (mysql:IsConnected()) then
				rain.db.onconnectionsuccess()
				rain:LoadVolumes()
				rain.item.loadFromDir(GAMEMODE.FolderName.."/gamemode/raindrop/items")
			end
		end)
	end
end	

function rain.util.countargs(wArg1, wArg2, wArg3, wArg4, wArg5)

	if wArg1 and !wArg2 then
		return 1
	end

	if wArg2 and !wArg3 then
		return 2
	end

	if wArg3 and !wArg4 then
		return 3
	end

	if wArg4 and !wArg5 then
		return 4
	end

	if wArg5 then
		return 5
	end

	return 1

end

rain.meta = {}

function rain.util.findmetatable(sKey)
	return rain.meta[sKey]
end

--[[
	Name: Print Formatted
	Desc: Shitty util function meant to very quickly print out data while devmode is enabled
--]]

function printF(wArgs)
	if rain.dev then
		if type(wArgs) == "Table" then
			PrintTable(wArgs)
		else
			print(wArgs)
		end
	end
end

rain.util.TypeBuffer = {}
rain.util.TypeBuffer[TYPE_ANGLE] 	= "Angle"
rain.util.TypeBuffer[TYPE_BOOL] 	= "Bool"
rain.util.TypeBuffer[TYPE_COLOR]	= "Color"
rain.util.TypeBuffer[TYPE_NUMBER] 	= "Number"
rain.util.TypeBuffer[TYPE_STRING] 	= "String"
rain.util.TypeBuffer[TYPE_VECTOR] 	= "Vector"
rain.util.TypeBuffer[TYPE_TABLE] 	= "Table"

function rain.util.typeEnumToString(enumType)
	return string.lower(rain.util.TypeBuffer(enumType))
end

function rain.util.isType(wToTest, wType)

	local sTypeID = ""

	if type(wType) == "String" then
		sTypeID = wType
	elseif type(wType) == "Number" then
		sTypeID = rain.util.typeEnumToString(wType)
	end

	if type(wToTest) == sTypeID then
		return true
	end

	return false
end

function rain.util.print(name, ...)
	if (istable({...})) then
		print(name)
		PrintTable(unpack({...}))
	else
		print(name, unpack({...}))
	end
end