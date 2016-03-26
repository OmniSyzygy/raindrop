PANEL = {}

local ImageSize = {w = 1024, h = 1024}

function PANEL:Init()
	self.StartU, self.StartV, self.EndU, self.EndV = 0, 0, 0, 0
end

function PANEL:SetCoords(X, Y)

	local StartX, EndX, StartY, EndY = X, X + 1, Y, Y + 1 -- don't need to specify starting points and end points since every character icon is equal in size. (thank fuck)

	local IconSize = {}
	IconSize.x = 123
	IconSize.y = 87 -- lol why even

	self.StartU  = (StartX * IconSize.x) / ImageSize.w
	self.EndU    = (EndX * IconSize.x) / ImageSize.w

	self.StartV = (StartY * IconSize.y) / ImageSize.h
	self.EndV = (EndY * IconSize.y) / ImageSize.h
end

local iconmat = Material("stalker/ui_actor_portraits.png", "noclamp")

function PANEL:Paint( w, h )

	surface.SetMaterial(iconmat)
	surface.SetDrawColor(Color(255,255,255,255))
	surface.DrawTexturedRectUV(0, 0, w, h, self.StartU, self.StartV, self.EndU, self.EndV) 

	return true
end

derma.DefineControl( "RD_StalkerCharIcon", "", PANEL, "DPanel" )