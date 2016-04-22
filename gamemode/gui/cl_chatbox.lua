PANEL = {}

function PANEL:Init()
	self.HTMLPanel = vgui.Create("RD_HTMLPanel", self)
	--self.HTMLPanel:Dock(FILL)
	self.HTMLPanel:LoadHTMLComponent("chatbox")
	self.HTMLPanel:SetPos(0, 22)
	self.HTMLPanel:SetSize(650, 350)
	for i = 1, 25 do
		self.HTMLPanel:RunJavascript('chatbox.AddMessage("johnny guitar", "hello world! '..tostring(i)..'")')
	end

	self.chatopen = false

	self.chatinput = vgui.Create("DTextEntry", self)
	self.chatinput:SetPos(0, 275)
	self.chatinput:SetSize(650, 24)
	self.chatinput:RequestFocus()

	self.chatinput.OnEnter = function()
		self.HTMLPanel:RunJavascript('chatbox.AddMessage("johnny guitar", "'..string.JavascriptSafe(tostring(self.chatinput:GetValue()))..'")')

		self.chatinput:SetText("")
		self.chatinput:RequestFocus()
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