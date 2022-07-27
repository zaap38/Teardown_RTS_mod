detectRange = 2.5

vehicle = {}

maxSpeed = 15

goalPos = Vec(0, 0, 0)
SPOTMARKED = false

gCost = 1

testHeight = 2
drivePower = 0.6

detectPoints = {
	[1] = Vec(0, 0, -detectRange * 2),
	[2] = Vec(detectRange, 0, -detectRange),
	[3] = Vec(-detectRange, 0, -detectRange),
	[4] = Vec(-detectRange, 0, 0),
	[5] = Vec(detectRange, 0, 0),
	[6] = Vec(0, 0, detectRange)
}

weights = {
	[1] = 0.85,
	[2] = 0.85,
	[3] = 0.85,
	[4] = 0.5,
	[5] = 0.5,
	[6] = 0.25
}

targetMoves = {
	list = {},
	target = Vec(0, 0, 0),
	targetIndex = 1
}

hitColour = Vec(1, 0, 0)
clearColour = Vec(0, 1, 0)
numberVehicles = #FindVehicles("cfg",true)
SetInt("level.totalVehicles", numberVehicles)

function init()
	for i = 1, 10 do
		targetMoves.list[i] = Vec(0, 0, 0)
	end

	vehicle.id = FindVehicle("cfg")
	updatePlayerPosTimer = 0
end

identifier = nil

function tick(dt)

	local health = GetVehicleHealth(vehicle.id)

	identifier = GetTagValue(GetVehicleBody(vehicle.id), "identifier")
	
	--DebugWatch(vehicle.id .. " health " ,health)

	local healthBarBase = VecAdd(GetVehicleTransform(vehicle.id).pos,Vec( 0,3,0))
	local healthBarMiddle = VecAdd(GetVehicleTransform(vehicle.id).pos,Vec( 0,3 + health,0))
	local healthBarTop = VecAdd(GetVehicleTransform(vehicle.id).pos,Vec( 0,4,0))

	setHealthInRegistry()
	setStatusInRegistry()
	if(health <= 0.5) then
		onDestroyed()
	else
		--DrawLine(healthBarBase,healthBarMiddle, 0, 1, 0)
		--DrawLine(healthBarMiddle,healthBarTop, 1, 0, 0)
	end

	updatePlayerPosTimer = updatePlayerPosTimer - dt
	if updatePlayerPosTimer <= 0 then
		updatePlayerPosTimer = 0.5
		goalPos = getNavigationPosFromRegistry() --VecAdd(GetPlayerTransform().pos, Vec(0,1,0))
	end
	--DrawLine(goalPos, GetVehicleTransform(vehicle.id).pos)
	--markLoc()
	targetCost = vehicleDetection3()
	targetCost.target = MAV(targetCost.target)
	controlVehicle(targetCost)
	drawTeamOutline(GetVehicleBody())
end

function drawTeamOutline(body)
	--for i=1, #bodies do
		local r = 1
		local g = 0
		--if GetTagValue(bodies[i], "team") == "1" then
		if GetTagValue(body, "team") == "1" then
			r = 0
			g = 1
		end
		--DrawBodyOutline(bodies[i], r, g, 0, 1)
		DrawBodyOutline(body, r, g, 0, 1)
	--end
end

function setHealthInRegistry()
	SetFloat("level.rts.health." .. identifier, (GetVehicleHealth(vehicle.id) - 0.5) * 100)
end

function getNavigationPosFromRegistry()
	local pos = Vec()
	for i=1, 3 do
		pos[i] = GetFloat("level.rts.navigation_pos." .. identifier .. "." .. i)
	end
	return pos
end

function setStatusInRegistry()
	SetBool("level.rts.alive." .. identifier, GetVehicleHealth(vehicle.id) * 100 > 0)
end

onDestroyedCalled = false
function onDestroyed()
	if not onDestroyedCalled then
		onDestroyedCalled=true

		if BLOWN then
		--DebugPrint(vehicle.id .. " DESTROYED BLOWN")
			
		else
			--DebugPrint(vehicle.id .. " DESTROYED")
			Explosion(GetVehicleTransform(vehicle.id).pos, 3)
			local a = GetInt("level.destroyedVehicles")
			--if a == 0 then a = 1 end
			Delete(vehicle.id)
			--DebugPrint("destroyedVehicles " .. a)
			SetInt("level.destroyedVehicles", a + 1)
		end
	end
end

function draw()

end




function update(dt)
	--if GetInt("level.tankdispatch") == 0 then
	--	return
	--end
end

