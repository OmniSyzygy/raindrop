--[[
	Filename: sandboxhooks.lua
	Purpose: Disable sandbox functionality.
--]]

--	function rain:PlayerSpawnVehicle(pClient, sModel, sName, tVehicle)
--		return false
--	end
--	
--	function rain:PlayerSpawnSWEP(pClient, sWeapon, tSwep)
--		return false
--	end
--	
--	function rain:PlayerSpawnSENT(pClient, sEntClass)
--		return false
--	end
--	
--	function rain:PlayerSpawnRagdoll(pClient, sModel)
--		return false
--	end
--	
--	function rain:PlayerSpawnProp(pClient, sModel)
--		return false
--	end
--	
--	function rain:PlayerSpawnObject(pClient, sModel, nSkin)
--		return false
--	end
--	
--	function rain:PlayerSpawnNPC(pClient, sNPC, sWeapon)
--		return false
--	end
--	
--	function rain:PlayerSpawnEffect(pClient, sModel)
--		return false
--	end
--	
--	function rain:CanDrive(pClient, eEntity)
--		return false
--	end
--end
--
--function rain:CanTool(pClient, tr, tool)
--	if tool == "remover" and !pClient:IsAdmin() then
--		return false
--	end
--end

-- the really nice thing about loading a set of 'core' files then a psuedo schema is the fact that we can re-enable these hooks later on

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