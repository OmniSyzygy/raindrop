RaindropRegisterPerk( true, 'Endurance II', 10, 'You get +15 HP when you spawn', function( ply )
	if (active && ply:Health() == ply:GetMaxHealth()) then
		ply:SetHealth( ply:Health() + 15 )
	else
		ply:SetHealth( ply:GetMaxHealth() )
	end
end)