if CLIENT then
	local function DrawDisplay()
	if not(LevelSystemConfiguration.ShowPlayerLevel) then return end
	local shootPos = LocalPlayer():GetShootPos()
	local aimVec = LocalPlayer():GetAimVector()
	for k, ply in pairs(players or player.GetAll()) do
		if not ply:Alive() then continue end
		local hisPos = ply:GetShootPos()
		if LevelSystemConfiguration.AlwaysShowPlayerLevel and ply ~= localplayer then
				local pos = ply:EyePos()
				pos.z = pos.z + 10 -- The position we want is a bit above the position of the eyes
				pos = pos:ToScreen()
				pos.y = pos.y-20
				draw.DrawText('Level: '..(GetGlobalInt(SQLStr(ply:SteamID64()).."Level", 0)), "LevelPrompt", pos.x+1, pos.y -56, Color(0,0,0,255), 1)
				draw.DrawText('Level: '..(GetGlobalInt(SQLStr(ply:SteamID64()).."Level", 0)), "LevelPrompt", pos.x, pos.y -55, Color(255,255,255,200), 1)
		elseif not LevelSystemConfiguration.AlwaysShowPlayerLevel and hisPos:Distance(shootPos) < 250 then
			local pos = hisPos - shootPos
			local unitPos = pos:GetNormalized()

				local trace = util.QuickTrace(shootPos, pos, localplayer)
				if trace.Hit and trace.Entity ~= ply then return end
					local pos = ply:EyePos()
					pos.z = pos.z + 10 -- The position we want is a bit above the position of the eyes
					pos = pos:ToScreen()
					pos.y = pos.y-20
					draw.DrawText('Level: '..(GetGlobalInt(SQLStr(ply:SteamID64()).."Level", 0)), "LevelPrompt", pos.x, pos.y -58, Color(0,0,0,255), 1)
					draw.DrawText('Level: '..(GetGlobalInt(SQLStr(ply:SteamID64()).."Level", 0)), "LevelPrompt", pos.x+1, pos.y -57, Color(255,255,255,200), 1)
		end
	end
 
	local tr = LocalPlayer():GetEyeTrace()

end
	local OldXP = 0
	
	local function HUDPaint()
		if not LevelSystemConfiguration then return end
		if not LevelSystemConfiguration.EnableHUD then return end
		local PlayerLevel = GetGlobalInt(SQLStr(LocalPlayer():SteamID64()).."Level", 0)
		local PlayerXP = GetGlobalInt(SQLStr(LocalPlayer():SteamID64()).."XP", 0) -- Draw the XP Bar
		local percent = ((PlayerXP or 0) / math.pow((((10+((PlayerLevel*(PlayerLevel+1)*90))))*.261), 2.131)) -- Gets the accurate level up percentage
		local drawXP = Lerp(8 * FrameTime(), OldXP, percent)
		OldXP = drawXP
		local percent2 = percent * 100
		percent2 = math.Round(percent2)
		percent2 = math.Clamp(percent2, 0, 99) -- Make sure it doesn't round past 100 %
		surface.SetDrawColor(0, 0, 0, 200)
		surface.DrawRect(10, (ScrH()/2) - 400, 200, 15) -- Draw the XP Bar before the texture
		surface.SetDrawColor(LevelSystemConfiguration.LevelBarColor[1], LevelSystemConfiguration.LevelBarColor[2], LevelSystemConfiguration.LevelBarColor[3], 255)
		surface.DrawRect(10, (ScrH()/2) - 400, 200 * drawXP, 15) -- Render the texture
		draw.DrawText(math.Truncate((GetGlobalInt(SQLStr(LocalPlayer():SteamID64()).."XP", 0) or 0), 0)..' / '..math.Truncate(math.pow((((10+((PlayerLevel*(PlayerLevel+1)*90))))*.261), 2.131)), "HeadBar", 110, (ScrH()/2) - 400, (LevelSystemConfiguration.XPTextColor or Color(255, 255, 255, 255)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		
		local rankName = ""
		if (GetGlobalInt(SQLStr(LocalPlayer():SteamID64()).."Level", 0) or 0) == 1 then
			rankName = "Rookie"
		elseif (GetGlobalInt(SQLStr(LocalPlayer():SteamID64()).."Level", 0) or 0) == 2 then
			rankName = "Experienced"
		elseif (GetGlobalInt(SQLStr(LocalPlayer():SteamID64()).."Level", 0) or 0) == 3 then
			rankName = "Veteran"
		elseif (GetGlobalInt(SQLStr(LocalPlayer():SteamID64()).."Level", 0) or 0) == 4 then
			rankName = "Expert"
		elseif (GetGlobalInt(SQLStr(LocalPlayer():SteamID64()).."Level", 0) or 0) == 5 then
			rankName = "Master"
		else
			rankName = "NA"
		end
		draw.SimpleText('Level: ' .. rankName, "LevelPrompt", 10, (ScrH()/2) - 425, ((Color(0, 0, 0, 255))), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
		draw.SimpleText('Level: ' .. rankName, "LevelPrompt", 11, (ScrH()/2) - 426, (LevelSystemConfiguration.LevelColor or (Color(0, 0, 0, 255))), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
		DrawDisplay()
	end
	hook.Add("HUDPaint", "RaindropLevels:HUDPaint", HUDPaint)
end