rain.pdata = {}

function rain.pdata.clientinitialspawn(pClient)
	if !pClient.rain then
		local QueryObj = mysql:Select("players")
		QueryObj:Where("steam_id64", pClient:SteamID64())
		QueryObj:Callback(function(result, status, lastID)
			if type(result) == "table" and #result > 0 then
				local UpdateObj = mysql:Update("players")
				UpdateObj:Update("steam_name", pClient:Name())
				UpdateObj:Update("last_ip", pClient:IPAddress())
				UpdateObj:Where("steam_id64", pClient:SteamID64())
				UpdateObj:Execute()
				UpdateObj:Callback(function(result, status, lastID)
					rain.pdata.updateloggeddata(pClient)
				end)
			else
				local InsertObj = mysql:Insert("players")
				InsertObj:Insert("steam_name", pClient:Name())
				InsertObj:Insert("steam_id64", pClient:SteamID64())
				InsertObj:Insert("steam_name_history", "{}")
				InsertObj:Insert("characters", "{}")
				InsertObj:Insert("last_ip", "{}")
				InsertObj:Insert("iphistory", "{}")
				InsertObj:Insert("client_data", "{}")

				InsertObj:Callback(function(result, status, lastID)
					rain.util.log("inserted "..pClient:Name().." into the database.", "DB")
					rain.pdata.updateloggeddata(pClient)
				end)
				InsertObj:Execute()
			end
		end)

		QueryObj:Execute()
	end
end

function rain.pdata.updateloggeddata(pClient)
	rain.util.log("Update logged data for "..pClient:Name()..".", "DB")

	local QueryObj = mysql:Select("players")
	QueryObj:Where("steam_id64", pClient:SteamID64())
	QueryObj:Callback(function(result, status, lastID)
		if type(result) == "table" and #result > 0 then

			local namehistory = pon.decode(result[1].steam_name_history)
			
			if !table.HasValue(namehistory, pClient:Name()) then
				table.insert(namehistory, pClient:Name())
			end
			
			local iphistory = pon.decode(result[1].iphistory)
			
			if !table.HasValue(iphistory, pClient:IPAddress()) then
				table.insert(iphistory, pClient:IPAddress())
			end

			namehistory = pon.encode(namehistory)
			iphistory = pon.encode(iphistory)

			local UpdateObj = mysql:Update("players")
			UpdateObj:Update("steam_name", pClient:Name())
			UpdateObj:Update("steam_name_history", namehistory)
			UpdateObj:Update("last_ip", tostring(pClient:IPAddress()))
			UpdateObj:Update("iphistory", iphistory)
			UpdateObj:Where("steam_id64", pClient:SteamID64())
			UpdateObj:Execute()
		end
	end)

	QueryObj:Execute()
end