rain.chat = {}

rain.chatbuffer = {}

-- chat type enums

CHAT_OOC = 0
CHAT_IC = 1
CHAT_PM = 2
CHAT_PDA = 3
CHAT_ADMIN = 4

TYPING_OOC = 0
TYPING_IC = 1
TYPING_ME = 2
TYPING_IT = 3
TYPING_YELLING = 4
TYPING_WHISPERING = 5

rain.chat.typingstrings = {}
rain.chat.typingstrings[TYPING_OOC] = "typing"
rain.chat.typingstrings[TYPING_IC] = "talking"
rain.chat.typingstrings[TYPING_ME] = "performing"
rain.chat.typingstrings[TYPING_IT] = "improvising"
rain.chat.typingstrings[TYPING_YELLING] = "yelling"
rain.chat.typingstrings[TYPING_WHISPERING] = "whispering"


rain.struct:RegisterStruct("ChatStruct", {nRadius = 1024, sFont = "Arial", sIcon = "default", prefix = "//"})

--[[
	Name: Add
	Category: Chat
	Desc: Add a type of chat to the chatbox
--]]

function rain.chat.add(tChatStruct, fnOnChat, fnFormatText)
	if tChatStruct:IsStruct() then
		if tChatStruct:Matches("ChatStruct") then
			rain.chatbuffer[tChatStruct.prefix] = {struct = tChatStruct, OnChat = fnOnChat, FormatText = fnFormatText}
		end
	end
end

--[[
	Name: AddChatCommand
	Category: Chat
	Desc: Adds a chat command, CanUse() is called with the client attempting to use the command being the argument, returning true/false
	      Determines if the command can be ran by that person, OnUse() is called when the command is called by somebody who can use it
	      OnFail() is called when the command cannot be run by the person attempting to call it.
	      OnSuccess() is called when the command is ran by the person attempting to call it successfuly calls it.
--]]

function rain.chat.addchatcommand(fnCanUse, fnOnUse, fnOnFail, fnOnSuccess)

end

--[[
	Name: Add In Area
	Category: Chat
	Desc: Adds chat to all players within certain bounds
--]]

function rain.chat.addinarea(vMin, vMax, enumType, sText)

end

--[[
	Name: Add In Radius
	Category: Chat
	Desc: Adds chat to all players in a specific radius, useful for player zones, CastToTarget means that the chat is muffled if there are barriers between the two people talking.
--]]

function rain.chat.addinradius(vPos, nRadius, enumType, sText, bCastToTarget)
	for k, v in pairs(ents.FindInSphere(vPos, nRadius)) do
		if v:IsPlayer() then
			v:AddChat(enumType, sText)
		end
	end
end

--[[
	Name: Get Typing Text
	Category: Chat
	Desc: returns the string used to display over a players head when they are typing.
--]]

function rain.chat.gettypingtext(enumTypingText)
	if enumTypingText then
		return rain.chat.typingstrings[enumTypingText]
	else
		return "typing"
	end
end

--[[
	Name: Player Say
	Category: Chat
	Desc: Called when a player sends out a chat message
--]]

function rain:PlayerSay(pSender, sText, bTeamChat)
	if string.StartWith(sText, "/") then
		-- do additional shit here
	else
		-- assume IC chat here
		rain.chat.addinradius(pSender:GetPos(), 1024, 1, pSender:GetRPName()..": "..sText)
	end

	return "" -- always return nothing
end

local rainclient = FindMetaTable("Player")

--[[
	Name: Add Chat
	Category: Chat->PlayerMeta
	Desc: Adds chat to a specific players chatbox
--]]

if (SV) then
	util.AddNetworkString("rain.chat.addchat")
else
	net.Receive("rain.chat.addchat", function()
		LocalPlayer():AddChat(rain.net.ReadUByte(), net.ReadString())
	end)
end

function rainclient:AddChat(enumType, sText)
	local sText = sText or ""
	local enumType = enumType or CHAT_IC

	if (CL) then
		chat.AddText(sText)
	else
		net.Start("rain.chat.addchat")
		rain.net.WriteUByte(enumType)
		net.WriteString(sText)
		net.Send(self)
	end
end

--[[
	Name: Get Chat Info
	Category: Chat->PlayerMeta
	Desc: Gets a players chat info, this is wether they are typing/not typing, the type of chat they're performing, etc.
--]]

function rainclient:GetChatInfo()

end

--[[
	Name: Set Chat Info
	Category: Chat->PlayerMeta
	Desc: Sets the players chat info, this is called from client to the server hence why the variables are strictly type checked.
--]]

function rainclient:SetChatInfo(bTyping, enumTypingText)

end

if (CLIENT) then

	--[[
		Name: Add Chat
		Category: Chat
		Desc: Add some text to the chatbox, the text should be formatted on the server ahead of time.
	--]]

	function rain.chat.addchat(sText)

	end

	--[[
		Name: Process Chat String
		Category: Chat
		Desc: Recursively adds <b> and <i> tags to chat based on where * and / is found
	--]]

	function rain.chat.processchatstring(sText)

	end
end