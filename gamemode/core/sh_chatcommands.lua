--[[
	Filename: sh_chatcommands.lua
--]]

-- # Micro-ops
local rain = rain

rain.cc = {}
rain.ccbuffer = {}

--[[
	Name: Default Can Use
	Category: Chat Commands
	Desc: Default/Fallback function for wether or not a user can use a chat command
--]]

function rain.cc.defaultcanuse(pUser)
	if pUser:IsAdmin() then
		return true
	end

	return false
end

--[[
	Name: Default On Use
	Category: Chat Commands
	Desc: Default/Fallback function for when a chat command is called
--]]

function rain.cc.defaultonuse(pUser, sArguments)
	pUser:AddChat(CHAT_NOTIFY, sArguments)
end

--[[
	Name: Default On Fail
	Category: Chat Commands
	Desc: Default/Fallback function for when a user cannot use a chat command
--]]

function rain.cc.defaultonfail(pUser)
	pUser:AddChat(CHAT_NOTIFY, "You cannot use this command.")
end

--[[
	Name: Default Can Success
	Category: Chat Commands
	Desc: Default/Fallback function for when a command is successfuly executed
--]]

function rain.cc.defaultonsuccess(pUser)
	pUser:AddChat(CHAT_NOTIFY, "Command successfuly ran.")
end

--[[
	Name: AddChatCommand
	Category: Chat Commands
	Desc: Adds a chat command, CanUse() is called with the client attempting to use the command being the argument, returning true/false
	      Determines if the command can be ran by that person, OnUse() is called when the command is called by somebody who can use it
	      OnFail() is called when the command cannot be run by the person attempting to call it.
	      OnSuccess() is called when the command is ran by the person attempting to call it successfuly calls it.
--]]

function rain.cc.addchatcommand(sCommandName, fnCanUse, fnOnUse, fnOnFail, fnOnSuccess)
	fnCanUse = fnCanUse or rain.cc.defaultcanuse
	fnOnUse = fnOnUse or rain.cc.defaultonuse
	fnOnFail = fnOnFail or rain.cc.defaultonfail
	fnOnSuccess = fnOnSuccess or rain.cc.defaultonsuccess

	rain.ccbuffer[sCommandName] = {CanUse = fnCanUse, OnUse = fnOnUse, OnFail = fnOnFail, OnSuccess = fnOnSuccess}
end

--[[
	Name: Is Chat Command
	Category: Chat Commands
	Desc: Gets wether or not the prefix provided is a chat command
--]]

function rain.cc.ischatcommand(sPrefix)
	if rain.ccbuffer[sPrefix] then
		return true
	end

	return false
end