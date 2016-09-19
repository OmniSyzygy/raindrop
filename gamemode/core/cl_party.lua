--[[

Name: cl_party.lua
Creator: LivKX
For: Deadi (Raindrop GM)

]]

local myreqs = {}

function fp(name)
	name = string.lower(name);
	for _,v in ipairs(player.GetHumans()) do
		if(string.find(string.lower(v:Name()),name,1,true) != nil)
			then return v;
		end
	end
end

hook.Add( "OnPlayerChat", "PartyCommands", function( ply, text, team )
	if ply == LocalPlayer() then
	
	if (string.sub(text, 1, 6) == "/party") then

		args = string.Explode(" ",text,false)

		if args then
			if args[1] == "create" then
				if args[2] then
					net.Start("FormParty")
					net.WriteString(args[2])
					net.SendToServer()
				else
					ply:ChatPrint("No name specified!")
				end
			elseif args[1] == "leave" then
				net.Start("PartyLeave")
				net.SendToServer()
			elseif args[1] == "invite" then
				if args[2] then
					local p2 = fp(args[2])
					if IsValid(p2) then
						net.Start("PartyReq")
						net.WriteEntity(p2)
						net.SendToServer()
					else
						ply:ChatPrint("Invalid player specified")
					end
				else
					ply:ChatPrint("No name specified!")
				end
			elseif args[1] == "kick" then
				if args[2] then
					local p2 = fp(args[2])
					if IsValid(p2) then
						net.Start("PartyKick")
						net.WriteEntity(p2)
						net.SendToServer()
					else
						ply:ChatPrint("Invalid player specified")
					end
				else
					ply:ChatPrint("No name specified!")
				end
			elseif args[1] == "accept" then
				if args[2] then
					if table.HasValue(myreqs,args[2]) then
						for k,v in pairs(myreqs) do
						if args[2] == v[1] then
							net.Start("ReqResult")
							net.WriteBool(true)
							net.WriteString(v[2])
							net.SendToServer()
						end
						end
					else
						ply:ChatPrint("Invalid Number Specified!")
					end
				else
					ply:ChatPrint("No number specified!")
				end

			else
				ply:ChatPrint("Usage: /party <create/leave/invite/kick> <name/nil/player/player>")
			end
		else
			ply:ChatPrint("Usage: /party <create/leave/invite/kick/accept> <name/nil/player/player/number>")
		end

        return ""
	end

	end
		
end)

--[[

This area is for VGUI HUD displaying of party stuff
This is NOT completed, it is here as an example/base

]]

net.Receive("RefreshP", function(len)
local t = net.ReadTable()

if !t == {} then
local PartyName = t[1] -- name of party
local PartyOwner = t[2] -- owner of party
local PartyMembers

if t[3] then && t[3] != {} then
PartyMembers == t[3] -- a table of members
end
else
	-- party no longer exists or player has left
end
end)

net.Receive("PartyReqSTC", function(len)
	local from = net.WriteEntity(ply)
	local name = net.WriteString(v[1])
	local number = net.WriteInt(k,16)
	table.insert(myreqs,{number,name})
	LocalPlayer():ChatPrint("You've been invited to party "..name.." by "..from:Nick())
	LocalPlayer():ChatPrint("Join using /party accept "..number)
end)