rain.db = {}

function rain.db.connect(sAddress, sUsername, sPassword, sDatabase, nPort)
	mysql:SetModule("tmysql4")
	mysql:Connect(sAddress, sUsername, sPassword, sDatabase, nPort)
end

function rain.db.onconnectionsuccess()
	local queryObj = mysql:Create("players")
	queryObj:Create("id", "INT NOT NULL AUTO_INCREMENT") -- unique player id for this server specifically
	queryObj:Create("steam_id64", "VARCHAR(256) NOT NULL") -- 64bit steam id, I use the 64bit steamid for ease of use
	queryObj:Create("steam_name", "VARCHAR(64) NOT NULL") -- last known steamname
	queryObj:Create("steam_name_history", "MEDIUMTEXT NOT NULL") -- history of steam names
	queryObj:Create("characters", "VARCHAR(64) NOT NULL") -- character ids
	queryObj:Create("last_ip", "VARCHAR(128) NOT NULL") -- last known ip addresses
	queryObj:Create("iphistory", "VARCHAR(512) NOT NULL") -- history of ip addresses
	queryObj:Create("client_data", "VARCHAR(1024) NOT NULL")
	queryObj:PrimaryKey("id")
	queryObj:Execute()

	local queryObj = mysql:Create("characters")
	queryObj:Create("id", "INT NOT NULL AUTO_INCREMENT")
	queryObj:Create("charname", "VARCHAR(48) NOT NULL")
	queryObj:Create("data_character", "MEDIUMTEXT NOT NULL")
	queryObj:Create("data_appearance", "MEDIUMTEXT NOT NULL")
	queryObj:Create("data_adminonly", "MEDIUMTEXT NOT NULL")
	queryObj:Create("data_inventory", "MEDIUMTEXT NOT NULL")
	queryObj:PrimaryKey("id")
	queryObj:Execute()

	local queryObj = mysql:Create("bans")
	queryObj:Create("id", "INT NOT NULL AUTO_INCREMENT") -- banid
	queryObj:Create("steam_id64", "VARCHAR(256) NOT NULL") -- steamid ban
	queryObj:Create("ip", "VARCHAR(64) NOT NULL") -- ip ban
	queryObj:Create("permanent", "TINYINT(1) NOT NULL") -- 0 or 1 indicating wether it is a permaban, expiration date still applies and is automatically set to a year in case of a permaban.
	queryObj:Create("expirationdate", "VARCHAR(256) NOT NULL") -- date the ban ends on

	queryObj:PrimaryKey("id")
	queryObj:Execute()

	local queryObj = mysql:Create("items")
	queryObj:Create("id", "INT NOT NULL AUTO_INCREMENT") -- item id, also doubles as the RNG seed
	queryObj:Create("ownerhistory", "VARCHAR(2048) NOT NULL") -- history of owners, when the item was picked up/dropped and who dropped/picked it up is stored here
	queryObj:Create("base", "VARCHAR(64) NOT NULL") -- string of the item base
	queryObj:Create("meta", "VARCHAR(64) NOT NULL") -- edited data, uses, etc goes here
	queryObj:Create("inworld", "TINYINT(1) NOT NULL") -- 0 or 1 indicating wether it should be in the world or not
	queryObj:Create("worlddata", "VARCHAR(256) NOT NULL") -- data such as the pos, angs, and any additional info needed to spawn the item
	queryObj:PrimaryKey("id")
	queryObj:Execute()

	rain.log.onconnectionsuccess()

	timer.Create("rain.db.think", 1, 0, function()
		mysql:Think()
	end)
end
