--[[
	Filename: sh_networking.lua
	Purpose: utility library to make networking a touch easier
--]]

rain.net = {} -- net wrapper
rain.repvars = {} -- all replicated vars in the gm
rain.repvar = {} -- repvar library
rain.reptablebuffer = {}
rain.reptable = {}

--[[
	Name: Write Tiny Int
	Category: Networking
--]]

function rain.net.WriteTinyInt(nInt)
	net.WriteInt(nInt, 2 + 1)
end

--[[
	Name: Write Nibble Int
	Category: Networking
--]]

function rain.net.WriteNibbleInt(nInt)
	net.WriteInt(nInt, 4 + 1)
end

--[[
	Name: Write Byte
	Category: Networking
--]]

function rain.net.WriteByte(nInt)
	net.WriteInt(nInt, 8 + 1)
end

--[[
	Name: Write Short Int
	Category: Networking
--]]

function rain.net.WriteShortInt(nInt)
	net.WriteInt(nInt, 16 + 1)
end

--[[
	Name: Write Long Int
	Category: Networking
--]]

function rain.net.WriteLongInt(nInt)
	net.WriteInt(nInt, 31 + 1)
end

--[[
	Name: Write Tiny UInt
	Category: Networking
--]]

function rain.net.WriteTinyUInt(nUInt)
	net.WriteUInt(nUInt, 2 + 1)
end

--[[
	Name: Write Nibble UInt
	Category: Networking
--]]

function rain.net.WriteNibbleUInt(nUInt)
	net.WriteUInt(nUInt, 4 + 1)
end

--[[
	Name: Write UByte
	Category: Networking
--]]

function rain.net.WriteUByte(nUInt)
	net.WriteUInt(nUInt, 8 + 1)
end

--[[
	Name: Write Short UInt
	Category: Networking
--]]

function rain.net.WriteShortUInt(nUInt)
	net.WriteUInt(nUInt, 16 + 1)
end

--[[
	Name: Write Long UInt
	Category: Networking
--]]

function rain.net.WriteLongUInt(nUInt)
	net.WriteUInt(nUInt, 31 + 1)
end

--[[
	Name: Write Table
	Category: Networking
--]]

function rain.net.WriteTable(tTable)
	if type(tTable) == "table" then
		net.WriteString(pon.encode(tTable))
	end
end

--[[
	Name: Write Wildcard
	Category: Networking
	Desc: Write any value to the current netmessage
--]]

