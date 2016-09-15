--[[

Name: sv_buffs.lua
Creator: LivKX
For: Deadi - Raindrop GM

Dear Developers:

Example buff creation:

RegisterBuff(string NameOfYourBuff,bool DoesItUseArgs,function(ply,time,...) - ... is only nescessary if it uses args
	local args = {...}
	timer.Create("NameOfYourBuff "..ply:GetEntIndex(),args[1],args[2],function() - Important to have the timer name like this!!
		ply:blablabla()
	end)
end)

]]

util.AddNetworkString("BuffStat")

buffsTable = buffsTable or {}
playerBuffs = playerBuffs or {}

function RegisterBuff(buffName, buffUsesArgs, buffFunc)
	if( !buffName || !buffFunc || type(buffUsesArgs) != "boolean" ) then return end
	
	for k, v in pairs( chatcommands ) do
		if( buffName == k ) then
			return
		end
	end
	
	buffsTable[ tostring( buffName ) ] = {buffUsesArgs, buffFunc}
end

local meta = FindMetaTable("Player")

function meta:ApplyBuff(name,time,...)
	if IsValid(self) && IsPlayer(self) then
		for k,v in pairs(buffsTable) do
			if name == k then
				local t = self:GetBuffs()
				if !table.HasValue(t,name) then
				if v[1] == true then
					if args != nil then
						v[2](self,time,args,...)
						table.insert(playerBuffs[self:GetEntIndex()],nil,name)
						if {...} then
						for k,v in pairs({...}) do
							table.insert(playerBuffs[self:GetEntIndex()],nil,v)
						end
						end
						net.Start("BuffStat")
						net.WriteBool(true)
						net.WriteString(name)
						net.WriteInt(time,32)
						if {...} then
						net.WriteTable({...})
						end
						net.Send(self)
						return true
					else
						return false
					end
				else
					v[2](self,time)
					table.insert(playerBuffs[self:GetEntIndex()],nil,name)
					net.Start("BuffStat")
					net.WriteBool(true)
					net.WriteString(name)
					net.WriteInt(time,32)
					net.Send(self)
					return true
				end
				else
					return false
				end
			end
		end
	else
		return false
	end
end

function meta:GetBuffs()
	if playerBuffs[self:GetEntIndex()] then
		return playerBuffs[self:GetEntIndex()]
	else
		return {}
	end
end

function meta:RemoveBuff(name)
	if playerBuffs[self:GetEntIndex()] then
		local t = playerBuffs[self:GetEntIndex()]
		if table.HasValue(t,name) then
			for k,v in pairs(t) do
				if v == name then
					table.remove(k)
					timer.Remove(name.." "..self:GetEntIndex())
					net.Start("BuffStat")
					net.WriteBool(false)
					net.WriteString(name)
					net.Send(self)
					local m = buffsTable[v]
					if m[1] == true then
						table.remove(k)
						local blyat = true
					end
				elseif !buffsTable[v] && blyat = true then
					table.remove[k]
				elseif buffsTable[v] && blyat = true then
					blyat = false
				end
			end
		else
			return false
		end
	else
		return false
	end
end

RegisterBuff("Poison",false,function(ply,time) -- Does 1hp damage per second for the specified time. Let's the client know.
	timer.Create("Poison "..ply:EntIndex(),1,time,function()
		ply:TakeDamage(1)
		ply:ChatPrint("You have been poisoned! Took 1hp damage.")
	end)
end)

RegisterBuff("CustPoison",true,function(ply,time,...) -- Does args[1] damage per args[2] for the specified ammount of times. Let's the client know.
	local args = {...}
	timer.Create("CustPoison "..ply:EntIndex(),args[2],time,function()
		ply:TakeDamage(args[1])
		ply:ChatPrint("You have been CustPoisoned™! Took 1hp damage.")
	end)
end)

RegisterBuff("MaxHealth",true,function(ply,time,...)
	local args = {...}
	ply:SetMaxHealth(args[1])
	timer.Create("MaxHealth "..ply:GetEntIndex(),time,0,function()
		ply:SetMaxHealth(100)
	end)
end)

RegisterBuff("HealthRegen",true,function(ply,time,...)
	local args = {...}
	timer.Create("HeathRegen "..ply:GetEntIndex(),2,(time * 2),function()
		ply:SetHealth(ply:Health() + args[1])
	end)
end)

RegisterBuff("SpeedBoost",true,function(ply,time,...)
	local args = {...}
	ply:SetMaxSpeed(ply:GetMaxSpeed() * args[1])
	ply:SetWalkSpeed(ply:GetWalkSpeed() * args[1])
	ply:SetRunSpeed(ply:GetRunSpeed() * args[1])
	timer.Create("SpeedBoost "..ply:GetEntIndex(),time,0,function()
		ply:SetMaxSpeed(ply:GetMaxSpeed() / args[1])
		ply:SetWalkSpeed(ply:GetWalkSpeed() / args[1])
		ply:SetRunSpeed(ply:GetRunSpeed() / args[1])
	end)
end)

RegisterBuff("Adrenaline",false,function(ply,time)
	ply:SetKeyValue("staminafrozen","true")
	timer.Create("Adrenaline "..ply:GetEntIndex(),time,0,function()
		ply:SetKeyValue("staminafrozen","false")
	end)
end)

RegisterBuff("OnFire",false,function(ply,time)
	timer.Create("OnFire "..ply:GetEntIndex(),1,time,function()
		ply:TakeDamage(5)
	end)
end)

RegisterBuff("KnockOut",false,function(ply,time)

	if ply:InVehicle() then
		local vehicle = ply:GetParent()
		ply:ExitVehicle()
	end

	local ragdoll = ents.Create( "prop_ragdoll" )
	ragdoll.ragdolledPly = ply

	ragdoll:SetPos( ply:GetPos() )
	local velocity = ply:GetVelocity()
	ragdoll:SetAngles( ply:GetAngles() )
	ragdoll:SetModel( ply:GetModel() )
	ragdoll:Spawn()
	ragdoll:Activate()
	ply:SetParent( ragdoll )
	local j = 1
	while true do
		local phys_obj = ragdoll:GetPhysicsObjectNum( j )
		if phys_obj then
			phys_obj:SetVelocity( velocity )
			j = j + 1
		else
			break
		end
	end

	ply:Spectate( OBS_MODE_CHASE )
	ply:SpectateEntity( ragdoll )
	ply:StripWeapons()

	ply.ragdoll = ragdoll

	timer.Create("KnockOut "..ply:GetEntIndex(),time,0,function()
	ply:SetParent()

	ply:UnSpectate()

	local ragdoll = ply.ragdoll
	ply.ragdoll = nil 

	if not ragdoll:IsValid() then
		ply:Spawn()
	else
		local pos = ragdoll:GetPos()
		pos.z = pos.z + 10 -- So they don't end up in the ground
		ply:Spawn()
		ply:SetPos( pos )
		ply:SetVelocity( ragdoll:GetVelocity() )
		local yaw = ragdoll:GetAngles().yaw
		ply:SetAngles( Angle( 0, yaw, 0 ) )
		ragdoll:DisallowDeleting( false )
		ragdoll:Remove()
	end

	end)

end)

