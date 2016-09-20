local pmeta = FindMetaTable("Player")
if (SV) then
util.AddNetworkString("rain.notify")
end

if (CL) then

	-- I'll let the GUI expert handle the drawing of notifications
	function pmeta:Notify(sNotification, nSeconds)
		if sNotification then
			nSeconds = nSeconds or 3.5
		end
	end

elseif (SV) then

	function pmeta:Notify(sNotification, nSeconds)
		net.Start("rain.notify")
			net.WriteString(sNotification or "")
			rain.net.WriteUByte(nSeconds or 0)
		net.Send(self)
	end
end
