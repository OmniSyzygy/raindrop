PANEL = {}

function PANEL:Init()
	self.TickSpacing = 4
	self.TickWidth = 2
end

function PANEL:SetColor(cColor)
	self.color = cColor
end

function PANEL:GetColor()
	return self.color or Color(255,255,255,255)
end

function PANEL:SetProgress(fProgress)
	self.progress = math.Clamp(fProgress, 0, 1)
end

function PANEL:GetProgress()
	return self.progress or 0
end

function PANEL:Paint(w, h)
	if (!self.FadeProg) then
		self.FadeProg = 0
		self.MaxTicks = w / self.TickSpacing
	end

	if (!self.HideBackground) then
		surface.SetDrawColor(10,10,10,255)
		surface.DrawRect(0,0,w,h)
	end

	if (self:GetProgress() != 0) then
		self.FadeProg = math.Approach(self.FadeProg, self:GetProgress(), FrameTime() * 1.3)
		for i = 0, math.floor(self.FadeProg * self.MaxTicks) do
			surface.SetDrawColor(self:GetColor())
			surface.DrawRect(i * self.TickSpacing, 0, self.TickWidth, h)
			surface.SetDrawColor(0,0,0,60)
			surface.DrawRect(i * self.TickSpacing, 0, 1, h)
		end
	else
		self.FadeProg = 0
	end

	return true
end

derma.DefineControl( "RD_StalkerProgressBar", "", PANEL, "DPanel" )