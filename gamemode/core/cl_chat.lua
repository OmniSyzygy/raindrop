--[[
	Filename: cl_chat.lua
	Description: Tabbed chat
--]]

rain.chat = {}
rain.chat.tabs = {}
rain.chat.ui = rain.chat.ui or nil

rain.chat.currentTab 	= 1
rain.chat.pmTab			= 5

E_NOMESSAGE 	= 0
E_SERVER		= 1
E_WHISPERING	= 2
E_TALKING		= 3
E_YELLING		= 4
E_OOC			= 5
E_LOOC			= 6
E_PM			= 7
E_HELP			= 8
E_ADMIN			= 9
E_DEV			= 10
E_NOTIFICATION	= 11
E_PM			= 12



--[[
	Initializes the chat
	Can be called multiple times in order to rebuild the chatbox
--]]

function rain.chat.init()
	if rain.chat.ui then
		rain.chat.ui:Remove()
	end

	rain.chat.ui = vgui.Create("RD_Chatbox")
end

--[[
	Name: AddTab
	Desc: Called to add tabs
--]]

function rain.chat.addTab(sChatID, sChatPrintID, tAcceptedEnums)
	tNewTab = rain.struct:GetStruct("S_ChatTab")

	tNewTab.sChatID = sChatID
	tNewTab.sChatPrintID = sChatPrintID
	tNewTab.tAcceptedEnums = tAcceptedEnums

	table.insert(rain.chat.tabs, tNewTab)
end

rain.struct:RegisterStruct("S_ChatTab", {
	sChatID = "", 		-- the id of the chat tab
	sChatPrintID = "", 	-- fancy ID for the chat
	sIcon = "icon16/tick.png",
	tAcceptedEnums = {},
	tMessages = {}
})

rain.struct:RegisterStruct("S_Message", {
	nTimeStamp = "", 	-- Timestamp of when the message was sent
	sSenderNick = "", 	-- Nickname of the sender of the message, kept as a string.
	sMessage = "",
	enumMessageType = E_NOMESSAGE
})


rain.chat.addTab(
	"all", 
	"All",
	{
		E_SERVER, 
		E_WHISPERING, 
		E_TALKING, 
		E_YELLING, 
		E_OOC, 
		E_LOOC,
		E_HELP, 
		E_ADMIN, 
		E_DEV, 
		E_NOTIFICATION
	}
)

rain.chat.addTab(
	"ic", 
	"IC",
	{
		E_WHISPERING, 
		E_TALKING, 
		E_YELLING
	}
)

rain.chat.addTab(
	"ooc", 
	"OOC",
	{
		E_SERVER, 
		E_OOC, 
		E_LOOC,
		E_HELP, 
		E_ADMIN, 
		E_NOTIFICATION
	}
)

rain.chat.addTab(
	"admin", 
	"Admin",
	{
		E_ADMIN, 
		E_DEV, 
		E_NOTIFICATION
	}
)

rain.chat.addTab(
	"pm", 
	"PMs",
	{
		E_PM
	}
)

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
	Name: OpenChatbox
	Desc: Called when the chatbox is opened, this is only used to setup input on the chatbox
--]]

function rain.chat.openChatbox(nCurrentTab)
	if (rain.chat.ui) then
		rain.chat.ui:OpenChatbox()
		rain.chat.ui:SetCurrentTab(nCurrentTab or rain.chat.currentTab)
		rain.chat.ui:SetMouseInputEnabled(true)
		rain.chat.ui:SetKeyboardInputEnabled(true)
		gui.EnableScreenClicker(true)
	end
end


--[[
	Name: OnOpenWorldChat 
	Desc: Called when global/world chat is opened
--]]

function rain.chat.onOpenWorldChat()
	rain.chat.openChatbox(rain.chat.currentTab)
end


--[[
	Name: OnOpenTeamChat
	Desc: Called when team chat is opened, basically it sets the chatbox to use the PM tabs
--]]

function rain.chat.onOpenTeamChat()
	rain.chat.openChatbox(rain.chat.pmTab)
end


--[[
	Name: CloseChatbox 
	Desc: Called to release all input from the chatbox
--]]

function rain.chat.closeChatbox()
	if (rain.chat.ui) then
		rain.chat.ui:SetMouseInputEnabled(false)
		rain.chat.ui:SetKeyboardInputEnabled(false)
		rain.chat.ui:CloseChatbox(false)
		gui.EnableScreenClicker(false)
	end
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

--local chatAddText = chatAddText or chat.AddText()

function chat.AddText( ... )

	local tArgs = { ... }

	for _, wArg in pairs(tArgs) do
		if rain.util.isType(wArg, "color") then

		elseif rain.util.isType(wArg, "string") then

		elseif wArg:IsPlayer() then

		end
	end

	--chatAddText(...)
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