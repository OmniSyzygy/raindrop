local tHeadBobTarget = {}
tHeadBobTarget[1] = {v = Vector(-0.15,0.1,0.45), a = Angle(0,0,0)}
tHeadBobTarget[2] = {v = Vector(0.2,-0.05,-0.3), a = Angle(0,0,0)}

function rain:CalcView(pClient, vPos, aAngs, nFOV, nNearZ, nFarZ)
	
	local velocity = pClient:GetVelocity():Length()
	local alpha = Lerp((velocity / 400), 0, 1)
	local targetalpha = (math.sin(CurTime() * (10)) + 0.5)
	local vLocalPos, aLocalAngs = WorldToLocal(vPos, aAngs, pClient:GetPos(), pClient:GetAngles())
	-- do headbob stuff past here --

	-- lerp between the two targets
	local vHeadBobPos = LerpVector(targetalpha, tHeadBobTarget[1].v, tHeadBobTarget[2].v)
	local aHeadBobAngs = LerpAngle(targetalpha, tHeadBobTarget[1].a, tHeadBobTarget[2].a)

	vLocalPos = LerpVector(alpha, vLocalPos, vHeadBobPos + vLocalPos)
	aLocalAngs = LerpAngle(alpha, aLocalAngs, aHeadBobAngs + aHeadBobAngs)

	-- dont do headbob stuff past here --
	local vWorldPos, aWorldAngs = LocalToWorld(vLocalPos, aLocalAngs, pClient:GetPos(), pClient:GetAngles()) 
	local view = {}
	view.origin = vWorldPos
	view.angles = aAngs
	view.fov = nFOV
	view.drawviewer = false

	return view
end