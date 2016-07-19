if SERVER then
	hook.Add("PlayerLevelUp", "ZSLeveling:PlayerLevelUp", function(ply)
		for k,v in pairs(player.GetAll()) do
			if (v == ply) then
				v:ChatPrint('Congratulations '..ply:Nick() ..'! You reached level '..(GetGlobalInt(SQLStr(ply:UniqueID()).."Level", 0)))
			end
		end
	end)
end