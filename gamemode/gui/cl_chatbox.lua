PANEL = {}
function PANEL:Init()
	self.tabs = {"ALL", "IC", "OOC", "PM", "HELP", "ADMIN", "DEV"}

	self.Organizer = vgui.Create("DPropertySheet", self)
	self.Organizer:Dock(FILL)
	self.chattabs = {}
	for i, sheet in pairs(self.tabs) do
		self.chattabs[i] = vgui.Create("RD_HTMLPanel", self.Organizer)
		self.chattabs[i]:LoadHTMLComponent("chatbox")
		self.chattabs[i]:SetSize(650, 250)
	
		self.Organizer:AddSheet(self.tabs[i], self.chattabs[i], "icon16/tick.png")
	end
end

function PANEL:GetAllTabs()
	local ret = {}
	for k, v in pairs(self.tabs) do
		table.insert(ret, k)
	end

	return ret
end

function PANEL:AddChat(sSender, sNewChat, tTabs)
	local tTabs = tTabs or self:GetAllTabs()

	for k, v in pairs(tTabs) do
		self.chattabs[v]:RunJavascript("chatbox.AddMessage('"..sSender.."', '"..sNewChat.."')")
	end	
end

function PANEL:Paint()

end

derma.DefineControl("RD_Chatbox", "", PANEL, "DPanel")