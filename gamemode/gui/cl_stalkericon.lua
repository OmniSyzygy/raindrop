PANEL = {}

AccessorFunc(PANEL, "m_Rotated", "Rotated",  FORCE_BOOL) -- wether or not there is a ccstalkerprogress bar reference to this file that this file should be setting progress on
AccessorFunc(PANEL, "m_cctooltiptitle", "TooltipTitle")
AccessorFunc(PANEL, "m_cctooltipdesc", "TooltipDesc")

renderdIcons = renderdIcons or {}
function renderNewIcon(panel, itemTable)
	if ((itemTable.iconCam and !renderdIcons[string.lower(itemTable.Model)]) or itemTable.forceRender) then
		local iconCam = itemTable.iconCam
		iconCam = {
			cam_pos = iconCam.pos,
			cam_fov = iconCam.fov,
			cam_ang = iconCam.ang,
		}
		renderdIcons[string.lower(itemTable.Model)] = true
		
		panel.Icon:RebuildSpawnIconEx(iconCam)
	end
end

function PANEL:Init()
	self:SetTooltipTitle("")
	self:SetTooltipDesc("")

	self:SetRotated(false)
	self.StartU, self.StartV, self.EndU, self.EndV = 0, 0, 0, 0
end

function PANEL:SetCoords(StartX, EndX, StartY, EndY, model)
	model = model or "models/props_junk/watermelon01.mdl"
	
	if model then
		self:SetSize(StartX * 50, StartY * 50)
		self:SetModel(model)
	end

	local ImageSize = {w = 2048, h = 4096}
	local IconSize = 50 -- this should awlays be 50

	if (self:GetRotated()) then
		ImageSize = {w = 4096, h = 2048}
	end

	if (self:GetRotated()) then
		StartX = (ImageSize.w/IconSize - StartX)
		EndX = (ImageSize.w/IconSize - EndX)
		StartY = (ImageSize.h/IconSize - StartY)
		EndY = (ImageSize.h/IconSize - EndY)
	end

	self.StartU  = (StartX * IconSize) / ImageSize.w
	self.EndU    = (EndX * IconSize) / ImageSize.w

	self.StartV = (StartY * IconSize) / ImageSize.h
	self.EndV = (EndY * IconSize) / ImageSize.h

end

local iconmat = Material("stalker/ui_icon_equipment.png", "noclamp mips")
local iconmat_rot = Material("stalker/ui_icon_equipment_rotated.png", "noclamp mips")

function PANEL:Paint( w, h )
	--surface.DrawTexturedRectUV( number x, number y, number width, number height, number startU, number startV, number endU, number endV )
	surface.SetMaterial(iconmat)
	surface.SetDrawColor(Color(255,255,255,255))
	if (self:GetRotated()) then
		surface.SetMaterial(iconmat_rot)
		surface.DrawTexturedRectUV(0, 0, w, h, self.StartU, self.EndV, self.EndU, self.StartV) 
	else
		surface.SetMaterial(iconmat)
		surface.DrawTexturedRectUV(0, 0, w, h, self.StartU, self.StartV, self.EndU, self.EndV) 
	end
	return true
end

function PANEL:PaintOver( w, h )
	self:DrawSelections()
end

function PANEL:Think()
	self:PostThink()
end

function PANEL:OnCursorEntered()
	if (!input.IsMouseDown(MOUSE_LEFT) and !self:GetRotated()) then
		DrawToolTip(self)
	end
end

function PANEL:PostThink()
	if (self:IsHovered() and !input.IsMouseDown(MOUSE_LEFT) and !self:GetRotated()) then
		UpdateToolTipTime()
	end
end

derma.DefineControl( "RD_StalkerIcon", "", PANEL, "SpawnIcon" )