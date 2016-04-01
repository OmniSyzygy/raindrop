--[[
	Filename: sv_anomaly.lua
	Notes: This is the file that new anomalies are registered in.
--]]

rain.anomalies = {}
rain.elements = {}

rain.struct:RegisterStruct("AnomalyStruct", {
	Name = "Anomaly", -- Name, for debugging purposes.
	Elements = {} -- Table of strings that contain the anomaly elements
})

rain.struct:RegisterStruct("AnomalyElement", {
	Name = "Anomaly Element", -- Name, for debugging purposes.
	OnEntityNear = function(ent, dist, strength) -- called constantly once OnEnter has been called
		print(ent, dist)
	end,
	AnomalyInit = function(ent) -- called once when it is set
		print("anomaly effects set")
	end,
	AnomalyThink = function(ent)
		print("ty fam")
	end,
	AnomalyDraw = function(ent)

	end
})

--[[
	Function: RegisterAnomaly
	Purpose: Registers an Anomaly for use in the future.
--]]

function rain:RegisterAnomaly(sName, tElements)
	local Anomaly = rain.struct:GetStruct("AnomalyStruct")
	Anomaly.Name = sName or Anomaly.Name
	Anomaly.Elements = tElements or Anomaly.Elements

	self.anomalies[sName] = Anomaly
end

--[[
	Function: RegisterElement
	Purpose: Registers an Anomaly element for use later on
--]]

function rain:RegisterElement(sName, fnAnomalyInit, fnAnomalyThink, fnAnomalyDraw)
	local AnomalyElement = rain.struct:GetStruct("AnomalyElement")
	AnomalyElement.Name = sName or AnomalyElement.Name
	AnomalyElement.AnomalyInit = fnAnomalyInit or AnomalyElement.AnomalyInit
	AnomalyElement.AnomalyThink = fnAnomalyThink or AnomalyElement.AnomalyThink
	AnomalyElement.AnomalyDraw = fnAnomalyDraw or AnomalyElement.AnomalyDraw

	self.elements[sName] = AnomalyElement
end

--[[
	Function: GetElement
	Purpose: Gets an element based off the keyname provided
--]]

function rain:GetElement(sName)
	return self.elements[sName]
end

--[[
	Function: GetAnomaly
	Purpose: Returns the anomaly struct indicated by the key
--]]

function rain:GetAnomaly(sName)
	return self.anomalies[sName]
end

--[[
	Function: SpawnAnomaly
	Purpose: Spawns an Anomaly at a given position, second argument is the anomaly type, third is the strength
--]]

function rain:SpawnAnomaly(vPos, sAnomalyType)
	local sAnomalyType = sAnomalyType or "ERROR"
	local pos = vPos or Vector(0,0,0)
	local anomaly = self.anomalies[sAnomalyType]

	local anom = ents.Create("cc_anomaly")
	anom:SetPos(pos)
	anom:SetAnomaly(anomaly)
	anom:Spawn()
end

--[[
	Function: Reload Anomalies
	Purpose: Called every time the gamemode is reloaded to make sure the anomalies have changes applied to them.
--]]

function rain:ReloadAnomalies()
	for k, v in pairs(ents.FindByClass("cc_anomaly")) do
		v:Reload()
	end
end

--[[
	Anything past this point is implementation of anomaly types
--]]

--rain:RegisterElement("TestElement")
--rain:RegisterAnomaly("TestAnomaly", {"TestElement"})

-- This metatable modification is required for one of the anomaly elements
local eMeta = FindMetaTable("Entity")
function eMeta:KeyValueTable(tbl)
	for k,v in pairs(tbl) do
		self:SetKeyValue(k,v)
	end
end


local function BeadInit(ent)
	if (CLIENT) then
		ent.Timer = 0
		ent.Emitter = ParticleEmitter( ent.Entity:GetPos() )
	elseif (SERVER) then
		ent.Pain = { Sound( "ambient/atmosphere/thunder1.wav" ), 
		Sound( "ambient/atmosphere/thunder2.wav" ), 
		Sound( "ambient/atmosphere/thunder3.wav" ), 
		Sound( "ambient/atmosphere/thunder4.wav" ),
		Sound( "ambient/atmosphere/terrain_rumble1.wav" ),
		Sound( "ambient/atmosphere/hole_hit4.wav" ),
		Sound( "ambient/atmosphere/cave_hit5.wav" ) }
		
		ent.Rape = Sound( "npc/strider/striderx_alert5.wav" )
		ent.Die = Sound( "NPC_Strider.OpenHatch" )
		ent.Cook = Sound( "ambient.whoosh_large_incoming1" )
		ent.Distance = 700

		ent.Entity:SetModel( "models/props_phx/misc/smallcannonball.mdl" )
		
		ent.Entity:PhysicsInit( SOLID_VPHYSICS )
		ent.Entity:SetMoveType( MOVETYPE_VPHYSICS )
		ent.Entity:SetSolid( SOLID_VPHYSICS )

		local phys = ent.Entity:GetPhysicsObject()
		
		if IsValid( phys ) then
		
			phys:Wake()
			phys:SetMaterial( "rainod_silent" )
	
		end
		
		ent:SetNoDraw(true)

		ent.SpawnPos = ent:GetPos()

		ent.Entity:StartMotionController()
		
		ent.Entity:EmitSound( ent.Rape )
		
		ent.SoundTime = 0
		ent.ExplodeTime = CurTime() + math.random( 5, 15 )

		function ent:PhysicsSimulate( phys, delta )
		
			phys:Wake()
		
			local trace = {}
			trace.start = self.Entity:GetPos()
			trace.endpos = trace.start + Vector(0,0,-9000)
			trace.filter = self.Entity
			
			local tr = util.TraceLine( trace )
			
			local pos = tr.HitPos + tr.HitNormal * ( 150 + math.sin( CurTime() * 3 ) * 100 )
			
			phys:ApplyForceCenter( ( pos - self.Entity:GetPos() ):GetNormal() * phys:GetMass() * 50 )
			
		end
	end
end

local function BeadThink(ent)
	if (CLIENT) then
		if ent.Timer < CurTime() then
		
			ent.Timer = CurTime() + math.Rand( 0.1, 2.5 )
		
			local dlight = DynamicLight( ent.Entity:EntIndex() )
		
			if dlight then
				dlight.Pos = ent.Entity:LocalToWorld( ent.Entity:OBBCenter() ) + VectorRand() * 10
				dlight.r = 50
				dlight.g = 50
				dlight.b = 50
				dlight.Brightness = 1
				dlight.Decay = 2048
				dlight.size = 512
				dlight.DieTime = CurTime() + 0.5
			end
		end
		
		local particle = ent.Emitter:Add( "sprites/light_glow02_add", ent.Entity:LocalToWorld( ent.Entity:OBBCenter() ) + VectorRand() * 5 )
 		particle:SetVelocity( Vector(0,0,-50) ) 
 		particle:SetLifeTime( 0 )  
 		particle:SetDieTime( math.Rand( 0.50, 0.75 ) ) 
 		particle:SetStartAlpha( 50 ) 
 		particle:SetEndAlpha( 0 ) 
 		particle:SetStartSize( math.random( 4, 8 ) ) 
 		particle:SetEndSize( 0 ) 
 		particle:SetColor( 255, 255, 255 )
		particle:SetAirResistance( 10 )
	elseif (SERVER) then
		if (ent.ExplodeTime and ent.ExplodeTime < CurTime()) then
				for k,v in pairs( player.GetAll() ) do
					if IsValid( v ) and v:Alive() and ent.Entity:GetPos():Distance( v:GetPos() ) < ent.Distance then
						local scale = 1 - math.Clamp( ent.Entity:GetPos():Distance( v:GetPos() ) / ent.Distance, 0, 1 ) 
						util.ScreenShake( v:GetPos(), scale * 25, scale * 25, 2, 100 )
						v:TakeDamage( 100 * scale, ent.Entity )
						if scale > 0.5 then
							v:EmitSound( ent.Cook )
							v:Kill()
						end
					end
				end
			
				local ed = EffectData()
				ed:SetOrigin( ent.Entity:GetPos() )
				util.Effect( "bead_explode", ed, true, true )
				
				ent.Entity:EmitSound( ent.Die )

			ent.ExplodeTime = CurTime() + math.random( 5, 15 )
			ent:ARespawn()

		end
		if (ent.SoundTime < CurTime()) then
			ent.SoundTime = CurTime() + math.Rand( 0.5, 1.5 )
			ent.Entity:EmitSound( table.Random( ent.Pain ), 100, math.random( 200, 220 ) )
		end
	end
end

local function BeadDraw(ent)
	if (CLIENT) then
		ent.Entity:DrawModel()
	end
end

rain:RegisterAnomaly("Bead", {"EBead"})
rain:RegisterElement("EBead", BeadInit, BeadThink, BeadDraw)

local function BigVortexInit(self)
	self.PreSuck = Sound( "ambient/levels/labs/teleport_mechanism_windup5.wav" )
	self.SuckExplode = Sound( "weapons/mortar/mortar_explode2.wav" )
	self.SuckBang = Sound( "ambient/levels/labs/teleport_postblast_thunder1.wav" )
	
	self.WaitTime = 3
	self.SuckTime = 6
	self.SuckRadius = 3500
	self.KillRadius = 750

	self.NPCs = { "npc_zombie_fast", "npc_zombie_poison", "npc_zombie_normal", "npc_rogue" }

	if (CLIENT) then
		self.Emitter = ParticleEmitter( self.Entity:GetPos() )
		self.VortexPos = self.Entity:GetPos() + Vector( 0, 0, 2000 )
		self.Alpha = 0
		self.Timer = 0
		self.DustTimer = 0
		self.Fraction = 0
		self.Size = 3500
	
		self.Entity:SetRenderBounds( Vector() * -6000, Vector() * 6000 )

	else
		function self:Touch( ent ) 
			if self.SetOff then return end
			if not IsValid( ent ) then return end
			if ent:IsPlayer() and not ent:Alive() then return end
			if ent:IsPlayer() or string.find( ent:GetClass(), "npc" ) or string.find( ent:GetClass(), "prop_phys" ) then
			
				self.SetOff = CurTime() + self.WaitTime
				
				self.Entity:EmitSound( self.PreSuck )
				self.Entity:SetNWBool( "Suck", true )
			end
		end 

		self.Entity:SetMoveType( MOVETYPE_NONE )
		self.Entity:SetSolid( SOLID_NONE )
		

		self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
		self.Entity:SetTrigger( true )
		self.Entity:SetNotSolid( true )
		self.Entity:DrawShadow( false )	
			
		self.Entity:SetCollisionBounds( Vector( -4800, -4800, -4800 ), Vector( 4800, 4800, 4800 ) )
		self.Entity:PhysicsInitBox( Vector( -4800, -4800, -4800 ), Vector( 4800, 4800, 4800 ) )
		
		self.VortexPos = self.Entity:GetPos() + Vector( 0, 0, 2000 )
		self.NextVortexThink = 0
	end
