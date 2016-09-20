------------------------/
-- Configuration file  --
------------------------/

LevelSystemConfiguration = {} -- Ignore


LevelSystemConfiguration.EnableHUD = true -- Is the HUD enabled?
LevelSystemConfiguration.LevelColor = Color(255,255,255,255) -- The color of the "Level: 1" HUD element. White looks best.
LevelSystemConfiguration.XPTextColor = Color(255,255,255,255) -- The color of the XP percentage HUD element.
LevelSystemConfiguration.LevelBarColor = {230,161,14} -- The color of the XP bar.
LevelSystemConfiguration.PerksMenuColor1 = {82,85,100} -- The background color of the perks menu
LevelSystemConfiguration.PerksMenuColor2 = {116,130,143} -- The secondary color of the perks menu
LevelSystemConfiguration.PerksBoxColor1 = {190,185,181} -- The color of the main box that holds the perk information
LevelSystemConfiguration.PerksBoxColor2 = {194,91,86} -- The color of the secondary boxes that hold the perk information

LevelSystemConfiguration.XPMult = 1 -- How hard it is to level up. 2 would require twice as much XP, ect. NOTE: XP formula already sets the required XP exponentialy: (10+((currLevel)*((currLevel)+1)*90))*XPMult
LevelSystemConfiguration.MaxLevel = 5 -- The max level
LevelSystemConfiguration.MaxPerks = 10 -- The max ammount of active perks
LevelSystemConfiguration.ContinueXP = false -- If remaining XP continues over to next levels. I recommend this to be false. Seriously.
LevelSystemConfiguration.ShowPlayerLevel = false -- Show other player's level above their heads
LevelSystemConfiguration.AlwaysShowPlayerLevel = false -- Show other player's level regardless of weather we're looking at them or not