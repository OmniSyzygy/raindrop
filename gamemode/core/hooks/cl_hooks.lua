-- Enumeration
HUD_STALKER_COP = 1;
HUD_CLOCKWORK = 2;
HUD_NUTSCRIPT = 3;
HUD_COMBINECONTROL = 4;
HUD_MINIMUM = 5;
HUD_3D = 6;
HUD_SANDBOX = 7;

CreateClientConVar("RD_HUD_TYPE", HUD_STALKER_COP);

local tHeadBobTarget = {}
tHeadBobTarget[1] = {v = Vector(-0.15,0.1,0.45), a = Angle(-0.25,-0.25,0)}
tHeadBobTarget[2] = {v = Vector(0.2,-0.05,-0.3), a = Angle(0.25,0.1,0)}

function rain:CalcView(pClient, vPos, aAngs, nFOV, nNearZ, nFarZ)
	--[[
	local velocity = pClient:GetVelocity():Length()
	local alpha = Lerp((velocity / 400), 0, 1)
	local targetalpha = (math.sin(CurTime() * (10)) + 0.5)
	local vLocalPos, aLocalAngs = WorldToLocal(vPos, aAngs, pClient:GetPos(), pClient:GetAngles())
	-- do headbob stuff past here --

	-- lerp between the two targets
	local vHeadBobPos = LerpVector(targetalpha, tHeadBobTarget[1].v, tHeadBobTarget[2].v)
	local aHeadBobAngs = LerpAngle(targetalpha, tHeadBobTarget[1].a, tHeadBobTarget[2].a)

--	print(vHeadBobPos);
--	print(aHeadBobAngs);

	vLocalPos = LerpVector(alpha, vLocalPos, vHeadBobPos + vLocalPos)
	aLocalAngs = LerpAngle(alpha, aLocalAngs, aHeadBobAngs + aHeadBobAngs)

	-- dont do headbob stuff past here --
	local vWorldPos, aWorldAngs = LocalToWorld(vLocalPos, aLocalAngs, pClient:GetPos(), pClient:GetAngles()) 
	local view = {}
--	view.origin = vWorldPos
--	view.angles = aAngs
--	view.origin = vLocalPos + pClient:GetPos();
	view.angles = aLocalAngs + pClient:GetAngles();
	view.fov = nFOV
	view.drawviewer = false
	print(view.origin);
	print(view.angles);
--	PrintTable(view);

	return view
	--]]
end

--[[
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
});
--]]

local radarMat = Material("stalker/hud_radar_nobars.png");
local compassMat = Material("stalker/hud_radar_compass.png");
local statusMat = Material("stalker/hud_status.png");
local healthMat = Material("stalker/hud_status_health.png", "noclamp");
local stamMat = Material("stalker/hud_status_stam.png", "noclamp");
local barMat = Material("stalker/hud_3d_health.png", "noclamp");

local colorWhite = Color(255, 255, 255, 255);
local colorYellow = Color(239, 158, 14, 255);
local fadedYellow = Color(239, 158, 14, 100);
local colorBlue = Color(0, 50, 150, 255);
local colorGreen = Color(0, 150, 0, 255);
local colorGray = Color(50, 50, 50, 150);
local colorBlack = Color(0, 0, 0, 125);
local colorRed = Color(255, 0, 0, 255);

surface.CreateFont("RD.HUDLarge", {
	font = "GraffitiOne",
	size = 50,
	weight = 500
});

surface.CreateFont("RD.HUDNormal", {
	font = "GraffitiOne",
	size = 35,
	weight = 500
});

surface.CreateFont("RD.HUDSmall", {
	font = "Arial",
	size = 20,
	weight = 500
});

surface.CreateFont("RD.3DHUDNormal", {
	font = "Arial",
	size = 30,
	weight = 1000
});

