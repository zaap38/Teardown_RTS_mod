--This script will run on all levels when mod is active.
--Modding documentation: http://teardowngame.com/modding
--API reference: http://teardowngame.com/modding/api.html

#include "script/infantry/humanoid.lua"

--[[
	keys:
	level.rts.navigation_pos.identifier.i
]]

function init()

	INFANTRY = 1
	HEAVY_INFANTRY = 2
	SNIPER = 3
	CAPTAIN = 4
	TANK = 5
	DOC = 6

	ALLY_TEAM = 1
	ENEMY_TEAM = 2

	identifierCount = 1

	allies = {}
	enemies = {}

end


function tick(dt)
	if InputPressed("usetool") then
		makeSoldier(ALLY_TEAM, GetPlayerCameraTransform())
	end
	if InputPressed("grab") then
		setNavigationPosInRegistry(GetPlayerCameraTransform().pos, 1)
	end
end


function update(dt)
	
end


function draw(dt)
	
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

function initInfantry(team, t)
	local soldier = {
		t = TransformCopy(t),
		hp = 100,
		type = INFANTRY,
		team = team,
		id = identifierCount
	}

	local entities = Spawn("script/infantry/spawn/combine.xml", soldier.t)
	for i=1, #entities do
		SetTag(entities[i], "identifier", tostring(soldier.id))
	end
	identifierCount = identifierCount + 1

	return soldier
end

function makeSoldier(team, t, typeSoldier)

	local soldier = {}
	if typeSoldier == INFANTRY then
		soldier = initInfantry(team, t)
	else
		soldier = initInfantry(team, t)
	end

	if team == ALLY_TEAM then
		allies[#allies + 1] = soldier
	else
		enemies[#enemies + 1] = soldier
	end
end

function setNavigationPosInRegistry(pos, identifier)
	DebugWatch("p", pos)
	for i=1, 3 do
		SetFloat("level.rts.navigation_pos." .. identifier .. "." .. i)
	end
end
























































