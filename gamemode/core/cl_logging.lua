--[[

Raindrop Logs
Made by LivKX
For: Deadi

Client File for Logs
This is an example, please build upon it.

]]

concommand.Add("openlogs",function()
	net.Start("LogsRequest")
	net.WriteInt(1800,32) -- as seen in the explanations in logs serverside, 1800 is the time range of logs to be shown. 1800 default
	net.SendToServer() -- If the client fails authentification, all admins are alerted
end)

net.Receive("SendLogs",function(len)
local logs = net.ReadTable()
--LogsDermaPanel:Show()
--vgui stuff
end)

--[[

 The output of logs would be a table in the following format:

logs{
	
{Player Name, SteamID, tag, action, value, value2, player 2 name, player 2 SteamID, TimeString,TimeStamp,map}

}

YES, THAT IS A TABLE INSIDE A TABLE.

Please, do read the comments in the sv_logging.lua file, they will really, REALLY help.

]]
