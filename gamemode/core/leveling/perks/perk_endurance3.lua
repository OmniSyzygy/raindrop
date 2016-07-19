RaindropRegisterPerk( true, 'Endurance III', 20, 'You get +20 HP when you spawn', function( ply )
	if (active && ply:Health() == ply:GetMaxHealth()) then
		ply:SetHealth( ply:Health() + 20 )
	else
		ply:SetHealth( ply:GetMaxHealth() )
	end
end)