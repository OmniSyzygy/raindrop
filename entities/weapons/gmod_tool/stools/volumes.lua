TOOL.ClientConVar[ "type" ] = "AreaTrigger";
TOOL.ClientConVar[ "min" ] = "0 0 0";
TOOL.ClientConVar[ "max" ] = "0 0 0";

TOOL.Category		= "Teardrop";
TOOL.Name			= "#Volumes";
TOOL.Command		= nil;
TOOL.ConfigName		= "";

if( CLIENT ) then
	language.Add("#Volumes", "Volume")
	language.Add( "tool.volumes.name", "Volume" );
	language.Add( "tool.volumes.desc", "Used for creating volumes that have multiple applications." );
	language.Add( "tool_volumes_desc", "Used for creating volumes that have multiple applications." );
	language.Add( "tool.volumes.0", "Add a min, then a max, then click again to send to the server to save it, rightclick to reset. Right click near a min point to delete the volume. Reload to toggle between radial or box." );
	language.Add( "tool.volumes.1", "Add the max point or hit reload to reset." );
	language.Add( "tool.volumes.2", "Click anywhere to save the volume to the server, if you don't like it hit reload to reset it." );
end

local STAGE_PLACEMIN = 0
local STAGE_PLACEMAX = 1
local STAGE_SENDTOSERVER = 2

TOOL.progresstable = {}
TOOL.progresstable[STAGE_PLACEMIN] = "Add the min point."
TOOL.progresstable[STAGE_PLACEMAX] = "Add the max point."
TOOL.progresstable[STAGE_SENDTOSERVER] = "Send data?"

function TOOL:LeftClick( tr )
	
	return true;

end

function TOOL.BuildCPanel( CPanel )
	
	CPanel:AddControl("Header", { Text = "Volume Tool", Description = "This tool is for setting volumes that have multiple applications." })

	local params = {Label = "#Volumes", Height = 250, Options = {}}
	for k, v in pairs(GAMEMODE.volumeindex) do
		params.Options[v.Name] = {volumes_type = k}
	end
	CPanel:AddControl("ListBox", params)
end

function TOOL:LeftClick( trace )
		if (self:GetStage() == STAGE_PLACEMIN) then
			if (SERVER) then
				self:GetOwner():ConCommand( "volumes_min "..tostring(trace.HitPos))
				self:SetStage(STAGE_PLACEMAX)
			end
		elseif (self:GetStage() == STAGE_PLACEMAX) then
			if (SERVER) then
				self:GetOwner():ConCommand( "volumes_max "..tostring(trace.HitPos))
				self:SetStage(STAGE_SENDTOSERVER)
			end
		elseif (self:GetStage() == STAGE_SENDTOSERVER) then
			if (SERVER) then
				local NewVolume = GAMEMODE:GetStruct("Volume")
				NewVolume.Min = Vector(self:GetClientInfo("min"))
				NewVolume.Max = Vector(self:GetClientInfo("max"))
				NewVolume.Type = self:GetClientInfo("type")
				NewVolume.Radial = self.radial

				GAMEMODE:AddVolume(NewVolume)
			end
			self:SetStage(STAGE_PLACEMIN)
		end
	return true
end

function TOOL:DeleteVolume( trace )
	if (SERVER) then
		print("dad no")
		GAMEMODE:RemoveVolume(trace.HitPos)
	end
end

function TOOL:RightClick( trace )
	self:DeleteVolume(trace)

	if (SERVER) then
		self:SetStage(STAGE_PLACEMIN)
	end

	return true
end

function TOOL:Reload( trace )
	if (self:GetStage() == STAGE_SENDTOSERVER) then
			self:SetStage(STAGE_PLACEMIN)
	end
	if (IsFirstTimePredicted()) then
		self.radial = !self.radial
	end

	return false
end

