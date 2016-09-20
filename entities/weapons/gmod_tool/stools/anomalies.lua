TOOL.ClientConVar[ "type" ] = "Bead"
TOOL.ClientConVar[ "SpawnPos" ] = "0 0 0"

TOOL.Category		= "Teardrop"
TOOL.Name			= "#Anomalies"
TOOL.Command		= nil
TOOL.ConfigName		= ""

if( CLIENT ) then
	language.Add("#Anomalies", "Anomalies")
	language.Add( "tool.anomalies.name", "Anomaly Tool" )
	language.Add( "tool.anomalies.desc", "Used for placing anomalies and anomaly spawn points." )
	language.Add( "tool_anomalies_desc", "Used for placing anomalies and anomaly spawn points." )
	language.Add( "tool.anomalies.0", "Place an anomaly." )
	language.Add( "tool.anomalies.1", "Confirm placement and send to server, reload sends a spawn point with the default anomaly being the one you current have." )
end

local STAGE_PLACESPAWN = 0
local STAGE_CONFIRMSPAWN = 1

TOOL.progresstable = {}
TOOL.progresstable[STAGE_PLACESPAWN] = "Place a spawn point."
TOOL.progresstable[STAGE_CONFIRMSPAWN] = "Send to server?"

function TOOL:LeftClick( tr )
	
	return true

end

function TOOL.BuildCPanel( CPanel )
	
	CPanel:AddControl("Header", { Text = "Anomaly Tool", Description = "This tool is for spawning anomalies as well as setting their spawn points." })

	local params = {Label = "#Anomalies", Height = 250, Options = {}}
	for k, v in pairs(GAMEMODE.anomalies) do
		params.Options[v.Name] = {anomalies_type = k}
	end
	CPanel:AddControl("ListBox", params)
end

function TOOL:LeftClick( trace )
	if (self:GetStage() == STAGE_PLACESPAWN) then
		self:GetOwner():ConCommand( "anomalies_SpawnPos "..tostring(trace.HitPos))
		self:SetStage(STAGE_CONFIRMSPAWN)
	else
		if (SERVER) then
			GAMEMODE:SpawnAnomaly(Vector(self:GetClientInfo("SpawnPos")), self:GetClientInfo("type"))
		end
		self:SetStage(STAGE_PLACESPAWN)
	end

	return true
end

function TOOL:RightClick( trace )
	self:SetStage(STAGE_PLACESPAWN)

	return true
end

function TOOL:Reload( trace )

	return false
end

function TOOL:DrawToolScreen(w, h)
	surface.SetDrawColor(Color(20,20,20))
	surface.DrawRect(0,0,w,h)

	draw.SimpleText("Type: "..self:GetClientInfo("type"), "DermaLarge", w/2, (h/8)*3, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(self.progresstable[self:GetStage()], "DermaLarge", w/2, (h/8)*4, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

end

function TOOL:DrawHUD()
	if (self:GetStage() != STAGE_PLACESPAWN) then
		local pos = Vector(self:GetClientInfo("SpawnPos")):ToScreen()
		surface.SetDrawColor(240, 20, 20)
		surface.DrawRect(pos.x, pos.y, 12, 12)
	end

	for k, v in pairs(ents.FindByClass("cc_anomaly")) do
		local pos = v:GetPos():ToScreen()
		
		surface.SetDrawColor(240, 240, 240)
		surface.DrawRect(pos.x, pos.y, 4, 4)

		draw.SimpleText(v:GetAName(), "DermaLarge", pos.x, pos.y - 32, Color(240, 240, 240), TEXT_ALIGN_CENTER) 
	end
end