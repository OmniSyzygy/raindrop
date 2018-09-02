-- # Micro-ops
local rain = rain

local blur = Material("pp/blurscreen")

function rain.dpi(nUnscaledX, nUnscaledY)
	return (nUnscaledX / 1920) * ScrW(), (nUnscaledY / 1080) * ScrH()
end

function DrawBlurRect(x, y, w, h, amount, heavyness)
	local X, Y = 0,0
	local scrW, scrH = ScrW(), ScrH()

	surface.SetDrawColor(255,255,255)
	surface.SetMaterial(blur)

	for i = 1, heavyness do
		blur:SetFloat("$blur", (i / 3) * (amount or 6))
		blur:Recompute()

		render.UpdateScreenEffectTexture()

		render.SetScissorRect(x, y, x+w, y+h, true)
			surface.DrawTexturedRect(X * -1, Y * -1, scrW, scrH)
		render.SetScissorRect(0, 0, 0, 0, false)
	end
end

function DrawFancyRect(cDrawColor, nPosX, nPosY, nWidth, nHeight, nAlpha)
	nAlpha = nAlpha or 1

	cDrawColor.a = cDrawColor.a * nAlpha
	surface.SetDrawColor(cDrawColor)
	surface.DrawRect(nPosX, nPosY, nWidth, nHeight)

	DrawBlurRect(nPosX, nPosY, nWidth, nHeight, 5, 2)

	surface.SetDrawColor(cDrawColor)
	surface.DrawOutlinedRect(nPosX, nPosY, nWidth, nHeight)

	surface.SetDrawColor(50,50,50,30 * nAlpha)
	surface.DrawRect(nPosX + nWidth - 6, nPosY - 6, 12, 12)
	surface.DrawRect(nPosX - 6, nPosY - 6, 12, 12)
	surface.DrawRect(nPosX + nWidth - 6, nPosY + nHeight - 6, 12, 12)
	surface.DrawRect(nPosX - 6, nPosY + nHeight - 6, 12, 12)

	surface.SetDrawColor(cDrawColor)
	surface.DrawOutlinedRect(nPosX + nWidth - 6, nPosY - 6, 12, 12)
	surface.DrawOutlinedRect(nPosX - 6, nPosY - 6, 12, 12)
	surface.DrawOutlinedRect(nPosX + nWidth - 6, nPosY + nHeight - 6, 12, 12)
	surface.DrawOutlinedRect(nPosX - 6, nPosY + nHeight - 6, 12, 12)

	surface.SetDrawColor(255, 255, 255, 255 * nAlpha)
	surface.DrawRect(nPosX + nWidth - 3, nPosY - 3, 6, 6)
	surface.DrawRect(nPosX - 3, nPosY - 3, 6, 6)
	surface.DrawRect(nPosX + nWidth - 3, nPosY + nHeight - 3, 6, 6)
	surface.DrawRect(nPosX - 3, nPosY + nHeight - 3, 6, 6)
end

