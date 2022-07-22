--This script will run on all levels when mod is active.
--Modding documentation: http://teardowngame.com/modding
--API reference: http://teardowngame.com/modding/api.html

#include "script/main_road_detection.lua"
#include script/RTSInterface.lua

--[[
	keys:
	level.rts.navigation_pos.identifier.i
]]

function init()

	toolname = "strategic_map"

	RegisterTool(toolname, "Strategic Map", "MOD/vox/" .. toolname .. ".vox")
	SetBool("game.tool." .. toolname .. ".enabled", true)

	tool = {
		toggled = false,
		height = 50,
		x = 0,
		y = 0,
		selected = {},
		aa = Vec(0, 0, 0),
		bb = Vec(0, 0, 0)
	}

	INFANTRY = 1
	HEAVY_INFANTRY = 2
	SNIPER = 3
	CAPTAIN = 4
	TANK = 5
	DOC = 6

	ALLY_TEAM = 1
	ENEMY_TEAM = 2

	identifierCount = 1

	soldiers = {}

	nexus = {
		bodies = {},
		integrity = {
			initial = 0,
			current = 0,
			min = 40
		},
		wave = 0,
		alive = false,
		money = 800,
		moneyPerSecond = 50,
		enemiesCount = 0,
		maxEnemiesCount = 0,
		cooldown = {
			value = 0,
			default = 8
		},
		waveCooldown = {
			value = 0,
			default = 20
		},
		roundRobin = {},
		spawns = {},
		spawnCount = 0,
		tentative = Vec(),
		spawnInitTime = 0
	}
	oldCount = #nexus.spawns

	cost = {
		INFANTRY = 400,
		HEAVY_INFANTRY = 800,
		SNIPER = 600,
		CAPTAIN = 800,
		TANK = 6000,
		DOC = 1200
	}

	--[[health = {
		INFANTRY = 100,
		HEAVY_INFANTRY = 150,
		SNIPER = 600,
		CAPTAIN = 800,
		TANK = 6000,
		DOC = 100
	}]]
	health = {}
	health[INFANTRY] = 100
	health[HEAVY_INFANTRY] = 150
	health[SNIPER] = 75
	health[DOC] = 100


	md = nil--makeMappingData(Vec(-100, -100, -100), Vec(100, 100, 100))
	firstPassage = true
	world = {}
	world.aa, world.bb = GetBodyBounds(GetWorldBody())
	world.aa = floorVec(world.aa)
	world.bb = floorVec(world.bb)
	firstQuery = true
	queryQueue = {}
end


