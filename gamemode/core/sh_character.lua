--[[
	Filename: sh_character.lua
--]]

-- enums for data types

DATA_CHARACTER = 0
DATA_APPEARANCE = 1
DATA_INVENTORY = 2
DATA_ADMINONLY = 3

rain.character = {}

if (SERVER) then
	rain.characterindex = rain.characterindex or {}
end

local character_meta = {}

--[[
	Name: Get Char ID
	Category: Character
	Desc: returns the current character id
--]]

function character_meta:GetCharID()
	return self.id or 0
end

--[[
	Name: Get Name
	Category: Character
	Desc: returns the current character name
--]]

function character_meta:GetName()
	return self.charname or ""
end

--[[
	Name: Get Character Data
	Category: Character
	Desc: returns all of the available character data
--]]

function character_meta:GetCharacterData()
	return self.data_character, self.data_appearance, self.data_adminonly, self.data_inventory
end

if (SERVER) then

	--[[
		Name: Save
		Desc: Saves this character to the DB
	--]]
	
	function character_meta:Save()
		local SaveObj = mysql:Update("characters")
		SaveObj:Where("id", self:GetCharID())

		local SortData = {}
		local a, b, c, d = self:GetCharacterData()

		SortData["data_character"] = a
		SortData["data_appearance"] = b
		SortData["data_adminonly"] = c
		SortData["data_inventory"] = d

		for k, v in pairs(SortData) do
			if type(v) == "table" then
				SaveObj:Update(k, pon.encode(v))
			elseif type(v) == "string" then
				SaveObj:Update(k, v)
			end
		end
					
		SaveObj:Update("charname", self:GetName())
		SaveObj:Execute()
	end
	
	--[[
		Name: Sync
		Desc: Syncs this character to all players, in it's entirety. If a player is specified then it will network the data to that player only.
	--]]
	
	util.AddNetworkString("rain.charsync")

	function character_meta:Sync(pReceiver)
		local TargetPlayers = player.GetAll()

		if (pReceiver) then
			TargetPlayers = {pReceiver}
		else
			for k, v in pairs(TargetPlayers) do
				local data = {}

				data.target = self:GetOwningClient()

				if v:IsAdmin() then
					data.adminonly = self:GetAdminOnlyData()
				else
					data.adminonly = {}
				end

				data.character = self:GetData()
				data.appearance = self:GetAppearanceData()

				if (v == self:GetOwningClient()) or v:IsAdmin() then
					data.inventory = self:GetInventory()
				else
					data.inventory = {}
				end

				net.Start("rain.charsync")
					rain.net.WriteWildcard(data)
				net.Send(v)
			end
		end
	end

	--[[
		Name: Sync Data By Key
		Category: Character
		Desc: Syncs the key, in the given dataset, to all players (admin only data only gets networked to that specific player and admins.)
	--]]

	util.AddNetworkString("rain.charsyncdatabykey")

	function character_meta:SyncDataByKey(enumDataType, sKey, tNewData)
		for k, v in pairs(player.GetAll()) do
			net.Start("rain.charsyncdatabykey")
			rain.net.WriteTinyInt(enumDataType)
			rain.net.WriteWildcard({target = self:GetOwningClient(), key = sKey, newdata = tNewData})

			if enumDataType == DATA_ADMINONLY and v:IsAdmin() then
				net.Send(v)
			elseif enumDataType != DATA_ADMINONLY then
				net.Send(v)
			end
		end
	end

	--[[
		Name: Sync Data
		Category: Character
		Desc: syncs an entire table of data, only a specific table is networked.
	--]]	

	util.AddNetworkString("rain.charsyncdata")

	function character_meta:SyncData(enumDataType, tNewData)
		for k, v in pairs(player.GetAll()) do
			net.Start("rain.charsyncdatabykey")
			rain.net.WriteTinyInt(enumDataType)
			rain.net.WriteWildcard({target = self:GetOwningClient(), newdata = tNewData})

			if enumDataType == DATA_ADMINONLY and v:IsAdmin() then
				net.Send(v)
			elseif enumDataType != DATA_ADMINONLY then
				net.Send(v)
			end
		end
	end

end

--[[
	Name: Get Owning Player
	Category: Character
	Desc: returns the client that owns this character
--]]

function character_meta:GetOwningClient()
	return self.cm_owningclient or false
end

--[[
	Name: Set Owning Player
	Category: Character
	Desc: sets the client that owns this character
--]]

