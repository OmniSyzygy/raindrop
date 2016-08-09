	function onConnected()
		local queryObj = mysql:Create("levels")
		queryObj:Create("steam_id64", "VARCHAR(256) NOT NULL") -- 64bit steam id, I use the 64bit steamid for ease of use
		queryObj:Create("steam_name", "VARCHAR(64) NOT NULL") -- last known steamname
		queryObj:Create("level", "INT NOT NULL") -- character ids
		queryObj:Create("xp", "INT NOT NULL") -- last known ip addresses
		queryObj:Unique("steam_id64")
		queryObj:Execute()
		mysql:RawQuery("CREATE TABLE IF NOT EXISTS levels(steam_id64 VARCHAR(32) NOT NULL, steam_name VARCHAR(32) NOT NULL,level int NOT NULL,xp int NOT NULL,UNIQUE(steam_id64))")
	end
	hook.Add("DatabaseConnected", "Raindrop:DataBaseConnected", onConnected)

	function onConnectionFailed()
	end
	hook.Add("DatabaseConnectionFailed", "Raindrop:DatabaseConnectionFailed", onConnectionFailed)

	function Raindrop.retrievePlayerLevelXP(ply, callback)
		mysql:RawQuery("SELECT level,xp FROM levels WHERE steam_id64 = " .. SQLStr(ply:SteamID64()) .. "", function (r) callback(r) end)
	end

	function Raindrop.createPlayerLevelData(ply)
		mysql:RawQuery("REPLACE INTO levels VALUES(" .. SQLStr(ply:SteamID64()) .. ","..SQLStr(ply:Name())..",'1','0')")
		Raindrop.logLevels(ply, "Created levels entry for the first time")
	end

	function Raindrop.retrievePlayerLevelData(ply)
		Raindrop.retrievePlayerLevelXP(ply, function (data)
				if not IsValid(ply) then return end
				local info = data and data[1] or {}
				info.xp = (info.xp or 0)
				info.level = (info.level or 1)
				if (data[1] == nil) then
					Raindrop.createPlayerLevelData(ply)
				end
				SetGlobalInt(SQLStr(ply:SteamID64()).."XP", tonumber(info.xp))
				SetGlobalInt(SQLStr(ply:SteamID64()).."Level", tonumber(info.level))
			end)
	end

	function Raindrop.storeXPData(ply, level, xp)
		xp = math.max(xp, 0)
		mysql:RawQuery("UPDATE levels SET level = " .. SQLStr(level) .. ", xp = " .. SQLStr(xp) .. " WHERE steam_id64 = " .. SQLStr(ply:SteamID64()))
	end
	
	function Raindrop.logLevels(ply, action)
		rain.log.levels(ply:Nick() .. " (ID: " .. ply:SteamID64() .. "): " .. action)
	end