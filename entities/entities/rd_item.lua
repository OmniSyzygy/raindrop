AddCSLuaFile()

ENT.Base = "base_entity"
ENT.Type = "anim"
ENT.PrintName = "Item"
ENT.Category = "RAINDROP"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.DefaultModel = "models/props_junk/cardboard_box004a.mdl"

if (SERVER) then
	function ENT:PostEntityPaste(player, ent)
		rain:LogSecurity(player:SteamID(), "n/a", player:GetVisibleRPName(), "[SECURITY] Tried to duplicate " .. ent:GetClass() .. "!");
		ent:Remove()
	end

	function ENT:Initialize()
		self:SetModel(self.DefaultModel)
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		
		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(true)
			physObj:Wake()
		end
		
		self:SetUseType(SIMPLE_USE)
		
		hook.Run("OnItemSpawned", self)
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)
	end

	function ENT:Use(activator, caller)
		if (!activator:CanTakeItem(self:GetItemID())) then
			return activator:AddChat(Color(200, 0, 0, 255), "That's too heavy for you to carry.")
		end
		
		self:Remove()
		activator:GiveItem(self:GetItemID(), 1)
	end
	
	function ENT:SetItem(itemID)
		local itemTable = rain:GetItemByID(itemID)

		if (itemTable) then
			self:SetSkin(itemTable.skin or 0)
			self:SetModel(itemTable.Model or self.DefaultModel)
			self:PhysicsInit(SOLID_VPHYSICS)
			self:SetSolid(SOLID_VPHYSICS)
			if (itemTable.ProcessEntity) then
				itemTable.ProcessEntity(item, e)
			end
			self:setNetVar("id", itemTable.UniqueID)
			self.rainItemID = itemID

			local physObj = self:GetPhysicsObject()

			if (!IsValid(physObj)) then
				local min, max = Vector(-8, -8, -8), Vector(8, 8, 8)

				self:PhysicsInitBox(min, max)
				self:SetCollisionBounds(min, max)
			end

			if (IsValid(physObj)) then
				physObj:EnableMotion(true)
				physObj:Wake()
			end
		end
	end
end

function ENT:GetItemID()
	return self:getNetVar("id", "")
end

function ENT:GetItemTable()
	return rain:GetItemByID(self:GetItemID())
end

function ENT:Draw()
	self:DrawModel()
end