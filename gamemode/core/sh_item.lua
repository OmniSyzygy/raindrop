-- # Micro-ops
local rain = rain

rain.items = {}

local path = GM.FolderName.."/gamemode/raindrop/items/"
local files = file.Find(path.."*.lua", "LUA", "namedesc")

if (#files > 0) then
	for k = 1, #files do
		local v = files[k]

		ITEM = {}
		ITEM.ID				= ""
		ITEM.Name 			= ""
		ITEM.Description	= ""
		ITEM.Model			= ""
		ITEM.Weight			= 1
		ITEM.SizeX			= 1
		ITEM.SizeY			= 1
		
		ITEM.ProcessEntity	= function() end
		ITEM.IconMaterial	= nil
		ITEM.IconColor		= nil
		
		ITEM.Usable			= false
		ITEM.Droppable		= true
		ITEM.Throwable		= true
		ITEM.UseText		= nil
		ITEM.DeleteOnUse	= false
		
		ITEM.OnPlayerUse	= function() end
		ITEM.OnPlayerSpawn	= function() end
		ITEM.OnPlayerPickup	= function() end
		ITEM.OnPlayerDeath	= function() end
		ITEM.OnRemoved		= function() end
		ITEM.Think			= function() end
		
		AddCSLuaFile(path..v)
		include(path..v)
		MsgC(Color(200, 200, 200, 255), "Item "..v.." loaded.\n")
		
		table.insert(rain.items, ITEM)
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
			ITEM.Description	= v.ItemDescription or ""
			ITEM.Model			= v.WorldModel
			ITEM.Weight			= v.ItemWeight or 1
			ITEM.SizeX			= v.ItemSizeX or 1
			ITEM.SizeY			= v.ItemSizeY or 1
			
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
			
			function ITEM.OnPlayerSpawn( item, ply )
				if( SERVER ) then
					ply:Give( item )
				end
			end
			
			function ITEM.OnPlayerPickup( item, ply )
				if( SERVER ) then
					ply:Give( item )
				end
			end
			
			function ITEM.OnRemoved( item, ply )
				if( SERVER and ply:GetNumItems( item ) < 2 ) then
					ply:StripWeapon( item )
				end
			end
			
			table.insert(self.Items, ITEM)
			MsgC(Color(200, 200, 200, 255 , "Weapon item " .. v.ClassName .. " loaded.\n"))
		end
	end
end

function rain:GetItemByID(id)
	if (id and #self.items > 0) then
		for k = 1, #self.items do
			local item = self.items[k]
			if (item.ID == id) then
				return item
			end
		end
	end
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
	e:SetItemID(item)
	e:SetModel(self:GetItemByID(item).Model)
	e:SetPos(pos)
	e:SetAngles(ang)
	
	if (self:GetItemByID(item).ProcessEntity) then
		self:GetItemByID(item).ProcessEntity(item, e)
	end
	
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