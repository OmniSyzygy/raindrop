-- # Micro-ops
local rain = rain
rain.items = rain.items or {}

local path = GM.FolderName.."/gamemode/raindrop/items/"
local files = file.Find(path.."*.lua", "LUA", "namedesc")

if (#files > 0) then
	for k = 1, #files do
		local v = files[k]
		local id = v:match("([_%w]+)%.lua")

		ITEM = {}
		ITEM.UniqueID		= id
		ITEM.Name 			= ""
		ITEM.Desc			= ""
		ITEM.Model			= ""
		ITEM.Weight			= 1
		ITEM.SizeX			= 1
		ITEM.SizeY			= 1
		ITEM.IconX			= 1
		ITEM.IconY			= 1
		
		ITEM.ProcessEntity	= function() end
		ITEM.IconMat		= nil
		ITEM.IconColor		= nil
		
		ITEM.Usable			= false
		ITEM.Droppable		= true
		ITEM.Throwable		= true
		ITEM.UseText		= nil
		ITEM.DeleteOnUse	= false
		ITEM.IsWeapon		= false
		ITEM.IsArtifact		= false
		
		ITEM.OnPlayerUse	= function() end
		ITEM.OnPlayerSpawn	= function() end
		ITEM.OnPlayerPickup	= function() end
		ITEM.OnPlayerDeath	= function() end
		ITEM.OnRemoved		= function() end
		ITEM.Think			= function() end
		
		AddCSLuaFile(path..v)
		include(path..v)
		MsgC(Color(200, 200, 200, 255), "Item "..v.." loaded.\n")
		
		rain.items[id] = ITEM
		
		v, id = nil, nil
	end
else
	if (SV) then
		rain:LogBug( "[BUG] Warning: No items found.", true )
	end
end
path, files = nil, nil -- # Don't need.

function rain:GetItemByID(ItemID)
	if (ItemID) then
		return self.items[ItemID]
	end
end

function rain:CreateItem(item, pos, ang)
	if (self:GetItemByID(item)) then
		local client

		-- If the first argument is a player, then we will find a position to drop
		-- the item based off their aim.
		if (type(pos) == "Player") then
			client = pos
			pos = pos:GetItemDropPos()
		end

		-- Spawn the actual item entity.
		local entity = ents.Create("rd_item")
		entity:Spawn()
		entity:SetPos(pos)
		entity:SetAngles(ang or Angle(0, 0, 0))
		-- Make the item represent this item.
		entity:SetItem(item)

		if (IsValid(client)) then
			entity.rainSteamID = client:SteamID()
			entity.rainCharID = client:GetCharacter():GetCharID()
		end

		-- Return the newly created entity.
		return entity
	end
end