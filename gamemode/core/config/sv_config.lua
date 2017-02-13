rain.cfg = rain.cfg or {}

rain.cfg.db = {}
rain.cfg.db.address 	= "localhost"	-- database ip address or localhost
rain.cfg.db.username 	= "root"		-- username for the DB
rain.cfg.db.password 	= ""			-- password for the DB
rain.cfg.db.database 	= "raindrop"	-- the name of the DB within the mysql server
rain.cfg.db.port 		= 3306			-- the port of the mysql server, default is 3306
rain.cfg.db.module 		= "mysqloo"
rain.cfg.db.thinktime 	= 1 			-- the time between when a query is pushed to the mysql