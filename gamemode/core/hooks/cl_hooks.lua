local tHeadBobTarget = {}
tHeadBobTarget[1] = {v = Vector(-0.15,0.1,0.45), a = Angle(0,0,0)}
tHeadBobTarget[2] = {v = Vector(0.2,-0.05,-0.3), a = Angle(0,0,0)}

function rain:CalcView(pClient, vPos, aAngs, nFOV, nNearZ, nFarZ)
	
	local velocity = pClient:GetVelocity():Length()
	local alpha = Lerp((velocity / 400), 0, 1)
	local targetalpha = (math.sin(CurTime() * (10)) + 0.5)
	local vLocalPos, aLocalAngs = WorldToLocal(vPos, aAngs, pClient:GetPos(), pClient:GetAngles())
	-- do headbob stuff past here --

	-- lerp between the two targets
	local vHeadBobPos = LerpVector(targetalpha, tHeadBobTarget[1].v, tHeadBobTarget[2].v)
	local aHeadBobAngs = LerpAngle(targetalpha, tHeadBobTarget[1].a, tHeadBobTarget[2].a)

	vLocalPos = LerpVector(alpha, vLocalPos, vHeadBobPos + vLocalPos)
	aLocalAngs = LerpAngle(alpha, aLocalAngs, aHeadBobAngs + aHeadBobAngs)

	-- dont do headbob stuff past here --
	local vWorldPos, aWorldAngs = LocalToWorld(vLocalPos, aLocalAngs, pClient:GetPos(), pClient:GetAngles()) 
	local view = {}
	view.origin = vWorldPos
	view.angles = aAngs
	view.fov = nFOV
	view.drawviewer = false

	return view
end

local LerpTarget = 0

surface.CreateFont("BlurredAmmoCounter48", {
	font = "Arial",
	size = 48,
	weight = 0,
	blursize = 3,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
}) 

surface.CreateFont("AmmoCounter48", {
	font = "Arial",
	size = 48,
	weight = 0,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
}) 

surface.CreateFont("BlurredAmmoCounter54", {
	font = "Arial",
	size = 54,
	weight = 0,
	blursize = 3,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
}) 

surface.CreateFont("AmmoCounter54", {
	font = "Arial",
	size = 54,
	weight = 0,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
}) 

function rain:HUDPaint()
	if LocalPlayer():GetState() == STATE_ALIVE and LocalPlayer():Alive() then
		if LocalPlayer():GetActiveWeapon() and IsValid(LocalPlayer():GetActiveWeapon()) then
			if LocalPlayer():GetActiveWeapon().Primary then -- check if it's a C++ weapon or not
				if LocalPlayer():GetActiveWeapon():GetMaxClip1() > 0 then
					self:DrawAmmoCounter()
				end
			elseif LocalPlayer():GetActiveWeapon():GetMaxClip1() > 0 then
				self:DrawAmmoCounter()
			end
		end
	end
end

local NextFlash = CurTime()
local FlashDelay = 0.3
local CurrentlyFlashed = false
local rescol = Color(255, 255, 255, 255)
function rain:DrawAmmoCounter(nAlpha)
	if (LocalPlayer():GetActiveWeapon():LastShootTime() > CurTime() - 3) then

		DrawFancyRect(Color(0, 0, 0, 75), ScrW() - 32 - 128, ScrH() - 32 - 128, 128, 128)
	
		if (LocalPlayer():GetActiveWeapon():LastShootTime() < CurTime() - 0.15) then
			surface.SetFont("AmmoCounter54")
		else
			surface.SetFont("BlurredAmmoCounter54")
		end
	
		local toptext = LocalPlayer():GetActiveWeapon():Clip1().."/"..LocalPlayer():GetActiveWeapon():GetMaxClip1()
		local tw, th = surface.GetTextSize(toptext)
	
		surface.SetTextColor(0, 0, 0, 100)
		surface.SetTextPos(ScrW() - 32 + 2 - 64 - (tw/2), ScrH() - 32 + 2 - 64 - th)
		surface.DrawText(toptext)
	
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetTextPos(ScrW() - 32 - 64 - (tw/2), ScrH() - 32 - 64 - th)
		surface.DrawText(toptext)
	
		if (LocalPlayer():GetActiveWeapon():LastShootTime() < CurTime() - 0.15) then
			surface.SetFont("AmmoCounter48")
		else
			surface.SetFont("BlurredAmmoCounter48")
		end
	
		local toptext = "+"..LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType())
		local tw, th = surface.GetTextSize(toptext)
		
		if (LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType()) == 0) then
			if (CurTime() > NextFlash and !CurrentlyFlashed) then
				NextFlash = CurTime() + FlashDelay
				CurrentlyFlashed = true
				rescol = Color(255, 0, 0, 255)
			elseif (CurTime() > NextFlash  and CurrentlyFlashed) then
				NextFlash = CurTime() + FlashDelay
				CurrentlyFlashed = false
				rescol = Color(255, 255, 255, 255)
			end
		else 
			rescol = Color(255, 255, 255, 255)	
		end
	
		surface.SetTextColor(0, 0, 0, 100)
	
		surface.SetTextPos(ScrW() - 32 + 2 - 64 - (tw/2), ScrH() + 2 - 48 - th)
		surface.DrawText(toptext)
	
		surface.SetTextColor(rescol)
	
		surface.SetTextPos(ScrW() - 32 - 64 - (tw/2), ScrH() - 48 - th)
		surface.DrawText(toptext)

	end
end

--[[
local LocalPlayerValid = false

function rain:Think()
	if LocalPlayer() and IsValid(LocalPlayer()) and !LocalPlayerValid then
		LocalPlayerValid = true
		local ui = vgui.Create("RD_MainMenu")
		ui:MakePopup()
	end
end
--]]

function rain:InitPostEntity()
	rain:OnClientInitialized();
end;

function rain:OnClientInitialized()
//	rain.chat.clientspawn()

	local ui = vgui.Create("RD_MainMenu");

	ui:MakePopup();
end;