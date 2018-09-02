-- # Micro-ops
local rain = rain

rain.cfg = rain.cfg or {}

rain.cfg.db = {}
rain.cfg.db.address 	= "127.0.0.1"	-- # database ip address or localhost or 127.0.0.1
rain.cfg.db.username 	= "root"		-- # username for the DB
rain.cfg.db.password 	= ""			-- # password for the DB -- Rl#@tTXm3qyGgKV%
rain.cfg.db.database 	= "raindrop"	-- # the name of the DB within the mysql server
rain.cfg.db.port 		= 3306			-- # the port of the mysql server, default is 3306
rain.cfg.db.module 		= "mysqloo"		-- # MYSQL module: sqlite, mysqloo, tmysql4
rain.cfg.db.thinktime 	= 1 			-- # the time between when a query is pushed to the mysql