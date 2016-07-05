if SERVER then
	AddCSLuaFile()
	return
end

rainChat = {}

rainChat.config = {
	timeStamps = true,
	position = 1,	
	fadeTime = 12,
}

surface.CreateFont( "rainChat_18", {
	font = "Roboto Lt",
	size = 18,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "rainChat_16", {
	font = "Roboto Lt",
	size = 16,
	weight = 500,
	antialias = true,
} )

--// Prevents errors if the script runs too early, which it will
if not GAMEMODE then
	hook.Remove("Initialize", "rainChat_init")
	hook.Add("Initialize", "rainChat_init", function()
		include("raindrop/gamemode/core/sh_chat.lua")
		rainChat.buildBox()
	end)
	return
end

--// Builds the chatbox but doesn't display it
function rainChat.buildBox()
	rainChat.frame = vgui.Create("DFrame")
	rainChat.frame:SetSize( 625, 300 )
	rainChat.frame:SetTitle("")
	rainChat.frame:ShowCloseButton( false )
	rainChat.frame:SetDraggable( false )
	rainChat.frame:SetPos( 10, (ScrH() - rainChat.frame:GetTall()) - 20)
	rainChat.frame.Paint = function( self, w, h )
		rainChat.blur( self, 10, 20, 255 )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 200 ) )
		
		draw.RoundedBox( 0, 0, 0, w, 25, Color( 80, 80, 80, 100 ) )
	end
	rainChat.oldPaint = rainChat.frame.Paint
	
	local serverName = vgui.Create("DLabel", rainChat.frame)
	serverName:SetText( GetConVarString( "hostname" ) )
	serverName:SetFont( "rainChat_18")
	serverName:SizeToContents()
	serverName:SetPos( 5, 4 )
	
	local settings = vgui.Create("DButton", rainChat.frame)
	settings:SetText("Settings")
	settings:SetFont( "rainChat_18")
	settings:SetTextColor( Color( 230, 230, 230, 150 ) )
	settings:SetSize( 70, 25 )
	settings:SetPos( rainChat.frame:GetWide() - settings:GetWide(), 0 )
	settings.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 200 ) )
	end
	settings.DoClick = function( self )
		rainChat.openSettings()
	end
	
	rainChat.entry = vgui.Create("DTextEntry", rainChat.frame) 
	rainChat.entry:SetSize( rainChat.frame:GetWide() - 50, 20 )
	rainChat.entry:SetTextColor( color_white )
	rainChat.entry:SetFont("rainChat_18")
	rainChat.entry:SetDrawBorder( false )
	rainChat.entry:SetDrawBackground( false )
	rainChat.entry:SetCursorColor( color_white )
	rainChat.entry:SetHighlightColor( Color(52, 152, 219) )
	rainChat.entry:SetPos( 45, rainChat.frame:GetTall() - rainChat.entry:GetTall() - 5 )
	rainChat.entry.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 100 ) )
		derma.SkinHook( "Paint", "TextEntry", self, w, h )
	end

	rainChat.entry.OnTextChanged = function( self )
		if self and self.GetText then 
			gamemode.Call( "ChatTextChanged", self:GetText() or "" )
		end
	end

	rainChat.entry.OnKeyCodeTyped = function( self, code )
		local types = {"", "teamchat", "console"}

		if code == KEY_ESCAPE then

			rainChat.hideBox()
			gui.HideGameUI()

		elseif code == KEY_TAB then
			
			rainChat.TypeSelector = (rainChat.TypeSelector and rainChat.TypeSelector + 1) or 1
			
			if rainChat.TypeSelector > 3 then rainChat.TypeSelector = 1 end
			if rainChat.TypeSelector < 1 then rainChat.TypeSelector = 3 end
			
			rainChat.ChatType = types[rainChat.TypeSelector]

			timer.Simple(0.001, function() rainChat.entry:RequestFocus() end)

		elseif code == KEY_ENTER then
			-- Replicate the client pressing enter
			
			if string.Trim( self:GetText() ) != "" then
				if rainChat.ChatType == types[2] then
					LocalPlayer():ConCommand("say_team \"" .. (self:GetText() or "") .. "\"")
				elseif rainChat.ChatType == types[3] then
					LocalPlayer():ConCommand(self:GetText() or "")
				else
					LocalPlayer():ConCommand("say \"" .. self:GetText() .. "\"")
				end
			end

			rainChat.TypeSelector = 1
			rainChat.hideBox()
		end
	end
	
	rainChat.sheet = vgui.Create("DPropertySheet", rainChat.frame)
	rainChat.sheet:SetSize( rainChat.frame:GetWide() - 10, rainChat.frame:GetTall() - 60 )
	rainChat.sheet:SetPos( 5, 30 )
	rainChat.sheet.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 0 ) )
	end

	--[[rainChat.panel1 = vgui.Create( "DPanel", rainChat.sheet )
	rainChat.panel1:SetSize( rainChat.sheet:GetWide(), rainChat.sheet:GetTall())
	rainChat.panel1.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 0 ) )
	end
	rainChat.sheet:AddSheet( "All", rainChat.panel1, "icon16/cross.png" )
	
	rainChat.panel2 = vgui.Create( "DPanel", rainChat.sheet )
	rainChat.panel2:SetSize( rainChat.sheet:GetWide(), rainChat.sheet:GetTall())
	rainChat.panel2.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 0 ) )
	end
	rainChat.sheet:AddSheet( "OOC", rainChat.panel2, "icon16/cross.png" )]]
	
	rainChat.chatLog = vgui.Create("RichText", rainChat.sheet) 
	--rainChat.chatLog:SetSize( rainChat.frame:GetWide() - 10, rainChat.frame:GetTall() - 60 )
	rainChat.chatLog:SetSize( rainChat.sheet:GetWide(), rainChat.sheet:GetTall())
	--rainChat.chatLog:SetPos( 5, 30 )
	rainChat.chatLog:SetPos( 0, 0 )
	rainChat.chatLog.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 100 ) )
	end
	rainChat.chatLog.Think = function( self )
		if rainChat.lastMessage then
			--[[if CurTime() - rainChat.lastMessage > rainChat.config.fadeTime then
				self:SetVisible( false )
			else
				self:SetVisible( true )
			end]]
			
			self:InsertFade( rainChat.config.fadeTime, 1 )
		end
	end
	rainChat.chatLog.PerformLayout = function( self )
		self:SetFontInternal("rainChat_18")
		self:SetFGColor( color_white )
	end
	rainChat.oldPaint2 = rainChat.chatLog.Paint
	rainChat.sheet:AddSheet( "OOC", rainChat.chatLog, "icon16/cross.png" )
	
	local panel1 = vgui.Create( "DPanel", rainChat.sheet )
	panel1.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 100 ) )
	end
	rainChat.sheet:AddSheet( "IC", panel1, "icon16/cross.png" )

	local panel2 = vgui.Create( "DPanel", rainChat.sheet )
	panel2.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 100 ) )
	end
	rainChat.sheet:AddSheet( "PDA", panel2, "icon16/tick.png" )

	for k, v in pairs(rainChat.sheet.Items) do
		if (!v.Tab) then continue end
    
		v.Tab.Paint = function(self,w,h)
			if v.Tab:IsDown() then
				draw.RoundedBox( 0, 2, 2, w - 4, h - 4, Color( 0, 0, 0, 100 ) )
			end
			
			if v.Tab == rainChat.sheet:GetActiveTab() then
				draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30, 100))
			else
				draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30, 150))
			end
		end
	end
	
	local text = "Say :"

	local say = vgui.Create("DLabel", rainChat.frame)
	say:SetText("")
	surface.SetFont( "rainChat_18")
	local w, h = surface.GetTextSize( text )
	say:SetSize( w + 5, 20 )
	say:SetPos( 5, rainChat.frame:GetTall() - rainChat.entry:GetTall() - 5 )
	
	say.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 100 ) )
		draw.DrawText( text, "rainChat_18", 2, 1, color_white )
	end

	say.Think = function( self )
		local types = {"", "teamchat", "console"}
		local s = {}

		if rainChat.ChatType == types[2] then 
			text = "Say (TEAM) :"	
		elseif rainChat.ChatType == types[3] then
			text = "Console :"
		else
			text = "Say :"
			s.pw = 45
			s.sw = rainChat.frame:GetWide() - 50
		end

		if s then
			if not s.pw then s.pw = self:GetWide() + 10 end
			if not s.sw then s.sw = rainChat.frame:GetWide() - self:GetWide() - 15 end
		end

		local w, h = surface.GetTextSize( text )
		self:SetSize( w + 5, 20 )
		self:SetPos( 5, rainChat.frame:GetTall() - rainChat.entry:GetTall() - 5 )

		rainChat.entry:SetSize( s.sw, 20 )
		rainChat.entry:SetPos( s.pw, rainChat.frame:GetTall() - rainChat.entry:GetTall() - 5 )
	end	
	
	rainChat.hideBox()