end

local function BigVortexThink(self)
	if (CLIENT) then
			if self.DustTimer < CurTime() then
	
			self.DustTimer = CurTime() + 0.1
		
			local vec = VectorRand()
			vec.z = -0.1
		
			local newpos = self.Entity:GetPos() + vec * 2000
		
			local particle = self.Emitter:Add( "effects/fleck_cement" .. math.random(1,2), newpos )
			particle:SetVelocity( Vector( 0, 0, math.random( 50, 200 ) ) )
			particle:SetDieTime( 8.0 )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 255 )
			particle:SetStartSize( math.Rand( 5, 10 ) )
			particle:SetEndSize( 1 )
			particle:SetRoll( math.random( -360, 360 ) )
			particle:SetColor( 100, 100, 100 )
			particle:SetAirResistance( math.random( 0, 15 ) )
			particle:SetThinkFunction( DustThink )
			particle:SetNextThink( CurTime() + 0.1 )
			particle.VortexPos = self.VortexPos
		end
		
		if self.Entity:GetNWBool( "Suck", false ) and self.Timer < CurTime() then
			self.Timer = CurTime() + 8
			self.RagTimer = CurTime() + 1
		end	
	
		if self.Timer > CurTime() and self.RagTimer < CurTime() then
		
			self.RagTimer = CurTime() + 0.2
			local tbl = ents.FindByClass( "class C_HL2MPRagdoll" )
			tbl = table.Add( tbl, ents.FindByClass( "class C_ClientRagdoll" ) )
		
			for k, v in pairs ( tbl ) do
				if v:GetPos():Distance( self.VortexPos ) < 3000 then
				
					local phys = v:GetPhysicsObject()
					
					if IsValid( phys ) then
						local vel = ( self.VortexPos - v:GetPos() ):GetNormal()
						local scale = math.Clamp( ( 3000 - v:GetPos():Distance( self.VortexPos ) ) / 3000, 0.6, 1.0 )
						
						phys:ApplyForceCenter( vel * ( scale * phys:GetMass() * 50000 ) )
					end
					
					if self.Timer - CurTime() < 0.2 and v:GetPos():Distance( self.VortexPos ) < 700 and v:GetClass() != "class C_HL2MPRagdoll" then
						v:Remove()
					end
				end
			end
		end
	end

	if (SERVER) then
		if self.SetOff and self.SetOff < CurTime() and not self.VortexTime then
			self.VortexTime = CurTime() + self.SuckTime
			self.Entity:SetNWBool( "Suck", false )
		end

		if self.VortexTime and self.VortexTime > CurTime() and self.NextVortexThink < CurTime() then
			
			self.NextVortexThink = CurTime() + 0.2
		
			local tbl = ents.FindByClass( "prop_phys*" )
			tbl = table.Add( tbl, ents.FindByClass( "prop_veh*" ) )
			tbl = table.Add( tbl, ents.FindByClass( "npc*" ) )
			tbl = table.Add( tbl, ents.FindByClass( "sent_lootbag" ) )
			tbl = table.Add( tbl, player.GetAll() )
			
			for k,v in pairs( tbl ) do
				if v:GetPos():Distance( self.Entity:GetPos() ) < self.SuckRadius then
					local vel = ( self.VortexPos - v:GetPos() ):GetNormal()
					if ( v:IsPlayer() and v:Alive() ) or table.HasValue( self.NPCs, v:GetClass() ) then
						local scale = math.Clamp( ( self.SuckRadius - v:GetPos():Distance( self.VortexPos ) ) / self.SuckRadius, 0.25, 1.00 )
						if v:GetPos():Distance( self.VortexPos ) > self.KillRadius then
							v:SetVelocity( vel * ( scale * 700 ) )
						else
							if ( v:IsPlayer() and v:Alive() ) then
								v:Kill() 
							elseif table.HasValue( self.NPCs, v:GetClass() ) then
								v:DoDeath()
							end
						end
					else
						if v:GetPos():Distance( self.VortexPos ) > self.KillRadius / 2 then
							local phys = v:GetPhysicsObject()
							if IsValid( phys ) then
								phys:ApplyForceCenter( vel * ( phys:GetMass() * 500 ) )
							end
						elseif not v:IsPlayer() then
							v:Remove()
						end
					end
				end
			end
		elseif self.VortexTime and self.VortexTime < CurTime() then
		
			self.VortexTime = nil
			self.SetOff = nil
			self.Entity:EmitSound( self.SuckExplode, 500, math.random(100,120) )
			self.Entity:EmitSound( self.SuckBang, 500, math.random(120,140) )
			
			local ed = EffectData()
			ed:SetOrigin( self.VortexPos )
			util.Effect( "vortex_bigexplode", ed, true, true )
			
			local tbl = ents.FindByClass( "prop_phys*" )
			tbl = table.Add( tbl, ents.FindByClass( "prop_veh*" ) )
			tbl = table.Add( tbl, ents.FindByClass( "npc*" ) )
			tbl = table.Add( tbl, ents.FindByClass( "sent_lootbag" ) )
			tbl = table.Add( tbl, player.GetAll() )
			
			for k,v in pairs( tbl ) do
				if v:GetPos():Distance( self.VortexPos ) < self.KillRadius then
					if v:IsPlayer() then
						if v:Alive() then
							//v.Inventory = {}
							v:SetModel( "models/shells/shell_9mm.mdl" )
							v:Kill()
						end
					else
						v:Remove()
					end
				end
			end
			self.SetOff = false
		end
		self.Entity:NextThink( CurTime() )
	end
end

function DustThink( part )

	local dir = ( part.VortexPos - part:GetPos() ):GetNormal()
	local scale = math.Clamp( part.VortexPos:Distance( part:GetPos() ), 0, 500 ) / 500
	
	if scale < 0.1 and not part.Scale then
		part.Scale = math.Rand( 0.8, 1.2 )
	end
	
	if part.Scale then
		scale = part.Scale
	end
	
	part:SetNextThink( CurTime() + 0.1 )
	part:SetGravity( dir * ( scale * 500 ) )

end

local matRefract = Material( "effects/strider_bulge_dudv" )
local matGlow = Material( "effects/strider_muzzle" )

local function BigVortexDraw(self)
	local mypos = self:GetPos()
	local dist = LocalPlayer():GetPos():Distance(mypos)
	
	if(dist < 3000) then
		if self.Timer < CurTime() then
			self.Fraction = math.Approach( self.Fraction, 0.05 + math.sin( CurTime() * 0.5 ) * 0.02, 0.01 )
		else
			self.Fraction =  math.Approach( self.Fraction, ( 1 - ( self.Timer - CurTime() ) / 8 ) * 0.30, 0.01 )
			self.Alpha = ( 1 - ( self.Timer - CurTime() ) / 8 ) * 100
			
			render.SetMaterial( matGlow )
			render.DrawSprite( self.VortexPos, self.Size * 0.4 + math.sin( CurTime() ) * 500, self.Size * 0.4 + math.sin( CurTime() ) * 500, Color( 200, 200, 255, self.Alpha ) )
		end
		
		matRefract:SetFloat( "$refractamount", self.Fraction )

		if render.GetDXLevel() >= 80 then
				
			render.UpdateRefractTexture()
			render.SetMaterial( matRefract )
			render.DrawQuadEasy( self.VortexPos,
						 ( EyePos() - self.VortexPos ):GetNormal(),
						 self.Size + math.sin( CurTime() ) * 500, self.Size + math.sin( CurTime() ) * 500,
						 Color( 255, 255, 255, 255 ) )
		end
	end
end

rain:RegisterAnomaly("BigVortex", {"EBigVortex"})
rain:RegisterElement("EBigVortex", BigVortexInit, BigVortexThink, BigVortexDraw)

local function BubbleInit(self)
	self.Damage = 80
	self.Blast = Sound( "physics/nearmiss/whoosh_huge2.wav" )
	self.Blast2 = Sound( "ambient/levels/citadel/portal_beam_shoot5.wav" )

	if (CLIENT) then
		self.Emitter = ParticleEmitter( self.Entity:GetPos() )
		self.Fraction = 0
		self.Size = 80
	else
		self.Entity:SetMoveType( MOVETYPE_NONE )
		self.Entity:SetSolid( SOLID_NONE )
		
		self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
		self.Entity:SetTrigger( true )
		self.Entity:SetNotSolid( true )
		self.Entity:DrawShadow( false )	
			
		self.Entity:SetPos(Vector(self.Entity:GetPos().x, self.Entity:GetPos().y, self.Entity:GetPos().z + 64))

		self.Entity:SetCollisionBounds( Vector( -50, -50, -50 ), Vector( 50, 50, 50 ) )
		self.Entity:PhysicsInitBox( Vector( -50, -50, -50 ), Vector( 50, 50, 50 ) )
			
		self.LastHit = 0

		function self:Touch( ent ) 
		
			if self.LastHit > CurTime() then 
				return 
			end
			
			self.LastHit = CurTime() + 2
			self.BounceTime = CurTime() + 0.5
			
			self.Entity:EmitSound( self.Blast, 150, 150 )
		end 
	end
end

