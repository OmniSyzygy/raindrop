--[[
	Filename: sh_character.lua
--]]

-- enums for data types

DATA_CHARACTER = 0
DATA_APPEARANCE = 1
DATA_INVENTORY = 2
DATA_ADMINONLY = 3
DATA_NAME = 4

rain.character = {}

if (SERVER) then
	rain.characterindex = rain.characterindex or {}
end

local character_meta = {}

--[[
	Name: To String
	Category: Character
	Desc: Called when the character is being printed as a string
--]]

function character_meta:__tostring()
	return "Character - ID: '"..self:GetCharID().."' - NAME: "..self:GetName()
end

--[[
	Name: Apply Appearance
	Category: Character
	Desc: Applies the appearance to a character.
--]]

function character_meta:ApplyAppearance()
	local faceid = self:GetFaceID()

end

--[[
	Name: Get Face ID
	Category: Character
	Desc: Gets the characters Face ID, if called on the client it returns the cached FaceID.
--]]

function character_meta:GetFaceID()

end

--[[
	Name: Get Eye ID
	Category: Character
	Desc: Gets the characters eye ID, if called on the client it returns the cached material.
--]]

function character_meta:GetEyeID()

end

--[[
	Name: EQ
	Category: Character
	Desc: Called when the character is being compared to another
--]]

function character_meta:__eq(cOtherChar)
	return self:GetCharID() == self:GetCharID()
end

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

if (SV) then

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

	function character_meta:SaveByKey(enumDataType, sNewData)
		local SaveObj = mysql:Update("characters")
		SaveObj:Where("id", self:GetCharID())

		if sNewData and type(sNewData) == "table" then
			sNewData = pon.encode(sNewData)
		end

		if enumDataType == DATA_CHARACTER then
			SaveObj:Update("data_character", sNewData or pon.encode(self.data_character))
		elseif enumDataType == DATA_APPEARANCE then
			SaveObj:Update("data_appearance", sNewData or pon.encode(self.data_appearance))
		elseif enumDataType == DATA_INVENTORY then
			SaveObj:Update("data_inventory", sNewData or pon.encode(self.data_inventory))
		elseif enumDataType == DATA_ADMINONLY then
			SaveObj:Update("data_adminonly", sNewData or pon.encode(self.data_adminonly))
		elseif enumDataType == DATA_NAME then
			SaveObj:Update("charname", sNewData or self:GetName())
		end

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

				data.name = self:GetName()
				data.id = self:GetCharID()

				net.Start("rain.charsync")
					rain.net.WriteTable(data)
				net.Send(v)
			end
		end
	end

	--[[
		Name: Sync Data By Key
		Category: Character
		Desc: Syncs the key, in the given dataset, to all players (admin only data only gets networked to that specific player and admins.)
		Also automatically saves any data sent over the network.
	--]]

	util.AddNetworkString("rain.charsyncdatabykey")

	function character_meta:SyncDataByKey(enumDataType, sKey, tNewData, bNoSave)
		self:SaveByKey(enumDataType)

		for k, v in pairs(player.GetAll()) do
			net.Start("rain.charsyncdatabykey")
			rain.net.WriteTinyInt(enumDataType)
			rain.net.WriteTable({target = self:GetOwningClient(), key = sKey, newdata = tNewData})

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
		Also automatically saves any data sent over the network.
	--]]	

	util.AddNetworkString("rain.charsyncdata")

	function character_meta:SyncData(enumDataType, tNewData, bNoSave)
		self:SaveByKey(enumDataType)

		for k, v in pairs(player.GetAll()) do
			net.Start("rain.charsyncdatabykey")
			rain.net.WriteTinyInt(enumDataType)
			rain.net.WriteTable({target = self:GetOwningClient(), newdata = tNewData})

			if enumDataType == DATA_ADMINONLY and v:IsAdmin() then
				net.Send(v)
			elseif enumDataType != DATA_ADMINONLY then
				net.Send(v)
			end
		end
	end

	util.AddNetworkString("rain.charcreate");

	net.Receive("rain.charcreate", function(len, ply)
		local charData = rain.net.ReadTable();

		rain.character.create(ply, charData.data, charData.appearance);
	end);
end

--[[
	Name: Setup Default Data Fields
	Category: Character
	Desc: sets up the default data fields so indexing is garunteed to work.
--]]

function character_meta:SetupDefaultDataFields()
	self.data_appearance = {}
	self.data_inventory = {}
	self.data_adminonly = {}
	self.data_character = {}
end

function character_meta:SetNameAndID(sName, nID)
	self.charname = sName
	self.id = nID
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

function character_meta:GetAppearanceData(sKey, wDefault)
	if (sKey) then
		if self.data_appearance[sKey] then
			return self.data_appearance[sKey]
		else
			return wDefault
		end
	else
		return self.data_appearance
	end
