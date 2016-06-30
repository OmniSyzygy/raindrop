local pmeta = FindMetaTable("Player")

function pmeta:IsTechnician()
	for i = 1, 3 do 
		if pmeta:HasFlag(tostring(i)) then
			return true
		end
	end

	return false
end

if (SERVER) then
	-- creates a blueprint from an item object
	
	function pmeta:CreateBlueprint(objItem)
		if objItem then
			if objItem.Generation and objItem.Generation == 5 then
				self:Notify("ERROR: This item has been reproduced too many times.")
				return false
			end

			if objItem:GetBaseItem() then
				local bp = rain.item:New("blueprint")
				bp:SetBaseItem(objItem:GetBaseItem())

				
			end
		end	
	end

end