PANEL = {}
function PANEL:Init()
	self.tabs = {"ALL", "IC", "OOC", "PM", "HELP", "ADMIN", "DEV"}

	self:SetPos(rain.dpi(30, 750))
	self:SetSize(rain.dpi(700, 300))

	self.chatPanel = vgui.Create("DPropertySheet", self)
	self.chatPanel:Dock(FILL)

	for _, tab in pairs(rain.chat.tabs) do
		print(tab.sChatPrintID)
	end

	self.chatTextEntry = vgui.Create("DTextEntry", self)
	self.chatTextEntry:Dock(BOTTOM)
end


derma.DefineControl("RD_Chatbox", "", PANEL, "DFrame")