end

--// Hides the chat box but not the messages
function rainChat.hideBox()
	rainChat.frame.Paint = function() end
	rainChat.chatLog.Paint = function() end
	
	rainChat.chatLog:SetVerticalScrollbarEnabled( false )
	rainChat.chatLog:GotoTextEnd()
	
	rainChat.lastMessage = rainChat.lastMessage or CurTime() - rainChat.config.fadeTime
	rainChat.chatLog:ResetAllFades(false, false, -1)
	
	-- Hide the chatbox except the log
	local children = rainChat.frame:GetChildren()
	for _, pnl in pairs( children ) do
		if pnl == rainChat.frame.btnMaxim or pnl == rainChat.frame.btnClose or pnl == rainChat.frame.btnMinim then continue end
		
		if pnl != rainChat.sheet then
			pnl:SetVisible( false )
		end
	end
	
	for k, v in pairs(rainChat.sheet.Items) do
		if (!v.Tab) then continue end
		
		v.Tab:SetVisible( false )
	end
	
	-- Give the player control again
	rainChat.frame:SetMouseInputEnabled( false )
	rainChat.frame:SetKeyboardInputEnabled( false )
	gui.EnableScreenClicker( false )
	
	-- We are done chatting
	gamemode.Call("FinishChat")
	
	-- Clear the text entry
	rainChat.entry:SetText( "" )
	gamemode.Call( "ChatTextChanged", "" )