local function BubbleThink(self)
	if (SERVER) then
		if self.BounceTime and self.BounceTime < CurTime() then
		
			self.BounceTime = nil
			
			local tbl = player.GetAll()
			tbl = table.Add( tbl, ents.FindByClass( "prop_phys*" ) ) 
			tbl = table.Add( tbl, ents.FindByClass( "prop_veh*" ) )
			tbl = table.Add( tbl, ents.FindByClass( "npc*" ) )
			
			local ed = EffectData()
			ed:SetOrigin( self.Entity:GetPos() + Vector( 0, 0, 5 ) )
			util.Effect( "dust_burst", ed, true, true )
			
			self.Entity:EmitSound( self.Blast2, 100, 70 )
			
			for k, ent in pairs( tbl ) do
				if ent:GetPos():Distance( self.Entity:GetPos() ) < 100 then
					if ent:IsPlayer() then
						local dir = ( ent:GetPos() - self.Entity:GetPos()  ):GetNormal()
						
						ent:SetVelocity( dir * 2000 )
						ent:TakeDamage( self.Damage )
					
					elseif string.find( ent:GetClass(), "npc" ) then
					
						ent:TakeDamage( self.Damage )
						
					elseif string.find( ent:GetClass(), "prop" ) then
					
						local phys = ent:GetPhysicsObject()
						
						if IsValid( phys ) then
							local dir = ( self.Entity:GetPos() - ent:GetPos() ):GetNormal()
							phys:ApplyForceCenter( dir * phys:GetMass() * 500 )
						end
					end
				end
			end
		end
	end
end

local matRefract = Material( "effects/strider_pinch_dudv" )

local function BubbleDraw(self)
	local mypos = self:GetPos()
	local dist = LocalPlayer():GetPos():Distance(mypos)
	
	if(dist < 2000) then

		self.Fraction = 0.15 + math.sin( CurTime() ) * 0.15

		matRefract:SetFloat( "$refractamount", self.Fraction )

		if render.GetDXLevel() >= 80 then
			
			render.UpdateRefractTexture()
			render.SetMaterial( matRefract )
			render.DrawQuadEasy( self.Entity:GetPos() + Vector(0,0,5),
						 ( EyePos() - self.Entity:GetPos() ):GetNormal(),
						 self.Size + math.sin( CurTime() ) * 10, self.Size + math.sin( CurTime() ) * 10,
						 Color( 255, 255, 255, 255 ) )
			
		end
	end
end

rain:RegisterAnomaly("Bubble", {"EBubble"})
rain:RegisterElement("EBubble", BubbleInit, BubbleThink, BubbleDraw)

local function BurnerInit(self)
	self.Damage = 12
	self.Blast = Sound( "hgn/stalker/anom/burner_blow.mp3" )
	self.Death = Sound( "ambient/fire/mtov_flame2.wav" )
	self.Burn = Sound( "Fire.Plasma" )

	if (SERVER) then
		self.Entity:SetMoveType( MOVETYPE_NONE )
		self.Entity:SetSolid( SOLID_NONE )
		
		self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
		self.Entity:SetTrigger( true )
		self.Entity:SetNotSolid( true )
		self.Entity:DrawShadow( false )	
		
		self.Entity:SetCollisionBounds( Vector( -100, -100, -100 ), Vector( 100, 100, 100 ) )
		self.Entity:PhysicsInitBox( Vector( -100, -100, -100 ), Vector( 100, 100, 100 ) )
		
		self.BurnTime = 0

		function self:Touch( ent ) 
				
			if self.BurnTime != nil then
				if self.BurnTime >= CurTime() then 
					return 
				end
			end
			
			self.BurnTime = CurTime() + 10
			
			self.Entity:SetNWBool( "Burn", true )
			
			self.Entity:EmitSound( self.Blast, 150, 100 )
			self.Entity:EmitSound( self.Burn, 100, 100 )
		end 
		
		function self:UpdateTransmitState()
		
			return TRANSMIT_ALWAYS 
		end
	else
		local trace = {}
		trace.start = self.Entity:GetPos()
		trace.endpos = trace.start + Vector( 0, 0, -500 )
		trace.filter = self.Entity
		local tr = util.TraceLine( trace )
		
		self.Normal = tr.HitNormal
		self.Timer = 0
		self.BurnTime = 0
		self.Size = 50
		self.Emitter = ParticleEmitter( self.Entity:GetPos() )
	end
end

local function BurnerThink(self)
	if (SERVER) then
		if self.BurnTime and self.BurnTime >= CurTime() then
			local tbl = player.GetAll()
			tbl = table.Add( tbl, ents.FindByClass( "npc*" ) )
			
			for k,ent in pairs( tbl ) do
				if ent:GetPos():Distance( self.Entity:GetPos() ) < 150 then
					if ent:IsPlayer() then
						local dmg = DamageInfo()
						dmg:SetDamage( self.Damage )
						dmg:SetDamageType( DMG_ACID )
						dmg:SetAttacker( self.Entity )
						dmg:SetInflictor( self.Entity )
						
						ent:TakeDamageInfo( dmg )
					elseif string.find( ent:GetClass(), "npc" ) then
						ent:TakeDamage( self.Damage )
					end
				end
			end

		elseif self.BurnTime and self.BurnTime < CurTime() then
		
			self.BurnTime = nil
			
			self.Entity:StopSound( self.Burn )
			self.Entity:EmitSound( self.Death, 150, 100 )
			
			self.Entity:SetNWBool( "Burn", false )
		end
	else
		if self.Entity:GetNWBool( "Burn", false ) and self.BurnTime < CurTime() then
			
			self.BurnTime = CurTime() + 11
		
		end
		
		local mypos = self:GetPos()
		local dist = LocalPlayer():GetPos():Distance(mypos)
		
		if(dist < 5000) then
		
			if self.Timer < CurTime() then
	
				local particle = self.Emitter:Add( "sprites/heatwave", self.Entity:GetPos() + VectorRand() * 10 )
				particle:SetVelocity( self.Normal * 50 + VectorRand() * 5 + Vector(0,0,20) ) 
				particle:SetLifeTime( 0 )  
				particle:SetDieTime( math.Rand( 1.0, 1.5 ) ) 
				particle:SetStartAlpha( 255 ) 
				particle:SetEndAlpha( 255 ) 
				particle:SetStartSize( math.random( 20, 40 ) ) 
				particle:SetEndSize( 0 ) 
				particle:SetColor( 255, 255, 255 )
				particle:SetAirResistance( 50 )
				particle:SetGravity( Vector( 0, 0, 100 ) )
				
				if math.random(1,10) == 1 then
				
					local particle = self.Emitter:Add( "effects/fire_embers"..math.random(1,3), self.Entity:GetPos() + VectorRand() * 10 )
					particle:SetVelocity( self.Normal * 50 + VectorRand() * 10 + Vector(0,0,20) ) 
					particle:SetLifeTime( 0 )  
					particle:SetDieTime( math.Rand( 1.0, 2.0 ) ) 
					particle:SetStartAlpha( 255 ) 
					particle:SetEndAlpha( 255 ) 
					particle:SetStartSize( math.random( 3, 5 ) ) 
					particle:SetEndSize( 0 ) 
					particle:SetColor( 0, 0, 255 )
					particle:SetAirResistance( 50 )
					particle:SetGravity( Vector( 0, 0, 100 ) )
					
				end
				
				self.Timer = CurTime() + 0.5
	
			end
			
			if self.BurnTime > CurTime() then
			
				local particle = self.Emitter:Add( "effects/muzzleflash"..math.random(1,4), self.Entity:GetPos() + self.Normal * -5 )
				particle:SetVelocity( self.Normal * 150 + VectorRand() * 30 ) 
				particle:SetLifeTime( 0 )  
				particle:SetDieTime( math.Rand( 0.5, 1.0 ) ) 
				particle:SetStartAlpha( 255 ) 
				particle:SetEndAlpha( 0 ) 
				particle:SetStartSize( math.random( 10, 20 ) ) 
				particle:SetEndSize( math.random( 30, 40 ) ) 
				particle:SetColor( math.random(0,30), 0, 255 )
				particle:SetRoll( math.Rand( -360, 360 ) )
				particle:SetRollDelta( math.Rand( -5, 5 ) )
				particle:SetAirResistance( 0 )
				particle:SetGravity( Vector( 0, 0, 150 ) )
				
				local particle = self.Emitter:Add( "effects/muzzleflash"..math.random(1,4), self.Entity:GetPos() + self.Normal * 5 )
				particle:SetVelocity( self.Normal * 20 ) 
				particle:SetLifeTime( 0 )  
				particle:SetDieTime( math.Rand( 0.5, 1.0 ) ) 
				particle:SetStartAlpha( 200 ) 
				particle:SetEndAlpha( 0 ) 
				particle:SetStartSize( math.random( 5, 10 ) ) 
				particle:SetEndSize( math.random( 5, 10 ) ) 
				particle:SetColor( 200, 200, 255 )
				particle:SetRoll( math.Rand( -360, 360 ) )
				particle:SetRollDelta( math.Rand( -5, 5 ) )
				particle:SetAirResistance( 0 )
				particle:SetGravity( Vector( 0, 0, 20 ) )
				
			end
		end
	end
end	

local matBurner = Material( "sprites/heatwave" )

local function BurnerDraw(self)

	local mypos = self:GetPos()
	local dist = LocalPlayer():GetPos():Distance(mypos)
	
	if(dist < 5000) then

		if render.GetDXLevel() >= 80 then
			
			render.UpdateRefractTexture()
			render.SetMaterial( matBurner )
			render.DrawQuadEasy( self.Entity:GetPos(),
						 ( EyePos() - self.Entity:GetPos() ):GetNormal(),
						 self.Size + math.sin( CurTime() ) * 10, self.Size + math.sin( CurTime() ) * 10,
						 Color( 255, 255, 255, 255 ) )
		end
	end
end

rain:RegisterAnomaly("Burner", {"EBurner"})
rain:RegisterElement("EBurner", BurnerInit, BurnerThink, BurnerDraw)

