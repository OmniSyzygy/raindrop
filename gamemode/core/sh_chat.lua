rain.chat = {}

rain.chatbuffer = {}

-- chat type enums

CHAT_OOC = 0
CHAT_IC = 1
CHAT_PM = 2
CHAT_PDA = 3
CHAT_ADMIN = 4

rain.struct:RegisterStruct("ChatStruct", {nRadius = 1024, sFont = "Arial", sIcon = "default", })

--[[
	Name: Add
	Category: Chat
	Desc: Add a type of chat to the chatbox
--]]

function rain.chat.add(tChatStruct, fnOnChat, fnFormatText)

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
	Desc: Adds chat to all players in a specific radius, useful for player zones
--]]

function rain.chat.addinradius(nRadius, enumType, sText)

end

local rainclient = FindMetaTable("Player")

--[[
	Name: Add Chat
	Category: Chat->PlayerMeta
	Desc: Adds chat to a specific players chatbox
--]]

function rainclient:addchat(enumType, sText)

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