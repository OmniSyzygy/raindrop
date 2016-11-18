AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

function ENT:PostEntityPaste( ply, ent, tab )
	
	GAMEMODE:LogSecurity( ply:SteamID(), "n/a", ply:VisibleRPName(), "Tried to duplicate " .. ent:GetClass() .. "!" )
	ent:Remove()
	
end

function ENT:SetupDataTables()
	
	self:NetworkVar( "Int", 0, "ItemID" )
	self:NetworkVar( "String", 0, "Data" )
end

function ENT:Initialize()
	
	if( CLIENT ) then return end
	
	self:PhysicsInit( SOLID_VPHYSICS )
	
	local phys = self:GetPhysicsObject()
	
	if( phys and phys:IsValid() ) then
		
		phys:Wake()
		
	end
	
	self:SetUseType( SIMPLE_USE )
	
	self.KillTime = CurTime() + 21600 -- 6 hours
	
end

function ENT:OnTakeDamage( dmginfo )

	self:TakePhysicsDamage( dmginfo )
	
end

function ENT:Use( activator, caller, usetype, val )
	
	print(self:GetData())

	if( !activator:CanTakeItem( self:GetItemID() ) ) then
		
		net.Start( "nTooHeavy" )
		net.Send( activator )
		
		return
		
	end
	
	self:Remove()
	
	if (string.len(self:GetData()) > 0) then
		activator:GiveItem( self:GetItemID(), 1, pon.decode(self:GetData()) )
	else
		activator:GiveItem( self:GetItem(), 1)
	end
end

function ENT:Think()
	
	if( CLIENT ) then return end
	
	if( CurTime() > self.KillTime ) then
		
		self:Remove()
		
	end
	
end

function ENT:Draw()

	self:DrawModel()

end