local function DamageInit(self)
	self.BaseScale = 100
	self.PulseMultiplier = 70

	self.Damage = {}
	self.Damage.Radius = self.BaseScale*2
	self.Damage.BaseDamage = 20
	self.Damage.DamageType = 0
	self.Damage.Delay = 0.2
	self.Damage.RadInt = 0.2
	self.Damage.RadInc = 1
	self.Damage.NextRad = 0
	
	self.Warning = {}
	self.Warning.Sound = {"player/geiger1.wav","player/geiger2.wav","player/geiger3.wav"}
	self.Warning.NextTick = 0
	self.Warning.TickDelay = 0.1
	self.Warning.Radius = self.BaseScale*3

	if (SERVER) then
		self.model = "models/Gibs/HGIBS_spine.mdl"
		self.Entity:SetModel( self.model ) 
 		
		self.Entity:SetMoveType( MOVETYPE_NONE )
		self.Entity:SetSolid( SOLID_NONE )
	
		local phys = self.Entity:GetPhysicsObject()
	
		if (phys:IsValid()) then
			phys:Wake()
			phys:SetMass(10000)
		end

		function self:CreateSprite(color,size,alpha)
			local pos = self.Entity:GetPos()
			
			local sprite = ents.Create("env_sprite")
			sprite:SetPos(pos)
			local kv = {
				model="",
				scale=size,
				rendermode=5,
				renderamt=alpha,
				rendercolor=color,
			}
			sprite:KeyValueTable(kv);
			sprite:Spawn()
			sprite:Activate()
			sprite:SetParent(self.Entity)
		end
		
		function self:CreatePointHurt()
			local hurt = ents.Create("point_hurt")
			hurt:SetPos(self.Entity:GetPos())
			local kvs = {
				DamageRadius = self.Damage.Radius,
				Damage = self.Damage.BaseDamage,
				DamageDelay = self.Damage.Delay,
				DamageType = self.Damage.DamageType
			}
			hurt:KeyValueTable(kvs)
			hurt:Spawn()
			hurt:SetParent(self.Entity)
			hurt:Fire("turnon","",0)
		end

		self.Entity:DrawShadow(false)
		self:CreatePointHurt()
		self:CreateSprite("220 0 0",0.5,200)

		function self:KeyValue(key,value)
			self[key] = tonumber(value) or value
		end

	end
end 

local function DamageThink(self)
	if (SERVER) then
		local all = player.GetAll()
		local ePos = self.Entity:GetPos()
		for k,user in pairs(all) do
			local uPos = user:GetPos()
			local dist = (ePos-uPos):Length()
			if dist < self.Warning.Radius then
				if CurTime() > self.Warning.NextTick then
					local ran = math.random(1,table.getn(self.Warning.Sound))
					user:EmitSound(self.Warning.Sound[ran])
					self.Warning.NextTick = CurTime()+self.Warning.TickDelay
				end
			end
		end
		if CurTime() > self.Damage.NextRad then
			self.Damage.NextRad = CurTime()+self.Damage.RadInt
			for k,user in pairs(all) do
				local uPos = user:GetPos()
				local dist = (ePos-uPos):Length()
			end
		end
	end
end

local Heatwave = Material("effects/strider_bulge_dudv")

local function DamageDraw(self)
	local mypos = self:GetPos()
	local dist = LocalPlayer():GetPos():Distance(mypos)
	
	if(dist < 5000) then

		local pulse = math.sin(CurTime())*self.PulseMultiplier
		local Size = self.BaseScale+pulse

		if Size < 0 then
			Size = 0.01
		end
		
		render.UpdateScreenEffectTexture()
		
		render.SetMaterial(Heatwave)
		
		if (render.GetDXLevel() >= 90) then
			render.DrawSprite(self.Entity:GetPos(), Size, Size, Color(255, 0, 0, 25))
		end
	end
end

rain:RegisterAnomaly("Damage", {"EDamage"})
rain:RegisterElement("EDamage", DamageInit, DamageThink, DamageDraw)

local function DeathFogInit(self)
	self.Awaken = Sound( "ambient/atmosphere/cave_hit5.wav" )
	
	self.Coughs = { "ambient/voices/cough1.wav",
	"ambient/voices/cough2.wav",
	"ambient/voices/cough3.wav",
	"ambient/voices/cough4.wav",
	"ambient/voices/citizen_beaten3.wav",
	"ambient/voices/citizen_beaten4.wav" }
	
	self.WaitTime = 5
	self.KillRadius = 2000
	self.Damage = 2

	if (CLIENT) then
		self.Emitter = ParticleEmitter( self.Entity:GetPos() )
		self.Timer = CurTime() + 3
		self.DustTimer = 0
		self.Distance = 2500
		self.SpawnTable = {}
		
		local trace = {}
		trace.start = self.Entity:GetPos()
		trace.endpos = trace.start + Vector(2500,2500,0)
		local tr = util.TraceLine( trace )
		
		self.Left = trace.start + Vector(2500,2500,0)
		
		if tr.Hit then
		
			self.Left = tr.HitPos
		
		end
		
		trace = {}
		trace.start = self.Entity:GetPos()
		trace.endpos = trace.start + Vector(-2500,-2500,0)
		tr = util.TraceLine( trace )
		
		self.Right = trace.start + Vector(-2500,-2500,0)
		
		if tr.Hit then
		
			self.Right = tr.HitPos
		
		end
	else
		self.Entity:SetMoveType( MOVETYPE_NONE )
		self.Entity:SetSolid( SOLID_NONE )
		
		self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
		self.Entity:SetTrigger( true )
		self.Entity:SetNotSolid( true )
		self.Entity:DrawShadow( false )	
		
		self.Entity:EmitSound( self.Awaken, 500, 80 )
		
		self.Timer = CurTime() + self.WaitTime
		self.KillTime = CurTime() + 60
		self.DamageTimer = 0
		
		local trace = {}
		trace.start = self.Entity:GetPos()
		trace.endpos = trace.start + Vector(2500,2500,0)
		local tr = util.TraceLine( trace )
		
		self.Left = trace.start + Vector(2500,2500,0)
		
		if tr.Hit then
			self.Left = tr.HitPos
		end
		
		trace = {}
		trace.start = self.Entity:GetPos()
		trace.endpos = trace.start + Vector(-2500,-2500,0)
		tr = util.TraceLine( trace )
		
		self.Right = trace.start + Vector(-2500,-2500,0)
		
		if tr.Hit then
			self.Right = tr.HitPos
		end
	end
end

local function DeathFogThink(self)
	if (CLIENT) then
		if self.Timer > CurTime() then 
			return 
		end
		
		local mypos = self:GetPos()
		local dist = LocalPlayer():GetPos():Distance(mypos)
		
		if(dist < 3000) then
		
			if self.DustTimer < CurTime() then
			
				self.DustTimer = CurTime() + 0.1
			
				local vec = Vector( math.random( self.Right.x, self.Left.x ), math.random( self.Right.y, self.Left.y ), self.Entity:GetPos().z )
				
				local trace = {}
				trace.start = Vector( math.random( self.Right.x, self.Left.x ), math.random( self.Right.y, self.Left.y ), self.Entity:GetPos().z )
				trace.endpos = Vector( math.random( self.Right.x, self.Left.x ), math.random( self.Right.y, self.Left.y ), self.Entity:GetPos().z - 9000 )
				trace.filter = self.Entity
				
				local tr = util.TraceLine( trace )
				
				local roll = math.random( -360, 360 )
			
				local particle = self.Emitter:Add( "particle/particle_smokegrenade", tr.HitPos )
				particle:SetDieTime( 10 )
				particle:SetStartAlpha( 0 )
				particle:SetEndAlpha( 150 )
				particle:SetStartSize( math.random( 400, 800 ) )
				particle:SetEndSize( 600 )
				particle:SetRoll( roll )
				particle:SetColor( 150, 150, 100 )
				
				table.insert( self.SpawnTable, { CurTime() + 10, tr.HitPos, roll } )
			
			end
			
			for k,v in pairs( self.SpawnTable ) do
			
				if v[1] <= CurTime() then
				
					local particle = self.Emitter:Add( "particle/particle_smokegrenade", v[2] )
					particle:SetVelocity( Vector( 0, 0, math.random( -10, 10 ) ) )
					particle:SetDieTime( 10 )
					particle:SetStartAlpha( 150 )
					particle:SetEndAlpha( 0 )
					particle:SetStartSize( 600 )
					particle:SetEndSize( math.random( 400, 800 ) )
					particle:SetRoll( v[3] )
					particle:SetColor( 150, 150, 100 )
					
					table.remove( self.SpawnTable, k )
					
					break
				end
			end
		end	
	else
		if self.Timer > CurTime() then 
			return 
		end

		for k,v in pairs( player.GetAll() ) do
			local pos = v:GetPos()
			pos.z = self.Entity:GetPos().z
			if pos:Distance( self.Entity:GetPos() ) < self.KillRadius then
				for i=1,3 do
					local vec = Vector( math.random( self.Right.x, self.Left.x ), math.random( self.Right.y, self.Left.y ), self.Entity:GetPos().z )
					local trace = {}
					trace.start = vec
					trace.endpos = v:GetPos() + Vector(0,0,30)
					trace.filter = self.Entity
					
					local tr = util.TraceLine( trace )
					
					if tr.Entity == v then//and not v:HasItem( "models/items/combine_rifle_cartridge01.mdl" ) then
						v.CoughTimer = v.CoughTimer or 0
						if v.CoughTimer < CurTime() then
							v:EmitSound( table.Random( self.Coughs ) )
							v.CoughTimer = CurTime() + math.Rand( 1.5, 3.0 )
						end
						
						if self.DamageTimer < CurTime() then
							local dmg = DamageInfo()
							dmg:SetDamage( self.Damage )
							dmg:SetDamageType( DMG_POISON )
							dmg:SetAttacker( self.Entity )
							dmg:SetInflictor( self.Entity )
							v:TakeDamageInfo( dmg )
						end
					end

				end
			end
		end
			
		if self.DamageTimer < CurTime() then
			self.DamageTimer = CurTime() + 3
		end
	end
end

rain:RegisterAnomaly("DeathFog", {"EDeathFog"})
rain:RegisterElement("EDeathFog", DeathFogInit, DeathFogThink)

local function EvadeInit(self)
	if (SERVER) then
		self.Entity:SetModel( "models/props_junk/watermelon01.mdl" ) --Set its model.
		self.Entity:SetMoveType( MOVETYPE_NONE )   -- after all, rainod is a physics
		self.Entity:SetSolid( SOLID_NONE ) 	-- Toolbox
		self.Entity:SetKeyValue("rendercolor", "150 255 150") 
		self.Entity:SetKeyValue("renderamt", "0") 
		self.Entity:SetMaterial("models/props_combine/portalball001_sheet")
		self:MakeSprite( self.Entity, "15", "100 100 100", "sprites/glow1.vmt", "10", "255")
		self:MakeSprite( self.Entity, "23", "250 250 250", "sprites/glow1.vmt", "5", "150")
	        local phys = self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end

		self:DrawShadow(false)
	end
end