function rain.net.WriteWildcard(wVar)
	local encoded = pon.encode({wVar})
	local compressed = util.Compress(encoded)

	rain.net.WriteLongUInt(#compressed)
	net.WriteData(compressed, #compressed)
end

if (SV) then

	--[[
		Name: Broadcast
		Category: Networking
		Desc: Broadcasts a netmessage to all players, exlcuding admins or including admins
	--]]
	
	function rain.net.broadcast(bAdminOnly)
		if bAdminOnly then
			for k, v in pairs(player.GetAll()) do
				if v:IsAdmin() then
					net.Send(v)
				end
			end
		else
			for k, v in pairs(player.GetAll()) do
				net.Send(v)
			end
		end
	end

end

--[[
	Name: Read Table
	Category: Networking
--]]

function rain.net.ReadTable()
	return pon.decode(net.ReadString())
end

--[[
	Name: Read Tiny Int
	Category: Networking
--]]

function rain.net.ReadTinyInt()
	return net.ReadInt(2 + 1)
end

--[[
	Name: Read Nibble Int
	Category: Networking
--]]

function rain.net.ReadNibbleInt()
	return net.ReadInt(4 + 1)
end

--[[
	Name: Read Byte
	Category: Networking
--]]
	
function rain.net.ReadByte()
	return net.ReadInt(8 + 1)
end

--[[
	Name: Read Short Int
	Category: Networking
--]]
	
function rain.net.ReadShortInt()
	return net.ReadInt(16 + 1)
end

--[[
	Name: Read Long Int
	Category: Networking
--]]
	
function rain.net.ReadLongInt()
	return net.ReadInt(31 + 1)
end

--[[
	Name: Read Tiny UInt
	Category: Networking
--]]

function rain.net.ReadTinyUInt()
	return net.ReadUInt(2 + 1)
end

--[[
	Name: Read Nibble UInt
	Category: Networking
--]]
	
function rain.net.ReadNibbleUInt()
	return net.ReadUInt(4 + 1)
end

--[[
	Name: Read UByte
	Category: Networking
--]]
	
function rain.net.ReadUByte()
	return net.ReadUInt(8 + 1)
end

--[[
	Name: Read Short UInt
	Category: Networking
--]]
	
function rain.net.ReadShortUInt()
	return net.ReadUInt(16 + 1)
end

--[[
	Name: Read Long UInt
	Category: Networking
--]]

function rain.net.ReadLongUInt()
	return net.ReadUInt(31 + 1)
end

--[[
	Name: Read Wildcard
	Category: Networking
--]]

function rain.net.ReadWildcard()
	local length = rain.net.ReadLongUInt()
	local wVar = net.ReadData(length)
	wVar = util.Decompress(wVar)
	wVar = pon.decode(wVar)

	return wVar[1]
end

if (SV) then
	util.AddNetworkString("rain.clientspawn")

	function rain.net.clientplayerspawn(pClient)
		net.Start("rain.clientspawn")
		net.Send(pClient)
	end
end

if (SV) then
	util.AddNetworkString("rain.repvar.setup")
	util.AddNetworkString("rain.repvar.update")

	-- these are repvars, objects that can be created and will be automatically networked from server to client
	local rain_repvar = {}
	rain_repvar.TypeIDFilter = {}
	rain_repvar.TypeIDFilter[TYPE_ANGLE] = true
	rain_repvar.TypeIDFilter[TYPE_BOOL] = true
	rain_repvar.TypeIDFilter[TYPE_COLOR] = true
	rain_repvar.TypeIDFilter[TYPE_NUMBER] = true
	rain_repvar.TypeIDFilter[TYPE_STRING] = true
	rain_repvar.TypeIDFilter[TYPE_VECTOR] = true
	rain_repvar.TypeIDFilter[TYPE_CONVAR] = false
	rain_repvar.TypeIDFilter[TYPE_COUNT] = false
	rain_repvar.TypeIDFilter[TYPE_DAMAGEINFO] = false
	rain_repvar.TypeIDFilter[TYPE_DLIGHT] = false
	rain_repvar.TypeIDFilter[TYPE_EFFECTDATA] = false
	rain_repvar.TypeIDFilter[TYPE_ENTITY] = false
	rain_repvar.TypeIDFilter[TYPE_FILE] = false
	rain_repvar.TypeIDFilter[TYPE_FUNCTION] = false
	rain_repvar.TypeIDFilter[TYPE_IMESH] = false
	rain_repvar.TypeIDFilter[TYPE_INVALID] = false
	rain_repvar.TypeIDFilter[TYPE_LIGHTUSERDATA] = false
	rain_repvar.TypeIDFilter[TYPE_LOCOMOTION] = false
	rain_repvar.TypeIDFilter[TYPE_MATERIAL] = false
	rain_repvar.TypeIDFilter[TYPE_MATRIX] = false
	rain_repvar.TypeIDFilter[TYPE_MOVEDATA ] = false
	rain_repvar.TypeIDFilter[TYPE_NAVAREA] = false
	rain_repvar.TypeIDFilter[TYPE_NAVLADDER] = false
	rain_repvar.TypeIDFilter[TYPE_NIL] = false
	rain_repvar.TypeIDFilter[TYPE_PANEL] = false
	rain_repvar.TypeIDFilter[TYPE_PARTICLE] = false
	rain_repvar.TypeIDFilter[TYPE_PARTICLEEMITTER] = false
	rain_repvar.TypeIDFilter[TYPE_PARTICLESYSTEM] = false
	rain_repvar.TypeIDFilter[TYPE_PATH] = false
	rain_repvar.TypeIDFilter[TYPE_PHYSOBJ] = false
	rain_repvar.TypeIDFilter[TYPE_PIXELVISHANDLE] = false
	rain_repvar.TypeIDFilter[TYPE_RECIPIENTFILTER] = false
	rain_repvar.TypeIDFilter[TYPE_RESTORE] = false
	rain_repvar.TypeIDFilter[TYPE_SAVE] = false
	rain_repvar.TypeIDFilter[TYPE_SCRIPTEDVEHICLE] = false
	rain_repvar.TypeIDFilter[TYPE_SOUND] = false
	rain_repvar.TypeIDFilter[TYPE_SOUNDHANDLE] = false
	rain_repvar.TypeIDFilter[TYPE_TEXTURE] = false
	rain_repvar.TypeIDFilter[TYPE_TEXTURE] = false
	rain_repvar.TypeIDFilter[TYPE_THREAD] = false
	rain_repvar.TypeIDFilter[TYPE_USERCMD] = false
	rain_repvar.TypeIDFilter[TYPE_USERDATA] = false
	rain_repvar.TypeIDFilter[TYPE_USERMSG] = false
	rain_repvar.TypeIDFilter[TYPE_VIDEO] = false
	rain_repvar.TypeIDFilter[TYPE_TABLE] = false

	rain_repvar.rv_valid = false
	rain_repvar.rv_type = TYPE_NIL
	rain_repvar.rv_uid = 0
	rain_repvar.rv_value = 0
	rain_repvar.rv_adminonly = false
	rain_repvar.__index = rain_repvar

	--[[
		Name: Valid Type
		Category: repvar
		Desc: Returns wether or not the type is valid for a replicated var
	--]]

	function rain_repvar:ValidType(wVar)
		return self.TypeIDFilter[TypeID(wVar)]
	end

	--[[
		Name: Setup
		Category: repvar
		Desc: Sets up a new replicated var, which everytime it is set, will replicate to clients.
	--]]

	function rain_repvar:Setup(sID, wVar)
		if self:ValidType(wVar) then
			self:SetTypeID(wVar)
			self:Validate()
			self:SetUID(sID)
			self:NetSetup()
			rain.repvars[sID] = self -- reference to this metatable
		end
	end

	function rain_repvar:GetAdminOnly()
		return self.rv_adminonly
	end

	function rain_repvar:SetAdminOnly(bAdminOnly)
		self.rv_adminonly = bAdminOnly
	end

	function rain_repvar:SetUID(nUID)
		self.rv_uid = nUID
	end

	function rain_repvar:GetUID()
		return self.rv_uid
	end

	function rain_repvar:SetTypeID(wVar)
		self.rv_value = wVar
		self.rv_type = TypeID(wVar)
	end

	function rain_repvar:GetTypeID()
		return self.rv_type
	end

	function rain_repvar:Validate()
		self.rv_valid = true
	end

	function rain_repvar:InValidate()
		self.rv_valid = false
	end

	function rain_repvar:IsValid()
		return self.rv_valid
	end

	function rain_repvar:SetVar(wNewVar)
		local bUpdate = false

		if wNewVar != self:GetVar() then -- only replicate if the variable changes, this is extremely useful for doing stuff in a think hook
			bUpdate = true
		end

		if TypeID(wNewVar) == self:GetTypeID() then
			self.rv_value = wNewVar

			if bUpdate then
				self:NetUpdate()
			end
		else
			error("invalid variable type")
		end
	end

	function rain_repvar:NetUpdate()
		net.Start("rain.repvar.update")
		net.WriteString(self:GetUID())
		net.WriteBit(false)
		rain.net.WriteWildcard(self:GetVar())
		rain.net.broadcast(self:GetAdminOnly())
	end

	function rain_repvar:NetSetup()
		net.Start("rain.repvar.setup")
		net.WriteString(self:GetUID())
		net.WriteBit(false)
		rain.net.WriteWildcard(self:GetVar())
		rain.net.broadcast(self:GetAdminOnly())
	end

	function rain_repvar:GetVar()
		return self.rv_value
	end

	--[[
		Name: New
		Category: repvar
		Desc: Attempts to setup a replicated var, ID is the ID to access the var in the future, Var is the variable.
		Admin Only will only replicate this to admins.
	--]]

	function rain_repvar:New(sID, wVar, bAdminOnly)
		local NewRepVar = setmetatable({}, rain_repvar)
		NewRepVar:SetAdminOnly(bAdminOnly or false)
		NewRepVar:Setup(sID, wVar)

		if NewRepVar:IsValid() then
			return NewRepVar
		else
			error("Invalid replicated variable using Type:"..type(wVar))
		end
	end

	function rain.repvar.newrepvar(sID, wVar)
		rain_repvar:New(sID, wVar)
	end

	function rain.repvar.newadminrepvar(sID, wVar)
		rain_repvar:New(sID, wVar, true)
	end

	function rain.repvar.setvar(sID, wNewVar)
		if rain.repvars[sID] then
			rain.repvars[sID]:SetVar(wNewVar)
		end
	end

	function rain.repvar.getvar(sID)
		if sID and rain.repvars[sID] then
			return rain.repvars[sID]:GetVar()
		end
	end

	function rain.repvar.getrepvarobject(sID)
		return rain.repvars[sID]
	end

	-- replicated tables

	util.AddNetworkString("rain.reptable.setup")
	util.AddNetworkString("rain.reptable.update")

	local rain_reptable = {}
	rain_reptable.rt_uid = ""
	rain_reptable.rt_adminonly = false
	rain_reptable.__index = rain_reptable

	function rain_reptable:SetUID(sUID)
		self.rt_uid = sUID
	end

	function rain_reptable:GetUID()
		return self.rt_uid
	end

	function rain_reptable:SetAdminOnly(bAdminOnly)
		self.rt_adminonly = bAdminOnly
	end

	function rain_reptable:GetAdminOnly()
		return self.rt_adminonly
	end

	function rain_reptable:Setup()
		rain.reptablebuffer[self:GetUID()] = self
		self:NetSetup()
	end

	-- setup the table
	function rain_reptable:NetSetup()
		net.Start("rain.reptable.setup")
		net.WriteString(self:GetUID())
		rain.net.broadcast(self:GetAdminOnly())
	end

	-- update a single key in the table
	function rain_reptable:NetUpdate(sNewKey, wNewValue, bRemoveKey)
		net.Start("rain.reptable.update")
		net.WriteBool(bRemoveKey or false)
		net.WriteString(sNewKey..";"..self:GetUID())
		rain.net.WriteWildcard(wNewValue)
		rain.net.broadcast(self:GetAdminOnly())
	end

	-- adds a single key to the table
	function rain_reptable:ModifyKey(sNewKey, wNewValue)
		rain.reptablebuffer[self:GetUID()][sNewKey] = wNewValue

		self:NetUpdate(sNewKey, wNewValue)
	end

	-- removes a single key from the table
	function rain_reptable:RemoveKey(sKeyToRemove)
		rain.reptablebuffer[self:GetUID()][sKeyToRemove] = nil

		self:NetUpdate(sNewKey)
	end

	-- gets a key from the table
	function rain_reptable:GetKey(sKeyToGet)
		return rain.reptablebuffer[self:GetUID()][sKeyToGet]
	end

	function rain_reptable:New(sUID, bAdminOnly)
		if (!rain.reptablebuffer[sUID]) and (TypeID(sUID) == TYPE_STRING) then

			NewRepTable = setmetatable({}, rain_reptable)

			NewRepTable:SetUID(sUID)
			NewRepTable:SetAdminOnly(bAdminOnly)
			NewRepTable:Setup()
		else
			error("Duplicate replicated table")
		end
	end

	function rain.reptable.newreptable(sUID)
		rain_reptable:New(sUID)
	end

	function rain.reptable.setkey(sUID, sKey, wKeyValue)
		rain.reptablebuffer[sUID]:ModifyKey(sKey, wKeyValue)
	end

	function rain.reptable.getkey(sUID, sKey)
		return rain.reptablebuffer[sUID]:GetKey(sKey)
	end

	function rain.reptable.removekey(sUID, sKey)
		rain.reptablebuffer[sUID]:RemoveKey(sKey)
	end

elseif (CL) then

	function rain.repvar.setup(sID, wVar)
		rain.repvars[sID] = wVar
	end

	function rain.repvar.update(sID, wVar)
		rain.repvars[sID] = wVar
		hook.Call("rain.netvar.onupdate."..sID, rain, wVar, rain.repvars[sID]) -- new var, old var are passed as arguments
	end

	function rain.reptable.setup(sID)
		rain.reptablebuffer[sID] = {}
	end

	function rain.reptable.modifykey(sID, sKey, wVar)
		rain.reptablebuffer[sID][sKey] = wVar
	end

	net.Receive("rain.repvar.setup", function()
		local ID = net.ReadString()
		net.ReadBit()
		local wVar = rain.net.ReadWildcard()

		rain.repvar.setup(ID, wVar)
	end)

	net.Receive("rain.repvar.update", function()
		local ID = net.ReadString()
		net.ReadBit()
		local wVar = rain.net.ReadWildcard()

		rain.repvar.update(ID, wVar)
	end)

	net.Receive("rain.reptable.setup", function()
		local ID = net.ReadString()

		rain.reptable.setup(ID)
	end)

	net.Receive("rain.reptable.update", function()
		local remove = net.ReadBool()
		local data = net.ReadString()
		local var = rain.net.ReadWildcard()

		local newdat = string.Explode(";", data)

		if newdat[1] and newdat[2] then
			if remove then
				var = nil
			end

			rain.reptable.modifykey(newdat[2], newdat[1], var)
		end
	end)
end