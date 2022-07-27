function init()
	platform = FindBody("turretplat")
	me = FindBody("gunturret")
	barrel = FindShape("barrel")
	rotJoint = FindJoint("rot")
	vertJoint = FindJoint("vert")

	notplayer = true
	debugMode = false
	
	mgtimer = 6 -- time between shoot bursts
	shootTimer = 0.25 -- time between shoots
	shootCount = 0

	o = 1
	shotDelay = 8
	shots = shotDelay
	shootSound = LoadSound("chopper-shoot0.ogg")
	rocketSound = LoadSound("tools/launcher0.ogg")
end

function canSeePlayer()
	local playerPos = GetPlayerPos()

	--Direction to player
	local dir = VecSub(playerPos, selfTrans.pos)
	local dist = VecLength(dir)
	dir = VecNormalize(dir)

	QueryRejectVehicle(GetPlayerVehicle())
	QueryRejectBody(platform)
	ignoreTargetBodies()
	return not QueryRaycast(selfTrans.pos, dir, dist, 0, true)
end

identifier = 0

function tick(dt)
	--update infos
	targets = FindBodies("target", true)

	identifier = GetTagValue(platform, "identifier")

	a = GetJointMovement(rotJoint)
	b = GetJointMovement(vertJoint)

	platTrans = GetBodyTransform(platform)
	platTrans.rot = QuatRotateQuat(platTrans.rot, QuatEuler(0, 90, 0))
	selfTrans = GetBodyTransform(me)
	selfPos = selfTrans.pos
	gunTrans = GetShapeWorldTransform(barrel)
	gunPos = gunTrans.pos
	--find direction
	direction = TransformToParentVec(gunTrans, Vec(0, -1, 0))
	shootPos = VecAdd(gunPos, VecScale(direction, 0.05))

	playerCam = GetCameraTransform()
	camDir = TransformToParentVec(playerCam, Vec(0, 0, -1))
	v = GetPlayerVehicle()

	--find size of target list
	all = 0
	for i = 1, #targets do
		all = all + 1
		DrawBodyHighlight(targets[i], 0.5)
	end

	notplayer = false

	if o < 1 then
		o = all
	elseif o > all then
		o = 1
	end
	target = targets[o]

	--targeting function
	if target ~= me then
		--if IsBodyBroken(me) ~= true then
		follow()
	--end
	end

	-- line of sight
	distance = math.sqrt(bZ ^ 2 + bX ^ 2 + db ^ 2)
	hit, d, norm, rayShape = QueryRaycast(shootPos, direction, 100)
	if hit then
		rayBody = GetShapeBody(rayShape)
		if rayBody ~= target then
			los = false
		else
			los = true
		end
	end

	--shoot
	if getTargetId() ~= 0 and canSeePlayer() then
		
		fire(dt)
		mgtimer = mgtimer - dt
		if mgtimer <= 0 then
			mgtimer = 5
			shootCount = math.random(3, 6)
		end
		if shootCount > 0 then
			shootTimer = shootTimer - dt
			if shootTimer <= 0 then
				mgfire()
			end
		end
	end
end

function ignoreTargetBodies()
	local target = getTargetId()
	local bodies = getBodiesFromRegistry(target)
	for i=1, #bodies do
		QueryRejectBody(bodies[i])
	end
	local vehicle = GetBodyVehicle(bodies[1])
	if IsHandleValid(vehicle) then
		QueryRejectVehicle(vehicle)
	end
end

