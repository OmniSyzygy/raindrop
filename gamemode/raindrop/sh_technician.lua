local pmeta = FindMetaTable("Player")

function pmeta:IsTechnician()
	for i = 1, 3 do 
		if pmeta:HasFlag(tostring(i)) then
			return true
		end
	end

	return false
end