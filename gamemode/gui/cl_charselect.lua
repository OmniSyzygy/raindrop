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

	local text = "CHOOSE YOUR CHARACTER"

	local gamemodetitle_bd = vgui.Create("DLabel", topbar)
	gamemodetitle_bd:Dock(FILL)
	gamemodetitle_bd:SetContentAlignment(5)
	gamemodetitle_bd:SetText(text)
	gamemodetitle_bd:SetFont("TitleFontBlur")
	gamemodetitle_bd:SetTextColor(Color(0,0,0,255))

	local gamemodetitle = vgui.Create("DLabel", topbar)
	gamemodetitle:Dock(FILL)
	gamemodetitle:SetContentAlignment(5)
	gamemodetitle:SetText(text)
	gamemodetitle:SetFont("TitleFont")

	local midbar = vgui.Create("DPanel", mid)
	midbar:SetSize(450, mid:GetTall())
	midbar:SetPos((mid:GetWide()/2) - (midbar:GetWide()/2))
	midbar.Paint = function()
		local w, h = midbar:GetSize()
		rain.skin.paintpanel(w, h, bottom, Color(0,0,0,60))
	end
end

function PANEL:Paint()
	DrawBlurRect(0, 0, self:GetWide(), self:GetTall(), 5, 2)
end

derma.DefineControl("RD_Charselect", "", PANEL, "DPanel")