local function EvadeThink(self)
	if (SERVER) then
	    for k, v in pairs( ents.FindInSphere( self.Entity:GetPos(), 400 )  ) do	
				--If it is a valid entity and nearby		
			if v:GetClass() != "anom_physicspush" then -- if the entity isnt a anom_physicspush
				if( v:IsValid() and v:GetPhysicsObject():IsValid() and v:GetPos( ):Distance( self:GetPos( ) ) <= 300 ) then
				
					local dir = self:GetPos() - v:GetPos()
					local force = 35					
					local newForce = -1 * dir * force 
					v:GetPhysicsObject():SetVelocity( newForce )
							
				end
			
				if( v:IsPlayer() and v:IsValid() and v:GetPos( ):Distance( self:GetPos( ) ) <= 350 ) then
					local dir = v:GetPos() - self:GetPos()
					v:SetVelocity(dir * 5)
				end
			end
		  
		if v:IsPlayer() and v:IsValid() and v:GetPos( ):Distance( self:GetPos( ) ) <= 1200 then
			self:EmitSound("hgn/stalker/anom/gravy_blast1.mp3")
			
			local brange = math.random( 120, 570 )
			local b = ents.Create( "point_hurt" )
			b:SetKeyValue("targetname", "fier" ) 
			b:SetKeyValue("DamageRadius", brange )
			b:SetKeyValue("Damage",  math.random( 11, 19 ) )
			b:SetKeyValue("DamageDelay", "5" )
			b:SetKeyValue("DamageType", "1" )
			b:SetPos( self.Entity:GetPos() )
			b:Spawn()
			b:Fire("turnon", "", 0)
			b:Fire("turnoff", "", 1)
			b:Fire("kill", "", 1)
			end
		end
		
		local shake = ents.Create("env_shake")
		shake:SetKeyValue("duration", 1)
		shake:SetKeyValue("amplitude", 20)
		shake:SetKeyValue("radius", 900) 
		shake:SetKeyValue("frequency", 100)
		shake:SetPos(self:GetPos())
		shake:Spawn() 
		shake:Fire("StartShake","","0.6") 
		shake:Fire("kill", "", 1)
		
		local exp = ents.Create("env_smoketrail")
			exp:SetKeyValue("startsize","400")
			exp:SetKeyValue("endsize","128")
			exp:SetKeyValue("spawnradius","64")
			exp:SetKeyValue("minspeed","1")
			exp:SetKeyValue("maxspeed","2")
			exp:SetKeyValue("startcolor","120 220 220")
			exp:SetKeyValue("endcolor","220 140 220")
			exp:SetKeyValue("opacity",".8")
			exp:SetKeyValue("spawnrate","10")
			exp:SetKeyValue("lifetime","1")
			exp:SetPos(self.Entity:GetPos())
			exp:SetParent(self.Entity)
		    exp:Spawn()
		exp:Fire("kill","",0.5)	
	end
end

rain:RegisterAnomaly("Evade", {"EEvade"})
rain:RegisterElement("EEvade", EvadeInit, EvadeThink)

local function HeatInit(self)
	if (SERVER) then
		self.Entity:SetModel( "models/props_junk/watermelon01.mdl" ) --Set its model.
		self.Entity:SetMoveType( MOVETYPE_NONE )   -- after all, rainod is a physics
		self.Entity:SetSolid( SOLID_NONE ) 	-- Toolbox
		
		self.Entity:SetKeyValue("rendercolor", "150 255 150") 
		self.Entity:SetKeyValue("renderamt", "alpha") 
		self.Entity:SetMaterial("models/props_combine/portalball001_sheet")
		self:MakeSprite( self.Entity, "15", "240 80 80", "sprites/glow1.vmt", "10", "255")
		self:MakeSprite( self.Entity, "23", "250 250 250", "sprites/glow1.vmt", "5", "150")
		
   		local phys = self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end
	end
end

local function HeatThink(self)
	if (CLIENT) then
		local mypos = self:GetPos()
		local dist = LocalPlayer():GetPos():Distance(mypos)
		
		if(dist < 3000) then
	
			local Size = 450
	
			if Size < 0 then
				Size = 0.01
			end
	
			render.UpdateScreenEffectTexture()
			render.SetMaterial(Heatwave)
			
			if (render.GetDXLevel() >= 90) then
				render.DrawSprite(self.Entity:GetPos(), Size, Size, Color(255, 0, 0, 25))
			end
		end
	else
		local brange = math.random( 64, 350 )
		local b = ents.Create( "point_hurt" )
		b:SetKeyValue("targetname", "pointhurtfire" ) 
		b:SetKeyValue("DamageRadius", brange )
		b:SetKeyValue("Damage",  math.random( 11, 19 ) )
		b:SetKeyValue("DamageDelay", "5" )
		b:SetKeyValue("DamageType", "8" )
		b:SetPos( self.Entity:GetPos() )
		b:Spawn()
		b:Fire("turnon", "", 0)
		b:Fire("turnoff", "", 1)
		b:Fire("kill", "", 1)
	end	
end

rain:RegisterAnomaly("Heat", {"EHeat"})
rain:RegisterElement("EHeat", HeatInit, HeatThink)

local function HoverstoneInit(self)
	self.Models = { "models/props_debris/concrete_column001a_chunk01.mdl",
	"models/props_debris/concrete_column001a_chunk02.mdl",
	"models/props_debris/concrete_column001a_chunk03.mdl",
	"models/props_debris/concrete_column001a_chunk04.mdl",
	"models/props_debris/concrete_chunk01b.mdl",
	"models/props_debris/concrete_chunk02a.mdl",
	"models/props_debris/concrete_chunk03a.mdl",
	"models/props_debris/concrete_chunk06d.mdl",
	"models/props_debris/concrete_chunk07a.mdl",
	"models/props_debris/concrete_chunk08a.mdl",
	"models/props_debris/concrete_chunk09a.mdl",
	"models/props_debris/concrete_spawnchunk001a.mdl",
	"models/props_debris/concrete_spawnchunk001b.mdl",
	"models/props_debris/concrete_spawnchunk001e.mdl",
	"models/props_debris/concrete_spawnchunk001f.mdl",
	"models/props_wasteland/rockgranite03a.mdl",
	"models/props_wasteland/rockgranite03b.mdl",
	"models/props_wasteland/rockgranite03c.mdl",
	"models/props_junk/Rock001a.mdl" }
	
	self.BumpSounds = { Sound( "ambient/materials/metal4.wav" ),
	Sound( "ambient/levels/canals/critter5.wav" ),
	Sound( "ambient/machines/station_train_squeel.wav" ) }

	if (CLIENT) then
		self.Emitter = ParticleEmitter( self.Entity:GetPos() )
		self.Dist = self.Entity:OBBCenter():Distance( self.Entity:OBBMaxs() )
	else
		self.Entity:SetModel( table.Random( self.Models ) )
		self.Entity:PhysicsInit( SOLID_VPHYSICS )
		self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
		self.Entity:SetSolid( SOLID_VPHYSICS )
		
		local phys = self.Entity:GetPhysicsObject()
		
		if IsValid( phys ) then
			phys:SetMaterial( "wood" )
			phys:Wake()
		end
		
		self.Entity:StartMotionController()
		
		self.Active = false
		self.Distance = math.random( 100, 400 )
		self.Scale = math.Rand( 10, 20 )

		function self:OnTakeDamage( dmg )
			if dmg:GetAttacker():IsPlayer() then
				local phys = self.Entity:GetPhysicsObject()
				if IsValid( phys ) then
					phys:ApplyForceCenter( VectorRand() * ( phys:GetMass() * self.Scale * 2 ) )
				end
			
				if math.random(1,10) == 1 then
					self.Entity:EmitSound( table.Random( self.BumpSounds ), 100, math.random( 140, 180 ) )
				end
			
				if math.Rand(1,100) == 1 then
					local prop = ents.Create( "artifact_petrock" )
					prop:SetPos( self.Entity:GetPos() )
					prop:Spawn()
				end
			end
		end

		function self:PhysicsSimulate( phys, delta )
			if not self.Active then 
				return SIM_NOTHING 
			end
			
			if self.ReActivate then
				self.ReActivate = false
				phys:ApplyForceCenter( Vector( 0, 0, 1 ) * ( phys:GetMass() * self.Scale ) )
			end
			
			local trace = {}
			trace.start = self.Entity:GetPos()
			trace.endpos = trace.start + Vector( 0, 0, -1000 )
			trace.filter = self.Entity
			
			local tr = util.TraceLine( trace )
			
			local dist = tr.HitPos:Distance( tr.StartPos )
			local scale = math.Clamp( 150 - dist, 0.25, 150 ) / 150
			
			if tr.Hit then
				phys:ApplyForceCenter( tr.HitNormal * ( phys:GetMass() * ( scale * self.Scale ) ) )
			end
		end
		
		function self:PhysicsCollide( data, phys )
			if data.HitEntity:IsPlayer() then
				data.HitEntity:TakeDamage( 10, self.Entity )
			end
			
			if data.DeltaTime > 0.15 and math.random(1,10) == 1 then
				self.Entity:EmitSound( table.Random( self.BumpSounds ), 100, math.random( 100, 150 ) )
			end
		end
	end
end

local function HoverstoneThink(self)
	if (CLIENT) then
		local mypos = self:GetPos()
		local dist = LocalPlayer():GetPos():Distance(mypos)
		
		if(dist < 3000) then
			local particle = self.Emitter:Add( "effects/muzzleflash"..math.random(1,4), self.Entity:LocalToWorld( self.Entity:OBBCenter() ) + VectorRand() * self.Dist )
			
			particle:SetVelocity( VectorRand() * 10 ) 
			particle:SetLifeTime( 0 )  
			particle:SetDieTime( math.Rand( 0.50, 0.75 ) ) 
			particle:SetStartAlpha( 30 ) 
			particle:SetEndAlpha( 0 ) 
			particle:SetStartSize( math.random( 15, 30 ) ) 
			particle:SetEndSize( math.random( 3, 6 ) ) 
			particle:SetColor( 100, math.random( 100, 150 ), math.random( 150, 250 ) )
			particle:SetAirResistance( 50 )
		end	
	else
		local active = false
	
		for k,v in pairs( player.GetAll() ) do
			if v:GetPos():Distance( self.Entity:GetPos() ) < 2000 then
				active = true
			end
		end
		
		self.Active = active
		
		if active == false then
			self.ReActivate = true
		else
			local phys = self.Entity:GetPhysicsObject()
			if IsValid( phys ) then
				phys:Wake()
			end
		end
	end
end

local function HoverstoneDraw(self)
	local mypos = self:GetPos()
	local dist = LocalPlayer():GetPos():Distance(mypos)
	
	if(dist < 3000) then
		self.Entity:DrawModel()
	end
end

