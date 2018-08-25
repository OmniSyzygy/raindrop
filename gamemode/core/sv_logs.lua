rain.ConsoleLog = true

function rain:LogFile( name, text )
	if( !file.IsDir( "raindrop/logs/" .. os.date( "!%y-%m-%d" ), "DATA" ) ) then
		file.CreateDir( "raindrop/logs/" .. os.date( "!%y-%m-%d" ) );
	end
	
	local c = file.Read( "raindrop/logs/" .. os.date( "!%y-%m-%d" ) .. "/" .. name .. ".txt" ) or "";
	file.Write( "raindrop/logs/" .. os.date( "!%y-%m-%d" ) .. "/" .. name .. ".txt", c .. text );
end

function rain:LogItems( text, ply )
	local ins = os.date( "!%H:%M:%S" ) .. "\t" .. ply:SteamID() .. "\t" .. text .. "\n";
	self:LogFile( "items", ins );
	if( self.ConsoleLog ) then
		MsgC( Color( 200, 200, 200, 255 ), ins );
	end
end

function rain:LogSecurity( steamid, networkid, name, text )
	local ins = os.date( "!%H:%M:%S" ) .. "\t" .. steamid .. "\t" .. networkid .. "\t" .. name .. "\t" .. text .. "\n";
	self:LogFile( "security", ins );
	if( self.ConsoleLog ) then
		MsgC( Color( 200, 200, 200, 255 ), ins );
	end
end