function character_meta:SetOwningClient(pClient)
	self.cm_owningclient = pClient
end

--[[
	Name: Set Appearance Data
	Category: Character
	Desc: If the number of arguments > 1 it will set the appearance data using the first argument as a key, second as the new data. 
		  A single argument means that it set the new appearance data to be equal to that data. The new data will be type checked to a table.
--]]

function character_meta:SetAppearanceData(wArg1, wArg2)
	if rain.util.countargs(wArg1, wArg2) > 1 then
		self.data_appearance[wArg1] = wArg2
		if (SV) then
			self:SyncDataByKey(DATA_APPEARANCE, wArg1, wArg2)
		end
	else
		self.data_appearance = wArg1
		if (SV) then
			self:SyncData(DATA_APPEARANCE, wArg1)
		end
	end
end

--[[
	Name: Set Data
	Category: Character
	Desc: If the number of arguments > 1 it will set the data using the first argument as a key, second as the new data. 
		  A single argument means that it set the new data to be equal to that data. The new data will be type checked to a table.
--]]

function character_meta:SetData(wArg1, wArg2)
	if rain.util.countargs(wArg1, wArg2) > 1 then
		self.data_character[wArg1] = wArg2
		if (SV) then
			self:SyncDataByKey(DATA_CHARACTER, wArg1, wArg2)
		end
	else
		self.data_character = wArg1
		if (SV) then
			self:SyncData(DATA_CHARACTER, wArg1)
		end
	end
end

--[[
	Name: Set Admin Only Data
	Category: Character
	Desc: If the number of arguments > 1 it will set the admin only data using the first argument as a key, second as the new data. 
		  A single argument means that it set the new admin only data to be equal to that data. The new data will be type checked to a table.
--]]

function character_meta:SetAdminOnlyData(wArg1, wArg2)
	if rain.util.countargs(wArg1, wArg2) > 1 then
		self.data_adminonly[wArg1] = wArg2
		if (SV) then
			self:SyncDataByKey(DATA_ADMINONLY, wArg1, wArg2)
		end
	else
		self.data_adminonly = wArg1
		if (SV) then
			self:SyncData(DATA_ADMINONLY, wArg1)
		end
	end
end

--[[
	Name: Set Inventory Data
	Category: Character
	Desc: If the number of arguments > 1 it will set the inventory using the first argument as a key, second as the new data. 
		  A single argument means that it set the new inventory to be equal to that data. The new data will be type checked to a table.
--]]

function character_meta:SetInventoryData(wArg1, wArg2)
	if rain.util.countargs(wArg1, wArg2) > 1 then
		self.data_inventory[wArg1] = wArg2
		if (SV) then
			self:SyncDataByKey(DATA_INVENTORY, wArg1, wArg2)
		end
	else
		self.data_inventory = wArg1
		if (SV) then
			self:SyncData(DATA_INVENTORY, wArg1)
		end
	end
end

--[[
	Name: Get Appearance Data
	Category: Character
	Desc: Gets the appearance data by a key, if no key is supplied the entire table is returned
--]]

function character_meta:GetAppearanceData(sKey)
	if (sKey) then
		return self.data_appearance[sKey]
	else
		return self.data_appearance
	end
end

--[[
	Name: Get Data
	Category: Character
	Desc: Gets the character data by a key, if no key is supplied the entire table is returned
--]]

function character_meta:GetData(sKey)
	if (sKey) then
		return self.data_character(sKey)
	else
		return self.data_character
	end
end

--[[
	Name: Get Admin Only Data
	Category: Character
	Desc: Gets the admin only data by a key, if no key is supplied the entire table is returned
--]]

function character_meta:GetAdminOnlyData(sKey)
	if (sKey) then
		return self.data_adminonly[sKey]
	else
		return self.data_adminonly
	end
end

--[[
	Name: Get Inventory
	Category: Character
	Desc: Returns the inventory table
--]]

function character_meta:GetInventory()
	return self.data_inventory
end

character_meta.__index = character_meta

