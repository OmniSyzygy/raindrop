-- # Micro-ops
local rain = rain

rain.faction = {}
if (CL) then
	
	concommand.Add("dev_testcreatefaction",function()
		creationData = {}
		creationData.Name = {"Soren's Faction"}
		creationData.RankNames = {"Owner", "Lieutenant", "Peasant"}
		creationData.Desc = {"A faction about worshipping me, Soren."}
		creationData.Uniforms = {"models/cakez/rxstalker/stalker_dolg/stalker_dolg1a.mdl", "models/gman_high.mdl", "models/Humans/Group02/male_03.mdl"}

		net.Start("rain.factioncreate")
			rain.net.WriteTable(creationData)
		net.SendToServer()
	end) 

	concommand.Add("dev_testfactiondelete",function()
		net.Start("rain.testfactiondelete")
		net.SendToServer()
	end) 

	concommand.Add("dev_testfactionjoin",function()
		net.Start("rain.testfactionjoin")
		net.SendToServer()
	end) 
	
end

if (SV) then


	local charmeta = rain.character.getmeta()
	
	util.AddNetworkString("rain.testfactiondelete")
	net.Receive("rain.testfactiondelete", function(len, ply)
		if ( IsValid( ply ) ) then
			ply:GetCharacter():RemoveFaction("3")
		end
	end)

	util.AddNetworkString("rain.testfactionjoin")
	
	net.Receive("rain.testfactionjoin", function(len, ply)
		if ( IsValid( ply ) ) then
			ply:GetCharacter():JoinFaction("3","1")
		end
	end)
	
	util.AddNetworkString("rain.factioncreate")
	net.Receive("rain.factioncreate", function(len, ply)
		if ( IsValid( ply ) ) then
			local factionData = rain.net.ReadTable()
			rain:LoadVolumes()
		end
	end)

	function rain.faction.create(pOwningClient, tFactCreateData)
		if !tFactCreateData then
		print("tFactCreateData doesn't exist.")
			return
		end
		print("tFactCreateData exists.")
		local name, factionData = "error", "{}"
		--thinking this should just be converted to a string? but this is a really quick fix atm.
		local name = "{}"
		if tFactCreateData.Name then
			name = pon.encode(tFactCreateData.Name)
		end

		local ranknames = "{}"
		if tFactCreateData.RankNames then
			ranknames = pon.encode(tFactCreateData.RankNames)
		end

		local uniforms = "{}"
		if tFactCreateData.Uniforms then
			uniforms = pon.encode(tFactCreateData.Uniforms)
		end
		
		local desc = "{}"
		if tFactCreateData.Desc then
			desc = pon.encode(tFactCreateData.Desc)
		end
		
		local resources = "{}"
		
		local inventory = "{}"

		
		local InsertObj = mysql:Insert("factions")
		InsertObj:Insert("fact_name", name)
		InsertObj:Insert("fact_steamid", pOwningClient:SteamID64())
		InsertObj:Insert("fact_ranknames", ranknames)
		InsertObj:Insert("fact_uniforms", uniforms)
		InsertObj:Insert("fact_desc", desc)
		InsertObj:Insert("fact_resources", resources)
		InsertObj:Insert("fact_inventory", inventory)
		InsertObj:Callback(function(result, status, lastID)
			
		end)
		InsertObj:Execute()
	end

end