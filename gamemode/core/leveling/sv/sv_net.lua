util.AddNetworkString("RaindropPerks")
util.AddNetworkString("RaindropActivePerks")
util.AddNetworkString("RaindropCreateActivePerks")

net.Receive( "RaindropActivePerks", function(length)
	Raindrop.ActivePerks = net.ReadTable()
	ply = net.ReadEntity()
	hook.Call("PerkUpdate", GAMEMODE, ply)
end)

local pm = FindMetaTable("Player")

-- PERKS
function pm:RaindropNetPerks()
	net.Start( "RaindropPerks" )
		net.WriteTable( Raindrop.Perks )
	net.Send( self )
end

function pm:RaindropCreateActivePerks()
	net.Start( "RaindropCreateActivePerks" )
	net.Send( self )
end