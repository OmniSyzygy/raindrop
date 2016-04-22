PANEL = {}

tabs = {"ALL", "IC", "OOC", "CSC", "PM", "HELP", "ADMIN", "DEV"}

function PANEL:Init()
	self.Organizer = vgui.Create("DPropertySheet", self)
	self.Organizer:Dock(FILL)

	for _, sheet in pairs(tabs) do
		self.HTMLPanel = vgui.Create("RD_HTMLPanel", self.Organizer)
		self.HTMLPanel:LoadHTMLComponent("chatbox")
		self.HTMLPanel:SetSize(650, 250)
		for i = 1, 50 do
			self.HTMLPanel:RunJavascript('chatbox.AddMessage("johnny guitar", "😂")')
		end
	
		self.Organizer:AddSheet(sheet, self.HTMLPanel, "icon16/tick.png")
	end

	self:SetTitle("")
	self:ShowCloseButton(false)

	self.chatopen = false

	self.chatinput = vgui.Create("DTextEntry", self)
	self.chatinput:SetPos(13, 312)
	self.chatinput:SetSize(624, 24)
	self.chatinput:RequestFocus()

	self.chatinput.OnEnter = function()
		self.HTMLPanel:RunJavascript('chatbox.AddMessage("johnny guitar", "'..string.JavascriptSafe(tostring(self.chatinput:GetValue()))..'")')

		self.chatinput:SetText("")
		self.chatinput:RequestFocus()

		self:CloseChat()
	end
end

function PANEL:Paint()

end

function PANEL:OpenChat()
	self.chatopen = true
end

function PANEL:CloseChat()
	self.chatopen = false
end

function PANEL:IsChatOpen()
	return self.chatopen 
end

derma.DefineControl("RD_Chatbox", "", PANEL, "DFrame")