--[[
	Credits to Willox on facepunch for the minimap code. BIG thank you!
	https://facepunch.com/member.php?u=257577
--]]
local function GenerateCircleVertices( x, y, radius, ang_start, ang_size )
    local vertices = {};
    local passes = 64; -- Seems to look pretty enough
    
    -- Ensure vertices resemble sector and not a chord
    vertices[ 1 ] = { 
        x = x,
        y = y
    };

    for i = 0, passes do
        local ang = math.rad(-90 + ang_start + ang_size * i / passes);

        vertices[ i + 2 ] = {
            x = x + math.cos( ang ) * radius,
            y = y + math.sin( ang ) * radius
        };
    end;

    return vertices;
end;

local RADAR_RADIUS = ScrH() * 0.123;
local RADAR_X, RADAR_Y = RADAR_RADIUS + (ScrW() * 0.0245), RADAR_RADIUS + (ScrH() * 0.015);
local RADAR_BARSIZE = RADAR_RADIUS / 9;
local RADAR_LINESIZE = 3; -- Outline and inline

local inner_vertices = GenerateCircleVertices(RADAR_X, RADAR_Y, RADAR_RADIUS - RADAR_BARSIZE - RADAR_LINESIZE * 2, 0, 360);
local inner_color = Color(0, 0, 0, 210);

local tex_white = surface.GetTextureID("vgui/white");

local rendering_map = false;
local map_rt = GetRenderTarget("RD.Minimap", RADAR_RADIUS * 2, RADAR_RADIUS * 2, true);
local map_rt_mat = CreateMaterial("RD.MinimapMat", "UnlitGeneric", {["$basetexture"] = "RD.Minimap"});

local function DrawMinimap()
	render.PushFilterMag( TEXFILTER.ANISOTROPIC )
	render.PushFilterMin( TEXFILTER.ANISOTROPIC )

		-- Render orthographic map to RT
		local old_rt = render.GetRenderTarget()
		local old_w, old_h = ScrW(), ScrH()

		rendering_map = true

		render.SetRenderTarget( map_rt )
			render.SetViewPort( 0, 0, RADAR_RADIUS * 2, RADAR_RADIUS * 2 )

				render.Clear( 0, 0, 0, 0 )

				local trace = util.TraceLine({
					start = EyePos(),
					endpos = EyePos() + Vector(0, 0, 100000)
				});
				local pos = trace.HitPos;
				local ang = Angle(90, EyeAngles().y, 0);

				render.RenderView({
					origin = pos,
					angles = ang,
					x = 0,
					y = 0,
					w = RADAR_RADIUS * 2,
					h = RADAR_RADIUS * 2,
					ortho = true,
					ortholeft = -1000,
					orthoright = 1000,
					orthotop = -1000,
					orthobottom = 1000,
					drawviewmodel = false
				});

			render.SetViewPort( 0, 0, old_w, old_h )
		render.SetRenderTarget( old_rt )

		rendering_map = false

		-- Bit of stencil wizardry, shit is drawn here
		render.SetStencilEnable( true )

			render.SetStencilReferenceValue( 1 )

			render.SetStencilWriteMask( 1 )
			render.SetStencilTestMask( 1 )

			render.SetStencilPassOperation( STENCIL_REPLACE )
			render.SetStencilFailOperation( STENCIL_KEEP )
			render.SetStencilZFailOperation( STENCIL_KEEP )

			render.ClearStencil()

			render.SetStencilCompareFunction( STENCIL_NOTEQUAL )
						
				surface.SetTexture( tex_white )
						
				surface.SetDrawColor( inner_color )
				surface.DrawPoly( inner_vertices )

			render.SetStencilCompareFunction( STENCIL_EQUAL ) -- Stop drawing from writing to the buffer for our MINIMAP!

				surface.SetMaterial( map_rt_mat )
				surface.DrawTexturedRect( RADAR_X - RADAR_RADIUS, RADAR_Y - RADAR_RADIUS, RADAR_RADIUS * 2, RADAR_RADIUS * 2 )

			render.ClearStencil()

	render.SetStencilEnable( false )

	render.PopFilterMag()
	render.PopFilterMin()
end;