function TOOL:Think()
	if (self.radial == nil) then
		self.radial = true
	end

	if (self.MinPoint == nil or self.MaxPoint == nil) then
		self.MinPoint = Vector(0,0,0)
		self.MaxPoint = Vector(0,0,0)
	end

	self.MinPoint = Vector(self:GetClientInfo("min"))

	if (self:GetStage() == STAGE_SENDTOSERVER) then
		self.MaxPoint = Vector(self:GetClientInfo("max"))
	else
		local tr = self:GetOwner():GetEyeTraceNoCursor()

		if (tr.Hit and tr.HitPos) then
			self.MaxPoint = tr.HitPos
		end
	end
end

--[[
	Function: DrawCurrentVolume
	Purpose: Special function meant to draw the volume that is being placed by the user.
--]]

if (CLIENT) then
	function TOOL:DrawCurrentVolume()
		if (self.MinPoint == nil or self.MaxPoint == nil) then
			return
		end
		local voldata = GAMEMODE:GetVolumeType(self:GetClientInfo("type"))

		cam.Start3D()
		if (self.radial) then

			render.DrawWireframeSphere(self.MinPoint, self.MaxPoint:Distance(self.MinPoint), 9, 9, voldata.DrawColor)
		else
			render.DrawWireframeBox(Vector(0,0,0), Angle(0,0,0), self.MinPoint, self.MaxPoint, voldata.DrawColor, true) 
		end

		render.DrawLine(self.MinPoint, self.MaxPoint, voldata.DrawColor, true)

		cam.End3D()

		local min = self.MinPoint:ToScreen()
		local max = self.MaxPoint:ToScreen()

		surface.SetFont("DermaLarge")
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetTextPos(min.x, min.y)
		surface.DrawText("Min")
		surface.SetTextPos(max.x, max.y)
		surface.DrawText("Max")

		surface.SetTextPos((max.x + min.x) / 2, (min.y + max.y) / 2)
		if (!self.radial) then
			surface.DrawText("Distance: "..math.floor(self.MaxPoint:Distance(self.MinPoint)))
		else
			surface.DrawText("Radius: "..math.floor(self.MaxPoint:Distance(self.MinPoint)))
		end
	end
end

function TOOL:DrawToolScreen(w, h)
	surface.SetDrawColor(Color(20,20,20))
	surface.DrawRect(0,0,w,h)

	draw.SimpleText(self:GetClientInfo("type"), "DermaLarge", w/2, h/8, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(self.progresstable[self:GetStage()], "DermaLarge", w/2, h/4, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if (self.radial) then
		surface.DrawCircle(w/2, (h/2) + (h/6), w/4, Color(255,100,100,255))
	else
		surface.SetDrawColor(100,255,100,255)
		surface.DrawOutlinedRect((w/16)*6, (h/16) * 8, (w/16) * 4, (h/16) * 4)
	end
end

function TOOL:DrawHUD()
	if (GAMEMODE and GAMEMODE.volumes) then
			for k, v in pairs(GAMEMODE.volumes) do
				local voldata = GAMEMODE:GetVolumeType(v.Type)
				cam.Start3D()
					if (v.Radial) then
						render.DrawWireframeSphere(v.Min, v.Max:Distance(v.Min), 9, 9, voldata.DrawColor)
						render.DrawLine(v.Min, v.Max, voldata.DrawColor, true)
					else
						render.DrawWireframeBox(Vector(0,0,0), Angle(0,0,0), v.Min, v.Max, voldata.DrawColor, true)
					end
	
					local min = v.Min:ToScreen()
					local max = v.Max:ToScreen()
				cam.End3D()

				if (self:GetStage() == STAGE_PLACEMIN) then
					surface.SetFont("DermaDefaultBold")
					surface.SetTextColor(voldata.DrawColor)
					surface.SetTextPos(min.x, min.y)
					surface.DrawText("Min")
					surface.SetTextPos(max.x, max.y)
					surface.DrawText("Max")
			
					surface.SetTextPos((max.x + min.x) / 2, (min.y + max.y) / 2)

					if (v.Radial) then
						surface.DrawText("Radius: "..math.floor(self.MaxPoint:Distance(self.MinPoint)))
					else
						surface.DrawText("Distance: "..math.floor(self.MaxPoint:Distance(self.MinPoint)))
					end
				end
			end
	end

	if (self:GetStage() != STAGE_PLACEMIN) then
		self:DrawCurrentVolume()
	end
end