rain:RegisterAnomaly("Hoverstone", {"EHoverstone"})
rain:RegisterElement("EHoverstone", HoverstoneInit, HoverstoneThink, HoverstoneDraw)

local function HydroInit(self)
	if (CLIENT) then
		self.Color = Color(255, 255, 255, 0)
	else
		self.Entity:SetModel( "models/props_borealis/bluebarrel001.mdl" )
		self.Entity:PhysicsInit( SOLID_NONE )      -- Make us work with physics,
		self.Entity:SetMoveType( MOVETYPE_NONE )   -- after all, rainod is a physics
		self.Entity:SetSolid( SOLID_NONE ) 	-- Toolbox
		 
		local phys = self.Entity:GetPhysicsObject()
		
			  if (phys:IsValid()) then
				phys:EnableMotion(false)
			  end
		self.Entity:SetKeyValue("rendercolor", "150 150 255") 
		self.Entity:SetKeyValue("renderamt", "0") 
		self.Entity:SetMaterial("models/props_combine/portalball001_sheet")
		MakeSprite( self.Entity, "15", "100 100 240", "sprites/glow1.vmt", "6", "255")
		MakeSprite( self.Entity, "23", "250 250 250", "sprites/glow1.vmt", "2", "150")
		distort(self.Entity, self.Entity:GetPos())
	end
end

local function HydroThink(self)
	if (SERVER) then
		local harange = math.random( 32, 128 )
		local b = ents.Create( "point_hurt" )
		b:SetKeyValue("targetname", "fier" ) 
		b:SetKeyValue("DamageRadius", harange )
		b:SetKeyValue("Damage", "5" )
		b:SetKeyValue("DamageDelay", "10" )
		b:SetKeyValue("DamageType", "16384" )
		b:SetPos( self.Entity:GetPos() )
		b:Spawn()
		b:Fire("turnon", "", 0)
		b:Fire("turnoff", "", 1)
		b:Fire("kill", "", 1)
	end
end

local function HydroDraw(self) -- is this a half assed attempt at optimization?
	local mypos = self:GetPos()
	local dist = LocalPlayer():GetPos():Distance(mypos)
	
	if(dist < 3000) then
	
	self.Entity:DrawModel()
	end
end

rain:RegisterAnomaly("Hydro", {"EHydro"})
rain:RegisterElement("EHydro", HydroInit, HydroThink, HydroDraw)

local function MysticInit(self)
	self.WeirdSounds = { Sound( "ambient/levels/citadel/strange_talk1.wav" ), 
	Sound( "ambient/levels/citadel/strange_talk3.wav" ), 
	Sound( "ambient/levels/citadel/strange_talk4.wav" ), 
	Sound( "ambient/levels/citadel/strange_talk5.wav" ), 
	Sound( "ambient/levels/citadel/strange_talk6.wav" ), 
	Sound( "ambient/levels/citadel/strange_talk7.wav" ), 
	Sound( "ambient/levels/citadel/strange_talk8.wav" ), 
	Sound( "ambient/levels/citadel/strange_talk9.wav" ),
	Sound( "ambient/levels/citadel/strange_talk10.wav" ),
	Sound( "ambient/levels/citadel/strange_talk11.wav" ) }
	
	self.Pain = { Sound( "ambient/atmosphere/thunder1.wav" ), 
	Sound( "ambient/atmosphere/thunder2.wav" ), 
	Sound( "ambient/atmosphere/thunder3.wav" ), 
	Sound( "ambient/atmosphere/thunder4.wav" ),
	Sound( "ambient/atmosphere/terrain_rumble1.wav" ),
	Sound( "ambient/atmosphere/hole_hit4.wav" ),
	Sound( "ambient/atmosphere/cave_hit5.wav" ) }
	
	self.Rape = Sound( "ambient/explosions/citadel_end_explosion2.wav" )
	
	self.Distance = 600

	if (CLIENT) then
		self.Timer = 0
	else
		self.Entity:SetModel( "models/XQM/Rails/gumball_1.mdl" )
		
		self.Entity:PhysicsInit( SOLID_VPHYSICS )
		self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
		self.Entity:SetSolid( SOLID_VPHYSICS )
		
		local phys = self.Entity:GetPhysicsObject()
		
		if IsValid( phys ) then
			phys:Wake()
		end
		
		self.SoundTime = 0
		self.HurtSound = 0
		self.Target = {}
	end
end

local function MysticThink(self)
	if (CLIENT) then
		local mypos = self:GetPos()
		local dist = LocalPlayer():GetPos():Distance(mypos)
		
		if(dist < 3000) then
			if self.Timer < CurTime() then
				self.Timer = CurTime() + math.Rand( 0.1, 2.5 )
				local dlight = DynamicLight(self.Entity:EntIndex())

				if dlight then
					dlight.Pos = self.Entity:LocalToWorld( self.Entity:OBBCenter() ) + VectorRand() * 10
					dlight.r = 255
					dlight.g = 255
					dlight.b = 255
					dlight.Brightness = 3
					dlight.Decay = 2048
					
					if self.Entity:GetNWBool( "Explode", false ) then
						dlight.size = 512
					else
						dlight.size = 1024
						self.Timer = CurTime() + math.Rand( 0.1, 1.0 )
					end
					dlight.DieTime = CurTime() + 2
				end
			end
		end
	else
		if self.ExplodeTime then
			if self.HurtSound < CurTime() then
				self.HurtSound = CurTime() + math.Rand( 0.5, 2.0 )
				self.Entity:EmitSound( table.Random( self.Pain ), 100, math.random( 180, 200 ) )
			end
		end

		if self.ExplodeTime and self.ExplodeTime < CurTime() then
			for k,v in pairs( player.GetAll() ) do
				if IsValid( v ) and table.HasValue( self.Target, v ) then
					v:SetDSP( 0, false ) 
				end
			end

			for k, v in pairs(player.GetAll()) do
				if IsValid(v) and v:Alive() and self.Entity:GetPos():Distance( v:GetPos() ) < 1000 then
					local scale = 1 - math.Clamp( self.Entity:GetPos():Distance( v:GetPos() ) / 1000, 0, 1 ) 
					util.ScreenShake( v:GetPos(), scale * 20, scale * 25, 2, 100 )
					v:TakeDamage( 75 * scale, self.Entity )
				end
			end
		
			local ed = EffectData()
			ed:SetOrigin(self.Entity:GetPos())
			util.Effect("pearl_explode", ed, true, true)
			
			self.Entity:EmitSound(self.Rape, 100, 160)
			
			if math.Rand(1,100) == 1 then
				local prop = ents.Create( "artifact_bead" )
				prop:SetPos( self.Entity:GetPos() + Vector(0,0,10) )
				prop:Spawn()
				timer.Simple( 60, function( ent ) if IsValid( ent ) then ent:Remove() end end, prop )
			end

			self.Entity:Respawn()
		end
		
		if self.SoundTime < CurTime() then
			self.SoundTime = CurTime() + math.random( 5, 10 )
			self.Entity:EmitSound( table.Random( self.WeirdSounds ), 100, math.random( 130, 160 ) )
		end
	end
end

local function MysticDraw(self)
	local mypos = self:GetPos()
	local dist = LocalPlayer():GetPos():Distance(mypos)
	
	if(dist < 3000) then
	
		self.Entity:DrawModel()
	end
end

rain:RegisterAnomaly("Mystic", {"EMystic"})
rain:RegisterElement("EMystic", MysticInit, MysticThink, MysticDraw)

local function distort(ent, pos)
	local effectdata = EffectData()
	effectdata:SetStart( pos )
	effectdata:SetOrigin( pos )
	effectdata:SetScale( 1 )
	util.Effect( "anom_punchpart", effectdata )	
end

local function PunchInit(self)
	if (CLIENT) then
		return 
	end
	
	self.Entity:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	self:MakeSprite( self.Entity, "15", "100 100 100", "sprites/glow1.vmt", "10", "255")
	self:MakeSprite( self.Entity, "23", "250 250 250", "sprites/glow1.vmt", "5", "150")

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end

	self.Entity:SetKeyValue("rendercolor", "255 150 150") 
	self.Entity:SetKeyValue("renderamt", "225") 
	self.Entity:SetNoDraw( true )
end

local function PunchThink(self)
	if (CLIENT) then
		return 
	end

	local b = ents.Create( "point_hurt" )
	b:SetKeyValue("targetname", "fier" ) 
	b:SetKeyValue("DamageRadius", 128 )
	b:SetKeyValue("Damage", "20" )
	b:SetKeyValue("DamageDelay", "5" )
	b:SetKeyValue("DamageType", "1048576" )
	b:SetPos( self.Entity:GetPos() )
	b:Spawn()
	b:Fire("turnon", "", 0)
	b:Fire("turnoff", "", 1)
	b:Fire("kill", "", 1)
	
	distort(self.Entity, self.Entity:GetPos())
end

rain:RegisterAnomaly("Punch", {"EPunch"})
rain:RegisterElement("EPunch", PunchInit, PunchThink)

