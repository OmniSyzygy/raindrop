ITEM.ID				= "vodka"
ITEM.Name			= "Vodka"
ITEM.Description	= "A bottle of vodka. Probably unsafe to drink."
ITEM.Model			= "models/props_junk/glassjug01.mdl"
ITEM.Weight 		= 2
ITEM.SizeX			= 2
ITEM.FOV 			= 11
ITEM.CamPos 		= Vector( 50, 50, 50 )
ITEM.LookAt 		= Vector( 0, 0, 5.56 )

ITEM.BulkPrice		= 100
ITEM.License		= LICENSE_ALCOHOL

ITEM.Usable			= true
ITEM.UseText		= "Drink"
ITEM.DeleteOnUse	= true
ITEM.OnPlayerUse	= function(self, player)
	if (CL) then
		player:ChatPrint("You open and drink the vodka.")
	end
end