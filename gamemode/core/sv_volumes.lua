
function rain:SaveVolume(tVolume)
		local InsertObj = mysql:Insert("volumes")
		InsertObj:Insert("Min", tVolume.Min)
		InsertObj:Insert("Max", tVolume.Max)
		InsertObj:Insert("Type", tVolume.Type)
		InsertObj:Insert("Map", game.GetMap())
		if tVolume.Radial then
		InsertObj:Insert("Radial", 1)
		else
		InsertObj:Insert("Radial", 0)
		end
		InsertObj:Callback(function(result, status, lastID)

		end)
		InsertObj:Execute()
end

function rain:DeleteVolume(Min, Max, Map)
	local delObj = mysql:Delete("volumes")
		delObj:Where("Min", Min)
		delObj:Where("Max", Max)
		delObj:Where("Map", Map)
		delObj:Execute()

	--	pOwner:RemoveCharacter(charID)
	end

function rain:LoadVolumes()
	local LoadObj = mysql:Select("volumes")
	LoadObj:Where("map", game.GetMap())
	LoadObj:Callback(function(tResult, uStatus, uLastID)
			for _, volumes in pairs(tResult) do
				rain:AddVolume(volumes, false)
			--	PrintTable(volumes)
			end
		end)
	LoadObj:Execute()
end

