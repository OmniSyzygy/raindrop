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

function ENT:PostEntityPaste( ply, ent )
	rain:LogSecurity( ply:SteamID(), "n/a", ply:GetVisibleRPName(), "[SECURITY] Tried to duplicate " .. ent:GetClass() .. "!" );
	ent:Remove()
end

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "ItemID" )
	self:NetworkVar( "String", 0, "Data" )
end

function ENT:Initialize()
	if( CLIENT ) then self.ResyncTime = CurTime() return end
	
	local entities = ents.FindInPVS(self:GetPos())
	for k = 1, #entities do
		local ent = entities[k]
		if ent:IsPlayer() then
			--print(ent.." is getting the item info for "..self:GetItemID())
			rain:SyncItem(self:GetItemID(), ent)
		end
		ent = nil
	end
	entities = nil
	
	self:PhysicsInit( SOLID_VPHYSICS )
	local phys = self:GetPhysicsObject()
	
	if(IsValid(phys)) then
		phys:Wake()
	end
	
	self:SetUseType( SIMPLE_USE )
	self.KillTime = CurTime() + 21600 -- 6 hours
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
	if (SV) then
		if( CurTime() > self.KillTime ) then
			self:Remove()
		end
	end
end

function ENT:Draw()
	if (CL) then
		if !rain.item.instances[self:GetItemID()] and CurTime() > self.ResyncTime then
			net.Start("ItemSyncRequest")
			net.WriteEntity( self )
			net.SendToServer()
			self.ResyncTime = CurTime() + 10
		end
	end
	self:DrawModel()
end

function ENT:getItemTable()
	if rain.item.instances[self:GetItemID("id")] then
		return rain.item.instances[self:GetItemID("id")]
	else
		if (CL) then
			print("failed to get the itemtable")
		else
			print("failed to load item table")
		end
	end
end