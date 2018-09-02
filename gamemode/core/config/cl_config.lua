-- # Micro-ops
local rain = rain

rain.cfg = rain.cfg or {}

rain.cfg.HiddenUIElements = {}
rain.cfg.HiddenUIElements["CHudAmmo"] 				= true
rain.cfg.HiddenUIElements["CHudBattery"] 			= true
rain.cfg.HiddenUIElements["CHudCrosshair"] 			= true
rain.cfg.HiddenUIElements["CHudDamageIndicator"] 	= true
rain.cfg.HiddenUIElements["CHudGeiger"] 			= true
rain.cfg.HiddenUIElements["CHudHealth"] 			= true
rain.cfg.HiddenUIElements["CHudSecondaryAmmo"] 		= true
rain.cfg.HiddenUIElements["CHudSquadStatus"] 		= true
rain.cfg.HiddenUIElements["CHudZoom"] 				= true
rain.cfg.HiddenUIElements["CHudChat"] 				= true


rain.cfg.modifiable = {} -- these will have a menu on the client where settings can be changed.
rain.cfg.modifiable.DrawSuitOverlay = true
rain.cfg.PlayerModels = {}

function rain.cfg:AddPlayerModels(model)
	self.PlayerModels[#self.PlayerModels + 1] = model
	util.PrecacheModel(model)
end

local CITIZEN_MODELS = {
	"models/humans/group01/male_01.mdl",
	"models/humans/group01/male_02.mdl",
	"models/humans/group01/male_04.mdl",
	"models/humans/group01/male_05.mdl",
	"models/humans/group01/male_06.mdl",
	"models/humans/group01/male_07.mdl",
	"models/humans/group01/male_08.mdl",
	"models/humans/group01/male_09.mdl",
	"models/humans/group02/male_01.mdl",
	"models/humans/group02/male_03.mdl",
	"models/humans/group02/male_05.mdl",
	"models/humans/group02/male_07.mdl",
	"models/humans/group02/male_09.mdl",
	"models/humans/group01/female_01.mdl",
	"models/humans/group01/female_02.mdl",
	"models/humans/group01/female_03.mdl",
	"models/humans/group01/female_06.mdl",
	"models/humans/group01/female_07.mdl",
	"models/humans/group02/female_01.mdl",
	"models/humans/group02/female_03.mdl",
	"models/humans/group02/female_06.mdl",
	"models/humans/group01/female_04.mdl"
}

for k, v in pairs(CITIZEN_MODELS) do
	if (type(v) == "string") then
		rain.cfg:AddPlayerModels(v)
	elseif (type(v) == "table") then
		rain.cfg:AddPlayerModels(v[1])
	end
end

CITIZEN_MODELS = nil