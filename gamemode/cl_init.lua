MsgC(Color(0,0,255,255),"Loading Raindrop CL...\n")
DeriveGamemode("sandbox")

function rain:OnGamemodeLoaded()
	self:LoadWeaponItems()
end

include("sh_init.lua")