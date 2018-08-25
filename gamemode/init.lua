MsgC(Color(0,0,255,255),"Loading Raindrop SV...\n")
DeriveGamemode("sandbox")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("sh_init.lua")
include("sh_init.lua")

function GM:OnGamemodeLoaded()
	rain:LoadWeaponItems()
end

MsgC(Color(0,255,0,255),"Loading complete!\n")