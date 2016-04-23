local PANEL = {}

function PANEL:Init()
	surface.CreateFont("RD.MenuButtonFont", {
		font = "Constantia",
		size = 24,
		weight = 600
	})

	self:SetTall(72)
	self:SetFont("RD.MenuButtonFont")
	self:SetTextColor(Color(220, 220, 220))
	self:SetBright(true)
end

function PANEL:Paint()
	local w, h = self:GetSize()
	rain.skin.paintbutton(w, h, self, Color(0, 0, 0, 100))
end

derma.DefineControl("RD_MenuButton", "", PANEL, "DButton")