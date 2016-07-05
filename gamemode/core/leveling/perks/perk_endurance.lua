RaindropRegisterPerk( true, 'Endurance I', 5, 'You get +10 HP when you spawn', function( ply, active )
	if (active && ply:Health() == ply:GetMaxHealth()) then
		ply:SetHealth( ply:Health() + 10 )
	else
		ply:SetHealth( ply:GetMaxHealth() )
	end
end)