end

--[[
	Name: Get Data
	Category: Character
	Desc: Gets the character data by a key, if no key is supplied the entire table is returned
--]]

function character_meta:GetData(sKey, wDefault)
	if (sKey) then
		if self.data_character[sKey] then
			return self.data_character[sKey]
		else
			return wDefault
		end
	else
		return self.data_character
	end
end

--[[
	Name: Get Admin Only Data
	Category: Character
	Desc: Gets the admin only data by a key, if no key is supplied the entire table is returned
--]]

function character_meta:GetAdminOnlyData(sKey, wDefault)
	if (sKey) then
		if self.data_adminonly[sKey] then
			return self.data_adminonly[sKey]
		else
			return wDefault
		end
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
	return self.data_inventory or {}
end

character_meta.__index = character_meta

local RAIN_CHARMETA = character_meta

--[[
	Name: Get Meta
	Category: Character
	Desc: Returns the character meta table
--]]

function rain.character.getmeta()
	return RAIN_CHARMETA
end

if (CL) then

	net.Receive("rain.charsync", function()
		local charsyncdata = rain.net.ReadTable()
		local target = charsyncdata.target
		local adminonly = charsyncdata.adminonly
		local character = charsyncdata.character
		local appearance = charsyncdata.appearance
		local inventory = charsyncdata.inventory
		local name = charsyncdata.name
		local id = charsyncdata.id

		if target then
			target.character = {}
			setmetatable(target.character, character_meta)
			target.character:SetOwningClient(target)

			local char = target.character
			char:SetupDefaultDataFields()
			char:SetNameAndID(name, id)
			char:SetAdminOnlyData(adminonly)
			char:SetAppearanceData(appearance)
			char:SetData(character)
			char:SetInventoryData(inventory)
		end
	end)

	net.Receive("rain.charsyncdatabykey", function()
		local datatype = rain.net.ReadTinyInt(enumDataType)
		local data = rain.net.ReadTable()

		local target = data.target.character

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

	net.Receive("rain.charsyncdata", function()
		local datatype = rain.net.ReadTinyInt(enumDataType)
		local data = rain.net.ReadTable()

		local target = data.target.character

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

if (CL) then
	function rain.character.loadcharacter(charid)
		net.Start("rain.loadcharacter")
		rain.net.WriteLongInt(charid)
		net.SendToServer()
	end
end


if (SV) then

	util.AddNetworkString("rain.loadcharacter")
	net.Receive("rain.loadcharacter", function(nLen, pClient)
		local charid = rain.net.ReadLongInt()
		if charid then
			pClient:LoadCharacter(charid)
		end 
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

	function rain.character.remove(pOwningClient, nCharacterID)
	end;

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

	function rain.character.playerspawn(pClient, tCharacter)
		local appearTable = tCharacter.data_appearance;

		pClient:SetModel(appearTable.model);
		pClient:SetSkin(appearTable.skin);
	end;

	local rainclient = FindMetaTable("Player")

	--[[
		Name: Load Characters For Selection
		Category: Character
		Desc: Loads all available characters and sends it to the client. 
	--]]

	function rainclient:LoadCharactersForSelection()
		local chars = self:GetCharacters()

		PrintTable(chars)

		for k, v in pairs(chars) do
			local LoadObj = mysql:Select("characters")
			LoadObj:Where("id", tostring(v))
			LoadObj:Callback(function(wResult, sStatus, nLastID)
				PrintTable(wResult)
				if (type(wResult) == "table") and (#wResult > 0) then
					local tResult = wResult[1]
					tResult.data_character = pon.decode(tResult.data_character or "{}")
					tResult.data_appearance = pon.decode(tResult.data_appearance or "{}")
					tResult.data_adminonly = pon.decode(tResult.data_adminonly or "{}")
					tResult.data_inventory = pon.decode(tResult.data_inventory or "{}")

					self.loaddata = self.loaddata or {}
					table.insert(self.loaddata, tResult)

					if k == #chars then
						self.menudata = true
						self:OnMenuDataLoaded()
					end
				end
			end)
			LoadObj:Execute()
		end
	end

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
							self.character.data_character = pon.decode(tResult.data_character)
							self.character.data_appearance = pon.decode(tResult.data_appearance)
							self.character.data_adminonly = pon.decode(tResult.data_adminonly)
							self.character.data_inventory = pon.decode(tResult.data_inventory)

							rain.characterindex[nCharID] = self.character

							setmetatable(self.character, character_meta)

							self.character:SetNameAndID(tResult.charname, nCharID)
							self.character:SetOwningClient(self)
							self.character:Sync()

							self:Spawn()
						end
					end)
					LoadCharObj:Execute()
				end
			end
		end)
		LoadObj:Execute()
	end

end