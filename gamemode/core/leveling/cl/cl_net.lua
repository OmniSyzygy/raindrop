net.Receive( "RaindropPerks", function(length)
	Raindrop.Perks = net.ReadTable()
	table.SortByMember( Raindrop.Perks, 'lvl', function(a, b) return tonumber(a) > tonumber(b) end )
end)

firstCall = true
net.Receive( "RaindropCreateActivePerks", function(length)
	if firstCall then
		Raindrop.ActivePerks[LocalPlayer():SteamID64()] = {}
		for i=1,#Raindrop.Perks do
			Raindrop.ActivePerks[LocalPlayer():SteamID64()][i] = false
		end
		LocalPlayer():RaindropNetActivePerks()
		firstCall = false
	end
end)

local pm = FindMetaTable("Player")

-- PERKS
function pm:RaindropNetActivePerks()
	net.Start( "RaindropActivePerks" )
		net.WriteTable( Raindrop.ActivePerks )
		net.WriteEntity( self )
	net.SendToServer()
end