function getBodiesFromRegistry(targetIdentifier)
	targetIdentifier = targetIdentifier or identifier
	local bodies = {}
	local count = GetInt("level.rts.bodies." .. targetIdentifier .. ".count")
	for i=1, count do
		bodies[#bodies + 1] = GetInt("level.rts.bodies." .. targetIdentifier .. "." .. i)
	end
	return bodies
end

function getTargetPosFromRegistry()
	local pos = Vec()
	for i=1, 3 do
		pos[i] = GetFloat("level.rts.target_pos." .. identifier .. "." .. i)
	end
	return pos
end

function getTargetId()
	return GetInt("level.rts.target." .. identifier)
end

function randVec(length)
	local v = VecNormalize(Vec(math.random(-100,100), math.random(-100,100), math.random(-100,100)))
	return VecScale(v, length)	
end

function getTargetTransform()
	local pos = getTargetPosFromRegistry()
	if getTargetId() == -1 then
		pos = VecAdd(randVec(1), pos)
	end
	return Transform(pos)
end

function getTargetPos()
	if notplayer then
		com = GetBodyCenterOfMass(target)
		targetPos = TransformToParentPoint(GetBodyTransform(target), com)
		DrawBodyOutline(target, 1, 0, 0, 1)
		vel = GetBodyVelocity(target)
	else
		if v == 0 then
			target = 0
			targetTrans = getTargetTransform() --GetPlayerTransform()
			targetPos = VecAdd(targetTrans.pos, Vec(0, 0.5, 0))
			vel = GetPlayerVelocity()
		else
			target = 0
			vbod = GetVehicleBody(v)
			targetTrans = GetBodyTransform(vbod)
			targetPos = VecAdd(targetTrans.pos, Vec(0, 0.5, 0))
			vel = GetBodyVelocity(vbod)
		end
	end
end

function addVelocity()
	--needs adjusting
	local distScaled = distance * 0.09
	local velScaled = VecScale(vel, 0.06)
	local velDist = VecScale(velScaled, distScaled)
	targetPos = VecAdd(targetPos, velDist)
end

function follow()
	aX = selfPos[1]
	aY = selfPos[2]
	aZ = selfPos[3]

	getTargetPos()

	localPos = TransformToLocalPoint(platTrans, targetPos)

	bX = localPos[1]
	bY = localPos[2]
	bZ = localPos[3]

	db = bY - aY
	distance = math.sqrt(bZ ^ 2 + bX ^ 2 + db ^ 2)

	addVelocity()

	localPos = TransformToLocalPoint(platTrans, targetPos)

	bX = localPos[1]
	bY = localPos[2]
	bZ = localPos[3]

	db = bY - aY
	ad = math.sqrt(bZ ^ 2 + bX ^ 2)

	rotAngle = math.deg(math.atan2(bZ, bX))
	vertAngle = math.deg(math.atan(db / ad))
	--do things
	SetJointMotorTarget(rotJoint, rotAngle, 5)
	SetJointMotorTarget(vertJoint, -vertAngle, 5)
	--DebugWatch("Vertical", -vertAngle)
end

function getAngleModifier(dist)
	local a = 70
	local b = 220
	local c = 30 - dist

	local delta = math.pow(b, 2) - 4 * a * c
	local res = (-b + math.sqrt(delta)) / (2 * a)

	return res
end

function fire(dt)
	
	local dist = VecLength(VecSub(targetTrans.pos, gunPos))

	if shots <= 0 then
		shots = shotDelay
		gunTrans = GetShapeWorldTransform(barrel)
		gunPos = gunTrans.pos
		--find direction
		local dist = VecLength(VecSub(targetTrans.pos, gunPos))
		
		local angleModifier = getAngleModifier(dist)

		direction = VecNormalize(TransformToParentVec(gunTrans, Vec(0, -1, angleModifier)))
		shootPos = VecAdd(gunPos, VecScale(direction, 0.2))
		--only shoot if not broken
		--if IsShapeBroken(barrel) ~= true then
		Shoot(shootPos, direction, 1)
		PlaySound(rocketSound, shootPos, 5)
	--end
	end
	shots = shots - dt
end

function mgfire()
	shootCount = shootCount -1
	shootTimer = 0.2
	
	gunTrans = GetShapeWorldTransform(barrel)
	gunPos = gunTrans.pos
	direction = TransformToParentVec(gunTrans, Vec(0, -1, 0))
	shootPos = VecAdd(gunPos, VecScale(direction, 0.2))
	local d = direction
	local spread = 0.03
	d[1] = d[1] + (math.random()-0.5)*2*spread
	d[2] = d[2] + (math.random()-0.5)*2*spread
	d[3] = d[3] + (math.random()-0.5)*2*spread
	d = VecNormalize(d)
	Shoot(shootPos, d)
	PlaySound(shootSound, shootPos, 5)
end
