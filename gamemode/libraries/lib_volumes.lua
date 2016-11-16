--[[
	Filename: sh_volumes.lua
	Notes: This is the file that handles volume creation, enter/exit events, etc.
--]]

rain.volumeindex = {} -- all the types of volumes are stored here
rain.volumes = {} -- this is where actual volume data is stored

-- enumerations
E_ENTERVOLUME = 0
E_INVOLUME = 1
E_EXITVOLUME = 2
if (SV) then
	util.AddNetworkString("nAddVolume")
	util.AddNetworkString("nRemoveVolume")
	util.AddNetworkString("nVolume")
end
rain.struct:RegisterStruct("Volume", {
	Type = "VolumeType",
	Min = Vector(0,0,0),
	Max = Vector(1,1,1),
	Radial = false
})

rain.struct:RegisterStruct("VolumeType", {
	Name = "VolumeType", -- Name, for debugging purposes mostly.
	Strength = 1, -- 0-1 variable, this is passed on to the OnEnter/OnExit/WhileInside functions.
	Metadata = {}, -- passed on as a function to the functions
	OnEnter = function(ent, sType, tMetadata)
		print(ent, "has entered the", sType, "volume")
	end,
	OnExit = function(ent, sType, tMetadata)
		print(ent, "has exited the ", sType, "volume")
	end,
	WhileInside = function(ent, sType, tMetadata)
		print("gimme da succ")
	end,
	DrawColor = Color(255, 255, 255, 255) -- this is the color used to draw the lines surrounding the volume when using the toolgun.
})

--[[
	Function: VolumeThink
	Purpose: Detect wether or not a player is in a volume.
--]]

local VolumeThinkLimit = 0.5
local NextThink = CurTime() + VolumeThinkLimit -- limit the tickrate

function rain:VolumeThink()
	if (CurTime() > NextThink) then
		for k, v in pairs(self.volumes) do
			local voldata = self:GetVolumeType(v.Type)
			local tocheck
	
			if (v.Radial) then
				tocheck = ents.FindInSphere(v.Min, v.Min:Distance(v.Max))
			else
				tocheck = ents.FindInBox(v.Min, v.Max)
			end
	
			for k2, v2 in pairs(tocheck) do
				if (SERVER) then
					if (v2:IsPlayer()) then
						if (!v2.Volumes) then
							v2.Volumes = {}
						end
	
						if (!v2.Volumes[k]) then
							net.Start("nVolume")
								net.WriteInt(E_ENTERVOLUME, 4)
								net.WriteInt(k, 11)
							net.Send(v2)

							voldata.OnEnter(v2, v.Type, {})
						end
	
						net.Start("nVolume")
							net.WriteInt(E_INVOLUME, 4)
							net.WriteInt(k, 11)
						net.Send(v2)

						v2.Volumes[k] = CurTime()
						voldata.WhileInside(v2, v.Type, {})
					end
				end
			end
		end
	
		for k, v in pairs(player.GetAll()) do
			if (v.Volumes) then
				for k2, v2 in pairs(v.Volumes) do
					if v2 != CurTime() then
						local voldata = self.volumeindex[self.volumes[k2].Type]
						voldata.OnExit(v, self.volumes[k2].Type)
						v.Volumes[k2] = nil
	
						net.Start("nVolume")
							net.WriteInt(E_EXITVOLUME, 4)
							net.WriteInt(k2, 11)
						net.Send(v)
					end
				end
			end
		end

		NextThink = CurTime() + VolumeThinkLimit
	end
end

--[[
	Function: RegisterVolumeType
	Purpose: Registers a volume type for future usage
--]]

