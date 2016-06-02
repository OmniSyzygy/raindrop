MsgC(Color(0,0,255,255),"Loading Raindrop SV...\n")
DeriveGamemode("sandbox")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("sh_init.lua")
include("sh_init.lua")

MsgC(Color(0,255,0,255),"Loading complete!\n")