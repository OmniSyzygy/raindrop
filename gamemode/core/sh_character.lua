rain.character = {}

if (SERVER) then
	rain.characterindex = rain.characterindex or {}
end

local character_meta = {}

--[[
	Name: Get Char ID
	Desc: returns the character ID
--]]

function character_meta:GetCharID()
	return self.id or 0
end

function character_meta:GetName()
	return self.charname or ""
end

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
		Desc: Syncs this character to all players
	--]]
	
	function character_meta:Sync()
	
	end

	--[[
		Name: Sync By Key
		Category: Character
		Desc: Syncs the key, in the given dataset, to all players (admin only data only gets networked to that specific player and admins.)
	--]]

	function character_meta:SyncByKey()

	end

	--[[
		Name: Get Owning Player
		Category: Character
		Desc: returns the client that owns this character
	--]]

	function character_meta:GetOwningPlayer()

	end

end

--[[
	Name: Set Appearance Data
	Category: Character
	Desc: If the number of arguments > 1 it will set the appearance data using the first argument as a key, second as the new data. 
		  A single argument means that it set the new appearance data to be equal to that data. The new data will be type checked to a table.
--]]

function character_meta:SetAppearanceData()

end

--[[
	Name: Set Data
	Category: Character
	Desc: If the number of arguments > 1 it will set the data using the first argument as a key, second as the new data. 
		  A single argument means that it set the new data to be equal to that data. The new data will be type checked to a table.
--]]

function character_meta:SetData()

end

--[[
	Name: Set Admin Only Data
	Category: Character
	Desc: If the number of arguments > 1 it will set the admin only data using the first argument as a key, second as the new data. 
		  A single argument means that it set the new admin only data to be equal to that data. The new data will be type checked to a table.
--]]

function character_meta:SetAdminOnlyData()

end

--[[
	Name: Set Inventory Data
	Category: Character
	Desc: If the number of arguments > 1 it will set the inventory using the first argument as a key, second as the new data. 
		  A single argument means that it set the new inventory to be equal to that data. The new data will be type checked to a table.
--]]

function character_meta:SetInventoryData()

end

--[[
	Name: Get Appearance Data
	Category: Character
	Desc: Gets the appearance data by a key, if no key is supplied the entire table is returned
--]]

function character_meta:GetAppearanceData()

end

--[[
	Name: Get Data
	Category: Character
	Desc: Gets the character data by a key, if no key is supplied the entire table is returned
--]]

function character_meta:GetData()

end

--[[
	Name: Get Admin Only Data
	Category: Character
	Desc: Gets the admin only data by a key, if no key is supplied the entire table is returned
--]]

function character_meta:GetAdminOnlyData()

end

--[[
	Name: Get Inventory
	Category: Character
	Desc: Returns the inventory table
--]]

function character_meta:GetInventory()

end

character_meta.__index = character_meta

if (SERVER) then

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
							self.character.data_character = tResult.data_character
							self.character.data_appearance = tResult.data_appearance
							self.character.data_adminonly = tResult.data_adminonly
							self.character.data_inventory = tResult.data_inventory

							rain.characterindex[nCharID] = self.character

							setmetatable(self.character, character_meta)

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