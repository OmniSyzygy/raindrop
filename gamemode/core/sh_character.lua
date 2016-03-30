rain.character = {}

if (SERVER) then
	rain.characterindex = rain.characterindex or {}
end

local character_meta = {
	Name = "Jon Doe",
	GetName = function() 
		return self.Name 
	end
}

character_meta.__index = character_meta

if (SERVER) then

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

		local appearance
		if !tAppearanceData then
			appearance = "{}"
		else
			appearance = pon.encode(tAppearanceData)
		end

		local inventory
		if !tInventory then
			inventory = "{}"
		else
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

	-- loads a character from the database and tosses it into the character index
	function rain.character.load()

	end

	-- sync a single character
	function rain.character.sync()

	end

	-- sync all characters in the index
	function rain.character.syncindex()

	end
end