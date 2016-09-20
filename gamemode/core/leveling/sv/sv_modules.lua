function RaindropLoadModules()
	local fs, dirs = file.Find( 'Raindrop/modules--[[', 'LUA' )
	for i=1,#dirs do

		print( 'Raindrop/modules/' .. dirs[i] )
		AddCSLuaFile( 'Raindrop/modules/' .. dirs[i] .. '/module.lua' )	
		include( 'Raindrop/modules/' .. dirs[i] .. '/module.lua' )
	end
	if (#fs > 0) then print( 'Found unused files in modules' ) end
end