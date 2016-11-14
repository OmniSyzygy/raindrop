--[[

Name: sv_party.lua
Creator: LivKX
For: Deadi (Raindrop GM)

]]

local parties = {}
local requests = {}

util.AddNetworkString("FormParty")
util.AddNetworkString("PartyReq")
util.AddNetworkString("PartyReqSTC")
util.AddNetworkString("ReqResult")
util.AddNetworkString("PartyLeave")
util.AddNetworkString("PartyKick")
util.AddNetworkString("RefreshP")

local meta = FindMetaTable("Player")

function PAuth(info)
local cnt = 0
for k,v in pairs(parties) do
	if v[1] == info then
		cnt = cnt + 1
	end
end
if cnt > 0 then
	return false
else
	return true
end
end

function MakeParty(ply,p)
	if IsValid(ply) then
		table.insert(parties,{p,ply,{}})
		raindrop.log.add(ply,"party","make",p)
		RefreshPForMembers(v[1])
	end
end

function meta:JoinParty(str)
	local cnt = 0
	for k,v in pairs(parties) do
		if v[1] == str then
			cnt = cnt + 1
			table.insert(v[3],self)
			self:SendLua("chat.AddText(Color( 0, 255, 128 ),'You have joined the party.')")
			RefreshPForMembers(v[1])
			raindrop.log.add(self,"party","join",p)
		end
	end
	if cnt == 0 then
		self:SendLua("chat.AddText(Color( 0, 255, 128 ),'Party no longer exists.')")
	end
end

function meta:GetParty()
	local cnt = 0
	for k,v in pairs(parties) do
		if v[2] == self then
			return v
			local cnt = cnt + 1
		elseif table.HasValue(v[3],self) then
			return v
			local cnt = cnt + 1
		end
	end
	if cnt == 0 then
		return {}
	end
end


function meta:LeaveParty()
	for k,v in pairs(parties) do
		local p = v[1]
		if v[2] == self then
			if v[3] == {} then
				table.remove(parties,k)
				self:SendLua("chat.AddText(Color( 0, 255, 128 ),'You have left the party.')")
				net.Start("RefreshP")
				net.WriteTable({})
				net.Send(self)
				raindrop.log.add(self,"party","leave",p)
			else
				v[2] = v[3][1]
				v[2]:SendLua("chat.AddText(Color( 0, 255, 128 ),'You are now the party owner.')")
				table.remove(v[3],1)
				self:SendLua("chat.AddText(Color( 0, 255, 128 ),'You have left the party.')")
				net.Start("RefreshP")
				net.WriteTable({})
				net.Send(self)
				raindrop.log.add(self,"party","leave",p)
				RefreshPForMembers(v[1])
			end
		else
			if table.HasValue(v[3],self) then
				table.RemoveByValue(v[3],self)
				self:SendLua("chat.AddText(Color( 0, 255, 128 ),'You have left the party.')")
				net.Start("RefreshP")
				net.WriteTable({})
				net.Send(self)
				raindrop.log.add(self,"party","leave",p)
				RefreshPForMembers(v[1])
			else
				self:SendLua("chat.AddText(Color( 0, 255, 128 ),'You are not in a party.')")
			end
		end
	end
end

function RefreshPForMembers(pname)
	for k,v in pairs(parties) do
		if v[1] == pname then
			local ps = {}
			table.insert(ps,v[2])
			if v[3] then
				for k,v in pairs(v[3]) do
					table.insert(ps,v)
				end
			end
			net.Start("RefreshP")
			net.WriteTable(v)
			net.Send(ps)
		end
	end
end

function GetPartyMembers(pname)
local cnt = 0
	for k,v in pairs(parties) do
		if v[1] == pname then
			local t = {v[2]}
			if v[3] && v[3] != {} then
				for k,v in pairs(v[3]) do
					table.insert(t,v)
				end
			end
			return t
			cnt = cnt + 1
		end
	end
	if cnt == 0 then
		return {}
	end
end

net.Receive("PartyLeave", function(len,ply)
ply:LeaveParty()
end)


net.Receive("FormParty", function(len,ply)
local p = net.ReadString()
if IsValid(v) then
	for k,v in pairs(parties) do
		if v[2] == ply then
			ply:SendLua("chat.AddText(Color( 0, 255, 128 ),'Sorry but you already formed a party. Leave it using /party leave!')")
		elseif table.HasValue(v[3],ply) then
			if PAuth(p) then
				MakeParty(ply,p)
				ply:SendLua("chat.AddText(Color( 0, 255, 128 ),'You have left your party and formed a new one.')")
			else
				ply:SendLua("chat.AddText(Color( 0, 255, 128 ),'Your party name is already taken. Try Again.')")
			end
		else
			if PAuth(p) then
				MakeParty(ply,p)
				ply:SendLua("chat.AddText(Color( 0, 255, 128 ),'You have formed a new party.')")
			else
				ply:SendLua("chat.AddText(Color( 0, 255, 128 ),'Your party name is already taken. Try Again.')")
			end
		end
		end	
	end
end)

net.Receive("PartyReq", function(len,ply)

local ply2 = net.ReadEntity

for k,v in pairs(parties) do
	if v[2] == ply then
		requests[ply2] = {v[1]}
		net.Start("PartyReqSTC")
		net.WriteEntity(ply)
		net.WriteString(v[1])
		net.WriteInt(k,16)
		net.Send(ply2)
	end
end

end)

net.Receive("ReqResult", function(len,ply)
local res = net.ReadBool()
local str = net.ReadString()
if res then
	ply:JoinParty(str)
	table.RemoveByValue(requests[ply],str)
elseif requests[ply] then
	table.RemoveByValue(requests[ply],str)
	ply:SendLua("chat.AddText(Color( 0, 255, 128 ),'You have denied the party request.')")
else
	--v:ChatPrint(ply:Nick().." may be exploiting or something has gone horribly wrong with party system.")
	raindrop.log.add(ply,"misc","exploit","Possible attempt to exploit party via net.send spoof request accept")
end
end

net.Receive("PartyKick", function(len,ply)
	local cnt = 0
	local ply2k = net.ReadEntity()
	if IsValid(ply2k) then
	for k,v in pairs(parties) do
		if v[2] == ply then
			cnt = cnt + 1
			ply2k:LeaveParty()
			raindrop.log.add(self,"party","kick","1","nil",ply2k)
		end 
	end
	if cnt > 0 then
		ply:SendLua("chat.AddText(Color( 0, 255, 128 ),'Kick Succcessful')")
	else
		ply:SendLua("chat.AddText(Color( 0, 255, 128 ),'You are not in a party or you are not the owner.')")
	end
	end
end)
