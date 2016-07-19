Raindrop.DamageIPerkOwners = {}

function ModifyDamage(target, dmginfo)
	if (table.HasValue(Raindrop.DamageIPerkOwners, dmginfo:GetAttacker())) then
		dmginfo:AddDamage(dmginfo:GetDamage()*10)
	end
end
hook.Add("EntityTakeDamage", "Raindrop:EntityTakeDamage", ModifyDamage)

RaindropRegisterPerk( true, 'Damage I', 1, 'You make x10 more damage', function( ply, active )
	if (table.HasValue(Raindrop.DamageIPerkOwners, ply) && active) then
		return
	elseif (table.HasValue(Raindrop.DamageIPerkOwners, ply) && !active) then
		table.RemoveByValue(Raindrop.DamageIPerkOwners, ply)
	else
		Raindrop.DamageIPerkOwners[#Raindrop.DamageIPerkOwners+1] = ply
	end
end)