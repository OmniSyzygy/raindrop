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

local availableModels = {
	"eco_neutralb3",
	"eco_old",
	"now_neutral_razgr_1",
	"stalker_exo_proto",
	"stalker_medic",
	"stalker_military_loner_1",
	"stalker_military_loner_2",
	"stalker_military_loner_3",
	"stalker_military_loner_4",
	"stalker_military_loner_5",
	"stalker_neutral_0",
	"stalker_neutral_1_gasmask",
	"stalker_neutral_1_mask",
	"stalker_neutral_2_halfmask",
	"stalker_neutral_2_halfmask_b",
	"stalker_neutral_2_mask_nohood",
	"stalker_neutral_3",
	"stalker_neutral_3_nohood",
	"stalker_neutral_4_light",
	"stalker_neutral_5",
	"stalker_neutral_8",
	"stalker_neutral_9",
	"stalker_neutral_9d",
	"stalker_neutral_10",
	"stalker_neutral_11",
	"stalker_neutral_12",
	"stalker_neutral_13",
	"stalker_neutral_13b",
	"stalker_neutral_14",
	"stalker_neutral_15",
	"stalker_neutral_16",
	"stalker_neutral_16d",
	"stalker_neutral_17",
	"stalker_neutral_18",
	"stalker_neutral_hunter",
	"stalker_neutral_pro",
	"stalker_neutral_unique",
	"stalker_neutral0a",
	"stalker_neutral0b",
	"stalker_neutral0c",
	"stalker_neutral0d",
	"stalker_neutral1a",
	"stalker_neutral1a_mask",
	"stalker_neutral1b",
	"stalker_neutral1b_mask",
	"stalker_neutral1c",
	"stalker_neutral1c_mask",
	"stalker_neutral1d",
	"stalker_neutral1d_mask",
	"stalker_neutral1e",
	"stalker_neutral1e_mask",
	"stalker_neutral1f",
	"stalker_neutral1f_mask",
	"stalker_neutral2a",
	"stalker_neutral2a_mask",
	"stalker_neutral2amask1",
	"stalker_neutral2amask2",
	"stalker_neutral2b",
	"stalker_neutral2b_mask",
	"stalker_neutral2bmask1",
	"stalker_neutral2bmask2",
	"stalker_neutral2c",
	"stalker_neutral2c_mask",
	"stalker_neutral2cmask1",
	"stalker_neutral2cmask2",
	"stalker_neutral2d",
	"stalker_neutral2d_mask",
	"stalker_neutral2dmask1",
	"stalker_neutral2dmask2",
	"stalker_neutrala2",
	"stalker_neutralb2",
	"stalker_neutralb3",
	"stalker_neutralc2",
	"stalker_neutrale2",
	"stalker_neutralf2",
	"stalker_neutralg2",
	"stalker_neutralh1",
	"stalker_neutrali1",
	"stalker_nutral_nauchnyi",
	"stalker_soldier_4",
	"stalker_soldierb2",
	"stalker_soldierb3",
	"stalker_soldierb4"
}

for k, v in pairs(availableModels) do
	table.insert( rain.cfg.PlayerModels, "models/cakez/rxstalker/stalker_neutral/"..v..".mdl" )
end