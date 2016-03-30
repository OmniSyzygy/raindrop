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

rain.pdata.datatypes = {}
rain.pdata.datatypes["steam_name_history"] = true
rain.pdata.datatypes["last_ip"] = true
rain.pdata.datatypes["iphistory"] = true
rain.pdata.datatypes["client_data"] = true

function rain.pdata.isvaliddatatype(sDataType)
	return rain.pdata.datatypes[sDataType] or false
end

local rainclient = FindMetaTable("Player")

-- Set Data
-- Sets data on a client and saves to the DB, wNewValue is a wildcard which should only be a serialized or unserialzed table

function rainclient:SetData(sDataType, wNewValue)
	if !sDataType or !wNewValue then
		return
	end

	local sNewValue = ""

	if type(wNewValue) = "table" then
		sNewValue = pon.encode(wNewValue)
		self[sDataType] = wNewValue
	else
		sNewValue = tostring(wNewValue)
		self[sDataType] = pon.decode(wNewValue)
	end

	local UpdateObj = mysql:Update("players")
	UpdateObj:Update(sDataType, wNewValue)
	UpdateObj:Where("steam_id64", self:SteamID64())
	UpdateObj:Execute()
end

-- Set Client Data
-- Quick and dirty version of the function above, rewritten slightly to be a bit easier on the eyes

function rainclient:SetClientData(wNewValue)
	self:SetData("client_data", wNewValue)
end