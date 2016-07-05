local ScreenW = ScrW()
local ScreenH = ScrH()

RaindropPerksPanel = {}
scale = 2

function RaindropPerksPanel:Init()

	self:SetSize( 425*scale, 650 )
	self:Center()

end

function RaindropPerksPanel:Paint( w, h )

	draw.RoundedBox( 0, 0, 0, w, h, Color(LevelSystemConfiguration.PerksMenuColor1[1], LevelSystemConfiguration.PerksMenuColor1[2], LevelSystemConfiguration.PerksMenuColor1[3], 230) )
	draw.RoundedBox( 0, 10, 40, w-20, h-50, Color(LevelSystemConfiguration.PerksMenuColor2[1], LevelSystemConfiguration.PerksMenuColor2[2], LevelSystemConfiguration.PerksMenuColor2[3], 230))
	draw.DrawText('Raindrop Leveling - Perks Menu', 'RaindropFontBig', 210*scale, 5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

end

RaindropPerksPerk = {}

function RaindropPerksPerk:Init()

	self:SetSize( 390*scale, 64 )
	self:Center()

end

function RaindropPerksPerk:Paint( w, h )

	draw.RoundedBox( 0, 0, 0, w, h, Color(LevelSystemConfiguration.PerksBoxColor1[1], LevelSystemConfiguration.PerksBoxColor1[2], LevelSystemConfiguration.PerksBoxColor1[3], 230) )

	draw.RoundedBox( 0, 5, 5, 54, 54, Color(LevelSystemConfiguration.PerksBoxColor2[1], LevelSystemConfiguration.PerksBoxColor2[2], LevelSystemConfiguration.PerksBoxColor2[3], 235) )
	draw.RoundedBox( 0, 64, 5, w-69, 54, Color(LevelSystemConfiguration.PerksBoxColor2[1], LevelSystemConfiguration.PerksBoxColor2[2], LevelSystemConfiguration.PerksBoxColor2[3], 235) )

end

RaindropPerksClose = {}

function RaindropPerksClose:Init()

	self:SetSize( 24, 24 )
	self:Center()

end

function RaindropPerksClose:Paint( w, h )

	draw.RoundedBox( 0, 0, 0, w, h, Color(LevelSystemConfiguration.PerksBoxColor1[1], LevelSystemConfiguration.PerksBoxColor1[2], LevelSystemConfiguration.PerksBoxColor1[3], 230) )

end

vgui.Register( 'RaindropPerksPanel', RaindropPerksPanel, 'Panel' )
vgui.Register( 'RaindropPerksPerk', RaindropPerksPerk, 'Panel' )
vgui.Register( 'RaindropPerksClose', RaindropPerksClose, 'DButton' )

local function RaindropShowPerks(ply, text)
	if (text == "!perks" && ply == LocalPlayer()) then
	PerksMain = vgui.Create( 'RaindropPerksPanel' )

	local PerksClose = vgui.Create( 'RaindropPerksClose', PerksMain )
	PerksClose:SetSize( 24, 24 )
	PerksClose:SetPos( 405*scale, 10 )
	PerksClose:SetText( 'X' )
	PerksClose:SetTextColor(Color(0,0,0,255))
	PerksClose.DoClick = function()
		LocalPlayer():RaindropNetActivePerks()
		PerksMain:Hide()	
	end

	local PerksScroll = vgui.Create( 'DScrollPanel', PerksMain )
	PerksScroll:SetSize( 410*scale, 580 )
	PerksScroll:SetPos( 5, 50 )

	local PerksScrollBar = PerksScroll:GetVBar()

	function PerksScrollBar:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(LevelSystemConfiguration.PerksBoxColor2[1], LevelSystemConfiguration.PerksBoxColor2[2], LevelSystemConfiguration.PerksBoxColor2[3], 235) )
	end

	function PerksScrollBar.btnUp:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(LevelSystemConfiguration.PerksBoxColor1[1]-20, LevelSystemConfiguration.PerksBoxColor1[2]-20, LevelSystemConfiguration.PerksBoxColor1[3]-20, 230) )
	end

	function PerksScrollBar.btnDown:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(LevelSystemConfiguration.PerksBoxColor1[1]-20, LevelSystemConfiguration.PerksBoxColor1[2]-20, LevelSystemConfiguration.PerksBoxColor1[3]-20, 230) )
	end

	function PerksScrollBar.btnGrip:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(LevelSystemConfiguration.PerksBoxColor1[1], LevelSystemConfiguration.PerksBoxColor1[2], LevelSystemConfiguration.PerksBoxColor1[3], 230) )
	end

	for i=1,#Raindrop.Perks do
		
		local Perk = vgui.Create( 'RaindropPerksPerk', PerksScroll )
		Perk:SetPos( 15, (i-1) * 74 )

		local PerkImage = vgui.Create( 'DImage', Perk )
		PerkImage:SetSize( 50, 50 )
		PerkImage:SetPos( 7, 7 )

		if (Raindrop.Perks[i]['lvl'] <= tonumber((GetGlobalInt(SQLStr(LocalPlayer():SteamID64()).."Level", 0) or 0))) then
			PerkImage:SetImage( 'Raindrop/perkunlocked.png' )
		else
			PerkImage:SetImage( 'Raindrop/perklocked.png' )
		end

		local PerkName = vgui.Create( 'DLabel', Perk )
		PerkName:SetSize( 286, 16 )
		PerkName:SetPos( 70, 7 )
		PerkName:SetText( Raindrop.Perks[i]['name'] )		
		PerkName:SetFont( 'RaindropFont' )
		PerkName:SetTextColor( Color(240, 240, 255, 225) )
		PerkName:SetContentAlignment( 4 )

			local PerkDescription = vgui.Create( 'DLabel', Perk )
			PerkDescription:SetSize( 286, 28 )
			PerkDescription:SetPos( 70, 20 )
			PerkDescription:SetText( Raindrop.Perks[i]['desc'] )
			PerkDescription:SetFont( 'RaindropFontSmall' )
			PerkDescription:SetTextColor( Color(240, 240, 255, 225) )
			PerkDescription:SetContentAlignment( 4 )

			local PerkLevel = vgui.Create( 'DLabel', Perk )
			PerkLevel:SetSize( 286, 28 )
			PerkLevel:SetPos( 70, 33 )
			PerkLevel:SetText( 'Lv. ' .. Raindrop.Perks[i]['lvl'] )
			PerkLevel:SetFont( 'RaindropFontSmall' )
			PerkLevel:SetTextColor( Color(240, 240, 255, 225) )
			PerkLevel:SetContentAlignment( 4 )
			
			if (Raindrop.Perks[i]['lvl'] <= tonumber((GetGlobalInt(SQLStr(LocalPlayer():SteamID64()).."Level", 0) or 0))) then
				local PerkActive = vgui.Create( "DCheckBoxLabel", Perk )
				PerkActive:SetChecked(Raindrop.ActivePerks[ply:SteamID64()][i])
				PerkActive:SetSize( 286, 28 )
				PerkActive:SetPos( 350*scale, 26 )
				PerkActive:SetText( "" )
				function PerkActive:OnChange( bVal )
					local count = 0
					for i=1,#Raindrop.ActivePerks[ply:SteamID64()] do
						if Raindrop.ActivePerks[ply:SteamID64()][i] then
							count = count + 1
						end
					end
					if ( bVal && count < LevelSystemConfiguration.MaxPerks) then
						Raindrop.ActivePerks[ply:SteamID64()][i] = true
						PerkActive:SetChecked( true )
					else
						Raindrop.ActivePerks[ply:SteamID64()][i] = false
						PerkActive:SetChecked( false )
					end
				end
			end
		end
	
		PerksMain:MakePopup()
	end
end
hook.Add( "OnPlayerChat", "Raindrop:OnPlayerChat", RaindropShowPerks)