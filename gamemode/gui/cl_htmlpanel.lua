local PANEL = {}

function PANEL:LoadHTMLComponent(sElement)
	local sPathToWebFolder = "gamemodes/raindrop/gamemode/gui/html/"..sElement

	local JS = file.Read(sPathToWebFolder.."/"..sElement..".js", "GAME") -- path to the JS File
	local CSS = file.Read(sPathToWebFolder.."/style.css", "GAME") -- path to the CSS Stylesheet
	local HTML = file.Read(sPathToWebFolder.."/home.html", "GAME") -- path to the HTML file

	self:SetHTML("<head><style media='screen' type='text/css'>"..CSS.."</style>".."<script src='https://ajax.googleapis.com/ajax/libs/jquery/2.2.2/jquery.min.js'></script><script>"..JS.."</script></head>"..HTML)
end

derma.DefineControl("RD_HTMLPanel", "", PANEL, "DHTML")