hook.Add("HUDPaint", "testblur", function()

	local sizemul = 0.05

	for k, v in ipairs(ents.FindByClass("rd_item")) do
		local scrdata = (v:GetPos() + v:GetAngles():Up() * 10):ToScreen()
		if (scrdata.visible) then
			local tl = (v:GetPos() + (v:GetAngles():Up()) + (v:GetAngles():Up() * (9)) + (v:GetAngles():Forward()) * (-144 * sizemul)):ToScreen()
			local tr = (v:GetPos() + (v:GetAngles():Up()) + (v:GetAngles():Up() * (9)) + (v:GetAngles():Forward()) * (2 * sizemul)):ToScreen()
			local br = (v:GetPos() + ((v:GetAngles():Up() * (9)) + v:GetAngles():Up() * (-42 * sizemul)) + (v:GetAngles():Up() * (10 * sizemul) + (v:GetAngles():Forward()) * (2 * sizemul))):ToScreen()
			local bl = (v:GetPos() + ((v:GetAngles():Up() * (9)) + v:GetAngles():Up() * (-42 * sizemul)) + (v:GetAngles():Up() * (10 * sizemul)) + (v:GetAngles():Forward()) * (-144 * sizemul)):ToScreen()


			local itemdata = {
				{x = tr.x, y = tr.y},
				{x = br.x, y = br.y},
				{x = bl.x, y = bl.y},
				{x = tl.x, y = tl.y}
			}

			render.ClearStencil()
			render.SetStencilEnable(true)
		
			--------------------------------------------------------
			--- Setup the stencil & draw the circle mask onto it ---
			--------------------------------------------------------
		
			render.SetStencilWriteMask(1)
			render.SetStencilTestMask(1)
		
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
			render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
			render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
			render.SetStencilPassOperation(STENCILOPERATION_KEEP)
			render.SetStencilReferenceValue(1)
		
			surface.SetDrawColor(255, 255, 255)
			draw.NoTexture()
			--surface.DrawRect(0,0,200,200)
			surface.DrawPoly(itemdata)			

				render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
				render.SetStencilReferenceValue(1)
				render.SetStencilFailOperation(STENCILOPERATION_ZERO)
				render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
				render.SetStencilPassOperation(STENCILOPERATION_KEEP)
		

				---- Background
				--surface.SetDrawColor(Color(255, 0, 0, 10))
				surface.SetDrawColor(Color(0, 0, 0, 35))
				surface.DrawRect(0, 0, ScrW(), ScrH())

				DrawBlurRect(0,0,ScrW(), ScrH(), 2, 5)

			render.SetStencilEnable(false)
			render.ClearStencil()

			local Pos = v:GetPos()
			local Ang1 = v:GetAngles()
		
			Ang1:RotateAroundAxis(Ang1:Right(), -90)
			Ang1:RotateAroundAxis(Ang1:Forward(), 90)
			Ang1:RotateAroundAxis(Ang1:Up(), 90)
		
			local min, max = v:GetModelBounds()
		
			cam.Start3D()
				cam.Start3D2D(v:GetPos() + (v:GetAngles():Up() * (10)) + (v:GetAngles():Forward()) * (-144 * sizemul) + (v:GetAngles():Right() * 0.1), Ang1, sizemul )
					local y = 0
					local x = 144
					surface.SetDrawColor(255, 255, 255)

					local shadowcolor = Color(35*2.5, 35*2.5, 35*2.5, 255)				
					local text = string.upper(v:GetItemTable().Name)
					local font = "Trebuchet24"

					surface.SetFont(font)
					local tw, th = surface.GetTextSize(text)

					--x = (tw / 2) + 2

					draw.DrawText(text, font, x - 1, y - 1, shadowcolor,  TEXT_ALIGN_RIGHT)
					draw.DrawText(text, font, x + 1, y + 1, shadowcolor,  TEXT_ALIGN_RIGHT)
					draw.DrawText(text, font, x, y - 1, shadowcolor,  TEXT_ALIGN_RIGHT)
					draw.DrawText(text, font, x - 1, y, shadowcolor,  TEXT_ALIGN_RIGHT)
					draw.DrawText(text, font, x, y + 1, shadowcolor,  TEXT_ALIGN_RIGHT)
					draw.DrawText(text, font, x + 1, y, shadowcolor,  TEXT_ALIGN_RIGHT)

					draw.DrawText(text, font, x, y + 0, Color( 230, 230, 230, 255 ),  TEXT_ALIGN_RIGHT)
			
					y = y + 20
			
					text = string.upper("Weight "..v:GetItemTable().Weight.."KG")

					draw.DrawText(text, font, x - 1, y - 1, shadowcolor,  TEXT_ALIGN_RIGHT)
					draw.DrawText(text, font, x + 1, y + 1, shadowcolor,  TEXT_ALIGN_RIGHT)
					draw.DrawText(text, font, x, y - 1, shadowcolor,  TEXT_ALIGN_RIGHT)
					draw.DrawText(text, font, x - 1, y, shadowcolor,  TEXT_ALIGN_RIGHT)
					draw.DrawText(text, font, x, y + 1, shadowcolor,  TEXT_ALIGN_RIGHT)
					draw.DrawText(text, font, x + 1, y, shadowcolor,  TEXT_ALIGN_RIGHT)

					draw.DrawText(text, font, x, y + 0, Color( 230, 230, 230, 255 ),  TEXT_ALIGN_RIGHT)

					surface.SetDrawColor(240, 240, 240)
					surface.DrawRect(x+2, 0, 4, 52)
					surface.DrawOutlinedRect(0, 0, 146, 52)

					surface.SetDrawColor(255, 255, 255)
					surface.DrawRect(x+6, 0, 2, 200)
					surface.DrawPoly(toitem)

				cam.End3D2D()
			cam.End3D()
		end
	end
end)

-- remove garrys mod default sandbox hints
timer.Remove("HintSystem_OpeningMenu")
timer.Remove("HintSystem_Annoy1")
timer.Remove("HintSystem_Annoy2")