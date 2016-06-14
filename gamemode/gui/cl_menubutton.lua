local PANEL = {}

surface.CreateFont("RD.MenuButtonFont", {
	font = "GraffitiOne",
	size = 30,
	weight = 1000
})

function PANEL:Init()
	self:SetTall(72)
	self:SetFont("RD.MenuButtonFont")
	self:SetTextColor(Color(220, 220, 220))
	self:SetBright(true)
end

function PANEL:Paint(w, h)
--	local w, h = self:GetSize()
--	rain.skin.paintbutton(w, h, self, Color(0, 0, 0, 255))
end

derma.DefineControl("RD_MenuButton", "", PANEL, "DButton")