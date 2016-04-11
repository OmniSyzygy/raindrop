rain.chat = {}

rain.chatbuffer = {}

-- chat type enums

CHAT_OOC = 0
CHAT_IC = 1
CHAT_PM = 2
CHAT_PDA = 3
CHAT_ADMIN = 4
CHAT_NOTIFY = 5

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


rain.struct:RegisterStruct("ChatStruct", {nRadius = 1024, bGlobal = false, sFont = "Arial", sIcon = "default", wPrefix = "//", sPrintName = "default", enumType = CHAT_OOC, sPrintNameShort = "def"})

--[[
	Name: Add
	Category: Chat
	Desc: Add a type of chat to the chatbox
--]]

function rain.chat.add(tChatStruct, fnFormatText, fnOnChat)
	local tChatData = rain.struct:GetStruct("ChatStruct")

	tChatData.nRadius = tChatStruct.nRadius or tChatData.nRadius
	tChatData.bGlobal = tChatStruct.bGlobal or tChatData.bGlobal
	tChatData.sFont = tChatStruct.sFont or tChatData.sFont
	tChatData.sIcon = tChatStruct.sIcon or tChatData.sIcon
	tChatData.wPrefix = tChatStruct.wPrefix or tChatData.wPrefix
	tChatData.sPrintName = tChatStruct.sPrintName or tChatData.sPrintName
	tChatData.sPrintNameShort = tChatStruct.sPrintNameShort or tChatStruct.sPrintNameShort
	tChatData.enumType = tChatStruct.enumType or tChatData.enumType

	local fnOnChat = fnOnChat or function(sText, pSpeaker) end

	rain.chatbuffer[tChatData.wPrefix] = {struct = tChatData, OnChat = fnOnChat, FormatText = fnFormatText}
end

rain.chat.add({sPrintName = "Out Of Character",
	nRadius = 0, 
	enumType = CHAT_OOC,
	bGlobal = true, 
	wPrefix = "//", 
	sPrintNameShort = "OOC"},
	function(sText, pSpeaker)
		return pSpeaker:Nick().." - [OOC]: "..sText
	end
)

rain.chat.add({sPrintName = "Action",
	nRadius = 1024, 
	enumType = CHAT_IC,
	wPrefix = "/me", 
	sPrintNameShort = "me"},
	function(sText, pSpeaker)
		return pSpeaker:GetRPName().." "..sText
	end
)

rain.chat.add({sPrintName = "Yell",
	nRadius = 2048, 
	enumType = CHAT_IC,
	wPrefix = "/y", 
	sPrintNameShort = "Yell"},
	function(sText, pSpeaker)
		return pSpeaker:GetRPName()..' yells "'..sText..'" '
	end
)

rain.chat.add({sPrintName = "Whisper",
	nRadius = 512, 
	enumType = CHAT_IC,
	wPrefix = "/w", 
	sPrintNameShort = "Whisper"},
	function(sText, pSpeaker)
		return pSpeaker:GetRPName()..' whispers "'..sText..'" '
	end
)

--[[
	Name: Format IC Text
	Category: Chat
	Desc: Formats IC chat, this is because IC is the 'default' and doesn't fit anywhere into the system
--]]

function rain.chat.formatictext(pSpeaker, sText)
	return pSpeaker:GetRPName()..' says "'..sText..'" '
end

--[[
	Name: Add In Area
	Category: Chat
	Desc: Adds chat to all players within certain bounds
--]]

function rain.chat.addinarea(vMin, vMax, enumType, sText)
	for k, v in pairs(ents.FindInBox(vMin, xMax)) do
		if v:IsPlayer() then
			v:AddChat(enumType, sText)
		end
	end
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
	Name: Broadcast
	Category: Chat
	Desc: Broadcasts chat to every connected player on the server
--]]

function rain.chat.broadcast(enumType, sText)
	for k, v in pairs(player.GetAll()) do
		v:AddChat(enumType, sText)
	end
end

--[[
	Name: Player Say
	Category: Chat
	Desc: Called when a player sends out a chat message
--]]

