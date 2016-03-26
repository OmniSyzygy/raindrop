PANEL = {}

AccessorFunc(PANEL, "m_ToolTipText", "ToolTipText");

local minheight = 256

function PANEL:Init()
	
	self:SetToolTipText("")
	self:SetSize(278, minheight)

	surface.CreateFont("TT_TitleFont", {
		font = "Constantia",
		size = 26,
		weight = 200
	})

	surface.CreateFont("TT_DescFont", {
		font = "Constantia",
		size = 18,
		weight = 200
	})

	-- this is the title of the item
	self.ToolTipTitle = vgui.Create("DLabel", self)
	self.ToolTipTitle:Dock(TOP)
	self.ToolTipTitle:DockMargin(8,16,24,4)
	self.ToolTipTitle:SetTextColor(Color(240,240,240))
	self.ToolTipTitle:SetText("")
	self.ToolTipTitle:SetFont("TT_TitleFont")
	self.ToolTipTitle:SetContentAlignment(5)

	-- this is the description text part of the tooltip

	self.ToolTipDesc = vgui.Create("DLabel", self)
	self.ToolTipDesc:Dock(TOP)
	self.ToolTipDesc:DockMargin(8,4,24,8)
	self.ToolTipDesc:SetTextColor(Color(200,200,200))
	self.ToolTipDesc:SetText("")
	self.ToolTipDesc:SetFont("TT_DescFont")
	self.ToolTipDesc:SetContentAlignment(7)
	self.ToolTipDesc:SetWrap(true)

	self:SizeToContents()
end

function PANEL:SetTitle(sNewTitle)
	self.ToolTipTitle:SetText(sNewTitle)
	self.ToolTipTitle:SizeToContentsY()
	self:SetToolTipText(sNewTitle)
end

function PANEL:SetDesc(sNewDesc)
	self.ToolTipDesc:SetText(sNewDesc)
	self.ToolTipDesc:SizeToContentsY()
end

function PANEL:Think()	
	self.ToolTipDesc:SizeToContentsY()
	self:SetTall(math.Clamp(46 + math.Clamp(self.ToolTipDesc:GetTall(), 0, ScrH()) + 12, minheight, ScrH())) -- clamps the tooltip to a minimal size of minheight
end

local tooltip = Material("stalker/ui_actor_elements.png", "noclamp mips")

function PANEL:Paint(w, h)
	--surface.SetDrawColor(255,255,255)
	--surface.DrawOutlinedRect(0,0,w,h)

	-- draw the top of the icon
	if (string.len(self:GetToolTipText()) > 0) then
		if (h < ScrH()) then
			self.TStartU = 0
			self.TEndU = 278/1024
			self.TStartV = 0
			self.TEndV = 112/1024

			surface.SetMaterial(tooltip)
			surface.DrawTexturedRectUV(0, 0, w, 112, self.TStartU, self.TStartV, self.TEndU, self.TEndV) -- draw the top portion of the tooltip

			self.BStartU = 0
			self.BEndU = 278/1024
			self.BStartV = 261/1024
			self.BEndV = 405/1024
			surface.DrawTexturedRectUV(0, h - 144, w, 144, self.BStartU, self.BStartV, self.BEndU, self.BEndV) -- draw the bottom part of the tooltip, draws from the botom up.

			local brw, brh = w, math.Clamp(h - minheight, 0, ScrH())

			if (brh > 0) then
				self.BrStartU = 0
				self.BrEndU = 278/1024

				self.BrStartV = 200/1024
				self.BrEndV = 201/1024

				surface.DrawTexturedRectUV(0, 112, w, brh, self.BrStartU, self.BrStartV, self.BrEndU, self.BrEndV) -- bridge the gap by using a tiled image to draw the difference
			end
		end
	end
end

derma.DefineControl( "RD_StalkerToolTip", "", PANEL, "DPanel" )