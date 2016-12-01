rain.faction = {}
if (CL) then
	
	concommand.Add("dev_testcreatefaction",function()
	creationData = {}
	creationData.Name = {"Soren's Faction"}
	creationData.RankNames = {"Owner", "Lieutenant", "Peasant"}
	creationData.Desc = {"A faction about worshipping me, Soren."}
	creationData.Uniforms = {"models/cakez/rxstalker/stalker_dolg/stalker_dolg1a.mdl", "models/gman_high.mdl", "models/Humans/Group02/male_03.mdl"}
print(creationData.Uniforms[1])
			net.Start("rain.factioncreate")
				rain.net.WriteTable(creationData)
			net.SendToServer()
	end) 

	concommand.Add("dev_testfactiondelete",function()
	print("trying to get name")
		print(LocalPlayer():GetEyeTrace().Entity:GetRPName())
	end) 

	concommand.Add("dev_testfactionjoin",function()
		PrintTable(rain.itemindex)
	--	for k, v in pairs(rain.itemindex) do
	--		local base = rain.itemindex[k].base
	--		 setmetatable(rain.itemindex[k], {__index = rain.itembuffer[base]})
	--	end
	--			PrintTable(rain.itemindex)
	--			print(rain.itemindex[1].SizeX)
	--			print(rain.itemindex[1]:GetSizeX())
		print("this should have a metatable now")
	end) 
	
		concommand.Add("dev_createitem",function()
		--rain.item.create("food", 1)
	--	LocalPlayer():GiveItem(2, 1, nil)
		net.Start("rain.createitem")
		net.SendToServer()
	end) 
	
	function cNewFaction(factionData)
		net.Start( "rain.factioncreate" )
		net.WriteTable( factionData )
		net.SendToServer()
	end
	
end

if (SV) then
		
	util.AddNetworkString("rain.createitem")
	net.Receive("rain.createitem", function(len, ply)
		if ( IsValid( ply ) ) then
			--	rain.item.new("food", 1)
			local droppos = ply:GetEyeTrace().HitPos
			print("hello trying to spawn entity")
			rain.itemindex[4]:SpawnEntity(droppos, Angle(0, 0, 0))
		end
	end)
		
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
			rain.faction.create(ply, factionData)
		end
	end)

	function rain.faction.create(pOwningClient, tFactCreateData)
		if !tFactCreateData then
		print("tFactCreateData doesn't exist.")
			return
		end
print("tFactCreateData exists.")
		local name, factionData = "error", "{}"

		if tFactCreateData.Name then
			name = tFactCreateData.Name
		end

		local ranknames = "{}"
		if tFactCreateData.RankNames then
			ranknames = pon.encode(tFactCreateData.RankNames)
		end

		local uniforms = "{}"
		if tFactCreateData.Uniforms then
			uniforms = pon.encode(tFactCreateData.Uniforms)
		end
		
		local desc = "No Desc Recorded"
		if tFactCreateData.Desc then
			desc = tFactCreateData.Desc
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