rain.pdata = {}

-- these are caches, so they're preserved when the gamemode reloads
rain.lastsyncindex = rain.lastsyncindex or {}

--[[
	Name: Client Initial Spawn
	Chategory: Player Data
	Desc: Called when a player spawns, currently is used to update their data in the database.
--]]

function rain.pdata.clientinitialspawn(pClient)
	pClient:LoadData()

	if !pClient.data then
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
					pClient:LoadData()
				end)
				InsertObj:Execute()
			end
		end)

		QueryObj:Execute()
	end
end

--[[
	Name: Update Logged Data
	Chategory: Player Data
	Desc: Updates IP logs, and Steam Name logs.
--]]

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

--[[
	Name: Load Data Offline
	Chategory: Player Data
	Desc: Retrieves data then calls a callback function supplying the players data
--]]

function rain.pdata.loaddataoffline(sSteamID, fnCallback)
	local LoadObj = mysql:Select("players")
	LoadObj:Where("steam_id64", self:SteamID64())
	LoadObj:Callback(function(wResult, uStatus, uLastID)
		if (type(wResult) == "table") and (#wResult > 0) then
			local tResult = wResult[1]

			local data = {}
			data.iphistory = pon.decode(tResult.iphistory)
			data.client_data = pon.decode(tResult.client_data)
			data.last_ip = tResult.last_ip
			data.steam_name_history = pon.decode(tResult.steam_name_history)

			if (fnCallback) then
				fnCallback(data)
			end
		end
	end)
end

--[[
	Name: Set Client Data Offline
	Chategory: Player Data
	Desc: Sets a players data while they're offline using their SteamID64
--]]

function rain.pdata.setdataoffline(sSteamID, sDataType, wNewValue)
	local sNewValue = ""

	if type(wNewValue) == "table" then
		sNewValue = pon.encode(wNewValue)
	else
		sNewValue = tostring(wNewValue)
	end

	local UpdateObj = mysql:Update("players")
	UpdateObj:Update(sDataType, sNewValue)
	UpdateObj:Where("steam_id64", sSteamID)
	UpdateObj:Execute()
end

--[[
	Name: Set Client Data Offline
	Chategory: Player Data
	Desc: Sets a players client data while they're offline using their SteamID64
--]]

function rain.pdata.setclientdataoffline(sSteamID, wNewValue)
	rain.pdata.setdataoffline(sSteamID, "client_data", wNewValue)
end

local rainclient = FindMetaTable("Player")

--[[
	Name: Add Character
	Desc: Adds a character id to the client data
--]]

function rainclient:AddCharacter(nCharID)
	table.insert(self.data.characters, nCharID)
	self:SaveData()
	self:SyncDataByKey("characters")
end

--[[
	Name: Remove Character
	Desc: Removes a character from the players character list, characters will never be deleted for security and logging purposes.
--]]

function rainclient:RemoveCharacter(nCharID)
	table.RemoveByValue(self.data.characters, nCharID)
	self:SaveData()
	self:SyncDataByKey("characters")

	for k, character in pairs(self.loaddata) do
		if (character.id == nCharID) then
			self.loaddata[k] = nil;

			net.Start("SyncMenuData");
				rain.net.WriteTable(self.loaddata);
			net.Send(self);

			break;
		end;
	end;
end

--[[
	Name: Get Characters
	Desc: Gets all owned character ID's, returns a blank table if nothing useful is found in the character data.
--]]

function rainclient:GetCharacters()
	if self.data then
		return self.data.characters or {}
	end

	return {}
end

--[[
	Name: Load Main Menu Data
	Desc: Loads all of the players characters to rainclient.loaddata.
--]]

function rainclient:LoadMainMenuData()
	self.menudata = false
	self:LoadCharactersForSelection()
end

--[[
	Name: On Menu Data Loaded
	Desc: Called when a player has all of his characters loaded into rainclient.loaddata
--]]

util.AddNetworkString("SyncMenuData")
function rainclient:OnMenuDataLoaded()
	net.Start("SyncMenuData")
		rain.net.WriteTable(self.loaddata)
	net.Send(self)
end

--[[
	Name: Save Data
	Desc: Saves a players data, this function is cached to reduce the length of a mysql query
--]]

function rainclient:SaveData()
	local SaveObj = mysql:Update("players")
	SaveObj:Where("steam_id64", self:SteamID64())

	for k, v in pairs(self.data) do
		if type(v) == "table" then
			SaveObj:Update(k, pon.encode(v))
		elseif type(v) == "string" then
			SaveObj:Update(k, v)
		end
	end

	SaveObj:Update("steam_name", self:Name())
	SaveObj:Execute()
end

--[[
	Name: Sync Data
	Desc: Syncs a clients data in its entirety
--]]

util.AddNetworkString("SyncPlayerData");
function rainclient:SyncData()
	net.Start("SyncPlayerData");
		rain.net.WriteTable(self.data);
	net.Send(rainclient);
end

--[[
	Name: Sync Data By Key
	Desc: Syncs data accross the network by a specific key, this should be used as much as possible to reduce overhead
--]]

function rainclient:SyncDataByKey(sKey)
	net.Start("SyncPlayerData");
		net.WriteString(sKey);
		rain.net.WriteTable(self.data[sKey]);
	net.Send(self);
end

--[[
	Name: Load Data
	Desc: Loads client data from the DB
--]]

function rainclient:LoadData()
	local LoadObj = mysql:Select("players")
	LoadObj:Where("steam_id64", self:SteamID64())
	LoadObj:Callback(function(wResult, uStatus, uLastID)
		if (type(wResult) == "table") and (#wResult > 0) then
			local tResult = wResult[1]

			self.data = {}
			self.data.characters = pon.decode(tResult.characters)
			self.data.iphistory = pon.decode(tResult.iphistory)
			self.data.client_data = pon.decode(tResult.client_data)
			self.data.last_ip = tResult.last_ip
			self.data.steam_name_history = pon.decode(tResult.steam_name_history)

			self:LoadMainMenuData()
		end
	end)
	LoadObj:Execute()
end

--[[
	Name: Set Data
	Desc: Sets data on a client and saves to the DB, wNewValue is a wildcard which should only be a serialized or unserialzed table
--]]

function rainclient:SetData(sDataType, wNewValue)
	if !sDataType or !wNewValue then
		return
	end

	if !self.data then
		return
	end

	local sNewValue = ""

	if type(wNewValue) == "table" then
		sNewValue = pon.encode(wNewValue)
		self.data[sDataType] = wNewValue
	else
		sNewValue = tostring(wNewValue)
		self.data[sDataType] = pon.decode(wNewValue)
	end

	local UpdateObj = mysql:Update("players")
	UpdateObj:Update(sDataType, sNewValue)
	UpdateObj:Where("steam_id64", self:SteamID64())
	UpdateObj:Execute()
end

--[[
	Name: Set Client Data
	Desc: Quick and dirty version of the function above, rewritten slightly to be a bit easier on the eyes
--]]

function rainclient:SetClientData(wNewValue)
	self:SetData("client_data", wNewValue)
end