end

--// Shows the chat box
function rainChat.showBox()
	-- Draw the chat box again
	rainChat.frame.Paint = rainChat.oldPaint
	rainChat.chatLog.Paint = rainChat.oldPaint2
	
	rainChat.chatLog:SetVerticalScrollbarEnabled( true )
	rainChat.lastMessage = nil
	rainChat.chatLog:ResetAllFades(true, false, -1)
	
	-- Show any hidden children
	local children = rainChat.frame:GetChildren()
	for _, pnl in pairs( children ) do
		if pnl == rainChat.frame.btnMaxim or pnl == rainChat.frame.btnClose or pnl == rainChat.frame.btnMinim then continue end
		
		pnl:SetVisible( true )
	end
	for k, v in pairs(rainChat.sheet.Items) do
		if (!v.Tab) then continue end
		
		v.Tab:SetVisible( true )
	end
	
	-- MakePopup calls the input functions so we don't need to call those
	rainChat.frame:MakePopup()
	rainChat.entry:RequestFocus()
	
	-- Make sure other addons know we are chatting
	gamemode.Call("StartChat")
end

--// Opens the settings panel
function rainChat.openSettings()
	rainChat.hideBox()
	
	rainChat.frameS = vgui.Create("DFrame")
	rainChat.frameS:SetSize( 400, 300 )
	rainChat.frameS:SetTitle("")
	rainChat.frameS:MakePopup()
	rainChat.frameS:SetPos( ScrW()/2 - rainChat.frameS:GetWide()/2, ScrH()/2 - rainChat.frameS:GetTall()/2 )
	rainChat.frameS:ShowCloseButton( true )
	rainChat.frameS.Paint = function( self, w, h )
		rainChat.blur( self, 10, 20, 255 )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 200 ) )
		
		draw.RoundedBox( 0, 0, 0, w, 25, Color( 80, 80, 80, 100 ) )
		
		draw.RoundedBox( 0, 0, 25, w, 25, Color( 50, 50, 50, 50 ) )
	end
	
	local serverName = vgui.Create("DLabel", rainChat.frameS)
	serverName:SetText( "rainChat - Settings" )
	serverName:SetFont( "rainChat_18")
	serverName:SizeToContents()
	serverName:SetPos( 5, 4 )
	
	local label1 = vgui.Create("DLabel", rainChat.frameS)
	label1:SetText( "Time stamps: " )
	label1:SetFont( "rainChat_18")
	label1:SizeToContents()
	label1:SetPos( 10, 40 )
	
	local checkbox1 = vgui.Create("DCheckBox", rainChat.frameS ) 
	checkbox1:SetPos(label1:GetWide() + 15, 42)
	checkbox1:SetValue( rainChat.config.timeStamps )
	
	local label2 = vgui.Create("DLabel", rainChat.frameS)
	label2:SetText( "Fade time: " )
	label2:SetFont( "rainChat_18")
	label2:SizeToContents()
	label2:SetPos( 10, 70 )
	
	local textEntry = vgui.Create("DTextEntry", rainChat.frameS) 
	textEntry:SetSize( 50, 20 )
	textEntry:SetPos( label2:GetWide() + 15, 70 )
	textEntry:SetText( rainChat.config.fadeTime ) 
	textEntry:SetTextColor( color_white )
	textEntry:SetFont("rainChat_18")
	textEntry:SetDrawBorder( false )
	textEntry:SetDrawBackground( false )
	textEntry:SetCursorColor( color_white )
	textEntry:SetHighlightColor( Color(52, 152, 219) )
	textEntry.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 100 ) )
		derma.SkinHook( "Paint", "TextEntry", self, w, h )
	end
	
	--[[local checkbox2 = vgui.Create("DCheckBox", rainChat.frameS ) 
	checkbox2:SetPos(label2:GetWide() + 15, 72)
	checkbox2:SetValue( rainChat.config.serainChatTags )
	
	local label3 = vgui.Create("DLabel", rainChat.frameS)
	label3:SetText( "Use chat tags: " )
	label3:SetFont( "rainChat_18")
	label3:SizeToContents()
	label3:SetPos( 10, 100 )
	
	local checkbox3 = vgui.Create("DCheckBox", rainChat.frameS ) 
	checkbox3:SetPos(label3:GetWide() + 15, 102)
	checkbox3:SetValue( rainChat.config.usrainChatTag )]]
	
	local save = vgui.Create("DButton", rainChat.frameS)
	save:SetText("Save")
	save:SetFont( "rainChat_18")
	save:SetTextColor( Color( 230, 230, 230, 150 ) )
	save:SetSize( 70, 25 )
	save:SetPos( rainChat.frameS:GetWide()/2 - save:GetWide()/2, rainChat.frameS:GetTall() - save:GetTall() - 10)
	save.Paint = function( self, w, h )
		if self:IsDown() then
			draw.RoundedBox( 0, 0, 0, w, h, Color( 80, 80, 80, 200 ) )
		else
			draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 200 ) )
		end
	end
	save.DoClick = function( self )
		rainChat.frameS:Close()
		
		rainChat.config.timeStamps = checkbox1:GetChecked() 
		rainChat.config.fadeTime = tonumber(textEntry:GetText()) or rainChat.config.fadeTime
	end
