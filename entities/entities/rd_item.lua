AddCSLuaFile();

ENT.Base = "base_anim";
ENT.Type = "anim";

ENT.PrintName		= "";
ENT.Author			= "";
ENT.Contact			= "";
ENT.Purpose			= "";
ENT.Instructions	= "";

ENT.Spawnable			= false;
ENT.AdminSpawnable		= false;

function ENT:PostEntityPaste( ply, ent, tab )
	
	GAMEMODE:LogSecurity( ply:SteamID(), "n/a", ply:VisibleRPName(), "Tried to duplicate " .. ent:GetClass() .. "!" );
	ent:Remove();
	
end

function ENT:SetupDataTables()
	
	self:NetworkVar( "String", 0, "Item" );
	self:NetworkVar( "String", 1, "Data" );
	
end

function ENT:Initialize()
	
	if( CLIENT ) then return; end
	
	self:PhysicsInit( SOLID_VPHYSICS );
	
	local phys = self:GetPhysicsObject();
	
	if( phys and phys:IsValid() ) then
		
		phys:Wake();
		
	end
	
	self:SetUseType( SIMPLE_USE );
	
	self.KillTime = CurTime() + 21600; -- 6 hours
	
end

function ENT:OnTakeDamage( dmginfo )

	self:TakePhysicsDamage( dmginfo );
	
end

function ENT:Use( activator, caller, usetype, val )
	
	local data = self:GetData()

	if( !activator:CanTakeItem( self:GetItem() ) ) then
		
		net.Start( "nTooHeavy" );
		net.Send( activator );
		
		return;
		
	end
	
	self:Remove();
	
	if (string.len(data) > 0) then
		activator:GiveItem( self:GetItem(), 1, pon.decode(data) );
	else
		activator:GiveItem( self:GetItem(), 1);
	end
end

function ENT:Think()
	
	if( CLIENT ) then return end
	
	if( CurTime() > self.KillTime ) then
		
		self:Remove();
		
	end
	
end

function ENT:Draw()

	self:DrawModel()

end

local triangle = {
	{ x = 100, y = 200 },
	{ x = 150, y = 100 },
	{ x = 200, y = 200 }

}

if (CLIENT) then
	hook.Add("HUDPaint", "testblur", function()

		local sizemul = 0.05

		for k, v in pairs(ents.FindByClass("cc_item")) do
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

				render.ClearStencil();
				render.SetStencilEnable(true);
			
				--------------------------------------------------------
				--- Setup the stencil & draw the circle mask onto it ---
				--------------------------------------------------------
			
				render.SetStencilWriteMask(1);
				render.SetStencilTestMask(1);
			
				render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER);
				render.SetStencilFailOperation(STENCILOPERATION_REPLACE);
				render.SetStencilZFailOperation(STENCILOPERATION_KEEP);
				render.SetStencilPassOperation(STENCILOPERATION_KEEP);
				render.SetStencilReferenceValue(1);
			
				surface.SetDrawColor(255, 255, 255);
				draw.NoTexture();
				--surface.DrawRect(0,0,200,200)
				surface.DrawPoly(itemdata)			

					render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL);
					render.SetStencilReferenceValue(1);
					render.SetStencilFailOperation(STENCILOPERATION_ZERO);
					render.SetStencilZFailOperation(STENCILOPERATION_ZERO);
					render.SetStencilPassOperation(STENCILOPERATION_KEEP);
			

					---- Background
					--surface.SetDrawColor(Color(255, 0, 0, 10));
					surface.SetDrawColor(Color(0, 0, 0, 35));
					surface.DrawRect(0, 0, ScrW(), ScrH());

					DrawBlurRect(0,0,ScrW(), ScrH(), 2, 5)

				render.SetStencilEnable(false);
				render.ClearStencil();

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

						local RNGData = GAMEMODE:GetRNGStats(v:GetItem(), pon.decode(v:GetData()).rng)

						local shadowcolor = Color(35*2.5, 35*2.5, 35*2.5, 255)				
						local text = string.upper(RNGData.." "..GAMEMODE:GetItemByID( v:GetItem() ).Name)
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
				
						text = string.upper("Weight "..GAMEMODE:GetItemByID( v:GetItem() ).Weight.."KG")

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
end