function rain:PlayerSay(pSender, sText, bTeamChat)
	if !pSender:CanSay() then
		return ""
	end

	if string.StartWith(sText, "/") then
		local expl = string.Explode(" ", sText)
		local prefix = expl[1]
		table.remove(expl, 1)
		local toformat = string.Implode(" ", expl)

		prefix = string.lower(prefix)

		if rain.chatbuffer[prefix] then
			local ChatType = rain.chatbuffer[prefix]
			local ChatData = ChatType.struct

			if ChatType.OnChat then
				ChatType.OnChat(pSender)
			end
			PrintTable(ChatType)
			local final = ChatType.FormatText(toformat, pSender)

			if ChatData.bGlobal then
				rain.chat.broadcast(ChatData.enumType, final)
			else
				rain.chat.addinradius(pSender:GetPos(), ChatData.nRadius, ChatData.enumType, final)
			end
		else
			pSender:AddChat(CHAT_NOTIFY, "Invalid Command")
			return ""
		end
	else
		-- assume IC
		rain.chat.addinradius(pSender:GetPos(), 1024, 1, rain.chat.formatictext(pSender, sText))
	end

	return "" -- always return nothing
end

local rainclient = FindMetaTable("Player")

--[[
	Name: Can Say
	Category: Chat->PlayerMeta
	Desc: returns true/false is a player can currently speak
--]]

function rainclient:CanSay()
	if self:GetState() == STATE_MENU then
		return false
	elseif self:GetState() == STATE_LOADING then
		return false
	end

	return true
end

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
		rain.chat.addchat(enumType, sText)
	else
		net.Start("rain.chat.addchat")
		rain.net.WriteUByte(enumType)
		net.WriteString(sText)
		net.Send(self)
	end
end

--[[
	Name: Get Chatting
	Category: Chat->PlayerMeta
	Desc: Gets wether or not a player is chatting, which if they are it will call more expensive functions to dig up more information.
--]]

function rainclient:GetChatting()
	return self.typing
end

--[[
	Name: Get Chat Info
	Category: Chat->PlayerMeta
	Desc: Gets a players chat info, this is wether they are typing/not typing, the type of chat they're performing, etc.
--]]

function rainclient:GetChatInfo()
	if self.chatinfo then
		return self.typing, self.texttype
	end
end

--[[
	Name: Set Chat Info
	Category: Chat->PlayerMeta
	Desc: Sets the players chat info, this is called from client to the server hence why the variables are strictly type checked.
--]]

if (SV) then
	util.AddNetworkString("rain.chat.setchatinfo")
end

net.Receive("rain.chat.setchatinfo", function(len, pSender)
	local bTyping, enumTypingText = net.ReadBool(), net.ReadUInt(5)

	if (SV) then
		pSender:SetChatInfo(bTyping, enumTypingText)
	else
		local target = net.ReadEntity()
		if target != LocalPlayer() then
			target:SetChatInfo(bTyping, enumTypingText)
		end
	end
end)

function rainclient:SetChatInfo(bTyping, enumTypingText)
	if (CL) then
		if self == LocalPlayer() then
			self.chatinfo = {}
			self.chatinfo.typing = bTyping
			self.chatinfo.texttype = enumTypingText

			net.Start("rain.chat.setchatinfo")
			net.WriteBool(bTyping)
			net.WriteUInt(enumTypingText, 5)
			net.SendToServer()
		else
			self.typing = bTyping
			self.texttype = enumTypingText
		end
	else
		self.typing = bTyping
		self.texttype = enumTypingText

		self:SyncChatInfo()
	end
end

function rainclient:SyncChatInfo()
	net.Start("rain.chat.setchatinfo")
	net.WriteBool(self.typing)
	net.WriteUInt(self.texttype, 5)
	net.WriteEntity(self)
	net.Broadcast()
end

if (CL) then

	--[[
		Name: Add Chat
		Category: Chat
		Desc: Add some text to the chatbox, the text should be formatted on the server ahead of time.
	--]]

	function rain.chat.addchat(enumChatType, sText)
		chat.AddText(rain.chat.processchatstring(sText))
	end

	--[[
		Name: Process Chat String
		Category: Chat
		Desc: Recursively adds <b> and <i> tags to chat based on where * and / is found
	--]]

	function rain.chat.processchatstring(sText)
		return sText
	end

	--[[
		Name: Start Chat
		Category: Chat
		Desc: Called when the player opens their chatbox
	--]]

	function rain:StartChat()
		LocalPlayer():SetChatInfo(true, 1)
	end

	--[[
		Name: Finish Chat
		Category: Chat
		Desc: Called when the player finishes chatting
	--]]

	function rain:FinishChat()
		LocalPlayer():SetChatInfo(false, 1)
	end
end