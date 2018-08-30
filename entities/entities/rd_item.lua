AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Item"
ENT.Category = "RAINDROP"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:PostEntityPaste( ply, ent )
	rain:LogSecurity( ply:SteamID(), "n/a", ply:GetVisibleRPName(), "[SECURITY] Tried to duplicate " .. ent:GetClass() .. "!" );
	ent:Remove()
end

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "ItemID" )
	self:NetworkVar( "String", 0, "Data" )
end

if (SERVER) then
	function ENT:Initialize()
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(true)
			physObj:Wake()
		end
		
		self:SetUseType( SIMPLE_USE )
		self.KillTime = CurTime() + 21600 -- 6 hours
		
		hook.Run("OnItemSpawned", self)
	end

	function ENT:OnTakeDamage( dmginfo )
		self:TakePhysicsDamage( dmginfo )
	end

	function ENT:Use( activator, caller, usetype, val )
		local data = self:GetData()

		if( !activator:CanTakeItem( self:GetItemID() ) ) then
			return
		end
		
		self:Remove()
		
		if (string.len(data) > 0) then
			activator:GiveItem( self:GetItemID(), 1, pon.decode(data) )
		else
			activator:GiveItem( self:GetItemID(), 1)
		end
	end

	function ENT:Think()
		if (CurTime() > self.KillTime) then
			self:Remove()
		end
	end
end

function ENT:Draw()
	self:DrawModel()
end