local function DrawCoPHUD(localPlayer, scrW, scrH)
	local radarSize = scrW * 0.15;
	local radarX, radarY = scrW * 0.02, 0;

	-- Draw the radar at the top left of the screen, along with any info displayed on it.
	surface.SetDrawColor(colorWhite);
	surface.SetMaterial(radarMat);
	surface.DrawTexturedRect(radarX, radarY, radarSize, radarSize);

	-- Draw the compass.
	surface.SetDrawColor(colorWhite);
	surface.SetMaterial(compassMat);
	surface.DrawTexturedRectRotated(radarX + radarSize * 0.125, radarY + radarSize * 0.12, radarSize * 0.045, radarSize * 0.13, -localPlayer:GetAngles().y);

	-- Draw the time.
	draw.SimpleText("10:46", "RD.HUDSmall", radarX + radarSize * 0.115, radarY + radarSize * 0.89, colorYellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);

	-- Draw the number of players near the client.
	local nPlayers = 0;
	local pos = localPlayer:GetPos();

	for k, v in pairs(player.GetAll()) do
		if (v == localPlayer or v:GetState() != STATE_ALIVE or !v:Alive()) then continue; end;

		if (v:GetPos():Distance(pos) <= 256) then
			nPlayers = nPlayers + 1;
		end;
	end;

	if (nPlayers > 0) then
		draw.SimpleText(nPlayers, "RD.HUDNormal", radarX + radarSize * 0.945, radarY + radarSize * 0.52, fadedYellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
	end;

	-- Draw the status panel at the bottom right of the screen.
	local statusW, statusH = scrW * 0.16, scrH * 0.165;
	local statusX, statusY = scrW * 0.995 - statusW, scrH * 0.985 - statusH;

	surface.SetDrawColor(colorWhite);
	surface.SetMaterial(statusMat);
	surface.DrawTexturedRect(statusX, statusY, statusW, statusH);

	-- Health Bar
	local healthFraction = localPlayer:Health() / localPlayer:GetMaxHealth();
	local healthWidth = statusW * 0.625;

	surface.SetDrawColor(colorWhite);
	surface.SetMaterial(healthMat);
	surface.DrawTexturedRectUV(statusX + statusW * 0.258, statusY + statusH * 0.115, healthWidth * healthFraction, statusH * 0.125, 0, 0, healthFraction, 0);

	-- Stamina Bar
	local stamFraction = 1; -- Placeholder until a stamina value can be supplied.
	local stamWidth = statusW * 0.63;

	surface.SetDrawColor(colorWhite);
	surface.SetMaterial(stamMat);
	surface.DrawTexturedRectUV(statusX + statusW * 0.257, statusY + statusH * 0.295, stamWidth * stamFraction, statusH * 0.08, 0, 0, stamFraction, 0);

	local activeWep = localPlayer:GetActiveWeapon();

	--Ammo Indicator
	if (IsValid(activeWep)) then
		local clip1 = activeWep:Clip1();
		local extraAmmo = localPlayer:GetAmmoCount(activeWep:GetPrimaryAmmoType());

		if ((clip1 and clip1 > 0) or (extraAmmo and extraAmmo > 0)) then	
			if (clip1 >= 0) then		
				draw.SimpleText(clip1, "RD.HUDLarge", statusX + statusW * 0.41, statusY + statusH * 0.59, colorYellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
			end;

			draw.SimpleText(extraAmmo, "RD.HUDNormal", statusX + statusW * 0.335, statusY + statusH * 0.81, colorYellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
			draw.SimpleText("0", "RD.HUDNormal", statusX + statusW * 0.49, statusY + statusH * 0.81, fadedYellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
		end;
	end;

	DrawMinimap();
end;

local function DrawClockworkHUD(localPlayer, scrW, scrH)
	local barX, barY, barW, barH = scrW * 0.01, scrH * 0.01, scrW * 0.3, 12;

	-- Health Bar.
	local fraction = localPlayer:Health() / localPlayer:GetMaxHealth();

	surface.SetDrawColor(colorBlack);
	surface.DrawRect(barX, barY, barW, barH);
	surface.SetDrawColor(colorRed);
	surface.DrawRect(barX + 2, barY + 2, (barW - 4) * fraction, barH - 4);
	barY = barY + barH + 14;

	-- Armor Bar.
	local fraction = localPlayer:Armor() / 100;

	if (fraction > 0) then
		surface.SetDrawColor(colorBlack);
		surface.DrawRect(barX, barY, barW, barH);
		surface.SetDrawColor(colorBlue);
		surface.DrawRect(barX + 2, barY + 2, (barW - 4) * fraction, barH - 4);
		barY = barY + barH + 14;
	end;

	-- Stamina Bar Placeholder.
	local fraction = 1;

	if (fraction < 0.75) then
		surface.SetDrawColor(colorBlack);
		surface.DrawRect(barX, barY, barW, barH);
		surface.SetDrawColor(colorGreen);
		surface.DrawRect(barX + 2, barY + 2, (barW - 4) * fraction, barH - 4);
		barY = barY + barH + 14;
	end;
end;

local blur = Material("pp/blurscreen")

local function Draw3DHUD(localPlayer, scrW, scrH)
	local eyePos = localPlayer:EyePos();
	local eyeAngles = localPlayer:EyeAngles();
	local viewmodel = localPlayer:GetViewModel(0);
	local attachmentIndex = viewmodel:LookupAttachment("muzzle")		
	local attachment = viewmodel:GetAttachment(attachmentIndex);
	local position = eyePos + (eyeAngles:Right() * 10) + (eyeAngles:Forward() * -20);
				
	if (attachment) then
		position = attachment.Pos - viewmodel:GetRight() * 10;
	end;

	position = position + eyeAngles:Forward() * 225;
	position = position + eyeAngles:Right() * -275;
	position = position + eyeAngles:Up() * -75;

	eyeAngles:RotateAroundAxis(eyeAngles:Forward(), 90);
	eyeAngles:RotateAroundAxis(eyeAngles:Right(), 25);

	render.ClearStencil()
	render.SetStencilEnable(true)
	render.SetStencilCompareFunction(STENCIL_ALWAYS)
	render.SetStencilPassOperation(STENCIL_REPLACE)
	render.SetStencilFailOperation(STENCIL_KEEP)
	render.SetStencilZFailOperation(STENCIL_KEEP)
	render.SetStencilWriteMask(254)
	render.SetStencilTestMask(254)
	render.SetStencilReferenceValue(45)

	local ammoW, ammoH = 55, 60;

	cam.Start3D();
		cam.Start3D2D(position, eyeAngles, 0.5);
			draw.RoundedBox(0, 0, 0, ammoW, ammoH, colorGray);
		cam.End3D2D();
	cam.End3D();

	render.SetStencilCompareFunction(STENCIL_EQUAL)

	render.SetMaterial(blur);
	render.DrawScreenQuad();
	render.SetStencilEnable(false);

	cam.Start3D();
		cam.Start3D2D(position, eyeAngles, 0.5);
			local activeWep = localPlayer:GetActiveWeapon();

			draw.RoundedBox(0, 0, 0, ammoW, ammoH, colorGray);

			--Ammo Indicator
			if (IsValid(activeWep)) then
				local clip1 = activeWep:Clip1();
				local extraAmmo = localPlayer:GetAmmoCount(activeWep:GetPrimaryAmmoType());

				if ((clip1 and clip1 > 0) or (extraAmmo and extraAmmo > 0)) then
					
					if (clip1 >= 0) then		
						draw.SimpleText(clip1, "RD.HUDNormal", ammoW * 0.5, ammoH * 0.30, colorWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
					end;

					draw.SimpleText(extraAmmo, "RD.HUDNormal", ammoW * 0.5, ammoH * 0.70, colorWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
				end;
			end;

			local fraction = localPlayer:Health() / localPlayer:GetMaxHealth();
			local healthX, healthY = 60, 10;
			local barW, barH = 124, 17;
			
			surface.SetDrawColor(colorBlack);
			surface.SetMaterial(barMat);
			surface.DrawTexturedRect(healthX, healthY, barW, barH);

			surface.SetDrawColor(colorYellow);
			surface.SetMaterial(barMat);
			surface.DrawTexturedRectUV(healthX, healthY, barW * fraction, barH, 0, 0, fraction, 0);

			fraction = localPlayer:Armor() / 100; healthY = 35;
			
			surface.SetDrawColor(colorBlack);
			surface.SetMaterial(barMat);
			surface.DrawTexturedRect(healthX, healthY, barW, barH);

			if (fraction > 0) then
				surface.SetDrawColor(colorBlue);
				surface.SetMaterial(barMat);
				surface.DrawTexturedRectUV(healthX, healthY, barW * fraction, barH, 0, 0, fraction, 0);
			end;

			-- Stamina placeholder.
			fraction = 0.75; healthY = 62; barH = 5; barW = 185;
			
			if (fraction < 1) then
				surface.SetDrawColor(colorBlack);
				surface.DrawRect(0, healthY, barW, barH);

				surface.SetDrawColor(colorGreen);
				surface.DrawRect(0, healthY, barW * fraction, barH);
			end;

		cam.End3D2D();
	cam.End3D();

	DrawMinimap();
end;

local hudCheck = {
	[HUD_STALKER_COP] = DrawCoPHUD,
	[HUD_CLOCKWORK] = DrawClockworkHUD,
	[HUD_3D] = Draw3DHUD
};

//local CHOSEN_HUD = HUD_3D;
//local CHOSEN_HUD = HUD_CLOCKWORK;
//local CHOSEN_HUD = HUD_STALKER_COP;
//local CHOSEN_HUD = HUD_SANDBOX;

function rain:HUDPaint()
	local localPlayer = LocalPlayer();

	if localPlayer:GetState() == STATE_ALIVE and localPlayer:Alive() then
		local scrW, scrH = ScrW(), ScrH();
		local chosenHUD = hudCheck[GetConVar("RD_HUD_TYPE"):GetInt() or HUD_STALKER_COP];

		if (chosenHUD) then
			chosenHUD(localPlayer, scrW, scrH);
		end;
	end;
end;

function rain:HUDShouldDraw(sName)
	if self.cfg.HiddenUIElements[sName] and GetConVar("RD_HUD_TYPE"):GetInt() != HUD_SANDBOX then
		return false
	else
		return true
	end
end

function rain:PreDrawSkyBox()
	if (rendering_map) then
		return true;
	end;
end;

function rain:PreRender()
	local showDefault = false;
	local isVisible = gui.IsGameUIVisible();

	if (gui.IsConsoleVisible()) then
		showDefault = true;
	end;

	if (showDefault and !isVisible) then
		showDefault = false;
	end;

	if (isVisible and !showDefault and LocalPlayer():GetCharacter()) then
		gui.HideGameUI();

		if (rain.MainMenuUI) then
			rain.MainMenuUI:Remove();
			rain.MainMenuUI = nil;
		else
			rain.MainMenuUI = vgui.Create("RD_MainMenu");
			rain.MainMenuUI:MakePopup();
		end;
	end;
end;

--[[
	Quick little code to animate the cursor until an animated texture can be made.
--]]
local cursorMats = {};
local curMat = 1;

for i = 1, 8 do
	cursorMats[i] = Material("stalker/animcursor/cursor_0"..i..".png");
end;

timer.Create("AnimCursor", 0.05, 0, function()
	curMat = curMat + 1

	if (curMat == 9) then
		curMat = 1;
	end;
end);

--[[ 
	Draw the STALKER cursor. This NEEDS to be after everything else, so the
	cursor will draw over other elements and not be drawn under them.
--]]
function rain:DrawOverlay()
	if (vgui.CursorVisible()) then
		local hoverPanel = vgui.GetHoveredPanel();

		if (hoverPanel) then
			hoverPanel:SetCursor("blank");
		end;

		local x, y = input.GetCursorPos();
		local w, h = 64, 64;

		surface.SetDrawColor(255, 255, 255, 255);
		surface.SetMaterial(cursorMats[curMat]);
		surface.DrawTexturedRect(x, y, w, h);
	end;
end;

--[[
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
--]]
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

	rain.MainMenuUI = vgui.Create("RD_MainMenu");

	rain.MainMenuUI:MakePopup();
end;