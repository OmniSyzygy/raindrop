--[[
	Filename: sandboxhooks.lua
	Purpose: Disable sandbox functionality.
--]]

if (CL) then
	function rain:HUDAmmoPickedUp(sItemName, nAmount)
		return false
	end

	function rain:HUDDrawPickupHistory()
		return false
	end

	function rain:HUDDrawTargetID()
		return false
	end

	function rain:HUDDrawScoreBoard()
		return false
	end

	function rain:HUDItemPickedUp(sItemName)
		return false
	end

	function rain:HUDShouldDraw(sName)
		if rain.cfg.HiddenUIElements[sName] then
			return false
		else
			return true
		end
	end
end