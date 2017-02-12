function onPlayerDeath(victim, inflictor, attacker)
	if victim != attacker and attacker:IsPlayer() then
		local hsBonus = 0
		if victim.lastHitGroup && victim.lastHitGroup == HITGROUP_HEAD then
			hsBonus = 1
		end
		
		Raindrop.addXP(attacker, 25 + (hsBonus*10), true)
	end
end
hook.Add("PlayerDeath", "Raindrop:PlayerDeath", onPlayerDeath)

-- the fuck is this

function checkHeadshot(pl, hitGroup)
	pl.lastHitGroup = hitGroup
end
hook.Add("ScalePlayerDamage", "Raindrop:CheckHeadshot", checkHeadshot)