Raindrop.Perks = {}
Raindrop.ActivePerks = {}
Raindrop.PerksFunctions = {}

local pm = FindMetaTable( 'Player' )

function pm:RaindropFetchPerks()
	if (self.raindroplevelsperks == nil) then self.raindroplevelsperks = {} end --Safety
	for i=1,#Raindrop.Perks do
		if (!table.HasValue(self.raindroplevelsperks, i) && (tonumber(Raindrop.Perks[i]['lvl']) <= (GetGlobalInt(SQLStr(self:SteamID64()).."Level", 0)))) then
			self.raindroplevelsperks[#self.raindroplevelsperks+1] = i
		end
	end
end

function RaindropRegisterPerk( pcat, pname, plvl, pdesc, pfunc )

	local perkindex = #Raindrop.Perks + 1

	Raindrop.Perks[perkindex] = {}
	Raindrop.Perks[perkindex]['cat'] = pcat
	Raindrop.Perks[perkindex]['name'] = pname
	Raindrop.Perks[perkindex]['lvl'] = plvl
	Raindrop.Perks[perkindex]['desc'] = pdesc

	Raindrop.PerksFunctions[perkindex] = pfunc --Seperate table because we don't send this to the client
end

function RaindropLoadPerks()

	local fs, dirs = file.Find( 'perks/*', 'LUA' )
	for i=1,#fs do	
		print( 'perks/' .. fs[i] )
		AddCSLuaFile( 'perks/' .. fs[i] )
		include( 'perks/' .. fs[i] )
	end

	for i=1, #dirs do
		local perks = file.Find( 'perks/' .. dirs[i] .. '/*.lua', 'LUA' )
		for perkid=1,#perks do	
			print( 'perks/' .. dirs[i] .. '/' .. perks[perkid] )
			AddCSLuaFile( 'perks/' .. dirs[i] .. '/' .. perks[perkid] )
			include( 'perks/' .. dirs[i] .. '/' .. perks[perkid])
		end
	end
end