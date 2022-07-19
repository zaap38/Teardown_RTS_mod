--This script will run on all levels when mod is active.
--Modding documentation: http://teardowngame.com/modding
--API reference: http://teardowngame.com/modding/api.html

--#include "script/main_road_detection.lua"

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
		money = 0,
		moneyPerSecond = 100,
		enemies = {},
		cooldown = {
			value = 0,
			default = 4
		}
	}

	cost = {
		INFANTRY = 400,
		HEAVY_INFANTRY = 800,
		SNIPER = 600,
		CAPTAIN = 800,
		TANK = 6000,
		DOC = 1200
	}


	--[[md = nil--makeMappingData(Vec(-100, -100, -100), Vec(100, 100, 100))
	firstPassage = true
	world = {}
	world.aa, world.bb = GetBodyBounds(GetWorldBody())
	world.aa = floorVec(world.aa)
	world.bb = floorVec(world.bb)
	firstQuery = true]]
end


function tick(dt)
	
	--[[if firstPassage then
		firstPassage = false
		local worldAA, worldBB = GetBodyBounds(GetWorldBody())
		md = makeMappingData(worldAA, worldBB)
	end
	processDebugCross(md)
	processUpdate(md)
	
	if md.status > 3 and firstQuery == true then
		--exportToRegistry(md, false)
		--importFromRegistry()
		firstQuery = false
		queryPath(md, Vec(0, 0, 0), Vec(0, 0, 50))
	end
	
	-- to print the path
	local path = getPath(md)
	for i=1, #path - 1 do
		DrawLine(path[i], path[i + 1])
	end]]

	if nexus.alive then
		udpateNexus(dt)
		if nexus.cooldown.value <= 0 then
			spawnEnemieFromNexus()
			nexus.cooldown.value = nexus.cooldown.default
		end
		DebugWatch("integrity", getNexusIntegrity())
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
			makeSoldier(ENEMY_TEAM, spawnTransform)
		end
		if InputPressed("n") then
			spawnNexus(spawnTransform)
		end
		if InputPressed("b") then
			for i=1, #soldiers do
				if soldiers[i].team == ENEMY_TEAM then
					local pos = spawnTransform.pos
					local offset = randVec(4)
					offset[2] = 0
					pos = VecAdd(pos, offset)
					setNavigationPosInRegistry(pos, i)
				end
			end
		end
	else
		spawnTransform = Transform(makeOffset(getNexusTransform().pos, 3))
		if InputPressed("c") then
			if nexus.money >= cost.INFANTRY then
				nexus.money = nexus.money - cost.INFANTRY
				makeSoldier(ALLY_TEAM, spawnTransform, INFANTRY)
			end
		end
	end
end


function update(dt)
	if isLoading then
		return
	end
	updateTransformAllSoldiers()
	setAllTarget()
end


function draw(dt)
	if isLoading then
		return
	end
	if tool.toggled then
		UiMakeInteractive()
		updateStrategicView(dt)
		select()
		command()
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
	nexus.wave = 1
	nexus.alive = true
	nexus.enemies = {}
	nexus.cooldown.value = nexus.cooldown.default
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

function udpateNexus(dt)
	local value = nexus.moneyPerSecond * dt
	nexus.money = nexus.money + (value - (value % 1))
	nexus.integrity.current = getNexusVoxCount()
	nexus.alive = nexus.integrity.min <= getNexusIntegrity()
	nexus.cooldown.value = nexus.cooldown.value - dt
end

function makeOffset(origin, dist)
	local offset = randVec(dist)
	offset[2] = math.abs(offset[2])

	local flat = deepcopy(offset)
	flat[2] = 0
	while VecLength(flat) < dist * 0.9 do
		offset = randVec(dist)
		offset[2] = math.abs(offset[2])
		flat = deepcopy(offset)
		flat[2] = 0
	end
	return VecAdd(origin, offset)
end

function spawnEnemieFromNexus()
	local offset = makeOffset(getNexusTransform().pos, rand(70, 100))
	local soldier = makeSoldier(ENEMY_TEAM, Transform(offset), INFANTRY)

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
				DrawBodyHighlight(allBodies[i], 1)
				break
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

		for i=1, #tool.selected do
			if tool.selected[i].team == ALLY_TEAM then
				local offset = randVec(math.min((#tool.selected - 1 * 0.9), 5))
				offset[2] = 0
				local navPoint = VecAdd(hitPos, offset)
				setNavigationPosInRegistry(navPoint, tool.selected[i].id)
			end
		end
	end
end

function initInfantry(team, t)
	local soldier = {
		t = TransformCopy(t),
		hp = 100,
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

function makeSoldier(team, t, typeSoldier)

	typeSoldier = typeSoldier or INFANTRY

	local soldier = {}
	if typeSoldier == INFANTRY then
		soldier = initInfantry(team, t)
	else
		soldier = initInfantry(team, t)
	end
	setNavigationPosInRegistry(t.pos, soldier.id)

	soldiers[#soldiers + 1] = soldier
	setBodiesInRegistry(soldier.id)
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
		best.id = 0
		best.dist = distToNexus
	end
	return best.id, best.dist
end

function setAllTarget()
	for i=1, #soldiers do
		local target
		if soldiers[i].team == ALLY_TEAM or not nexus.alive then
			target = getClosestTargetIdentifier(soldiers[i])
		else
			target = getClosestTargetIdentifierIncludingNexus(soldiers[i])
		end
		if target ~= nil then
			setTargetPosInRegistry(target, i)
			setTargetIdInRegistry(target, i)
		end
	end
end
























































