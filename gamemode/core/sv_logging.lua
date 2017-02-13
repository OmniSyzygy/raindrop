--[[
	Filename: sv_logging.lua
	Desc: Logging system that also saves to the mysql DB
--]]

rain.log = {}

--[[
	Name: Error
	Category: Log
	Desc: Saves a log to console if devmode is on, to the db if devmode is off
--]]


function rain.log.error(sText)
	if !rain.dev then
		rain.log.savelog(sText, "ERROR")
	else
		rain.util.log(tostring(sText), "ERROR")
	end
end


--[[
	Name: GetPlayerInfo
	Category: Log
	Desc: Get the player name, or return a string stating the player is invalid.
--]]

function rain.log.getplayerinfo(aPlayer)
	if (IsValid(aPlayer) and aPlayer) then
		if (aPlayer:GetState() != E_LOADING) then
			return aPlayer:GetVisibleRPName()
		end
	else
		return "invalid client"
	end
end

--[[
	Name: Dev
	Category: Log
	Desc: Saves a development log to console if devmode is on, to the db if devmode is off.
--]]

function rain.log.dev(sText)
	if !rain.dev then
		rain.log.savelog(sText, "DEV")
	else
		rain.util.log(tostring(sText), "DEV")
	end
end

--[[
	Name: Warning
	Category: Log
	Desc: Saves a log to console if devmode is on, to the db if devmode is off
--]]

function rain.log.warning(sText)
	if !rain.dev then
		rain.log.savelog(sText, "WARNING")
	else
		rain.util.log(tostring(sText), "WARNING")
	end
end

--[[
	Name: MySQL
	Category: Log
	Desc: Saves a log to console if devmode is on, to the db if devmode is off
--]]

function rain.log.mysql(sText)
	if !rain.dev then
		rain.log.savelog(sText, "MYSQL")
	else
		rain.util.log(tostring(sText), "MYSQL")
	end
end

--[[
	Name: Admin
	Category: Log
	Desc: Saves an admin log to the mysql db for review later on
--]]

function rain.log.admin(sText)
	rain.log.savelog(sText, "ADMIN")
end

--[[
	Name: Levels
	Category: Log
	Desc: Saves a levels log to the mysql db for review later on
--]]

function rain.log.levels(sText)
	rain.log.savelog(sText, "LEVELS")
end

--[[
	Name: Error
	Category: Log
	Desc: Saves a log to console if devmode is on, to the db if devmode is off
--]]

function rain.log.player(sText)
	rain.util.log(tostring(sText), "PLAYER")
end

--[[
	Name: SaveLog
	Category: Log
	Desc: Saves a log to the mysql database for later review
--]]

function rain.log.savelog(sText, sTag)
	
	rain.util.log(tostring(sText), "LOG - "..sTag)

	local InsertObj = mysql:Insert("logs")
	InsertObj:Insert("time", tostring(util.DateStamp()))
	InsertObj:Insert("tag", tostring(sTag))
	InsertObj:Insert("logdata", tostring(sText))
	InsertObj:Execute()
end

--[[
	Name: On Connection Success
	Category: Log
	Desc: Called when the script has connected to the mysql database.
--]]

function rain.log.onconnectionsuccess()
	local queryObj = mysql:Create("logs")
	queryObj:Create("id", "INT NOT NULL AUTO_INCREMENT") -- log id
	queryObj:Create("time", "VARCHAR(128) NOT NULL") -- time the log was recorded
	queryObj:Create("tag", "VARCHAR(64) NOT NULL") -- the type of log being added to the DB
	queryObj:Create("logdata", "VARCHAR(4096) NOT NULL")
	queryObj:PrimaryKey("id")
	queryObj:Execute()
end