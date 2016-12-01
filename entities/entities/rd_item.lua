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
	
	GAMEMODE:LogSecurity( ply:SteamID(), "n/a", ply:GetRPName(), "Tried to duplicate " .. ent:GetClass() .. "!" )
	ent:Remove()
	
end

function ENT:SetupDataTables()
	
	self:NetworkVar( "Int", 0, "ItemID" )
	self:NetworkVar( "String", 0, "Data" )
end

function ENT:Initialize()
	
	if( CLIENT ) then self.ResyncTime = 0 return end
	
	for _, e in pairs(ents.FindInPVS(self:GetPos())) do
		if e:IsPlayer() then
			--print(e.." is getting the item info for "..self:GetItemID())
				rain:SyncItem(self:GetItemID(), e)
		end	
	end
	

	
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
		activator:GiveItem( self:GetItemID(), 1)
	end
end

function ENT:Think()
	if (SV) then
		if( CurTime() > self.KillTime ) then
			self:Remove()
		end
	end
end

function ENT:Draw()
	if CLIENT then
		if !rain.itemindex[self:GetItemID()] && CurTime() > self.ResyncTime then
			net.Start("ItemSyncRequest")
			net.WriteEntity( self )
			net.SendToServer()
			self.ResyncTime = CurTime() + 10
		end
		if rain.itemindex[self:GetItemID()] then
		
		end
	end
	self:DrawModel()

end

function ENT:getItemTable()
	if rain.itemindex[self:GetItemID("id")] ~= nil then
		return rain.itemindex[self:GetItemID("id")]
	else
	if (CL) then
	print("failed to get the itemtable ")
	end
	if (SV) then
	print("failed to load item table")
	end
	end
end
