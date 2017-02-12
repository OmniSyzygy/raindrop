--[[
	Filename: sh_state.lua
	Description: Establishes the state that the client is in at the current time.	
--]]

rain.state = {}

-- enums for state

E_LOADING 		= 0 --  this is before the player has any data loaded
E_MENU 			= 1 -- main menu state
E_ALIVE 		= 2 -- when the player is alive and in the world
E_ALIVE_OOC 	= 3 -- when the player is alive but OOC IE in observer
E_OBSERVER 		= 4 -- when a player is in observer
E_DEAD 			= 5 -- when a player is data
E_KO 			= 6 -- when a player is knocked out
E_AFK 			= 7 -- when a player is AFK

if (SV) then
	--[[
		Name: Player Spawn
		Category: State
		Desc: Called when a player spawns
	--]]

	function rain.state.playerspawn(pClient)
		if !pClient.character then
			pClient:KillSilent()
			pClient:SetNoDraw(true)
			pClient:SetState(E_MENU)
		else
			pClient:SetNoDraw(false)
			rain:PlayerLoadout(pClient)
			pClient:SetState(E_ALIVE)
		end
	end

end

local rainclient = FindMetaTable("Player")

--[[
	Name: Get State
	Category: State
	Desc: Gets the state that a player is currently in, the default being loading
--]]

function rainclient:GetState()
	return self.r_state or E_LOADING
end

--[[
	Name: Set State
	Category: State
	Desc: Sets the current state of the player
--]]

function rainclient:SetState(enumState)
	self.r_state = enumState

	if (SV) then
		self:SyncState()
	end
end

if (SV) then

	util.AddNetworkString("rain.syncstate")

	--[[
		Name: Sync State
		Category: State
		Desc: Syncs the state from server to client
	--]]

	function rainclient:SyncState()
		net.Start("rain.syncstate")
		rain.net.WriteTinyInt(self:GetState())
		net.Send(self)
	end

else

	net.Receive("rain.syncstate", function()
		local NewState = rain.net.ReadTinyInt()
		if IsValid(LocalPlayer()) then
			LocalPlayer():SetState(NewState)
		end
	end)

end