function tick(dt)
	
	if firstPassage then
		firstPassage = false
		local worldAA, worldBB = GetBodyBounds(GetWorldBody())
		md = makeMappingData(worldAA, worldBB)
		md.step = 2
	end
	processDebugCross(md)
	processUpdate(md)
	
	if md.status > 3 then
		--exportToRegistry(md, false)
		--importFromRegistry()
		firstQuery = false
		--queryPath(md, Vec(0, 0, 0), Vec(0, 0, 50))
		if #queryQueue > 0 then
			queryQueue[1].status = getPathState(md)
			for i=1, #queryQueue[1].askers do
				setPathStatusInRegistry(queryQueue[1].askers[i], queryQueue[1].status)
			end
			if queryQueue[1].status == "idle" then
				--DebugPrint("new " .. tableToString(queryQueue))
				queryPath(md, queryQueue[1].start, queryQueue[1].target)
				queryQueue[1].status = getPathState(md)
			elseif queryQueue[1].status == "fail" or queryQueue[1].status == "done" then
				local newQueue = {}
				if queryQueue[1].status == "done" then
					local path = getSmoothPath(md) --getPath(md)
					--lastPath = deepcopy(path)
					for i=1, #queryQueue[1].askers do
						setPathInRegistry(queryQueue[1].askers[i], path)
					end
					--local str = ""
					--for i=1, #queryQueue[1].askers do
						--str = str .. ", " .. queryQueue[1].askers[i]
					--end
					--DebugPrint(str)
				end
				abortPath(md)
				
				for i=2, #queryQueue do
					newQueue[#newQueue + 1] = queryQueue[i]
				end
				queryQueue = newQueue
			end
		end
		--edgesDebugLine(true, md)
	end

	if nexus.alive then
		updateNexus(dt)
		if nexus.cooldown.value <= 0 and nexus.maxEnemiesCount > nexus.enemiesCount and nexus.wave >= 0 then
			spawnEnemieFromNexus()
			nexus.cooldown.value = nexus.cooldown.default
		end
	end

	if GetString("game.player.tool") == toolname then
		if InputPressed("usetool") then
			tool.toggled = true
		end
		if InputPressed("x") then
			tool.toggled = false
		end

		if tool.toggled then
			setStrategicView()
		end

	else
		tool.toggled = false
	end

	local spawnTransform = Transform(TransformToParentPoint(GetPlayerCameraTransform(), Vec(0, 0, -1)))

	if not tool.toggled then
		if InputPressed("c") then
			makeSoldier(ALLY_TEAM, spawnTransform)
		end
		if InputPressed("v") then
			makeSoldier(ENEMY_TEAM, spawnTransform, HEAVY_INFANTRY)
		end
		if InputPressed("n") then
			spawnNexus(spawnTransform)
		end
		if InputPressed("b") then
			--[[for i=1, #soldiers do
				if soldiers[i].team == ENEMY_TEAM then
					local pos = spawnTransform.pos
					local offset = randVec(4)
					offset[2] = 0
					pos = VecAdd(pos, offset)
					setNavigationPosInRegistry(pos, i)
				end
			end]]
			makeSoldier(ENEMY_TEAM, spawnTransform, DOC)
		end
	else
		spawnTransform = Transform(makeOffset(getNexusTransform().pos, 3))
		if InputPressed("c") then
			if nexus.money >= cost.INFANTRY then
				nexus.money = nexus.money - cost.INFANTRY
				makeSoldier(ALLY_TEAM, spawnTransform, INFANTRY)
			end
		end
		if InputPressed("v") then
			if nexus.money >= cost.HEAVY_INFANTRY then
				nexus.money = nexus.money - cost.HEAVY_INFANTRY
				makeSoldier(ALLY_TEAM, spawnTransform, HEAVY_INFANTRY)
			end
		end
		if InputPressed("b") then
			if nexus.money >= cost.SNIPER then
				nexus.money = nexus.money - cost.SNIPER
				makeSoldier(ALLY_TEAM, spawnTransform, SNIPER)
			end
		end
		
		if InputPressed("n") then
			if nexus.money >= cost.DOC then
				nexus.money = nexus.money - cost.DOC
				makeSoldier(ALLY_TEAM, spawnTransform, DOC)
			end
		end

	end

	if InputPressed("p") then
		nexus.waveCooldown.value = 0
		nexus.money = 10000
	end

	SetFloat('level.rts.stats.integrity', getNexusIntegrity())
	SetFloat('level.rts.stats.money', nexus.money)
	SetInt('level.rts.stats.wave', nexus.wave)
	SetFloat('level.rts.stats.waveCooldown', nexus.waveCooldown.value)
end


function update(dt)
	if isLoading then
		return
	end
	updateTransformAllSoldiers()
	setAllTarget()
end


function draw(dt)
	RTSDrawMenu()
	
	if isLoading then
		return
	end
	if tool.toggled then
		UiMakeInteractive()
		updateStrategicView(dt)
		select()
		command()
		for i=1, #soldiers do
			if getAliveStatusInRegistry(i) then
				--health
				local size = 1.5
				local pos = VecAdd(soldiers[i].t.pos, Vec(-0.5, 1.2, 0.5))
				DrawLine(pos, VecAdd(pos, Vec(size)), 1, 0.2, 0.2, 1)
				DrawLine(pos, VecAdd(pos, Vec(size * getHealthInRegistry(i) / health[soldiers[i].type])), 0.2, 1, 0.2, 1)
			end
		end
	end
end

---------------------------------

function clearConsole()
	for i=1, 25 do
		DebugPrint("")
	end
end

function rand(minv, maxv)
	minv = minv or nil
	maxv = maxv or nil
	if minv == nil then
		return math.random()
	end
	if maxv == nil then
		return math.random(minv)
	end
	return math.random(minv, maxv)
end

--Helper to return a random number in range mi to ma
function randFloat(mi, ma)
	return math.random(1000)/1000*(ma-mi) + mi
end

--Return a random vector of desired length
function randVec(length)
	local v = VecNormalize(Vec(math.random(-100,100), math.random(-100,100), math.random(-100,100)))
	return VecScale(v, length)	
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


function floorVec(v)
	return Vec(math.floor(v[1]), math.floor(v[2]), math.floor(v[3]))
end

function debugWatchTable(t)
	for k, v in pairs(t) do
		if type(v) ~= "boolean" then
			DebugWatch(k, string.format("%.1f", v))
		end
	end
end

function sleep(timeInSeconds)
  local identifier = #sleeps.lock + 1
  sleeps.lock[identifier] = timeInSeconds + sleeps.time
  return identifier
end

function isSleeping(identifier)
  return sleeps.time < sleeps.lock[identifier]
end

function toDegree(angle)
	return angle * 180 / math.pi
end

function getAngle(u, v)
	return math.acos(VecDot(u, v) / (VecLength(u) * VecLength(v)))
end

function quatFromVec(v)
	return QuatLookAt(Vec(0, 0, 0), v)
end

function vecResize(v, s)
	return VecScale(VecNormalize(v), s)
end

---------------------------------

function setPathStatusInRegistry(identifier, status)
	SetString("level.rts.path.status." .. identifier, status)
end

function setPathInRegistry(identifier, path)
	--DebugPrint("len " .. #path)
	--SetString("level.rts.path.points." .. identifier, tableToString(path))
	--ClearKey("level.rts.path.points." .. identifier)
	SetInt("level.rts.path.points." .. identifier .. ".length", #path)
	for i=1, #path do
		for j=1, 3 do
			SetFloat("level.rts.path.points." .. identifier .. "." .. i .. "." .. j, path[i][j])
		end
	end
end

function spawnNexus(t)
	SetString("game.player.tool", toolname)
	local entities = Spawn("vox/nexus.xml", t)
	nexus.bodies = {}
	for i=1, #entities do
		if GetEntityType(entities[i]) == "body" then
			nexus.bodies[#nexus.bodies + 1] = entities[i]
		end
	end
	initNexus()
end

function initNexus()
	nexus.integrity.initial = getNexusVoxCount()
	nexus.integrity.current = nexus.integrity.initial
	nexus.wave = 0 --1
	nexus.alive = true
	nexus.enemies = {}
	nexus.money = 800
	nexus.cooldown.default = 8
	nexus.cooldown.value = nexus.cooldown.default
	nexus.waveCooldown.value = nexus.waveCooldown.default
	nexus.maxEnemiesCount = 8
	nexus.roundRobin = {}
	--nexus.roundRobin[#nexus.roundRobin + 1] = INFANTRY
	nexus.roundRobin[#nexus.roundRobin + 1] = INFANTRY
	nexus.roundRobin[#nexus.roundRobin + 1] = HEAVY_INFANTRY
	nexus.roundRobin[#nexus.roundRobin + 1] = SNIPER
	nexus.roundRobin[#nexus.roundRobin + 1] = DOC
	initNexusSpawns(4)
end

function initNexusSpawns(count)
	nexus.spawns = {}
	nexus.spawnCount = count
	nexus.tentative = Vec()
	nexus.spawnInitTime = 0
end

function getNexusVoxCount()
	local totalVox = 0
	for i=1, #nexus.bodies do
		local shapes = GetBodyShapes(nexus.bodies[i])
		for j=1, #shapes do
			totalVox = totalVox + GetShapeVoxelCount(shapes[j])
		end
	end
	return totalVox
end

function getNexusIntegrity()
	return 100 * nexus.integrity.current / nexus.integrity.initial
end

function getNexusTransform()
	return TransformCopy(GetBodyTransform(nexus.bodies[1]))
end

function makeSpawn()
	if #nexus.spawns >= nexus.spawnCount then
		nexus.wave = 1
		return
	end

	local state = GetPathState()
	if oldCount ~= #nexus.spawns then
		state = "idle"
	end
	oldCount = #nexus.spawns
	
	if state == "idle" or state == "fail" then
		local pos = getNexusTransform().pos
		local offset = VecAdd(makeOffset(pos, rand(70, 90)), Vec(0, 100, 0))
		local dir = Vec(0, -1, 0)
		local hit, dist, normal, shape = QueryRaycast(offset, dir, 300, 3)
		
		if hit then
			local hitPos = VecAdd(offset, VecScale(dir, dist - 0.5))
			nexus.tentative = hitPos

			minDist = 10000
			for i=1, #nexus.spawns do
				local distance = VecLength(VecSub(nexus.spawns[i], hitPos))
				if distance < minDist then
					minDist = distance
				end
			end

			if not IsPointInWater(hitPos) and minDist >= 20 then
				QueryPath(hitPos, pos, 200)
				nexus.spawnInitTime = 0
			end
		end
	elseif state == "busy" then
		if nexus.spawnInitTime >= 5 then
			AbortPath()
		end
	elseif state == "done" then
		nexus.spawns[#nexus.spawns +  1] = deepcopy(nexus.tentative)
	end
end

function updateNexus(dt)

	if nexus.wave == 0 then
		nexus.spawnInitTime = nexus.spawnInitTime + dt
		makeSpawn()
		--DrawLine(nexus.tentative, getNexusTransform().pos)
		return
	end
	
	local value = nexus.moneyPerSecond * dt
	nexus.money = nexus.money + value
	nexus.integrity.current = getNexusVoxCount()
	local oldState = nexus.alive
	nexus.alive = nexus.integrity.min <= getNexusIntegrity()
	if nexus.alive ~= oldState then
		Explosion(getNexusTransform().pos, 4)
	end
	nexus.cooldown.value = nexus.cooldown.value - dt
	nexus.waveCooldown.value = nexus.waveCooldown.value - dt
	local nextWave = false
	if nexus.waveCooldown.value <= 0 then
		nexus.waveCooldown.value = nexus.waveCooldown.default
		nexus.wave = nexus.wave + 1
		nextWave = true
	end
	nexus.cooldown.default = 8 - nexus.wave * 0.5
	nexus.enemiesCount = 0
	for i=1, #soldiers do
		if soldiers[i].team == ENEMY_TEAM and getAliveStatusInRegistry(i) then
			nexus.enemiesCount = nexus.enemiesCount + 1
		end
	end
	if nextWave then
		for i=1, nexus.wave * 2 do
			--nexus.roundRobin[#nexus.roundRobin + 1] = rand(1, 2)
		end
	end
end

function makeOffset(origin, dist, fillInside)
	fillInside = fillInside or false
	local offset = randVec(dist)
	offset[2] = math.abs(offset[2])

	local flat = deepcopy(offset)
	flat[2] = 0
	local limit = 0.9
	if fillInside then
		limit = 0
	end
	while VecLength(flat) < dist * limit do
		offset = randVec(dist)
		offset[2] = math.abs(offset[2])
		flat = deepcopy(offset)
		flat[2] = 0
	end
	return VecAdd(origin, offset)
end

function spawnEnemieFromNexus()
	local offset = nexus.spawns[rand(1, #nexus.spawns)] --makeOffset(getNexusTransform().pos, rand(60, 70))
	local soldier = makeSoldier(ENEMY_TEAM, Transform(offset), nexus.roundRobin[rand(1, #nexus.roundRobin)])

	offset = makeOffset(getNexusTransform().pos, 5)
	setNavigationPosInRegistry(offset, soldier.id)
end

function setStrategicView()
	local pos = Vec(tool.x, tool.height, tool.y)
	SetCameraTransform(Transform(pos, QuatEuler(-90, 0, 0)))
end

function updateStrategicView(dt)
	local mx, my = UiGetMousePos()
	local width = UiWidth()
	local height = UiHeight()

	local borderSizePercent = 0.03

	tool.height = tool.height - InputValue("mousewheel") * 7

	local multiplicator = 50
	if mx <= borderSizePercent * width then
		tool.x = tool.x - dt * multiplicator
	end
	if mx >= (1 - borderSizePercent) * width then
		tool.x = tool.x + dt * multiplicator
	end
	if my <= borderSizePercent * height then
		tool.y = tool.y - dt * multiplicator
	end
	if my >= (1 - borderSizePercent) * height then
		tool.y = tool.y + dt * multiplicator
	end
end

function getNavigationPosFromRegistry(identifier)
	local pos = Vec()
	for i=1, 3 do
		pos[i] = GetFloat("level.rts.navigation_pos." .. identifier .. "." .. i)
	end
	return pos
end

function setTypeInRegistry(identifier)
	SetInt("level.rts.type." .. identifier, soldiers[identifier].type)
end

function select()

	local mx, my = UiGetMousePos()

	if InputPressed("usetool") then
		
		tool.aa = Vec(mx, 0, my)
	end

	if InputDown("usetool") then
		tool.bb = Vec(mx, 0, my)

		UiPush()
			UiColor(0, 1, 0, 0.2)
			UiTranslate(tool.aa[1], tool.aa[3])
			UiRect(tool.bb[1] - tool.aa[1], tool.bb[3] - tool.aa[3])
		UiPop()

		tool.selected = {}
		for i=1, #soldiers do
			if soldiers[i].team == ALLY_TEAM then
				local x, y = UiWorldToPixel(soldiers[i].t.pos)
				if x >= tool.aa[1] and x <= tool.bb[1] and y >= tool.aa[3] and y <= tool.bb[3] and getAliveStatusInRegistry(soldiers[i].id) then
					tool.selected[#tool.selected + 1] = soldiers[i]
				end
			end
		end
	end

	local allBodies = FindBodies("identifier", true)
	for i=1, #allBodies do
		local identifier = GetTagValue(allBodies[i], "identifier")
		for j=1, #tool.selected do
			if identifier == tostring(tool.selected[j].id) then
				if getAliveStatusInRegistry(tool.selected[j].id) then
					DrawBodyHighlight(allBodies[i], 1)
					--if VecLength(VecSub(tool.selected[j].t.pos, getNavigationPosFromRegistry(tool.selected[j].id))) > 1.5 then
						--DrawLine(tool.selected[j].t.pos, getNavigationPosFromRegistry(tool.selected[j].id), 0.2, 0.7, 0.2, 0.2)
					--end
					local targetId = getTargetId(tool.selected[j].id)
					--DebugPrint(">" .. targetId .. type(targetId))
					if targetId ~= 0 then
						DrawLine(tool.selected[j].t.pos, soldiers[targetId].t.pos, 0.7, 0.2, 0.2, 0.2)
					end

					--health
					--local size = 1.5
					--DrawLine(tool.selected[j].t.pos, VecAdd(tool.selected[j].t.pos, Vec(size, 0, 0)), 0.7, 0.2, 0.2, 0.2)
					--DrawLine(tool.selected[j].t.pos, VecAdd(tool.selected[j].t.pos, Vec(size * getHealthInRegistry(identifier) / 100)), 0.2, 0.7, 0.2, 0.9)
					break
				end
			end
		end
	end
end

function command()
	if InputPressed("grab") then

		local mx, my = UiGetMousePos()
		local maxDist = 200
		local dir = UiPixelToWorld(mx, my)
		local pos = GetCameraTransform().pos
		local hit, dist, normal, shape = QueryRaycast(pos, dir, maxDist)
		local hitPos = Vec(0, -100, 0)
		if hit then
			hitPos = VecAdd(pos, VecScale(dir, dist - 0.2))
		end

		local size = 1
		local aa = Vec(-size, -100, -size)
		local bb = VecScale(aa, -1)
		local bodies = QueryAabbBodies(VecAdd(aa, hitPos), VecAdd(bb, hitPos))

		local targetId = nil
		for i=1, #bodies do
			local value = tonumber(GetTagValue(bodies[i], "identifier"))
			if value ~= nil then
				if soldiers[value].team == ENEMY_TEAM then
					targetId = value
					break
				end
			end
		end

		for i=1, #tool.selected do
			if tool.selected[i].team == ALLY_TEAM then
				if targetId == nil then
					--local offset = makeOffset(hitPos, math.min(((#tool.selected - 1) * 1.7), 10), true)
					--setNavigationPosInRegistry(offset, tool.selected[i].id)
					setNavigationPosInRegistry(hitPos, tool.selected[i].id)
				end
				if targetId ~= nil then
					setTargetPosInRegistry(targetId, tool.selected[i].id)
					setTargetIdInRegistry(targetId, tool.selected[i].id)
				end
			end
		end
	end
end

function initInfantry(team, t)
	local soldier = {
		t = TransformCopy(t),
		type = INFANTRY,
		team = team,
		id = identifierCount,
		bodies = {}
	}

	local entities = Spawn("script/infantry/spawn/combine.xml", soldier.t)
	for i=1, #entities do
		if GetEntityType(entities[i]) == "body" then
			soldier.bodies[#soldier.bodies + 1] = entities[i]
		end
		SetTag(entities[i], "identifier", tostring(soldier.id))
		SetTag(entities[i], "team", tostring(soldier.team))
	end
	identifierCount = identifierCount + 1
	return soldier
end

function initHeavy(team, t)
	local soldier = {
		t = TransformCopy(t),
		type = HEAVY_INFANTRY,
		team = team,
		id = identifierCount,
		bodies = {}
	}

	local entities = Spawn("script/infantry/spawn/heavy.xml", soldier.t)
	for i=1, #entities do
		if GetEntityType(entities[i]) == "body" then
			soldier.bodies[#soldier.bodies + 1] = entities[i]
		end
		SetTag(entities[i], "identifier", tostring(soldier.id))
		SetTag(entities[i], "team", tostring(soldier.team))
	end
	identifierCount = identifierCount + 1
	return soldier
end

function initSniper(team, t)
	local soldier = {
		t = TransformCopy(t),
		type = SNIPER,
		team = team,
		id = identifierCount,
		bodies = {}
	}

	local entities = Spawn("script/infantry/spawn/sniper.xml", soldier.t)
	for i=1, #entities do
		if GetEntityType(entities[i]) == "body" then
			soldier.bodies[#soldier.bodies + 1] = entities[i]
		end
		SetTag(entities[i], "identifier", tostring(soldier.id))
		SetTag(entities[i], "team", tostring(soldier.team))
	end
	identifierCount = identifierCount + 1
	return soldier
end

function initDoc(team, t)
	local soldier = {
		t = TransformCopy(t),
		type = DOC,
		team = team,
		id = identifierCount,
		bodies = {}
	}

	local entities = Spawn("script/infantry/spawn/doc.xml", soldier.t)
	for i=1, #entities do
		if GetEntityType(entities[i]) == "body" then
			soldier.bodies[#soldier.bodies + 1] = entities[i]
		end
		SetTag(entities[i], "identifier", tostring(soldier.id))
		SetTag(entities[i], "team", tostring(soldier.team))
	end
	identifierCount = identifierCount + 1
	return soldier
end

function setBodiesInRegistry(identifier)
	local soldier = soldiers[identifier]
	SetInt("level.rts.bodies." .. identifier .. ".count", #soldier.bodies)
	for i=1, #soldier.bodies do
		SetInt("level.rts.bodies." .. identifier .. "." .. i, soldier.bodies[i])
	end
end

function getAliveStatusInRegistry(identifier)
	return GetBool("level.rts.alive." .. identifier)
end

function getHealthInRegistry(identifier)
	return GetFloat("level.rts.health." .. identifier)
end

function makeSoldier(team, t, typeSoldier)

	typeSoldier = typeSoldier or INFANTRY

	local soldier = {}
	if typeSoldier == INFANTRY then
		soldier = initInfantry(team, t)
	elseif typeSoldier == HEAVY_INFANTRY then
		soldier = initHeavy(team, t)
	elseif typeSoldier == SNIPER then
		soldier = initSniper(team, t)
	elseif typeSoldier == DOC then
		soldier = initDoc(team, t)
	else
		soldier = initInfantry(team, t)
	end
	setNavigationPosInRegistry(t.pos, soldier.id)

	soldiers[#soldiers + 1] = soldier
	setBodiesInRegistry(soldier.id)
	setTypeInRegistry(soldier.id)
	return soldier
end

function setNavigationPosInRegistry(pos, identifier)
	for i=1, 3 do
		SetFloat("level.rts.navigation_pos." .. identifier .. "." .. i, pos[i])
	end
end

function setTargetIdInRegistry(identifierTarget, identifier)
	SetInt("level.rts.target." .. identifier, identifierTarget)
end

function setTargetPosInRegistry(identifierTarget, identifier)

	local pos
	if identifierTarget == 0 then -- targeting nexus
		pos = getNexusTransform().pos
	else
		pos = soldiers[identifierTarget].t.pos
	end

	if soldiers[identifier].type == SNIPER then
		pos = VecAdd(pos, Vec(0, -0.3, 0))
	end

	for i=1, 3 do
		SetFloat("level.rts.target_pos." .. identifier .. "." .. i, pos[i])
	end
end

function getSoldierByIdentifier(identifier)
	for i=1, #soldiers do
		if soldiers[i].id == identifier then
			return soldiers[i]
		end
	end
end

function updateTransformAllSoldiers()
	for i=1, #soldiers do
		soldiers[i].t = GetBodyTransform(soldiers[i].bodies[1])
	end
end

function getClosestTargetIdentifier(soldier)

	local best = {
		id = nil,
		dist = 0
	}
	for i=1, #soldiers do
		if soldiers[i].team ~= soldier.team and getAliveStatusInRegistry(soldiers[i].id) then
			local dist = VecLength(VecSub(soldiers[i].t.pos, soldier.t.pos))
			if best.id == nil or dist < best.dist then
				best.id = soldiers[i].id
				best.dist = dist
			end
		end
	end
	return best.id, best.dist
end

function getClosestTargetIdentifierIncludingNexus(soldier)
	local best = {
		id = nil,
		dist = 0
	}
	best.id, best.dist = getClosestTargetIdentifier(soldier)
	local distToNexus = VecLength(VecSub(getNexusTransform().pos, soldier.t.pos))
	if best.id == nil or distToNexus <= best.dist then
		best.id = nil
		best.dist = distToNexus
	end
	return best.id, best.dist
end

function getTargetId(identifier)
	return GetInt("level.rts.target." .. identifier)
end

function setHealingStatusInRegistry(identifier, value)
	return SetBool("level.rts.healing_status." .. identifier, value)
end

function getDocs()
	local docs = {}
	for i=1, #soldiers do
		if getAliveStatusInRegistry(soldiers[i].id) and soldiers[i].type == DOC then
			docs[#docs + 1] = soldiers[i]
		end
	end
	return docs
end

function getPathQueryInRegistry(identifier)
	return GetBool("level.rts.path.query." .. identifier)
end

function setPathQueryInRegistry(identifier, value)
	SetBool("level.rts.path.query." .. identifier, value)
end

function getAbortPathInRegistry(identifier)
	local value = GetBool("level.rts.path.abort." .. identifier)
	SetBool("level.rts.path.abort." .. identifier, false)
	return value
end

function isInTable(t, v)
	for i=1, #t do
		if t[i].id == v then
			return true
		end
	end
	return false
end

function setAllTarget()

	local docs = getDocs()
	local pathQuery = nil

	for i=1, #soldiers do
		if getAliveStatusInRegistry(soldiers[i].id) then
			if not getAliveStatusInRegistry(getTargetId(i)) then
				local target
				if soldiers[i].team == ALLY_TEAM or not nexus.alive then
					target = getClosestTargetIdentifier(soldiers[i])
				else
					target = getClosestTargetIdentifierIncludingNexus(soldiers[i])
				end
				if target ~= nil then
					setTargetIdInRegistry(target, i)
				end
				local healing = false
				for j=1, #docs do
					if soldiers[i].team == docs[j].team and VecLength(VecSub(soldiers[i].t.pos, docs[j].t.pos)) < 12 then
						healing = true
						DrawLine(soldiers[i].t.pos, docs[j].t.pos, 1, 0.6, 0.6, 0.5)
						break
					end
				end
				setHealingStatusInRegistry(i, healing)
			end
			--if getTargetId(i) ~= 0 or soldiers[i].team == ENEMY_TEAM then
				setTargetPosInRegistry(getTargetId(i), i)
			--end
			if getPathQueryInRegistry(i) then
				--DebugCross(getNavigationPosFromRegistry(i), 0, 1, 0)
				setPathQueryInRegistry(i, false)

				if pathQuery == nil then
					pathQuery = {
						askers = {},
						status = "idle",
						start = soldiers[i].t.pos,
						target = getNavigationPosFromRegistry(i)
					}
				end
				if soldiers[i].team == ENEMY_TEAM or isInTable(tool.selected, i) then
					pathQuery.askers[#pathQuery.askers + 1] = i
				end
			end
			--[[if getAbortPathInRegistry(i) then
				local newQueue = {}
				for i=1, #queryQueue do
					if i == 1 then
						queryQueue[1].status = "fail"
						break
					else
						if queryQueue[i].identifier ~= i then
							newQueue[#newQueue + 1] = deepcopy(queryQueue[i])
						end
					end
				end
				queryQueue = newQueue
			end]]
		end
	end
	if pathQuery ~= nil then
		if #pathQuery.askers > 0 then
			queryQueue[#queryQueue + 1] = pathQuery
		end
	end
end
























































