function PlayerInitialSpawn(ply)
	print("Retrieving info for player: "..ply:Name())
	Raindrop.retrievePlayerLevelData(ply)
	ply:RaindropFetchPerks()
	ply:RaindropNetPerks()
	ply.firstCall = true
end
hook.Add('PlayerInitialSpawn', 'Raindrop:PlayerInitialSpawn', PlayerInitialSpawn)

function PlayerSpawn(ply)
	--Weird thing where player hasn't fully spawned yet and perks don't work, so add a 1 second delay
	timer.Simple( 1, function()
		if ply.firstCall then
			ply:RaindropCreateActivePerks()
			ply.firstCall = false
		else
			for i=1,#Raindrop.Perks do
				if ((GetGlobalInt(SQLStr(ply:SteamID64()).."Level", 0) or 1) >= Raindrop.Perks[i]['lvl']) then 
					Raindrop.PerksFunctions[i](ply, Raindrop.ActivePerks[ply:SteamID64()][i])
				end
			end
		end
	end)
end
hook.Add('PlayerSpawn', 'Raindrop:PerksOnSpawn', PlayerSpawn)

function CheckPerks(ply)
	for i=1,#Raindrop.Perks do
		if ((GetGlobalInt(SQLStr(ply:SteamID64()).."Level", 0) or 1) == Raindrop.Perks[i]['lvl']) then 
			Raindrop.PerksFunctions[i](ply, Raindrop.ActivePerks[ply:SteamID64()][i])
		end
	end
end
hook.Add('PlayerLevelUp', 'Raindrop:PlayerLevelUp', CheckPerks)

function PerkStatusUpdate(ply)
	for i=1,#Raindrop.Perks do
		if ((GetGlobalInt(SQLStr(ply:SteamID64()).."Level", 0) or 1) >= Raindrop.Perks[i]['lvl']) then 
			Raindrop.PerksFunctions[i](ply, Raindrop.ActivePerks[ply:SteamID64()][i])
		end
	end
end
hook.Add('PerkUpdate', 'Raindrop:PerkUpdate', PerkStatusUpdate)