end

--// Panel based blur function by Chessnut from NutScript
local blur = Material( "pp/blurscreen" ); -- In place of Material outside of hook
function rainChat.blur( panel, layers, density, alpha )
	-- Its a scientifically proven fact that blur improves a script
	local x, y = panel:LocalToScreen(0, 0)

	surface.SetDrawColor( 255, 255, 255, alpha )
	surface.SetMaterial( blur )

	for i = 1, 3 do
		blur:SetFloat( "$blur", ( i / layers ) * density )
		blur:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
	end
end

local oldAddText = chat.AddText

--// Overwrite chat.AddText to detour it into my chatbox
function chat.AddText(...)
	if not rainChat.chatLog then
		rainChat.buildBox()
	end
	
	local msg = {}
	
	-- Iterate through the strings and colors
	for _, obj in pairs( {...} ) do
		if type(obj) == "table" then
			rainChat.chatLog:InsertColorChange( obj.r, obj.g, obj.b, obj.a )
			table.insert( msg, Color(obj.r, obj.g, obj.b, obj.a) )
		elseif type(obj) == "string"  then
			rainChat.chatLog:AppendText( obj )
			table.insert( msg, obj )
		elseif obj:IsPlayer() then
			local ply = obj
			
			if rainChat.config.timeStamps then
				rainChat.chatLog:InsertColorChange( 130, 130, 130, 255 )
				rainChat.chatLog:AppendText( "["..os.date("%X").."] ")
			end
			
			if rainChat.config.serainChatTags and ply:GetNWBool("rainChat_tagEnabled", false) then
				local col = ply:GetNWString("rainChat_tagCol", "255 255 255")
				local tbl = string.Explode(" ", col )
				rainChat.chatLog:InsertColorChange( tbl[1], tbl[2], tbl[3], 255 )
				rainChat.chatLog:AppendText( "["..ply:GetNWString("rainChat_tag", "N/A").."] ")
			end
			
			local col = GAMEMODE:GetTeamColor( obj )
			rainChat.chatLog:InsertColorChange( col.r, col.g, col.b, 255 )
			rainChat.chatLog:AppendText( obj:Nick() )
			table.insert( msg, obj:Nick() )
		end
	end
	rainChat.chatLog:AppendText("\n")
	
	rainChat.chatLog:SetVisible( true )
	rainChat.lastMessage = CurTime()
