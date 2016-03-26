rain.pdata = {}

function rain.pdata.clientinitialspawn(pClient)
	if !pClient.rain then
		local queryObj = mysql:Select("players")
		queryObj:Where("steam_id64", pClient:SteamID64())
		queryObj:Callback(function(result, status, lastID)
			if type(result) == "table" and #result > 0 then
				local updateObj = mysql:Update("players")
					updateObj:Update("steam_name", pClient:Name())
					updateObj:Where("steam_id64", pClient:SteamID64())
				updateObj:Execute()
			else
				local insertObj = mysql:Insert("players")
					insertObj:Insert("steam_name", pClient:Name())
					insertObj:Insert("steam_id64", pClient:SteamID64())
					insertObj:Callback(function(result, status, lastID)
						rain.util.log("inserted "..pClient:Name().." into the database.", "DB")
					end)
				insertObj:Execute()
			end
		end)

		queryObj:Execute()
	end
end