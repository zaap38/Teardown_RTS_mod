--This script will run on all levels when mod is active.
--Modding documentation: http://teardowngame.com/modding
--API reference: http://teardowngame.com/modding/api.html

#include "script/infantry/humanoid.lua"

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

end


function tick(dt)

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

	if not tool.toggled then
		if InputPressed("c") then
			makeSoldier(ALLY_TEAM, GetPlayerCameraTransform())
		end
		if InputPressed("v") then
			makeSoldier(ENEMY_TEAM, GetPlayerCameraTransform())
		end
		if InputPressed("x") then
			--[[for i=1, #soldiers do
				if soldiers[i].team == ALLY_TEAM then
					local pos = GetPlayerCameraTransform().pos
					local offset = randVec(4)
					offset[2] = 0
					pos = VecAdd(pos, offset)
					setNavigationPosInRegistry(pos, i)
				end
			end]]
		end
		if InputPressed("b") then
			for i=1, #soldiers do
				if soldiers[i].team == ENEMY_TEAM then
					local pos = GetPlayerCameraTransform().pos
					local offset = randVec(4)
					offset[2] = 0
					pos = VecAdd(pos, offset)
					setNavigationPosInRegistry(pos, i)
				end
			end
		end
	end
end


function update(dt)
	updateTransformAllSoldiers()
	setAllTarget()
end


function draw(dt)
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
				local offset = randVec(math.min((#tool.selected - 1 * 0.5), 4))
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

function getAliveStatusInRegistry(identifier)
	return GetBool("level.rts.alive." .. identifier)
end

function makeSoldier(team, t, typeSoldier)

	local soldier = {}
	if typeSoldier == INFANTRY then
		soldier = initInfantry(team, t)
	else
		soldier = initInfantry(team, t)
	end
	setNavigationPosInRegistry(t.pos, soldier.id)

	soldiers[#soldiers + 1] = soldier
end

function setNavigationPosInRegistry(pos, identifier)
	for i=1, 3 do
		SetFloat("level.rts.navigation_pos." .. identifier .. "." .. i, pos[i])
	end
end

function setTargetIdInRegistry(identifierTarget, identifier)
	SetInt("level.rts.target." .. identifier, identifierTarget)
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

function getClosestTarget(soldier)

	local best = {
		id = 0,
		dist = 0
	}
	for i=1, #soldiers do
		if soldiers[i].team ~= soldier.team and getAliveStatusInRegistry(soldiers[i].id) then
			local dist = VecLength(VecSub(soldiers[i].t.pos, soldier.t.pos))
			if best.id == 0 or dist < best.dist then
				best.id = soldiers[i].id
				best.dist = dist
			end
		end
	end
	return best.id
end

function setAllTarget()
	for i=1, #soldiers do
		setTargetIdInRegistry(getClosestTarget(soldiers[i]), soldiers[i].id)
	end
end
























