local function StaticInit(self)
	self.PreZap = {"weapons/physcannon/superphys_small_zap1.wav",
	"weapons/physcannon/superphys_small_zap2.wav",
	"weapons/physcannon/superphys_small_zap3.wav",
	"weapons/physcannon/superphys_small_zap4.wav"}
	
	self.ZapHit = {"weapons/physcannon/energy_disintegrate4.wav",
	"weapons/physcannon/energy_disintegrate5.wav"}
	
	self.ExplodeZap = {"ambient/explosions/explode_7.wav",
	"ambient/levels/labs/electric_explosion1.wav", 
	"ambient/levels/labs/electric_explosion2.wav", 
	"ambient/levels/labs/electric_explosion3.wav", 
	"ambient/levels/labs/electric_explosion4.wav"}
	
	self.ZapRadius = 300

	if (SERVER) then
		self.Entity:SetMoveType( MOVETYPE_NONE )
		self.Entity:SetSolid( SOLID_NONE )
	
		self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
		self.Entity:SetTrigger( true )
		self.Entity:SetNotSolid( true )
		self.Entity:DrawShadow( false )	
		
		self.Entity:SetCollisionBounds( Vector( -150, -150, -150 ), Vector( 150, 150, 150 ) )
		self.Entity:PhysicsInitBox( Vector( -150, -150, -150 ), Vector( 150, 150, 150 ) )
		
		self.SoundTime = 0

		function self:Explode()
		
			local tbl = ents.FindByClass( "prop_phys*" )
			tbl = table.Add( tbl, ents.FindByClass( "npc*" ) )
			tbl = table.Add( tbl, player.GetAll() )
			
			for k,v in pairs( tbl ) do
				if v:GetPos():Distance( self.Entity:GetPos() ) < self.ZapRadius then
					if ( v:IsPlayer() and not IsValid( v:GetVehicle() ) ) or not v:IsPlayer() then
						
						local ed = EffectData()
						ed:SetOrigin( v:GetPos() )
						util.Effect( "electric_zap", ed )
						
						local force = VectorRand()
						force.z = 0.25
					
						local dmg = DamageInfo()
						dmg:SetDamage( 60 )
						dmg:SetDamageType( DMG_DISSOLVE )
						dmg:SetAttacker( self.Entity )
						dmg:SetInflictor( self.Entity )
						dmg:SetDamageForce( force * 1000 )
						
						v:TakeDamageInfo( dmg )
						v:EmitSound( table.Random( self.ZapHit ), 100, math.random(90,110) )
						
						self.Entity:DrawBeams( self.Entity, v )
					end
				end
			end
			
			for i=1, math.random( 8, 12 ) do
				local vec = VectorRand() 
				vec.z = math.Rand( -1.0, 0.5 )
			
				local trace = {}
				trace.start = self.Entity:GetPos()
				trace.endpos = trace.start + vec * 500
				
				local tr = util.TraceLine( trace )
				
				while ( tr.HitPos:Distance( self.Entity:GetPos() ) < 50 or not tr.Hit ) do
				
					local vec = VectorRand() 
					vec.z = math.Rand( -0.25, 0.50 )
			
					local trace = {}
					trace.start = self.Entity:GetPos()
					trace.endpos = trace.start + vec * self.ZapRadius
					trace.filter = self.Entity
				
					tr = util.TraceLine( trace )
				end
				
				self.Entity:DrawBeams( self.Entity, self.Entity, tr.HitPos )
				
				local ed = EffectData()
				ed:SetOrigin( tr.HitPos )
				util.Effect( "electric_zap", ed )
			end
			
			self.Entity:EmitSound( table.Random( self.ExplodeZap ), 100, math.random(90,110) )
			
			local ed = EffectData()
			ed:SetOrigin( self.Entity:GetPos() )
			util.Effect( "electric_bigzap", ed )
		end
		
		function self:DrawBeams( ent1, ent2, pos )
			local target = ents.Create( "info_target" )
			target:SetPos( ent1:LocalToWorld( ent1:OBBCenter() ) )
			target:SetParent( ent1 )
			target:SetName( tostring( ent1 )..math.random(1,900) )
			target:Spawn()
			target:Activate()
			
			local target2 = ents.Create( "info_target" )
			
			if pos then
				target2:SetPos( pos )
				target2:SetName( tostring( pos ) )
			else
			
				target2:SetPos( ent2:LocalToWorld( ent2:OBBCenter() ) )
				target2:SetParent( ent2 )
				target2:SetName( tostring( ent2 )..math.random(1,900) )
			end

			target2:Spawn()
			target2:Activate()
			
			local laser = ents.Create( "env_beam" )
			laser:SetPos( ent1:GetPos() )
			laser:SetKeyValue( "spawnflags", "1" )
			laser:SetKeyValue( "rendercolor", "200 200 255" )
			laser:SetKeyValue( "texture", "sprites/laserbeam.spr" )
			laser:SetKeyValue( "TextureScroll", "1" )
			laser:SetKeyValue( "damage", "0" )
			laser:SetKeyValue( "renderfx", "6" )
			laser:SetKeyValue( "NoiseAmplitude", ""..math.random(5,20) )
			laser:SetKeyValue( "BoltWidth", "1" )
			laser:SetKeyValue( "TouchType", "0" )
			laser:SetKeyValue( "LightningStart", target:GetName() )
			laser:SetKeyValue( "LightningEnd", target2:GetName() )
			laser:SetOwner( self.Entity:GetOwner() )
			laser:Spawn()
			laser:Activate()
			
			laser:Fire( "kill", "", 0.2 )
			target:Fire( "kill", "", 0.2 )
			target2:Fire( "kill", "", 0.2 )
		end 

		function self:Touch( ent ) 
			if self.SetOff then 
				return 
			end

			if ent:IsPlayer() or string.find( ent:GetClass(), "npc" ) or string.find( ent:GetClass(), "prop_phys" ) then
				self.SetOff = CurTime() + 3
			end
		end 	
	elseif (CLIENT) then
		self.Size = 15
		self.Emitter = ParticleEmitter( self.Entity:GetPos() )
		self.Timer = 0
		self.Alpha = 0
	end
end

local function StaticThink(self)
	if (CLIENT) then
		if self.Timer < CurTime() then
		
			self.Timer = CurTime() + 0.75
		
			local vec = VectorRand()
			vec.z = math.Rand( -0.25, 0.25 )
		
			local newpos = self.Entity:GetPos() + vec * 150
		
		local mypos = self:GetPos()
		local dist = LocalPlayer():GetPos():Distance(mypos)
		
			if(dist < 3000) then
				local particle = self.Emitter:Add( "effects/spark", newpos )
				particle:SetVelocity( Vector(0,0,0) )
				particle:SetColor( 200, 200, 255 )
				particle:SetDieTime( 1.5 )
				particle:SetStartAlpha( 200 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand( 1, 3 ) )
				particle:SetEndSize( 0 )
				particle:SetRoll( math.Rand( -360, 360 ) )
				particle:SetRollDelta( math.Rand( -30, 30 ) )
				
				particle:SetAirResistance( 50 )
				particle:SetGravity( Vector( 0, 0, math.random( 25, 50 ) ) )
			end
		
		end
	elseif (SERVER) then
		if self.SetOff and self.SetOff > CurTime() then
			if self.SoundTime < CurTime() then
				self.SoundTime = CurTime() + 0.3

				local tbl = ents.FindByClass( "prop_phys*" )
				tbl = table.Add( tbl, ents.FindByClass( "npc*" ) )
				tbl = table.Add( tbl, player.GetAll() )

				for k,v in pairs( tbl ) do
					if v:GetPos():Distance( self.Entity:GetPos() ) < self.ZapRadius then
						v:EmitSound( table.Random( self.PreZap ), 100, math.random(60,80) )
					end
				end
			end
		elseif self.SetOff and self.SetOff < CurTime() then
			self.Entity:Explode()
			self.SetOff = nil
		end
	end
end

local yellowGlow = Material( "effects/yellowflare" )

local function StaticDraw(self)
	local mypos = self:GetPos()
	local dist = LocalPlayer():GetPos():Distance(mypos)
	
	if(dist < 3000) then
		self.Alpha = 100 + math.sin( CurTime() ) * 100

		render.SetMaterial( yellowGlow )
		render.DrawSprite( self.Entity:GetPos(), self.Size + math.sin( CurTime() * 3 ) * 10, self.Size + math.cos( CurTime() * 3 ) * 10, Color( 200, 200, 255, self.Alpha ) )
	end
end

rain:RegisterAnomaly("Static", {"EStatic"})
rain:RegisterElement("EStatic", StaticInit, StaticThink, StaticDraw)

local function VortexInit(self)
	self.PreSuck = Sound( "ambient/levels/labs/teleport_mechanism_windup5.wav" )
	self.SuckExplode = Sound( "weapons/mortar/mortar_explode2.wav" )
	self.SuckBang = Sound( "ambient/levels/labs/teleport_postblast_thunder1.wav" )
	
	self.WaitTime = 3
	self.SuckTime = 5
	self.SuckRadius = 700
	self.KillRadius = 300

	if (SERVER) then
		self.Entity:SetMoveType( MOVETYPE_NONE )
		self.Entity:SetSolid( SOLID_NONE )
		
		self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
		self.Entity:SetTrigger( true )
		self.Entity:SetNotSolid( true )
		self.Entity:DrawShadow( false )	
			
		self.Entity:SetCollisionBounds( Vector( -350, -350, -350 ), Vector( 350, 350, 350 ) )
		self.Entity:PhysicsInitBox( Vector( -350, -350, -350 ), Vector( 350, 350, 350 ) )
		
		self.VortexPos = self.Entity:GetPos() + Vector( 0, 0, 250 )

		function self:Touch( ent ) 
			if self.SetOff then 
				return 
			end

			if ent:IsPlayer() or string.find( ent:GetClass(), "npc" ) or string.find( ent:GetClass(), "prop_phys" ) or ent:GetClass() == "sent_lootbag" then
				self.SetOff = CurTime() + self.WaitTime
				self.Entity:EmitSound( self.PreSuck )
				self.Entity:SetNWBool( "Suck", true )
			end
		end 
	end

	if (CLIENT) then
		self.Emitter = ParticleEmitter( self.Entity:GetPos() )
		self.VortexPos = self.Entity:GetPos() + Vector( 0, 0, 250 )
		self.Alpha = 0
		self.Timer = 0
		self.DustTimer = 0
		self.Fraction = 0
		self.Size = 400
	end
end

