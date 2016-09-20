local HOLDTYPE_TRANSLATOR = {}
HOLDTYPE_TRANSLATOR[""] = "normal"
HOLDTYPE_TRANSLATOR["physgun"] = "smg"
HOLDTYPE_TRANSLATOR["ar2"] = "smg"
HOLDTYPE_TRANSLATOR["crossbow"] = "shotgun"
HOLDTYPE_TRANSLATOR["rpg"] = "shotgun"
HOLDTYPE_TRANSLATOR["slam"] = "normal"
HOLDTYPE_TRANSLATOR["grenade"] = "normal"
HOLDTYPE_TRANSLATOR["fist"] = "normal"
HOLDTYPE_TRANSLATOR["melee2"] = "melee"
HOLDTYPE_TRANSLATOR["passive"] = "normal"
HOLDTYPE_TRANSLATOR["knife"] = "melee"
HOLDTYPE_TRANSLATOR["duel"] = "pistol"
HOLDTYPE_TRANSLATOR["camera"] = "smg"
HOLDTYPE_TRANSLATOR["magic"] = "normal"
HOLDTYPE_TRANSLATOR["revolver"] = "pistol"

local PLAYER_HOLDTYPE_TRANSLATOR = {}
PLAYER_HOLDTYPE_TRANSLATOR[""] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["fist"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["pistol"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["grenade"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["melee"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["slam"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["melee2"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["passive"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["knife"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["duel"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["bugbait"] = "normal"

local string = string
local stringLower = string.lower
local stringFind = string.find

local getModelClass = rain.anim.getModelClass
local IsValid = IsValid
local type = type

function rain:TranslateActivity(client, act)
	local model = stringLower(client.GetModel(client))
	local class = getModelClass(model)
	local weapon = client.GetActiveWeapon(client)

	if (class == "player") then
		if (IsValid(weapon) and client.OnGround(client)) then
			if (stringFind(model, "zombie")) then
				local tree = rain.anim.zombie

				if (stringFind(model, "fast")) then
					tree = rain.anim.fastZombie
				end

				if (tree[act]) then
					return tree[act]
				end
			end

			local holdType = weapon.GetHoldType(weapon)
			holdType = PLAYER_HOLDTYPE_TRANSLATOR[holdType] or "passive"

			local tree = rain.anim.player[holdType]

			if (tree and tree[act]) then
				return tree[act]
			end
		end

		return self.BaseClass.TranslateActivity(self.BaseClass, client, act)
	end

	local tree = rain.anim[class]

	if (tree) then
		local subClass = "normal"

		if (client.InVehicle(client)) then
			local vehicle = client.GetVehicle(client)
			local class = vehicle:isChair() and "chair" or vehicle:GetClass()

			if (tree.vehicle and tree.vehicle[class]) then
				local act = tree.vehicle[class][1]
				local fixvec = tree.vehicle[class][2]
				--local fixang = tree.vehicle[class][3]

				if (fixvec) then
					client.ManipulateBonePosition(client, 0, fixvec)
				end

				if (type(act) == "string") then
					client.CalcSeqOverride = client.LookupSequence(client, act)

					return
				else
					return act
				end
			else
				act = tree.normal[ACT_MP_CROUCH_IDLE][1]

				if (type(act) == "string") then
					client.CalcSeqOverride = client:LookupSequence(act)
				end

				return
			end
		elseif (client.OnGround(client)) then
			client.ManipulateBonePosition(client, 0, vector_origin)

			if (IsValid(weapon)) then
				subClass = weapon.GetHoldType(weapon)
				subClass = HOLDTYPE_TRANSLATOR[subClass] or subClass
			end

			if (tree[subClass] and tree[subClass][act]) then
	--			local act2 = tree[subClass][act][client.isWepRaised(client) and 2 or 1]

				--Need to put together our own weapon raising system, defaulted to true until it is implemented.
				local act2 = tree[subClass][act][true and 2 or 1]

				if (type(act2) == "string") then
					client.CalcSeqOverride = client.LookupSequence(client, act2)

					return
				end

				return act2
			end
		elseif (tree.glide) then
			return tree.glide
		end
	end
end

function rain:DoAnimationEvent(client, event, data)
	local model = client:GetModel():lower()
	local class = rain.anim.getModelClass(model)

	if (class == "player") then
		return self.BaseClass:DoAnimationEvent(client, event, data)
	else
		local weapon = client:GetActiveWeapon()

		if (IsValid(weapon)) then
			local holdType = weapon:GetHoldType()
			holdType = HOLDTYPE_TRANSLATOR[holdType] or holdType

			local animation = rain.anim[class][holdType]

			if (event == PLAYERANIMEVENT_ATTACK_PRIMARY) then
				client:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, animation.attack or ACT_GESTURE_RANGE_ATTACK_SMG1, true)

				return ACT_VM_PRIMARYATTACK
			elseif (event == PLAYERANIMEVENT_ATTACK_SECONDARY) then
				client:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, animation.attack or ACT_GESTURE_RANGE_ATTACK_SMG1, true)

				return ACT_VM_SECONDARYATTACK
			elseif (event == PLAYERANIMEVENT_RELOAD) then
				client:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, animation.reload or ACT_GESTURE_RELOAD_SMG1, true)

				return ACT_INVALID
			elseif (event == PLAYERANIMEVENT_JUMP) then
				client.m_bJumping = true
				client.m_bFistJumpFrame = true
				client.m_flJumpStartTime = CurTime()

				client:AnimRestartMainSequence()

				return ACT_INVALID
			elseif (event == PLAYERANIMEVENT_CANCEL_RELOAD) then
				client:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)

				return ACT_INVALID
			end
		end
	end

	return ACT_INVALID
end

local vectorAngle = FindMetaTable("Vector").Angle
local normalizeAngle = math.NormalizeAngle

function rain:CalcMainActivity(client, velocity)
	local eyeAngles = client.EyeAngles(client)
	local yaw = vectorAngle(velocity)[2]
	local normalized = normalizeAngle(yaw - eyeAngles[2])

	client.SetPoseParameter(client, "move_yaw", normalized)

	if (CLIENT) then
		client.SetIK(client, false)
	end

	local oldSeqOverride = client.CalcSeqOverride
	local seqIdeal, seqOverride = self.BaseClass.CalcMainActivity(self.BaseClass, client, velocity)
	--client.CalcSeqOverride is being -1 after this line.

	return seqIdeal, oldSeqOverride or client.CalcSeqOverride
end