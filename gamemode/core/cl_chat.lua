--[[
	Filename: cl_chat.lua
	Description: Tabbed chat
--]]

rain.chat = {}
rain.chat.tabs = {}
rain.chat.ui = vgui.Create("RD_Chatbox")

E_NOMESSAGE 	= 0
E_ALL			= 1
E_WHISPERING	= 2
E_TALKING		= 3
E_YELLING		= 4
E_OOC			= 5
E_PM			= 6
E_HELP			= 7
E_ADMIN			= 8
E_DEV			= 9


--[[
	Initializes the chat
	Can be called multiple times in order to rebuild the chatbox
--]]

function rain.chat.init()

end

--[[
	Name: AddTab
	Desc: Called to add tabs
--]]

function rain.chat.addTab()

end

rain.struct:RegisterStruct("S_ChatTab", {
	sChatID = "", 		-- the id of the chat tab
	sChatPrintID = "", 	-- fancy ID for the chat
	tMessages = {}
})

rain.struct:RegisterStruct("S_Message", {
	nTimeStamp = "", 	-- Timestamp of when the message was sent
	sSenderNick = "", 	-- Nickname of the sender of the message, kept as a string.
	sMessage = "",
	enumMessageType = E_NOMESSAGE
})

--[[
	Name: RemoveTab
	Desc: Called when a tab is forcibly removed
--]]

function rain.chat.removeTab()

end


--[[
	Name: AddMessage
	Desc: Called when the server adds a message to the chatbox
--]]

function rain.chat.addMessage()

end


--[[
	Name: OnSendMessage
	Desc: Called when the local player inputs a chat message
--]]

function rain.chat.OnSendMessage()

end


--[[
	Name: OnOpenWorldChat 
	Desc: Called when global/world chat is opened
--]]

function rain.chat.onOpenWorldChat()

end


--[[
	Name: OnOpenTeamChat
	Desc: Called when team chat is opened
--]]

function rain.chat.onOpenTeamChat()

end


--[[
	Name: OpenChatbox
	Desc: Called when the chatbox is opened, this is only used to setup input on the chatbox
--]]

function rain.chat.openChatbox()

end


--[[
	Name: CloseChatbox 
	Desc: Called to release all input from the chatbox
--]]

function rain.chat.closeChatbox(objChatPanel)
	objChatPanel:SetMouseInputEnabled(false)
	objChatPanel:SetKeyboardInputEnabled(false)
	gui.EnableScreenClicker(false)
end


--[[
	Name: onBeginChat 
	Desc: Called when a player opens the chatbox
--]]

function rain.chat.onBeginChat()

end


--[[
	Name: onFinishChat 
	Desc: Called when a player stops using the chatbox
--]]

function rain.chat.onFinishChat()

end


--[[
	Name: AddText
	Desc: Overwrite gmod base function that adds text to the chatbox
--]]

local chatAddText = chatAddText or nil

if !chatAddText then
	chatAddText = chat.AddText()
end

function chat.AddText( ... )

	local tArgs = { ... }

	for _, wArg in pairs(tArgs) do
		if rain.util.isType(wArg, "color") then

		elseif rain.util.isType(wArg, "string") then

		elseif wArg:IsPlayer() then

		end
	end

	chatAddText(...)
end


hook.Add("PlayerBindPress", "rain.chat.playerinput", function(client, sBind, bPressed)
	bTeam = false

	if sBind == "messagemode" then
		bTeam = false
	elseif sBind == "messagemode2" then
		bTeam = true
	else
		return
	end

	if !bTeam then
		rain.chat.onBeginChat()
		rain.chat.onOpenWorldChat()
	else
		rain.chat.onBeginChat()
		rain.chat.onOpenTeamChat()
	end

	return true
end)