AddCSLuaFile('raindrop/gamemode/core/leveling/config.lua')
include('raindrop/gamemode/core/leveling/config.lua')
Raindrop = {}

include('raindrop/gamemode/core/leveling/sv/sv_perks.lua')

include('raindrop/gamemode/core/leveling/sv/sv_data.lua')
include('raindrop/gamemode/core/leveling/sv/sv_hooks.lua')
include('raindrop/gamemode/core/leveling/sv/sv_leveling.lua')
include('raindrop/gamemode/core/leveling/sv/sv_net.lua')
include('raindrop/gamemode/core/leveling/sv/sv_modules.lua')
include('raindrop/gamemode/core/leveling/sv/sv_rewards.lua')
include('raindrop/gamemode/core/leveling/sv/sv_chatcommands.lua')

/*
	UI
*/

include('raindrop/gamemode/core/leveling/cl/include.lua')

/*
	PERKS
*/

RaindropLoadPerks()

/*
	MODULES
*/

RaindropLoadModules()

/*
	REWARDS
*/

RaindropLoadRewards()