--	oldAddText(unpack(msg))
end

--// Write any server notifications
hook.Remove( "ChatText", "rainChat_joinleave")
hook.Add( "ChatText", "rainChat_joinleave", function( index, name, text, type )
	if not rainChat.chatLog then
		rainChat.buildBox()
	end
	
	if type != "chat" then
		rainChat.chatLog:InsertColorChange( 0, 128, 255, 255 )
		rainChat.chatLog:AppendText( text.."\n" )
		rainChat.chatLog:SetVisible( true )
		rainChat.lastMessage = CurTime()
		return true
	end
end)

--// Stops the default chat box from being opened
hook.Remove("PlayerBindPress", "rainChat_hijackbind")
hook.Add("PlayerBindPress", "rainChat_hijackbind", function(ply, bind, pressed)
	if string.sub( bind, 1, 11 ) == "messagemode" then
		--[[if bind == "messagemode2" then 
			rainChat.ChatType = "teamchat"
		else
			rainChat.ChatType = ""
		end]]
		
		rainChat.ChatType = ""
		
		if IsValid( rainChat.frame ) then
			rainChat.showBox()
		else
			rainChat.buildBox()
			rainChat.showBox()
		end
		return true
	end
end)

--// Hide the default chat too in case that pops up
hook.Remove("HUDShouldDraw", "rainChat_hidedefault")
hook.Add("HUDShouldDraw", "rainChat_hidedefault", function( name )
	if name == "CHudChat" then
		return false
	end
end)

 --// Modify the Chatbox for align.
local oldGetChatBoxPos = chat.GetChatBoxPos
function chat.GetChatBoxPos()
	return rainChat.frame:GetPos()
end

function chat.GetChatBoxSize()
	return rainChat.frame:GetSize()
end

chat.Open = rainChat.showBox
function chat.Close(...) 
	if IsValid( rainChat.frame ) then 
		rainChat.hideBox(...)
	else
		rainChat.buildBox()
		rainChat.showBox()
	end
end