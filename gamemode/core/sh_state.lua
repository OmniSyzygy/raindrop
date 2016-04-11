--[[
	Filename: sh_state.lua
	Description: Establishes the state that the client is in at the current time.	
--]]

rain.state = {}

-- enums for state

STATE_LOADING = 0
STATE_MENU = 1
STATE_ALIVE = 2
STATE_DEAD = 3
STATE_KO = 4
STATE_AFK = 5

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
			pClient:SetState(STATE_MENU)
		else
			pClient:SetNoDraw(false)
			rain:PlayerLoadout(pClient)
			pClient:SetState(STATE_ALIVE)
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
	return self.r_state or STATE_LOADING
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