--[[
	Filename: sv_logging.lua
	Desc: Logging system that also saves to the mysql DB
	Extended By: LivKX
	For: Deadi
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

--[[

Raindrop Logs
Made by LivKX
For: Deadi

]]

util.AddNetworkString("LogsRequest")
util.AddNetworkString("SendLogs")

local logs = {} -- Initialize Logs Table

if file.Exists("raindrop/logs.txt","DATA") then -- Does our local log exist?
	logs = util.JSONToTable(file.Read("raindrop/logs.txt","DATA")) -- Make the logs table load from our file which is converted from GMod Json to table
	print("Local logs have been loaded!")
else
	print("(!!! Logs) No local logs file found at DATA/raindrop/logs.txt")
	print("(!!! Logs) Check MySQL backup!")
end
 

-- !CUSTOMIZE THIS TO HOW YOU WANT LOGS AUTHING TO BE DONE!
function SAuth(ply)

if ply:IsAdmin() then
	return true
else
	return false
end

end
-- !CUSTOMIZE THIS TO HOW YOU WANT LOGS AUTHING TO BE DONE!

--[[

Dear Developers:


Log format is as follows:

raindrop.log.add(ply,tag,action,value,value2,ply2)

ply = player concerned (DONT LEAVE NIL)
tag = tag which is concerned, find default tag list below. (DONT LEAVE NIL)
YOU MAY USE A NON DEFAULT CATEGORY but it is NOT advised
action = the action that has been takes e.g. drop/give (DONT LEAVE NIL)
value = value of action e.g. ammount of money picked up or the item that's been picked up (DONT LEAVE NIL)
value2 = value 2 if concerned
ply2 = second player if concerned

if not concerned, please enter 'nil'

Default Tags:

moneyitem = money or items
admin = administration
dmgpvp = damage/pvp
misc = stuff like players connecting etc
rp = roleplay related stuff

Values:
(this is just a recommendation, as long as the vgui handles it, no problem)
moneyitem - pickup,drop,use,give,rename etc
dmgpvp - take
misc - chat,ooc,connect,disconnect,spawn
admin - command,tp,noclip etc



Table Structure:

logs{
	
{Player Name, SteamID, tag, action, value, value2, player 2 name, SteamID, TimeString,TimeStamp,map}

}

TimeString = 14/09/2016
TimeStamp = 1473883853 (Number of seconds past UNIX Epoch)

TO REQUEST LOGS AS A CLIENT:
net.Start("LogsRequest")
net.WriteInt(TimeRange,32) - Time Range should be in seconds, a default for first time logs load should be 1800 recommended
net.SendToServer()

If the client passes authorization, they will then get the results from the server which you should be receiving with

net.Recieve("SendLogs", function(len)
local logs = net.ReadTable()
end)

]]

-- (!)ADD MYSQL QUERY UNDERNEATH THE TABLE.INSERT
-- (!)Yes, we are inserting a table into a table!

function rain.log.add(ply,tag,action,value,value2,ply2) -- set up function
	local TimeStamp = os.time() -- get time
	local TimeString = os.date( "%d/%m/%Y" , TimeStamp ) -- format time and date for logging
	if ply && tag && action && value then -- if we have our essential values are present then
		if IsValid(ply) && IsPlayer(ply) then -- checks ply is valid
			if value2 && ply2 then -- if we have value2 and ply2 which are extras, go ahead
				if IsValid(ply2) && IsPlayer(ply2) then -- checks ply2 specified is valid
					local t = {ply:Nick(),ply:SteamID(),tag,action,value,value2,ply2:Nick(),ply2:SteamID(),TimeString,TimeStamp,game.GetMap()}
					table.insert(logs,nil,t) -- logs
					file.Write("raindrop/logs.txt",util.TableToJSON(logs))
					rain.log.savelog(table.concat(t,","), tag)
				else
					local t = {ply:Nick(),ply:SteamID(),tag,action,value,value2,"err","err",TimeString,TimeStamp,game.GetMap()}
					table.insert(logs,nil,t) -- Logs with errors for ply2
					file.Write("raindrop/logs.txt",util.TableToJSON(logs))
					rain.log.savelog(table.concat(t,","), tag)
				end
			elseif value2 && !ply2 then
				local t = {ply:Nick(),ply2:SteamID(),tag,action,value,value2,"nil","nil",TimeString,TimeStamp,game.GetMap()}
				table.insert(logs,nil,t)
				file.Write("raindrop/logs.txt",util.TableToJSON(logs))
				rain.log.savelog(table.concat(t,","), tag)
			elseif ply2 && !value2 then
				if IsValid(ply2) && IsPlayer(ply2) then
					local t = {ply:Nick(),ply2:SteamID(),tag,action,value,"nil",ply2:Nick(),ply2:SteamID(),TimeString,TimeStamp,game.GetMap()}
					table.insert(logs,nil,t)
					file.Write("raindrop/logs.txt",util.TableToJSON(logs))
					rain.log.savelog(table.concat(t,","), tag)
				else
					local t = {ply:Nick(),ply2:SteamID(),tag,action,value,"nil","err","err",TimeString,TimeStamp,game.GetMap()}
					table.insert(logs,nil,t)
					file.Write("raindrop/logs.txt",util.TableToJSON(logs))
					rain.log.savelog(table.concat(t,","), tag)
				end
			else
				local t = {ply:Nick(),ply2:SteamID(),tag,action,value,"nil","nil","nil",TimeString,TimeStamp,game.GetMap()}
				table.insert(logs,nil,t)
				file.Write("raindrop/logs.txt",util.TableToJSON(logs))
				rain.log.savelog(table.concat(t,","), tag)
			end
		end
	end
end

net.Receive("LogsRequest", function(len,ply) -- Server recieves a request for logs

if SAuth(ply) then -- If our player is authorized

if net.ReadInt(32) then -- If a time range has been specified
	local range = net.ReadInt(32) -- range = time range specified
else
	local range = 1800 -- range is 30 minutes
end

local myt = os.time() -- myt = time since unix epoch
local clogs = {} -- set up table

for k,v in pairs(logs) do -- loops through all table entries in logs table
	if v[10] >=  myt - range then -- if value 10 of the table (time since unix epoch) is bigger or equal to current time - range
		table.insert(clogs,nil,v) -- insert that log entry into clogs
	end
end

net.Start("SendLogs") -- sends it to the player
net.WriteTable(clogs) -- writes table
net.Send(ply) -- sends it to the player

else -- alert admins a non authed player tried to view logs

	for k,v in pairs(player.GetAll()) do 
		if v:IsAdmin() then 
			v:ChatPrint("WARNING: "..ply:Nick().." just tried to read the logs but they are not authed!")
		end
	end
end

end)

function dmglogs(plytk,dmginfo) -- Automatic Damage Logs!
	if plytk:IsPlayer() then
	local ply2 = dmginfo:GetAttacker()
	if IsPlayer(ply2) then
			local TimeStamp = os.time() -- get time
			local TimeString = os.date( "%d/%m/%Y" , TimeStamp )
			local t = {ply:Nick(),ply2:SteamID(),"dmgpvp","take",dmginfo:GetDamage(),ply2:GetActiveWeapon(),ply2:Nick(),ply2:SteamID(),TimeString,TimeStamp,game.GetMap()}
			table.insert(logs,nil,t)
			file.Write("raindrop/logs.txt",util.TableToJSON(t))
	else
		local TimeStamp = os.time() -- get time
		local TimeString = os.date( "%d/%m/%Y" , TimeStamp )
		local t = {ply:Nick(),ply:SteamID(),"dmgpvp","take",dmginfo:GetDamage(),dmginfo:GetDamageType(),ply2:GetClass(),"nil",TimeString,TimeStamp,game.GetMap()}
		table.insert(logs,nil,t)
		file.Write("raindrop/logs.txt",util.TableToJSON(t))
	end
	end
end
hook.Add(EntityTakeDamage,"DamageLogging",dmglogs)
