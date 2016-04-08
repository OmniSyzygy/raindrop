function rain:PlayerInitialSpawn(pClient)
	rain.pdata.clientinitialspawn(pClient)
end

function rain:PlayerSpawn(pClient)
	rain.state.playerspawn(pClient)
end

function rain:PlayerLoadout(pClient)

	pClient:Give("rain_hands")

	if (pClient:IsAdmin()) then
		pClient:Give("weapon_physgun")
		pClient:Give("gmod_tool")
		pClient:Give("weapon_physcannon")
	end

	return true
end