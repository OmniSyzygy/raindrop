-- accidentally committed the CC skin

-- # Micro-ops
local rain = rain

rain.skin = {}

function rain.skin.paintpanel(w, h, p, color)
	if !color then
		surface.SetDrawColor(120, 120, 120)
	else
		surface.SetDrawColor(color)
	end

	surface.DrawRect(0, 0, w, h)
end

function rain.skin.paintbutton(w, h, p, color)
	if !color then
		surface.SetDrawColor(60, 60, 60)
	else
		surface.SetDrawColor(color)
	end

	surface.DrawRect(0, 0, w, h)
	surface.DrawOutlinedRect(0, 0, w, h)
end