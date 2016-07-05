if SERVER then
	hook.Add("PlayerLevelUp", "Raindrop:PlayerLevelUp", function(ply)
		if ply:Alive() then ply:EmitSound("Raindrop/levelup.wav", 500, 120) end
	end)
end