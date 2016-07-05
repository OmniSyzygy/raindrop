function RaindropRegisterPerk( pname, pcat, plvl, pdesc, pfunc )
	Raindrop.Perks[#Raindrop.Perks+1] = {}

	Raindrop.Perks[#Raindrop.Perks]['name'] = pname
	Raindrop.Perks[#Raindrop.Perks]['lvl'] = plvl
	Raindrop.Perks[#Raindrop.Perks]['desc'] = pdesc
end