local function VortexThink(self)
	if (CLIENT) then
		if self.DustTimer < CurTime() then
		
			self.DustTimer = CurTime() + 0.5
		
			local vec = VectorRand()
			vec.z = -0.1
		
			local newpos = self.Entity:GetPos() + vec * 400
		
			local particle = self.Emitter:Add( "effects/fleck_cement" .. math.random(1,2), newpos )
			particle:SetVelocity( Vector( 0, 0, math.random( 50, 200 ) ) )
			particle:SetDieTime( 6.0 )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 255 )
			particle:SetStartSize( math.Rand( 2, 4 ) )
			particle:SetEndSize( 1 )
			particle:SetRoll( math.random( -360, 360 ) )
			particle:SetColor( 100, 100, 100 )
			particle:SetAirResistance( math.random( 0, 15 ) )
			particle:SetThinkFunction( DustThink )
			particle:SetNextThink( CurTime() + 0.1 )
			particle.VortexPos = self.VortexPos
		end
		
		if self.Entity:GetNWBool( "Suck", false ) and self.Timer < CurTime() then
			self.Timer = CurTime() + 8
		end	
	else
		if self.SetOff and self.SetOff < CurTime() and not self.VortexTime then
			self.VortexTime = CurTime() + self.SuckTime
			self.Entity:SetNWBool( "Suck", false )
		end
		
		if self.VortexTime and self.VortexTime > CurTime() then
		
			local tbl = ents.FindByClass( "prop_phys*" )
			tbl = table.Add( tbl, ents.FindByClass( "prop_veh*" ) )
			tbl = table.Add( tbl, ents.FindByClass( "npc*" ) )
			tbl = table.Add( tbl, ents.FindByClass( "sent_lootbag" ) )
			tbl = table.Add( tbl, player.GetAll() )
			
			for k,v in pairs( tbl ) do
				if v:GetPos():Distance( self.Entity:GetPos() ) < self.SuckRadius then
					local vel = ( self.VortexPos - v:GetPos() ):GetNormal()
					if ( v:IsPlayer() and v:Alive() ) or string.find( v:GetClass(), "npc" ) then
						local scale = math.Clamp( ( self.SuckRadius - v:GetPos():Distance( self.VortexPos ) ) / self.SuckRadius, 0.2, 1.0 )
						if v:GetPos():Distance( self.VortexPos ) > 80 then
							v:SetVelocity( vel * ( scale * 500 ) )
						else
							v:SetLocalVelocity( vel * ( scale * 500 ) )
						end
					else
						local phys = v:GetPhysicsObject()
						if IsValid( phys ) then
							phys:ApplyForceCenter( vel * ( phys:GetMass() * 500 ) )
						end
					end
				end
			end
				
		elseif self.VortexTime and self.VortexTime < CurTime() then
		
			self.VortexTime = nil
			self.SetOff = nil
			
			self.Entity:EmitSound( self.SuckExplode, 100, math.random(100,120) )
			self.Entity:EmitSound( self.SuckBang, 100, math.random(120,140) )
			
			local ed = EffectData()
			ed:SetOrigin( self.VortexPos )
			util.Effect( "vortex_explode", ed, true, true )
			
			local tbl = ents.FindByClass( "prop_phys*" )
			tbl = table.Add( tbl, ents.FindByClass( "prop_veh*" ) )
			tbl = table.Add( tbl, ents.FindByClass( "npc*" ) )
			tbl = table.Add( tbl, ents.FindByClass( "sent_lootbag" ) )
			tbl = table.Add( tbl, player.GetAll() )
			
			for k,v in pairs( tbl ) do
				if v:GetPos():Distance( self.VortexPos ) < self.KillRadius then
					if v:IsPlayer() then
						if v:Alive() then
							v:SetModel( "models/shells/shell_9mm.mdl" )
							v:Kill()
						end
					else
						v:Remove()
					end
				end
			end
		end
		
		self.Entity:NextThink( CurTime() )
   	 return true
	end
end

local function VortexDraw(self)
	local mypos = self:GetPos()
	local dist = LocalPlayer():GetPos():Distance(mypos)
	
	if(dist < 4000) then
		self.Alpha = 100 + math.sin( CurTime() ) * 100

		if self.Timer < CurTime() then
			self.Fraction = math.Approach( self.Fraction, 0.02 + math.sin( CurTime() * 0.5 ) * 0.02, 0.01 )
		else
			self.Fraction =  math.Approach( self.Fraction, ( 1 - ( self.Timer - CurTime() ) / 8 ) * 0.20, 0.01 )
			self.Alpha = ( 1 - ( self.Timer - CurTime() ) / 8 ) * 100
			
			render.SetMaterial( matGlow )
			render.DrawSprite( self.VortexPos, self.Size * 0.1 + math.sin( CurTime() ) * 50, self.Size * 0.1 + math.sin( CurTime() ) * 50, Color( 200, 200, 255, self.Alpha ) )
		end
		
		matRefract:SetFloat( "$refractamount", self.Fraction )

		if render.GetDXLevel() >= 80 then
			render.UpdateRefractTexture()
			render.SetMaterial( matRefract )
			render.DrawQuadEasy( self.VortexPos,
						 ( EyePos() - self.VortexPos ):GetNormal(),
						 self.Size + math.sin( CurTime() ) * 20, self.Size + math.sin( CurTime() ) * 20,
						 Color( 255, 255, 255, 255 ) )
		end
	end
end

rain:RegisterAnomaly("Vortex", {"EVortex"})
rain:RegisterElement("EVortex", VortexInit, VortexThink, VortexDraw)

local function WhirlgigInit(self)
	if (CLIENT) then
		return
	end

	self.Entity:SetModel( "models/props_junk/watermelon01.mdl" ) --Set its model.
	self.Entity:SetMoveType( MOVETYPE_NONE )   -- after all, rainod is a physics
	self.Entity:SetSolid( SOLID_NONE ) 	-- Toolbox
	
	self.Entity:SetKeyValue("rendercolor", "150 255 150") 
	self.Entity:SetKeyValue("renderamt", "0") 
	self.Entity:DrawShadow(false)
	
	self.DustSize = 200
	self.DustChange = 0
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

local function WhirlgigThink(self)
	if (CLIENT) then
		return
	end

	if( self.DustSize > 350 )then 
		self.DustSize = 120
	end

    for k, v in pairs( ents.FindInSphere( self.Entity:GetPos(), 300 ) ) do	
			--If it is a valid entity and nearby
		if( v:IsValid() and v:GetPhysicsObject():IsValid() and v:GetPos( ):Distance( self:GetPos( ) ) <= 300 ) then
			
            local dir = v:GetPos() - self:GetPos()
			local force = 35	
			local distance = dir:Length()			// The distance the phys object is from the ent
			local maxdistance = 300				// The max distance 
		
			// Lessen the force from a distance
			
			local ratio = math.Clamp( (1 - (distance/maxdistance)), 0, 1 )
			
			// Set up the 'real' force and the offset of the force
			local vForce = -1*dir * (force * ratio)
			
			// Apply it!
			v:GetPhysicsObject():ApplyForceOffset( vForce, dir )
						
		end
		
		if( v:IsPlayer() and v:IsValid() and v:GetPos( ):Distance( self:GetPos( ) ) <= 370 ) then
		 local dir = v:GetPos() - self:GetPos()
	
		  v:SetVelocity(dir * -1.2)
		end
	end
	
	if(self.DustChange < CurTime() )then
       self.DustChange = CurTime() + 1.6
      self.DustSize = self.DustSize + 5

        --Let make it shake nearby players.
		local shake = ents.Create("env_shake")
		shake:SetKeyValue("duration", 1)
		shake:SetKeyValue("amplitude", 13)
		shake:SetKeyValue("radius", 500) 
		shake:SetKeyValue("frequency", 800)
		shake:SetPos(self.Entity:GetPos())
		shake:Spawn()
		shake:Fire("StartShake","","0.6") 
        shake:Fire("kill", "", 1)
		
	local brange = math.random( 64, 350 )
	local b = ents.Create( "point_hurt" )
	b:SetKeyValue("targetname", "pointhurt" ) 
	b:SetKeyValue("DamageRadius", brange )
	b:SetKeyValue("Damage",  math.random( 11, 19 ) )
	b:SetKeyValue("DamageDelay", "5" )
	b:SetKeyValue("DamageType", "CHEMICAL" )
	b:SetPos( self.Entity:GetPos() )
	b:Spawn()
	b:Fire("turnon", "", 0)
	b:Fire("turnoff", "", 1)
	b:Fire("kill", "", 1)
	       -- local effectdata = EffectData()
            --effectdata:SetOrigin( self.Entity:GetPos() )
			--util.Effect( "smokegust", effectdata )
			
			local tonormlal = self.Entity:GetPos()+Vector( 0, 0, math.Rand( -100, 170) )
			local effectdata = EffectData()
            effectdata:SetStart( self.Entity:GetPos() + Vector( 0, 0, math.Rand( -100, 170) ) ) 
            effectdata:SetOrigin( self.Entity:GetPos() + Vector( 0, 0, math.Rand( -100, 170) ))
			effectdata:SetNormal(  tonormlal:GetNormal() )  
			effectdata:SetScale( self.DustSize )
			effectdata:SetRadius( 16 )
			effectdata:SetMagnitude( 8 )
            util.Effect( "ThumperDust", effectdata )
	 end
end

local bulge = Material("effects/strider_bulge_dudv")
local Size = 100

local function WhirlgigDraw(self)
	local mypos = self:GetPos()
	local dist = LocalPlayer():GetPos():Distance(mypos)
	
	if(dist < 3000) then		
		render.UpdateScreenEffectTexture()	
		render.SetMaterial(bulge)
		
		if (render.GetDXLevel() >= 90) then
		end
	end
end

rain:RegisterAnomaly("Whirlgig", {"EWhirlgig"})
rain:RegisterElement("EWhirlgig", WhirlgigInit, WhirlgigThink, WhirlgigDraw)

local function ElectroInit(self)
	self.ShockSound = "";
	
	self.Radius = 300;
	
	self.DoTime = 0;
	self.WaitTime = 3;
	
	self.Particles = { "electrical_arc_01", "electrical_arc_01_parent", "electrical_arc_01_system", "st_elmos_fire", "st_elmos_fire_cp0", "striderbuster_break_lightning" };
	
	self:SetMoveType(MOVETYPE_NONE);
	self:SetSolid(SOLID_NONE);
	
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER);
	self:SetNotSolid(true);
	self:DrawShadow(false);
	
	self:SetModel("models/dav0r/hoverball.mdl");
	
	for _, particle in next, self.Particles do
		PrecacheParticleSystem(particle);
	end

end

local function ElectroThink(self)
	local nearbyPlayers = ents.FindByClass("player");
	
	for k, v in pairs(nearbyPlayers) do
		if (IsValid(v) and v:IsPlayer() and v:Alive()) then
			local dist = v:GetPos():Distance(self:GetPos());
			if (dist > self.Radius) then continue; end // skip players outside of the radius
			if (self.DoTime < CurTime()) then
				
				if (SERVER) then
					local shock = DamageInfo();
					shock:SetDamage(10);
					shock:SetDamageType(DMG_SHOCK);
					shock:SetAttacker(v);
					if (IsValid(v) and v:IsPlayer() and v:Alive()) then
						v:TakeDamageInfo(shock);
					end
				end
				
				for _, particle in pairs(self.Particles) do
					ParticleEffect(particle, self:GetPos(), Angle(0, 0, 0));
				end
				
				self.DoTime = CurTime() + self.WaitTime;
			end
		end
	end
	
	self:NextThink(CurTime());
	return true;
end

rain:RegisterAnomaly("Electro", {"EElectro"})
rain:RegisterElement("EElectro", ElectroInit, ElectroThink)