function vehicleDetection3()
	local vehicleBody = GetVehicleBody(vehicle.id)
	local vehicleTransform = GetVehicleTransform(vehicle.id)
	local min, max = GetBodyBounds(vehicleBody)
	vehicleTransform.pos = TransformToParentPoint(vehicleTransform, Vec(0, testHeight, 0))
	local vehicleTransformOrig = TransformCopy(vehicleTransform)
	local fwd = TransformToParentPoint(vehicleTransform, Vec(0, 0, -detectRange * 1.5))
	local fwdL = TransformToParentPoint(vehicleTransform, Vec(detectRange, 0, -detectRange))
	local fwdR = TransformToParentPoint(vehicleTransform, Vec(-detectRange, 0, -detectRange))
	local boundsSize = VecSub(max, min)

	costs = {}
	bestCost = {key = 0, val = 1000, target = Vec(0, 0, 0)}

	if (VecLength(goalPos) > 0.5 and VecLength(VecSub(GetVehicleTransform(vehicle.id).pos, goalPos)) > 3) then
		for key, detect in ipairs(detectPoints) do
			vehicleTransform = GetVehicleTransform(vehicle.id)
			vehicleTransform.pos = TransformToParentPoint(vehicleTransform, Vec(0, testHeight, 0))
			if (detect[3] < 0) then
				vehicleTransform.pos = TransformToParentPoint(vehicleTransform, Vec(0, 0, -boundsSize[3] * .4))
			elseif (detect[3] > 0) then
				vehicleTransform.pos = TransformToParentPoint(vehicleTransform, Vec(0, 0, boundsSize[3] * .4))
			end
			if (detect[1] < 0) then
				vehicleTransform.pos = TransformToParentPoint(vehicleTransform, Vec(-boundsSize[1] * .25), 0, 0)
			elseif (detect[1] > 0) then
				vehicleTransform.pos = TransformToParentPoint(vehicleTransform, Vec(boundsSize[1] * .25), 0, 0)
			end
			--QueryRequire("physical static large")
			QueryRejectVehicle(vehicle.id)
			local fwdPos = TransformToParentPoint(vehicleTransform, detect)
			local direction = VecSub(fwdPos, vehicleTransform.pos)
			hit, dist = QueryRaycast(vehicleTransform.pos, direction, VecLength(direction) * .5, boundsSize[1] * .5)
			local lineColour = clearColour

			costs[key] = costFunc(TransformToParentPoint(vehicleTransform, detect), hit, key)

			if hit and dist < detectRange then
				lineColour = hitColour
			else
				if costs[key] < bestCost.val then
					bestCost.key = key
					bestCost.val = costs[key]
					bestCost.target = detect
				end
			end
			--DebugLine(vehicleTransform.pos, fwdPos, lineColour[1], lineColour[2], lineColour[3])
		end
	end
	return bestCost
end

function MAV(targetCost)
	targetMoves.targetIndex = (targetMoves.targetIndex % #targetMoves.list) + 1
	targetMoves.target = VecSub(targetMoves.target, targetMoves.list[targetMoves.targetIndex])
	targetMoves.target = VecAdd(targetMoves.target, targetCost)
	targetMoves.list[targetMoves.targetIndex] = targetCost
	return VecScale(targetMoves.target, (#targetMoves.list / 100))
end

function controlVehicle(targetCost)
	local targetMove = VecNormalize(targetCost.target)
	if (VecLength(VecSub(GetVehicleTransform(vehicle.id).pos, goalPos)) > 5) then
		if (targetMove[1] ~= 0 and targetMove[3] == 0) then
			targetMove[3] = 1

			targetMove[1] = -targetMove[1]
		end
		DriveVehicle(vehicle.id, -targetMove[3] * drivePower, -targetMove[1], false)
	else
		DriveVehicle(vehicle.id, 0, 0, true)
	end
end

function costFunc(testPos, hit, key)
	local cost = 100
	if (not hit) then
		cost = VecLength(VecSub(testPos, goalPos)) * (1 - weights[key])
	end
	return cost
end

function vehicleMovement(vel, angVel)
	local vehicleTransform = GetBodyTransform(vehicle.body)
	local targetVel = TransformToParentPoint(vehicleTransform, vel)
	targetVel = VecSub(targetVel, vehicleTransform.pos)
	local targetAngVel = angVel
	local currentVel = GetBodyVelocity(vehicle.body)
	local currentAngVel = GetBodyAngularVelocity(vehicle.body)

	if (VecLength(currentVel) < maxSpeed) then
		SetBodyVelocity(vehicle.body, VecAdd(currentVel, targetVel))
	end
	SetBodyAngularVelocity(vehicle.body, VecAdd(currentAngVel, targetAngVel))
end
