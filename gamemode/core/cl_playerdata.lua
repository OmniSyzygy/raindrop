rain.pdata = rain.pdata or {}
rain.pdata.cache = rain.pdata.cache or {}
rain.pdata.characters = rain.pdata.characters or {}
rain.menudata = rain.menudata or false

--[[
	Retrieves the players characters once they've been loaded from the server
--]]

function rain.pdata.getcharacters()
	return rain.pdata.characters or {}
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
	local data = rain.net.ReadTable()

	rain.pdata.characters = data
	rain.pdata.onreceivecharacters()

	if (rain.MainMenuUI and rain.MainMenuUI:GetName() == "RD_CharDelete") then
		rain.MainMenuUI:Remove()

		rain.MainMenuUI = vgui.Create("RD_CharDelete")
		rain.MainMenuUI:MakePopup()
	end
end)

net.Receive("SyncPlayerData", function(nLen)
	local key = net.ReadString()
	local data = rain.net.ReadTable()

	if (key and key != "") then
		rain.pdata.cache[key] = data
	else
		rain.pdata.cache = data
	end
end)