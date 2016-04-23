local PANEL = {}

function PANEL:Init()
	local topbar = vgui.Create("DPanel", self)
	local mid = vgui.Create("DPanel", self)
	local bottom = vgui.Create("DPanel", self)

	self:SetSize(ScrW(), ScrH() + 22)

	topbar:Dock(TOP)
	topbar:SetSize(ScrW(), ScrH()*0.2)
	topbar.Paint = function()
		local w, h = topbar:GetSize()
		rain.skin.paintpanel(w, h, topbar, Color(0, 0, 0, 250))
	end
	mid:Dock(TOP)
	mid:SetSize(ScrW(), ScrH()*0.7)
	mid.Paint = function()
		local w, h = mid:GetSize()
		rain.skin.paintpanel(w, h, mid, Color(0, 0, 0, 220))
	end
	bottom:Dock(TOP)
	bottom:SetSize(ScrW(), ScrH()*0.1)
	bottom.Paint = function()
		local w, h = bottom:GetSize()
		rain.skin.paintpanel(w, h, bottom, Color(0, 0, 0, 250))
	end

	surface.CreateFont("TitleFont", {
		font = "Constantia",
		size = 92,
		weight = 600
	})

	surface.CreateFont("TitleFontBlur", {
		font = "Constantia",
		size = 92,
		weight = 600,
		blursize = 7.5,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false
	})

	local gamemodetitle_bd = vgui.Create("DLabel", topbar)
	gamemodetitle_bd:Dock(FILL)
	gamemodetitle_bd:SetContentAlignment(5)
	gamemodetitle_bd:SetText("S.T.A.L.K.E.R. ROLEPLAY")
	gamemodetitle_bd:SetFont("TitleFontBlur")
	gamemodetitle_bd:SetTextColor(Color(0,0,0,255))

	local gamemodetitle = vgui.Create("DLabel", topbar)
	gamemodetitle:Dock(FILL)
	gamemodetitle:SetContentAlignment(5)
	gamemodetitle:SetText("S.T.A.L.K.E.R. ROLEPLAY")
	gamemodetitle:SetFont("TitleFont")

	local midbar = vgui.Create("DPanel", mid)
	midbar:SetSize(450, mid:GetTall())
	midbar:SetPos((mid:GetWide()/2) - (midbar:GetWide()/2))
	midbar.Paint = function()
		local w, h = midbar:GetSize()
		rain.skin.paintpanel(w, h, bottom, Color(0,0,0,60))
	end

	local newchar = vgui.Create("RD_MenuButton", midbar)
	newchar:Dock(TOP)
	newchar:SetTall(72)
	newchar:SetText("Create Character")

	local deletechar = vgui.Create("RD_MenuButton", midbar)
	deletechar:Dock(TOP)
	deletechar:SetTall(72)
	deletechar:SetText("Delete Character")

	local loadchar = vgui.Create("RD_MenuButton", midbar)
	loadchar:Dock(TOP)
	loadchar:SetTall(72)
	loadchar:SetText("Load Character")

	local exit = vgui.Create("RD_MenuButton", midbar)
	exit:Dock(BOTTOM)
	exit:SetTall(72)
	exit:SetText("Exit")

	local setting = vgui.Create("RD_MenuButton", midbar)
	setting:Dock(BOTTOM)
	setting:SetTall(72)
	setting:SetText("Settings")

end

function PANEL:Paint()
	DrawBlurRect(0, 0, self:GetWide(), self:GetTall(), 5, 2)
end

derma.DefineControl("RD_MainMenu", "", PANEL, "DFrame")