function Raindrop.setLevel(ply, level)
	if not (level or ply:IsPlayer()) then return end
	SetGlobalInt(SQLStr(ply:SteamID64()).."Level", (level))
	hook.Call("PlayerLevelUp", GAMEMODE, ply)
	
	Raindrop.logLevels(ply, "Level set to: " .. tostring(level))
end

function Raindrop.setXP(ply, xp)
	if not (xp or ply:IsPlayer()) then return end
	SetGlobalInt(SQLStr(ply:SteamID64()).."XP", (xp))
	
	Raindrop.logLevels(ply, "XP set to: " .. tostring(xp))
end

function Raindrop.addXP(ply, amount, notify, carryOver)
	local PlayerLevel = (GetGlobalInt(SQLStr(ply:SteamID64()).."Level", 0))
	local PlayerXP = (GetGlobalInt(SQLStr(ply:SteamID64()).."XP", 0))
	amount = tonumber(amount)

	if((not amount) or (not IsValid(ply)) or (not PlayerLevel) or (not PlayerXP) or (PlayerLevel>=LevelSystemConfiguration.MaxLevel)) then return 0 end
	if(not carryOver) then
		if(ply.VXScaleXP) then
			amount = (amount*tonumber(ply.VXScaleXP))
		end
	end
	
	local TotalXP = PlayerXP + amount

	if(TotalXP>=Raindrop.getMaxXP(ply)) then -- Level up!
		PlayerLevel = PlayerLevel + 1

		local RemainingXP = (TotalXP-Raindrop.getMaxXP(ply))
		if(LevelSystemConfiguration.ContinueXP) then
			if(RemainingXP>0) then
				Raindrop.setXP(ply, 0)
				Raindrop.setLevel(ply, PlayerLevel)
				return ply:addXP(ply, RemainingXP, true, true)
			end
		end
		
		Raindrop.setLevel(ply, PlayerLevel)
		Raindrop.setXP(ply, 0)
		
		Raindrop.storeXPData(ply,PlayerLevel,0)
	else
		Raindrop.storeXPData(ply,PlayerLevel,(TotalXP or 0))
		Raindrop.setXP(ply, math.max(0,TotalXP))

	end
	
	Raindrop.logLevels(ply,"Gained " .. tostring(amount) .. " XP")
	return (amount or 0)
	
end

function Raindrop.AddXP(ply, amount, notify)
	Raindrop.addXP(ply, amount, notify)
end

function Raindrop.getMaxXP(ply)
	return math.pow((((10+(((GetGlobalInt(SQLStr(ply:SteamID64()).."Level", 0) or 1)*((GetGlobalInt(SQLStr(ply:SteamID64()).."Level", 0) or 1)+1)*90))))*.261),2.131)
end

function Raindrop.addLevels(levels)
	if((GetGlobalInt(SQLStr(ply:SteamID64()).."Level", 0) or 1) == LevelSystemConfiguration.MaxLevel) then
			return false
	end
	if(((GetGlobalInt(SQLStr(ply:SteamID64()).."Level", 0) or 1) +levels)>LevelSystemConfiguration.MaxLevel) then
		-- Determine how many levels we can add.
		local LevelsCan = ((((GetGlobalInt(SQLStr(ply:SteamID64()).."Level", 0) or 1)+levels))-LevelSystemConfiguration.MaxLevel)
		if(LevelsCan == 0) then
			return 0
		else
			Raindrop.storeXPData(ply, LevelSystemConfiguration.MaxLevel, 0)
			SetGlobalInt(SQLStr(ply:SteamID64()).."XP", 0)
			SetGlobalInt(SQLStr(ply:SteamID64()).."Level", LevelSystemConfiguration.MaxLevel)
			hook.Call("PlayerLevelUp", GAMEMODE, ply)
			return LevelsCan
		end
		
	else
		Raindrop.storeXPData(ply,((GetGlobalInt(SQLStr(ply:SteamID64()).."Level", 0) or 1) +levels), (GetGlobalInt(SQLStr(ply:SteamID64()).."XP", 0) or 0))
		SetGlobalInt(SQLStr(ply:SteamID64()).."Level", (GetGlobalInt(SQLStr(ply:SteamID64()).."Level", 0) or 1) + levels)
		hook.Call("PlayerLevelUp", GAMEMODE, ply)
		return levels
	end
	
	Raindrop.logLevels(ply, "Gained " .. tostring(levels) .. " level(s)")
end

function Raindrop.hasLevel(level)
	return ((ply.level) >= level)
end


concommand.Add("levels", function(ply)
	print("Leveling System by @Heracles421")
end)