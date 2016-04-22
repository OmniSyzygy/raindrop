PANEL = {}

function PANEL:Init()
	self.HTMLPanel = vgui.Create("RD_HTMLPanel", self)
	--self.HTMLPanel:Dock(FILL)
	self.HTMLPanel:LoadHTMLComponent("chatbox")
	self.HTMLPanel:SetPos(0, 22)
	self.HTMLPanel:SetSize(650, 350)
	for i = 1, 60 do
		self.HTMLPanel:RunJavascript('chatbox.AddMessage("testman", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque tincidunt augue ex, in hendrerit ligula maximus eget. Proin at orci lacus. Ut eget diam neque. Curabitur elementum fringilla purus in euismod. Etiam porttitor mi in venenatis lacinia. Nunc in felis efficitur, hendrerit dui eu, feugiat arcu. Curabitur pellentesque, velit in rhoncus ullamcorper, nisi erat accumsan lorem, viverra vehicula tortor sem ac dolor. Vestibulum vel tincidunt arcu, ac malesuada tortor. Duis et risus placerat, aliquam urna nec, ultrices turpis. Phasellus rutrum vehicula dapibus. ")')
	end

	self.chatopen = false
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