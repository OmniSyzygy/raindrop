rain.cfg = rain.cfg or {}



rain.cfg.db = {}
rain.cfg.db.address 	= "LOCALHOST"	-- database ip address or localhost
rain.cfg.db.username 	= "gmod"		-- username for the DB
rain.cfg.db.password 	= "fuckyoufortryingtolookasshole"			-- password for the DB
rain.cfg.db.database 	= "rain"		-- the name of the DB within the mysql server
rain.cfg.db.port 		= 3306				-- the port of the mysql server, default is 3306
rain.cfg.db.module = "tmysql4" -- The module you are using. OPTIONS: tmysql4, mysqloo, sqlite
rain.cfg.db.thinktime 	= 1 			-- the time between when a query is pushed to the mysql