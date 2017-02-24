PANEL = {}
function PANEL:Init()

	self.Open = false

	self:SetPos(rain.dpi(30, 700))
	self:SetSize(rain.dpi(700, 350))

	self.chatPanel = vgui.Create("DPropertySheet", self)
	self.chatPanel:Dock(FILL)
	self.chatPanel.drawpanel = false
	self.chatPanel.Paint = function(p, w, h)
		if p.drawpanel then
			return false
		else
			return true
		end
	end

	self.tabs = {}
	self.sheets = {}

	for index, tab in pairs(rain.chat.tabs) do
		local sheet = vgui.Create("DPanel", self.chatPanel)
		local ScrollPanel = vgui.Create("DScrollPanel", sheet)
		ScrollPanel:Dock(FILL)

		sheet.drawpanel = false
		sheet.Paint = function(p, w, h)
			if p.drawpanel then
				return false
			else
				return true
			end
		end

		self.tabs[index] = ScrollPanel

		self.chatPanel:AddSheet(tab.sChatPrintID, sheet, tab.sIcon)
	end

	self.chatTextEntry = vgui.Create("DTextEntry", self)
	self.chatTextEntry:Dock(BOTTOM)

	self:SetTitle("")
	self:ShowCloseButton(false)

	self:MakePopup()
	rain.chat.closeChatbox()

end

function PANEL:Think()
	if !self.Open then

	end
end
			

function PANEL:Paint()

end

function PANEL:OpenChatbox()
	self.Open = true
end

function PANEL:CloseChatbox()
	self.Open = false
end

function PANEL:SetCurrentTab(nCurrentTab)
	--self.chatPanel:SetActiveTab(self.chattabs[nCurrentTab])
end

derma.DefineControl("RD_Chatbox", "", PANEL, "DFrame")