function rain:RegisterVolumeType(sType, sName, nStrength, bServerSideVerification, tMetadata, cDrawColor, fnOnEnter, fnOnExit, fnWhileInside)
	local VolumeType = rain.struct:GetStruct("VolumeType")

	VolumeType.Name = sName or VolumeType.Name
	VolumeType.Strength = nStrength or VolumeType.Strength
	VolumeType.ServerSideVerification = bServerSideVerification
	VolumeType.Metadata = tMetadata or VolumeType.Metadata
	VolumeType.OnEnter = fnOnEnter or VolumeType.OnEnter
	VolumeType.OnExit = fnOnExit or VolumeType.OnExit
	VolumeType.WhileInside = fnWhileInside or VolumeType.WhileInside
	VolumeType.DrawColor = cDrawColor or VolumeType.DrawColor

	self.volumeindex[sType] = VolumeType
end

--[[
	Function: GetVolume
	Purpose: Gets the volume from the index at the specified point.
--]]

function rain:GetVolumeType(sName)
	return self.volumeindex[sName]
end

--[[
	Function: AddVolume
	Purpose: When called it adds a volume to the registry, this function gets replicated from server to client but not the other way around.
--]]

function rain:AddVolume(tVolume, index)
	local NewVolume = rain.struct:GetStruct("Volume")
	NewVolume.Min = tVolume.Min or NewVolume.Min
	NewVolume.Max = tVolume.Max or NewVolume.Max
	NewVolume.Type = tVolume.Type or NewVolume.Type
	NewVolume.Radial = tVolume.Radial or NewVolume.Radial

	local newindex = index or #self.volumes+1
	self.volumes[newindex] = NewVolume

	if (SERVER) then
		net.Start("nAddVolume")
		net.WriteInt(newindex, 11) -- since I assume there will be a lot of volumes created I'm using a fairly larger int, this allows for up to 1,024 volumes which is more than enough
		net.WriteTable(NewVolume)
		net.Broadcast()
	end
end

--[[
	Function: RemoveVolume
	Purpose: Removes a volume by iterating through all of the volumes, removing the first volume that is within 256 units of the first argument
--]]

function rain:RemoveVolume(vPos)
	for k, v in pairs(self.volumes) do
		if ((v.Min:Distance(vPos) < 256) or (v.Max:Distance(vPos) < 256)) then
			self.volumes[k] = nil

			if (SERVER) then
				net.Start("nRemoveVolume")
				net.WriteVector(vPos)
				net.Broadcast()
			end
			return
		end
	end
end

if (CLIENT) then
	local function nAddVolume(len)
		local Index = net.ReadInt(11)
		local NewVolume = net.ReadTable()

		GAMEMODE:AddVolume(NewVolume, Index)
	end
	net.Receive("nAddVolume", nAddVolume)

	local function nRemoveVolume(len)
		local Pos = net.ReadVector()
		GAMEMODE:RemoveVolume(Pos)
	end
	net.Receive("nRemoveVolume", nRemoveVolume)

	local function nVolume(len)
		local ChangeType = net.ReadInt(4)
		local Index = net.ReadInt(11)

		local voldata = GAMEMODE.volumeindex[GAMEMODE.volumes[Index].Type]

		if (ChangeType == E_ENTERVOLUME) then
			voldata.OnEnter(LocalPlayer(), GAMEMODE.volumes[Index].Type)
		elseif (ChangeType == E_INVOLUME) then
			voldata.WhileInside(LocalPlayer(), GAMEMODE.volumes[Index].Type)
		elseif (ChangeType == E_EXITVOLUME) then
			voldata.OnExit(LocalPlayer(), GAMEMODE.volumes[Index].Type)
		end
	end
	net.Receive("nVolume", nVolume)
end

--[[
	This needs to be moved to a config file
	
	if its moved to the config file it needs to actually be set up with functions, might be better to just have these setup in the specific files they're needed.
--]]

rain:RegisterVolumeType(
"AmbientSound",
 "Ambient Sound",
 1, 
 true, 
 {}, 
 Color(100, 255, 100, 255),
function(ent, sType, tMetadata)
		print(ent, "has entered the", sType, "volume")
end)
 
rain:RegisterVolumeType("AreaTrigger", "Area Trigger", 1, true, {}, Color(100, 100, 255, 255))
rain:RegisterVolumeType("S2KZone", "S2K Zone", 1, true, {}, Color(255, 100, 100, 255))