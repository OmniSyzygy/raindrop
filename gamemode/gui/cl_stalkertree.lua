PANEL = {}

function PANEL:Init()
end

function PANEL:Paint(w, h)

	surface.SetMaterial(iconmat)
	surface.SetDrawColor(Color(255,255,255,255))
	surface.DrawRect(0,0,w,h)

	return true
end

derma.DefineControl("RD_StalkerTree", "", PANEL, "DPanel")