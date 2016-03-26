AddCSLuaFile();

ENT.Base = "base_anim";
ENT.Type = "anim";

ENT.PrintName		= "";
ENT.Author			= "";
ENT.Contact			= "";
ENT.Purpose			= "";
ENT.Instructions	= "";

ENT.Spawnable			= false;
ENT.AdminSpawnable		= false;

function ENT:PostEntityPaste( ply, ent, tab )
	
	GAMEMODE:LogSecurity( ply:SteamID(), "n/a", ply:VisibleRPName(), "Tried to duplicate " .. ent:GetClass() .. "!" );
	ent:Remove();
	
end

function ENT:SetupDataTables()
	
	self:NetworkVar( "String", 0, "Item" );
	self:NetworkVar( "String", 1, "Data" );
	
end

function ENT:Initialize()
	
	if( CLIENT ) then return; end
	
	self:PhysicsInit( SOLID_VPHYSICS );
	
	local phys = self:GetPhysicsObject();
	
	if( phys and phys:IsValid() ) then
		
		phys:Wake();
		
	end
	
	self:SetUseType( SIMPLE_USE );
	
	self.KillTime = CurTime() + 21600; -- 6 hours
	
end

function ENT:OnTakeDamage( dmginfo )

	self:TakePhysicsDamage( dmginfo );
	
end

function ENT:Use( activator, caller, usetype, val )
	
	local data = self:GetData()

	if( !activator:CanTakeItem( self:GetItem() ) ) then
		
		net.Start( "nTooHeavy" );
		net.Send( activator );
		
		return;
		
	end
	
	self:Remove();
	
	if (string.len(data) > 0) then
		activator:GiveItem( self:GetItem(), 1, pon.decode(data) );
	else
		activator:GiveItem( self:GetItem(), 1);
	end
end

function ENT:Think()
	
	if( CLIENT ) then return end
	
	if( CurTime() > self.KillTime ) then
		
		self:Remove();
		
	end
	
end

function ENT:Draw()

	self:DrawModel()

end