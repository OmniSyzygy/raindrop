--[[

Name: cl_buffs.lua
Creator: LivKX
For: Deadi - Raindrop GM

This is an example for vgui stuff.

]]

net.Receive("BuffStat", function(len)
	local b = net.ReadBool()
	local name = net.ReadString()
	if b then
		local time = net.ReadInt(32)
		if net.ReadTable() then
			local args = net.ReadTable()
		end
	if name == "OnFire" then
		RunConsoleCommand("say","help me im on fucking fire oh god oh why the humanity woe is me")
		-- add this buff to my hud
	end
	else
		-- remove this buff from my hud
	end
end)