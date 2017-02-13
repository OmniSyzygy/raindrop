local ITEM = {}

ITEM.Name = "Blueprint"
ITEM.Description = "Used to craft an item."
ITEM.Tier = E_WHTIE
ITEM.Generation = 1 -- how many times this item has been scanned.
ITEM.Durability = 100 -- durability of the item that gets created
ITEM.RNGNumber = 1

rain.item.registerbase(ITEM)