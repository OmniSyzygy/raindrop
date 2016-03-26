rain.db = {}

function rain.db.connect(sAddress, sUsername, sPassword, sDatabase, nPort)
	mysql:SetModule("mysqloo")
	mysql:Connect(sAddress, sUsername, sPassword, sDatabase, nPort)
end

function rain.db.onconnectionsuccess()
	local queryObj = mysql:Create("players")
	queryObj:Create("id", "INT NOT NULL AUTO_INCREMENT")
	queryObj:Create("steam_id64", "VARCHAR(255) NOT NULL")
	queryObj:Create("steam_name", "TINYTEXT NOT NULL")
	queryObj:Create("steam_name_history", "MEDIUMTEXT NOT NULL")
	queryObj:Create("characters", "TINYTEXT NOT NULL")
	queryObj:Create("last_ip", "VARCHAR(128) NOT NULL")
	queryObj:Create("iphistory", "VARCHAR(512) NOT NULL")
	queryObj:Create("client_data", "TEXT NOT NULL")
	queryObj:PrimaryKey("id")
	queryObj:Execute()

	local queryObj = mysql:Create("characters")
	queryObj:Create("id", "INT NOT NULL AUTO_INCREMENT")
	queryObj:Create("charname", "TINYTEXT NOT NULL")
	queryObj:Create("data_character", "MEDIUMTEXT NOT NULL")
	queryObj:Create("data_appearance", "MEDIUMTEXT NOT NULL")
	queryObj:Create("data_adminonly", "MEDIUMTEXT NOT NULL")
	queryObj:PrimaryKey("id")
	queryObj:Execute()

	local queryObj = mysql:Create("bans")
	queryObj:Create("id", "INT NOT NULL AUTO_INCREMENT")
	queryObj:Create("steam_id64", "VARCHAR(255) NOT NULL")
	queryObj:Create("ip", "VARCHAR(64) NOT NULL")
	queryObj:PrimaryKey("id")
	queryObj:Execute()

	timer.Create("rain.db.think", 1, 0, function()
		mysql:Think()
	end)
end
