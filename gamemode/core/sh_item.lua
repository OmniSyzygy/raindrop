-- # Micro-ops
local rain = rain
rain.items = rain.items or {}

local path = GM.FolderName.."/gamemode/raindrop/items/"
local files = file.Find(path.."*.lua", "LUA", "namedesc")

if (#files > 0) then
	for k = 1, #files do
		local v = files[k]

		ITEM = {}
		ITEM.ID				= v:match("([_%w]+)%.lua") -- # UniqueID
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
		
		rain.items[#rain.items + 1] = ITEM
		
		v = nil
	end
else
	if (SV) then
		rain:LogBug( "[BUG] Warning: No items found.", true )
	end
end
path, files = nil, nil -- # Don't need.

function rain:LoadWeaponItems()
	for k = 1, #weapons.GetList() do
		local v = weapons.GetList()[k]
		if (v.Itemize) then
			ITEM = {}
			ITEM.ID				= v.ClassName
			ITEM.Name 			= v.PrintName
			ITEM.Desc			= v.ItemDescription or ""
			ITEM.Model			= v.WorldModel
			ITEM.Weight			= v.ItemWeight or 1
			ITEM.SizeX			= v.ItemSizeX or 1
			ITEM.SizeY			= v.ItemSizeY or 1
			ITEM.IconX			= v.ItemIconX or 1
			ITEM.IconY			= v.ItemIconY or 1
			
			ITEM.FOV			= v.ItemFOV
			ITEM.CamPos			= v.ItemCamPos
			ITEM.LookAt			= v.ItemLookAt
			
			ITEM.ProcessEntity	= v.ItemProcessEntity
			ITEM.PProcessEntity	= v.ItemPProcessEntity
			ITEM.IconMaterial	= v.ItemIconMaterial
			ITEM.IconColor		= v.ItemIconColor
			
			ITEM.BulkPrice		= v.ItemBulkPrice
			ITEM.SinglePrice	= v.ItemSinglePrice
			ITEM.License		= v.ItemLicense
			
			ITEM.Droppable		= true
			ITEM.Throwable		= true
			ITEM.Usable			= false
			ITEM.UseText		= nil
			ITEM.IsWeapon		= false
			ITEM.IsArtifact		= false
			
			function ITEM.OnPlayerSpawn(item, player)
				if (SV) then player:Give(item) end
			end
			
			function ITEM.OnPlayerPickup(item, player)
				if (SV) then player:Give(item) end
			end
			
			function ITEM.OnRemoved(item, player)
				if (SV and player:GetNumItems(item) < 2) then
					player:StripWeapon(item)
				end
			end
			
			self.items[#self.items + 1] = ITEM
			MsgC(Color(200, 200, 200, 255 , "Weapon item " .. v.ClassName .. " loaded.\n"))
		end
	end
end

function rain:GetItemByID(id)
	if (id and #self.items > 0) then
		for k = 1, #self.items do
			if (self.items[k].ID == id) then
				return item
			end
		end
	end
	
	return false
end

function rain:CreateItem(player, item)
	local trace = {}
	trace.start = player:GetShootPos()
	trace.endpos = trace.start + player:GetAimVector() * 50
	trace.filter = player
	
	local tr = util.TraceLine(trace)
	local ent = self:CreatePhysicalItem(item, tr.HitPos + tr.HitNormal * 10, Angle())
	
	if (ent and IsValid(player)) then
		ent.rainSteamID = player:SteamID()
	end

	return ent
end

function rain:CreatePhysicalItem(item, pos, ang)
	local e = ents.Create("rd_item")
	e:SetModel(self:GetItemByID(item).Model)
	e:SetPos(pos)
	e:SetAngles(ang)
	
	if (self:GetItemByID(item).ProcessEntity) then
		self:GetItemByID(item).ProcessEntity(item, e)
	end
	
	e:SetItemID(item)
	e:Spawn()
	e:Activate()
	
	if (self:GetItemByID(item).PProcessEntity) then
		self:GetItemByID(item).PProcessEntity(item, e)
	end
	
	if (IsValid(e:GetPhysicsObject())) then
		e:GetPhysicsObject():Wake()
	end
	
	return e
end

print("rain.items")
PrintTable(rain.items)