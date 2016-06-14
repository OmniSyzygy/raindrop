rain.pdata = {}
rain.menudata = rain.menudata or false
rain.menucharacters = rain.menucharacters or {}

--[[
	Retrieves the players characters once they've been loaded from the server
--]]

function rain.pdata.getcharacters()
	return rain.menucharacters
end

--[[
	Called when the player receives his characters data from the server.
--]]

function rain.pdata.onreceivecharacters()
	rain.menudata = true
end

--[[
	Returns if the player has received his data from the server, can be called every tick with no performance impact
--]]

function rain.pdata.canloadcharacters()
	return rain.menudata
end

net.Receive("SyncMenuData", function(nLen)
	local data = rain.net.ReadTable();

	rain.menucharacters = data;
	rain.pdata.onreceivecharacters();
end);