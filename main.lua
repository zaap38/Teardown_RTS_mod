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
		spawnInitTime = 0,
		fuel = {
			value = 0,
			max = 300,
			lose = {
				base = 5,
				perUnit = 1
			}
		},
		supplies = {
			array = {},
			identifier = 0,
			cooldown = {
				value = 0,
				default = 5
			},
			fuel = 150
		},
		waveIncrement = {}
	}
	oldCount = #nexus.spawns

	nexus.waveIncrement[#nexus.waveIncrement + 1] = makeWaveIncrement(1, 1, 0, 0, 0, 0)
	nexus.waveIncrement[#nexus.waveIncrement + 1] = makeWaveIncrement(0, 1, 1, 0, 0, 0)
	nexus.waveIncrement[#nexus.waveIncrement + 1] = makeWaveIncrement(0, 0, 1, 0, 0, 1)
	nexus.waveIncrement[#nexus.waveIncrement + 1] = makeWaveIncrement(1, 0, 1, 0, 0, 1)

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
	countQuery = 0

	sndInfantry = LoadSound("MOD/snd/spawn_infantry.ogg")
	sndHeavy = LoadSound("MOD/snd/spawn_heavy.ogg")
	sndSniper = LoadSound("MOD/snd/spawn_sniper.ogg")
	sndDoc = LoadSound("MOD/snd/spawn_doc.ogg")
	sndNewNavPos = {}
	sndNewNavPos[#sndNewNavPos + 1] = LoadSound("MOD/snd/new_nav_pos1.ogg")
	sndNewNavPos[#sndNewNavPos + 1] = LoadSound("MOD/snd/new_nav_pos2.ogg")
	sndNewNavPos[#sndNewNavPos + 1] = LoadSound("MOD/snd/new_nav_pos3.ogg")
	sndNewTarget = {}
	sndNewTarget[#sndNewTarget + 1] = LoadSound("MOD/snd/new_target1.ogg")
	sndNewTarget[#sndNewTarget + 1] = LoadSound("MOD/snd/new_target2.ogg")
	sndNewTarget[#sndNewTarget + 1] = LoadSound("MOD/snd/new_target3.ogg")

	powers = {
		artillery = {
			cooldown = {
				value = 0,
				default = 30
			},
			delay = {
				value = 0,
				default = 5
			},
			count = {
				value = 0,
				default = 5,
				baseInterval = 0.3
			},
			target = Vec()
		},
		minefield = {
			cooldown = {
				value = 0,
				default = 30
			},
			mines = {}
		}
	}
end


function tick(dt)
	
	handlePathfindingQueries()

	handlePowers(dt)

	if nexus.alive then
		updateNexus(dt)
	end

	drawSuppliesOutline()

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
		
		local hitPos = getMouseHitPos()
		if hitPos ~= nil then
			if InputPressed("f1") and powers.minefield.cooldown.value <= 0 then
				minefield(hitPos)
			end
			if InputPressed("f2") and powers.artillery.cooldown.value <= 0 then
				artillery(hitPos)
			end
		end
	end

	SetFloat('level.rts.stats.integrity', getNexusIntegrity())
	SetFloat('level.rts.stats.fuel', getFuelPercent())
	SetFloat('level.rts.stats.money', nexus.money)
	SetInt('level.rts.stats.wave', nexus.wave)
	SetFloat('level.rts.stats.waveCooldown', nexus.waveCooldown.value)
end


function update(dt)
	if isLoading then
		return
	end
	updateTransformAllSoldiers()
	updateSoldiers()
end


function draw(dt)
	if nexus.alive then
		RTSDrawMenu()
	end
	
	if isLoading then
		return
	end
	if tool.toggled then
		UiMakeInteractive()
		updateStrategicView(dt)
		select()
		command()
		for i=1, #soldiers do
			local soldier = soldiers[i]
			if getAliveStatusInRegistry(soldier.id) then
				--health
				local size = 1.5
				local pos = VecAdd(soldier.t.pos, Vec(-0.5, 1.2, 0.5))
				DrawLine(pos, VecAdd(pos, Vec(size)), 1, 0.2, 0.2, 1)
				DrawLine(pos, VecAdd(pos, Vec(size * getHealthInRegistry(soldier.id) / health[soldier.type])), 0.2, 1, 0.2, 1)
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

function makeWaveIncrement(infCount, heavyCount, sniperCount, capCount, tankCount, docCount)
	return {
		INFANTRY = infCount,
		HEAVY_INFANTRY = heavyCount,
		SNIPER = sniperCount,
		CAPTAIN = capCount,
		TANK = tankCount,
		DOC = docCount
	}
end

function setUpdatedStatusInRegistry(identifier, value)
	return SetBool("level.rts.path.updated." .. identifier, value)
end

function setPathStatusInRegistry(identifier, status)
	SetString("level.rts.path.status." .. identifier, status)
end

function setPathInRegistry(identifier, path)
	SetInt("level.rts.path.points." .. identifier .. ".length", #path)
	for i=1, #path do
		for j=1, 3 do
			SetFloat("level.rts.path.points." .. identifier .. "." .. i .. "." .. j, path[i][j])
		end
	end
end

function getPathInRegistry(identifier)
	local path = {}
	local len = GetInt("level.rts.path.points." .. identifier .. ".length")
	for i=1, len do
		local v = Vec()
		for j=1, 3 do
			v[j] = GetFloat("level.rts.path.points." .. identifier .. "." .. i .. "." .. j)
		end
		path[#path + 1] = VecCopy(v)
	end
	return path
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
	nexus.wave = 0
	nexus.alive = true
	nexus.money = 800
	nexus.cooldown.default = 8
	nexus.cooldown.value = nexus.cooldown.default
	nexus.waveCooldown.value = nexus.waveCooldown.default
	nexus.maxEnemiesCount = 25
	nexus.fuel.value = nexus.fuel.max
	nexus.roundRobin = {}
	nexus.roundRobin[#nexus.roundRobin + 1] = INFANTRY
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

function getAllies()
	local allies = {}
	for i=1, #soldiers do
		local soldier = soldiers[i]
		if getAliveStatusInRegistry(soldier.id) and soldier.team == ALLY_TEAM then
			allies[#allies + 1] = soldier
		end
	end
	return allies
end

function getEnemies()
	local enemies = {}
	for i=1, #soldiers do
		local soldier = soldiers[i]
		if getAliveStatusInRegistry(soldier.id) and soldier.team == ENEMY_TEAM then
			enemies[#enemies + 1] = soldier
		end
	end
	return enemies
end

function makeSpawn()
	if #nexus.spawns >= nexus.spawnCount then
		nexus.wave = 1
		return
	end

	local state = getPathState(md)
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

			minDist = nil
			for i=1, #nexus.spawns do
				local distance = VecLength(VecSub(nexus.spawns[i], hitPos))
				if minDist == nil or distance < minDist then
					minDist = distance
				end
			end

			if not IsPointInWater(hitPos) and (#nexus.spawns == 0 or minDist >= 20) then
				queryPath(md, hitPos, pos)
				nexus.spawnInitTime = 0
			end
		end
	elseif state == "busy" then
		if nexus.spawnInitTime >= 5 then
			abortPath(md)
		end
	elseif state == "done" then
		nexus.spawns[#nexus.spawns +  1] = deepcopy(nexus.tentative)
	end

	DrawLine(nexus.tentative, VecAdd(nexus.tentative, Vec(0, 5, 0)))
end

function updateNexus(dt)

	if nexus.wave == 0 then
		nexus.spawnInitTime = nexus.spawnInitTime + dt
		makeSpawn()
		return
	end

	drawNexusOutline()
	updateFuel(dt)
	incrementMoney(dt)
	updateNexusState()
	updateNexusWave(dt)
	updateNexusEnemySpawn(dt)
	updateSupplies(dt)
end

function updateSupplies(dt)
	nexus.supplies.cooldown.value = nexus.supplies.cooldown.value - dt
	if nexus.wave > 0 and nexus.supplies.cooldown.value <= 0 then
		nexus.supplies.cooldown.value = nexus.supplies.cooldown.default
		while not spawnSupply() do end
	end
end

function updateNexusEnemySpawn(dt)
	nexus.cooldown.value = nexus.cooldown.value - dt
	
	nexus.cooldown.default = math.max(8 - nexus.wave * 0.6, 2)
	nexus.enemiesCount = #getEnemies()

	if nexus.cooldown.value <= 0 and nexus.maxEnemiesCount > nexus.enemiesCount and nexus.wave >= 0 then
		spawnEnemieFromNexus()
		nexus.cooldown.value = nexus.cooldown.default
	end
end

function updateNexusWave(dt)
	nexus.waveCooldown.value = nexus.waveCooldown.value - dt
	if nexus.waveCooldown.value <= 0 then
		nexus.waveCooldown.value = nexus.waveCooldown.default
		nexus.wave = nexus.wave + 1
		local increment = nexus.waveIncrement[(nexus.wave % #nexus.waveIncrement) + 1]
		for k, v in ipairs(increment) do
			for i=1, v do
				nexus.roundRobin[#nexus.roundRobin + 1] = k
			end
		end
	end
end

function updateFuel(dt)
	nexus.fuel.value = nexus.fuel.value - (nexus.fuel.lose.base + nexus.fuel.lose.perUnit * #getAllies()) * dt
end

function drawNexusOutline()
	for i=1, #nexus.bodies do
		DrawBodyOutline(nexus.bodies[i], 1, 0.6, 0.6, 1)
	end
end

function incrementMoney(dt)
	local value = nexus.moneyPerSecond * dt
	nexus.money = nexus.money + value
end

function updateNexusState()
	nexus.integrity.current = getNexusVoxCount()
	local oldState = nexus.alive
	nexus.alive = nexus.integrity.min <= getNexusIntegrity()
	
	if nexus.fuel.value <= 0 then
		nexus.alive = false
	end

	if nexus.alive ~= oldState then
		Explosion(getNexusTransform().pos, 4)
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

function spawnSupply()
	local offset = makeOffset(getNexusTransform().pos, 70, true)

	local hit, dist, normal, shape = QueryRaycast(offset, Vec(0, -1, 0), 200)
	if hit then
		offset = VecAdd(offset, VecScale(Vec(0, -1, 0), dist - 0.5))
		if IsPointInWater(offset) then
			return false
		end
	else
		return false
	end
	
	local entities = Spawn("vox/supply.xml", Transform(offset))

	nexus.supplies.identifier = nexus.supplies.identifier + 1

	local bodies = {}

	for i=1, #entities do
		if GetEntityType(entities[i]) == "body" then
			--SetTag(entities[i], "identifier_supply", nexus.supplies.identifier)
			bodies[#bodies + 1] = entities[i]
		end
	end

	nexus.supplies.array[#nexus.supplies.array + 1] = {
		pos = offset,
		alive = true,
		bodies = bodies,
		id = nexus.supplies.identifier
	}

	return true
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

function getMouseHitPos()
	local mx, my = UiGetMousePos()
	local maxDist = 200
	local dir = UiPixelToWorld(mx, my)
	local pos = GetCameraTransform().pos
	local hit, dist, normal, shape = QueryRaycast(pos, dir, maxDist)
	local hitPos = Vec(0, -100, 0)
	if hit then
		return VecAdd(pos, VecScale(dir, dist - 0.2))
	end
	return nil
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
			local soldier = soldiers[i]
			if soldier.team == ALLY_TEAM then
				local x, y = UiWorldToPixel(soldier.t.pos)
				if x >= tool.aa[1] and x <= tool.bb[1] and y >= tool.aa[3] and y <= tool.bb[3] and getAliveStatusInRegistry(soldier.id) then
					tool.selected[#tool.selected + 1] = soldier
				end
			end
		end
	end

	local allBodies = FindBodies("identifier", true)
	for i=1, #allBodies do
		local identifier = GetTagValue(allBodies[i], "identifier")
		for j=1, #tool.selected do
			local soldier = tool.selected[j]
			if identifier == tostring(soldier.id) then
				if getAliveStatusInRegistry(soldier.id) then
					DrawBodyHighlight(allBodies[i], 1)
					if VecLength(VecSub(soldier.t.pos, getNavigationPosFromRegistry(soldier.id))) > 3 then
						local path = getPathInRegistry(soldier.id)
						local draw = true
						for i=1, #path - 1 do
							local dashStyle = true
							if VecLength(VecSub(soldier.t.pos, path[i])) <= 3 then
								draw = false
							end
							if dashStyle and (i % 2 == 0) then
					
							else
								if draw then
									DrawLine(path[i], path[i + 1], 0, 1, 1, 0.7)
								end
							end
						end
					end
					local targetId = getTargetId(tool.selected[j].id)
					if targetId > 0 then
						DrawLine(tool.selected[j].t.pos, soldiers[targetId].t.pos, 0.7, 0.2, 0.2, 0.2)
					end
					break
				end
			end
		end
	end
end

function getCameraPos()
	return Vec(tool.x, tool.height, tool.y)
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
					setNavigationPosInRegistry(hitPos, tool.selected[i].id)
					PlaySound(sndNewNavPos[rand(1, 3)], getCameraPos())
				end
				if targetId ~= nil then
					PlaySound(sndNewTarget[rand(1, 3)], getCameraPos())
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
	if team == ALLY_TEAM then
		PlaySound(sndInfantry, getCameraPos())
	end
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
	if team == ALLY_TEAM then
		PlaySound(sndHeavy, getCameraPos())
	end
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
	if team == ALLY_TEAM then
		PlaySound(sndSniper, getCameraPos())
	end
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
	if team == ALLY_TEAM then
		PlaySound(sndDoc, getCameraPos())
	end
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

	setTargetIdInRegistry(0, soldier.id)

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
	if identifierTarget == -1 then -- targeting nexus
		pos = getNexusTransform().pos
	elseif identifierTarget == 0 then
		pos = Vec(0, -100, 0)
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
		local soldier = soldiers[i]
		if soldier.id == identifier then
			return soldier
		end
	end
end

function updateTransformAllSoldiers()
	for i=1, #soldiers do
		local soldier = soldiers[i]
		soldier.t = GetBodyTransform(soldier.bodies[1])
	end
end

function getFuelPercent()
	return math.max(nexus.fuel.value, 0) / nexus.fuel.max
end

function getClosestTargetIdentifier(soldier)

	local best = {
		id = 0,
		dist = 0
	}
	for i=1, #soldiers do
		local soldier = soldiers[i]
		if soldier.team ~= soldier.team and getAliveStatusInRegistry(soldier.id) then
			local dist = VecLength(VecSub(soldier.t.pos, soldier.t.pos))
			if best.id == 0 or dist < best.dist then
				best.id = soldier.id
				best.dist = dist
			end
		end
	end
	return best.id, best.dist
end

function getClosestTargetIdentifierIncludingNexus(soldier)
	local best = {
		id = 0,
		dist = 0
	}
	best.id, best.dist = getClosestTargetIdentifier(soldier)
	local distToNexus = VecLength(VecSub(getNexusTransform().pos, soldier.t.pos))
	if best.id == 0 or distToNexus <= best.dist then
		best.id = -1
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
		local soldier = soldiers[i]
		if getAliveStatusInRegistry(soldier.id) and soldier.type == DOC then
			docs[#docs + 1] = soldier
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

function getSupply(identifier)
	nexus.fuel.value = math.min(nexus.fuel.value + nexus.supplies.fuel, nexus.fuel.max)
	for i=1, #nexus.supplies.array[identifier].bodies do
		Delete(nexus.supplies.array[identifier].bodies[i])
	end
end

function getAliveSoldiers()
	local aliveSoldiers = {}

	for i=1, #soldiers do
		local soldier = soldiers[i]
		if getAliveStatusInRegistry(soldier.id) then
			aliveSoldiers[#aliveSoldiers + 1] = soldier
		end
	end

	return aliveSoldiers
end

function updateSoldiers()

	local aliveSoldiers = getAliveSoldiers()
	local docs = getDocs()

	for i=1, #aliveSoldiers do
		local soldier = aliveSoldiers[i]
		if getAliveStatusInRegistry(soldier.id) then
			updateSoldier(soldier, docs)
		end
	end

	handleSoldiersPathQuery()
end

function updateSoldier(soldier, docs)
	setTarget(soldier)
	healSoldier(soldier, docs)
	grabSupply(soldier)
end

function setTarget(soldier)
	local targetId = getTargetId(soldier.id)

	if targetId == -1 or not getAliveStatusInRegistry(targetId) then
		local target
		if soldier.team == ALLY_TEAM or not nexus.alive then
			target = getClosestTargetIdentifier(soldier)
		else
			target = getClosestTargetIdentifierIncludingNexus(soldier)
		end
		if target ~= nil then
			setTargetIdInRegistry(target, soldier.id)
		end
	end

	setTargetPosInRegistry(getTargetId(soldier.id), soldier.id)
end

function healSoldier(soldier, docs)
	for i=1, #docs do

		local doc = docs[i]
		local healing = false

		if soldier.team == doc.team and VecLength(VecSub(soldier.t.pos, doc.t.pos)) < 12 then
			healing = true
			DrawLine(soldier.t.pos, doc.t.pos, 1, 0.6, 0.6, 0.5)
			break
		end
	end
	
	setHealingStatusInRegistry(soldier.id, healing)
end

function grabSupply(soldier)
	if soldier.team == ALLY_TEAM then
		for j=1, #nexus.supplies.array do
			local supply = nexus.supplies.array[j]
			if supply.alive then
				if VecLength(VecSub(soldier.t.pos, supply.pos)) <= 6 then
					supply.alive = false
					getSupply(supply.id)
				end
			end
		end
	end
end

function handleSoldiersPathQuery()
	local pathQuery = nil
	for i=1, #soldiers do
		local soldier = soldiers[i]
		if getAliveStatusInRegistry(soldier.id) then

			if getPathQueryInRegistry(soldier.id) then
				setPathQueryInRegistry(soldier.id, false)

				if pathQuery == nil then
					pathQuery = {
						askers = {},
						status = "idle",
						start = soldier.t.pos,
						target = getNavigationPosFromRegistry(i)
					}
				end
				
				if soldier.team == ENEMY_TEAM or isInTable(tool.selected, soldier.id) then
					pathQuery.askers[#pathQuery.askers + 1] = soldier.id
				end
			end
		end
	end

	if pathQuery ~= nil then
		if #pathQuery.askers > 0 then
			queryQueue[#queryQueue + 1] = pathQuery
		end
	end
end

function handlePowers(dt)
	handleMinefield(dt)
	handleArtillery(dt)
end

function handleMinefield(dt)
	powers.minefield.cooldown.value = powers.minefield.cooldown.value - dt
	local newMines = {}
	for i=1, #powers.minefield.mines do
		if not IsHandleValid(powers.minefield.mines[i].body) then
			powers.minefield.mines[i].alive = false
		end
		if powers.minefield.mines[i].alive then
			local minePos = GetBodyTransform(powers.minefield.mines[i].body).pos
			for j=1, #soldiers do
				if getAliveStatusInRegistry(soldiers[j].id) and soldiers[j].team == ENEMY_TEAM and VecLength(VecSub(soldiers[j].t.pos, minePos)) <= 2 then
					powers.minefield.mines[i].alive = false
					Delete(powers.minefield.mines[i].body)
					Explosion(minePos, 2)
					break
				end
			end
			newMines[#newMines + 1] = powers.minefield.mines[i]
		end
	end
	powers.minefield.mines = newMines
end

function handleArtillery(dt)
	local art = powers.artillery
	art.cooldown.value = art.cooldown.value - dt
	if art.count.value > 0 then
		art.delay.value = art.delay.value - dt
		if art.delay.value <= 0 then
			art.delay.value = art.count.baseInterval + rand(1, 4) / 10
			art.count.value = art.count.value - 1
			Explosion(makeOffset(art.target, 5, true), 3)
		end
	end
end

function minefield(pos)
	powers.minefield.cooldown.value = powers.minefield.cooldown.default
	for i=1, 6 do
		local entities = Spawn("vox/mine.xml", Transform(makeOffset(pos, 4, true)))
		for j=1, #entities do
			if GetEntityType(entities[j]) == "body" then
				powers.minefield.mines[#powers.minefield.mines + 1] = {
					body = entities[j],
					alive = true
				}
			end
		end
	end
end

function artillery(pos)
	local art = powers.artillery
	art.delay.value = art.delay.default
	art.target = deepcopy(pos)
	art.count.value = art.count.default
	art.cooldown.value = art.cooldown.default
end

function drawSuppliesOutline()
	for i=1, #nexus.supplies.array do
		local supply = nexus.supplies.array[i]
		if supply.alive then
			for j=1, #supply.bodies do
				DrawBodyOutline(supply.bodies[j], 1, 1, 0, 1)
			end
		end
	end
end

function handlePathfindingQueries()
	if firstPassage then
		firstPassage = false
		local worldAA, worldBB = GetBodyBounds(GetWorldBody())
		md = makeMappingData(worldAA, worldBB)
		md.step = 3
	end
	processUpdate(md, dt)
	
	if md.status > 3 then
		if #queryQueue > 0 then
			queryQueue[1].status = getPathState(md)
			local status = queryQueue[1].status
			local askers = queryQueue[1].askers
			if queryQueue[1].status == "idle" then
				queryPath(md, queryQueue[1].start, queryQueue[1].target)
				countQuery = countQuery + 1
				queryQueue[1].status = getPathState(md)
			elseif queryQueue[1].status == "fail" or queryQueue[1].status == "done" then
				local newQueue = {}
				if queryQueue[1].status == "done" then
					local path = getSmoothPath(md)
					for i=1, #queryQueue[1].askers do
						personnalPath = deepcopy(path)
						table.insert(personnalPath, 1, getNavigationPosFromRegistry(queryQueue[1].askers[i]))
						setPathInRegistry(queryQueue[1].askers[i], personnalPath)
					end
					for i=1, #queryQueue[1].askers do
						setUpdatedStatusInRegistry(queryQueue[1].askers[i], true)
					end
				end
				abortPath(md)
				
				for i=2, #queryQueue do
					newQueue[#newQueue + 1] = queryQueue[i]
				end
				queryQueue = newQueue
			end
			for i=1, #askers do
				setPathStatusInRegistry(askers[i], status)
			end
		end
		--edgesDebugLine(true, md)
	end
end
























































