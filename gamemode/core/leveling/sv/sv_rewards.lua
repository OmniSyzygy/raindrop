function RaindropLoadRewards()
	local fs, dirs = file.Find( 'Raindrop/rewards--[[', 'LUA' )
	
	for i=1,#fs do
		print( 'Raindrop/rewards/' .. fs[i] )
		AddCSLuaFile( 'Raindrop/rewards/' .. fs[i] )	
		include( 'Raindrop/rewards/' .. fs[i] )
	end
	
	if (#fs > 0) then print( 'Found unused files in rewards' ) end
end