if (CL) then

	net.Receive("rain.charsync", function()
		local charsyncdata = rain.net.ReadWildcard()
		local target = charsyncdata.target
		local adminonly = charsyncdata.adminonly
		local character = charsyncdata.character
		local appearance = charsyncdata.appearance
		local inventory = charsyncdata.inventory

		if target then
			target.character = {}
			setmetatable(target, character_meta)
			target.character:SetOwningClient(target)

			local char = target.character
			char:SetAdminOnlyData()
			char:SetAppearanceData()
			char:SetData(character)
			char:SetInventoryData(inventory)
		end
	end)

	net.Receive("rain.charsyncdata", function()
		local datatype = rain.net.ReadTinyInt(enumDataType)
		local data = rain.net.ReadWildcard()

		local target = data.target

		if datatype == DATA_CHARACTER then
			target:SetData(data.key, data.newdata)
		elseif datatype == DATA_ADMINONLY then
			target:SetAdminOnlyData(data.key, data.newdata)
		elseif datatype == DATA_INVENTORY then
			target:SetInventoryData(data.key, data.newdata)
		elseif datatype == DATA_APPEARANCE then
			target:SetAppearanceData(data.key, data.newdata)
		end
	end)

	net.Receive("rain.charsyncdatabykey", function()
		local datatype = rain.net.ReadTinyInt(enumDataType)
		local data = rain.net.ReadWildcard()

		local target = data.target

		if datatype == DATA_CHARACTER then
			target:SetData(data.newdata)
		elseif datatype == DATA_ADMINONLY then
			target:SetAdminOnlyData(data.newdata)
		elseif datatype == DATA_INVENTORY then
			target:SetInventoryData(data.newdata)
		elseif datatype == DATA_APPEARANCE then
			target:SetAppearanceData(data.newdata)
		end
	end)

end


if (SERVER) then

	util.AddNetworkString("rain.requestchardata")

	net.Receive("rain.requestchardata", function()
		-- add a request system for data here
	end)

	--[[
		Name: Create
		Category: Character
		Desc: Creates a character and inserts it into the database.
	--]]

	function rain.character.create(pOwningClient, tCharCreateData, tAppearanceData, tInventory)
		if !tCharCreateData then
			return
		end

		local name, chardata = "error", {}

		if tCharCreateData.Name then
			name = tCharCreateData.Name
		end

		if tCharCreateData.CharData then
			chardata = tCharCreateData.CharData
		end

		local appearance = "{}"
		if tAppearanceData then
			appearance = pon.encode(tAppearanceData)
		end

		local inventory = "{}"
		if tInventory then
			inventory = pon.encode(tInventory)
		end

		local InsertObj = mysql:Insert("characters")
		InsertObj:Insert("charname", name)
		InsertObj:Insert("data_character", chardata)
		InsertObj:Insert("data_appearance", appearance)
		InsertObj:Insert("data_adminonly", "{}")
		InsertObj:Insert("data_inventory", inventory)
		InsertObj:Callback(function(result, status, lastID)
			pOwningClient:AddCharacter(lastID)
		end)
		InsertObj:Execute()
	end

	--[[
		Name: Sync
		Category: Character
		Desc: Syncs a single character
	--]]

	function rain.character.sync()
		-- this will be written once I figure out some networking backend stuff
	end

	--[[
		Name: Sync Index
		Category: Character
		Desc: Syncs the character index to all clients in the server
	--]]

	function rain.character.syncindex()
		-- this will be written once I figure out some networking backend stuff
	end

	local rainclient = FindMetaTable("Player")

	--[[
		Name: Load Character
		Desc: Loads a character, then sets the clients current character to the new character.
	--]]

	function rainclient:LoadCharacter(nCharID)
		local LoadObj = mysql:Select("players")
		LoadObj:Where("steam_id64", self:SteamID64())
		LoadObj:Callback(function(wResult, uStatus, uLastID)
			if (type(wResult) == "table") and (#wResult > 0) then
				local tResult = wResult[1]

				local chars = pon.decode(tResult.characters)
				if !table.HasValue(chars, nCharID) then
					return
				else
					local LoadCharObj = mysql:Select("characters")
					LoadCharObj:Where("id", nCharID)
					LoadCharObj:Callback(function(wResult, sStatus, nLastID)
						if (type(wResult) == "table") and (#wResult > 0) then
							local tResult = wResult[1]

							self.character = {}
							self.character.charname = tResult.charname
							self.character.data_character = pon.decode(tResult.data_character)
							self.character.data_appearance = pon.decode(tResult.data_appearance)
							self.character.data_adminonly = pon.decode(tResult.data_adminonly)
							self.character.data_inventory = pon.decode(tResult.data_inventory)

							rain.characterindex[nCharID] = self.character

							setmetatable(self.character, character_meta)

							self.character:SetOwningClient(self)
							self.character:Sync()
						end
					end)
					LoadCharObj:Execute()
				end
			end
		end)
		LoadObj:Execute()
	end

end