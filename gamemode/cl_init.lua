MsgC(Color(0,0,255,255),"Loading Raindrop CL...\n")
DeriveGamemode("sandbox")

include("sh_init.lua")

function GM:OnGamemodeLoaded()
	rain:LoadWeaponItems()
end