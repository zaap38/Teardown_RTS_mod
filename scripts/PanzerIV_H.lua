
#include "mountedGun.lua"
--[[
 Vehicle config
]]

vehicle = {
	mainName 				= "PanzerIV_H",
	Vehiclename 			= "body",
  	CannonName 				= "gun",
  	turretName 				= "turret",
  	CannonJointName 		= "turretMount",
  	gunJointName			= "turretGunMount",
  	trigger 				= "",
  	Create 					= "Eric700",
  	barrelOffset 			= .1
}
--[[
 rocket Launcher config
]]

weaponFeatures = {
	rocketFlavourText 		= "75mm KwK 37 gun",
	mgFlavourText 			= "coax.",
	armed 					= true,
	highVelocityShells		= true,
	rocketRPM 				= 15,
	timeToFire 				= .5,
	magazineCapacity 		= 10,
	reloadTime 				= 2,
	hasRockets 				= true,
	hasRocketCapacity		= false,
	rocketCapacity 			= 50,
	rocketStartingAmmo 		= 36,
	explosionSize			= 2,
	-- maxPenetration 			= 3,
	startRockets			= true,  
	hasMG 					= true,
	hasMGCapacity			= false,
	MGCapacity 				= 500,
	MGStartingAmmo 			= 250,
	hasCoax 				= false,
	elevationMax			= 14,
	elevationMin			= -10,
	displayWeaponDetails	= true,
	rocketExtraconsumption 	= 10,
	rocketReloadPenalty 	= 1,
	smokeFactor 			= 3,
	smokeMulti				= 20,
	ammoBoxMGName 			= "",
	ammoBoxRocketName 		= "",
	rocketSound				= "LEVEL/sounds/PanzerIVFire",
	reloadSound				= "LEVEL/sounds/tankReload",
	usingHud				= true
}

function Config_getWeaponFeatures()
	return weaponFeatures
end
function init()
	setValues(vehicle,weaponFeatures)
	gunInit()

	end

function tick(dt)
	gunTick(dt)
end

function update(dt)
	gunUpdate(dt)
end