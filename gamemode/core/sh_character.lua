rain.character = {}

if (SERVER) then
	rain.characterindex = rain.characterindex or {}
	rain.lastsaveindex = rain.lastsaveindex or {}
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
		local SaveObj = mysql:Select("characters")
		SaveObj:Where("id", self:GetCharID())

		local SortData = {}
		local a, b, c, d = self:GetCharacterData()

		SortData["data_character"] = a
		SortData["data_appearance"] = b
		SortData["data_adminonly"] = c
		SortData["data_inventory"] = d

		if rain.lastsaveindex[self:GetCharID()] then
			for k, v in pairs(SortData) do
				if v != rain.lastinsertindex[self:SteamID()].sortdata[k] then
					SaveObj:Update(k, pon.encode(v))
				end
			end
		else
			for k, v in pairs(SortData) do
				SaveObj:Update(k, pon.encode(v))
			end
		end
			
		rain.lastinsertindex[self:SteamID()].sortdata = SortData
		
		SaveObj:Update("charname", self:GetName())
		SaveObj:Execute()
	end
	
	--[[
		Name: Sync
		Desc: Syncs this character to all players
	--]]
	
	function character_meta:Sync()
	
	end

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
			--pOwningClient:AddCharacter(lastID)
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