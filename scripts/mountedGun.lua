


--[[
**********************************************************************
*
* FILEHEADER: Elboydo's vehicle mounted gun and turret control script 
*
* FILENAME :        mountedGun.lua             
*
* DESCRIPTION :
*       File that controls player vehicle turrets within the game teardown (2020)
*
*		File Handles both player physics controlled and in vehicle controlled turrets
*		
*		
*
* SETUP FUNCTIONS :
*		In accessor init: 
*
*       setValues(vehicle,weaponFeatures) - Establishes environment variables for vehicle
*       gunInit() 						  - Establishes vehicle gun state
*
*		In accessor Tick(dt):
*
*		gunTick(dt)						  - Manages gun control during gameplay
*
*
*		gunUpdate(d)					  - Manages gun elevation during gameplay
*
* NOTES :
*       Future versions may ammend issue with exact gun location
*		physics based gun control lost after driving player vehicle.
*       
* 		Please ensure to add player click to hud.lua. 
*
*       Copyright - Of course no copyright but please give credit if this code is 
* 		re-used in part or whole by yourself or others.
*
* AUTHOR :    elboydo        START DATE :    04 Nov 2020
*
*
* ACKNOWLEDGEMENTS:
*
*		Mnay thanks to the many users of the teardown discord for support in coding an establishing this mod,
* 		particularly @rubikow for their invaluable assistance in grasping lua and the functions
*		provided to teardown modders at the inception of this mod.  
*
* HUB REPO: https://github.com/elboydo/TearDownTurretControl
*
* CHANGES :
*
*			Release: Public release V_1 - NOV 11 - 11 - 2020
*
*			V2: Added Turret elevation
*					Added crane functionality to control turret 
*					Added high velocity shells
*					+ other quality of life features
*
*



]]

vehicle = {
	-- mainName 				= "technicalVehicle",
	-- Vehiclename 			= "technicalBody",
 --  	CannonName 				= "canon",
 --  	CannonJointName 		= "gunMount",
 --  	Create 					= "elboydo",
 --  	barrelOffset 			= .6
}

--[[
 multi purpose gun config
]]

weaponFeatures = {
	-- armed 					= true,
	-- timeToFire 				= 1,
	-- magazineCapacity 		= 10,
	-- reloadTime 				= 1,
	-- hasRockets 				= true,
	-- hasRocketCapacity		= false,
	-- rocketCapacity 			= 50,
	-- rocketStartingAmmo 		= 25,
	-- startRockets			= false,  
	-- hasMG 					= true,
	-- hasMGCapacity			= false,
	-- MGCapacity 				= 500,
	-- MGStartingAmmo 			= 250,
	-- displayWeaponDetails	= false,
	-- rocketExtraconsumption 	= 5,
	-- rocketReloadPenalty 	= 1 
}

artillaryHandler = 
{
	shellNum = 1,

	explosionSize = 3,

	shells = {
		[1] = {active=false, hitpos=nil,timeToTarget =0},
		[2] = {active=false, hitpos=nil,timeToTarget =0},
		[3] = {active=false, hitpos=nil,timeToTarget =0},
		[4] = {active=false, hitpos=nil,timeToTarget =0},
		[5] = {active=false, hitpos=nil,timeToTarget =0},
		[6] = {active=false, hitpos=nil,timeToTarget =0},
		[7] = {active=false, hitpos=nil,timeToTarget =0},
		[8] = {active=false, hitpos=nil,timeToTarget =0},
		[9] = {active=false, hitpos=nil,timeToTarget =0},
		[10] = {active=false, hitpos=nil,timeToTarget =0},
		[11] = {active=false, hitpos=nil,timeToTarget =0}

	}

}
shellSpeed = 0.005--0.05


--[[
 MG only config
]]

-- weaponFeatures = {
-- 	armed 					= true,
-- 	timeToFire 				= 1,
-- 	magazineCapacity 		= 10,
-- 	reloadTime 				= 1,
-- 	hasRockets 				= false,
-- 	hasRocketCapacity		= false,
-- 	rocketCapacity 			= 50,
-- 	rocketStartingAmmo 		= 25,
-- 	startRockets			= false,  
-- 	hasMG 					= true,
-- 	hasMGCapacity			= false,
-- 	MGCapacity 				= 500,
-- 	MGStartingAmmo 			= 250,
-- 	displayWeaponDetails	= false,
-- 	rocketExtraconsumption 	= 5,
-- 	rocketReloadPenalty 	= 1 
-- }

--[[
 rocket Launcher config
]]

-- weaponFeatures = {
-- 	armed 					= true,
-- 	timeToFire 				= 1,
-- 	magazineCapacity 		= 5,
-- 	reloadTime 				= 1,
-- 	hasRockets 				= true,
-- 	hasRocketCapacity		= false,
-- 	rocketCapacity 			= 50,
-- 	rocketStartingAmmo 		= 25,
-- 	startRockets			= true,  
-- 	hasMG 					= false,
-- 	hasMGCapacity			= false,
-- 	MGCapacity 				= 500,
-- 	MGStartingAmmo 			= 250,
-- 	displayWeaponDetails	= false,
-- 	rocketExtraconsumption 	= 5,
-- 	rocketReloadPenalty 	= 1 
-- }

function setValues(t_vehicle,t_weapon)
	vehicle = t_vehicle
	weaponFeatures = t_weapon
end

function gunInit()
	vehicle.body = FindBody(vehicle.Vehiclename,true)
	vehicle.transform = GetBodyTransform(vehicle.body)
	vehicle.gun  = FindShape(vehicle.CannonName,true)
	vehicle.turret = FindShape(vehicle.turretName,true)


	vehicle.CannonJoint = FindJoint(vehicle.CannonJointName,true)	

	vehicle.reloadRockets = FindShape(weaponFeatures.ammoBoxRocketName,true)
	vehicle.reloadMG = FindShape(weaponFeatures.ammoBoxMGName,true)

	if(vehicle.trigger) then
		vehicle.trigger = FindShape(vehicle.trigger,true)
	end
	lastTrigger = #GetJointsConnectedToShape(vehicle.trigger)

	vehicleArmed = weaponFeatures.armed


	manualControl = vehicle.manualControl
-- lazy flavour text
	gunStateText = "Fire"
	if(weaponFeatures.rocketFlavourText) then 
		rocketFlavourText = weaponFeatures.rocketFlavourText
	else
		rocketFlavourText = "Rockets"
	end

	if (weaponFeatures.mgFlavourText)then

		mgFlavourtext   = weaponFeatures.mgFlavourText 
	else
		mgFlavourtext 	= "MG"
	end

-- relaod management
	reloading = false
	outOfAmmo = false
	reloadTime = weaponFeatures.reloadTime
	currentReload = reloadTime
-- Gun firemode
	-- time to fire
	maxDist = 500


--reqiures gun joint name
	if(vehicle.gunJointName)then
		-- printStr(vehicle.gunJointName)
		vehicle.gunJoint = FindJoint(vehicle.gunJointName,true)
	end	
	if(vehicle.gunJoint)then
		gunMin = weaponFeatures.elevationMin
		gunMax = weaponFeatures.elevationMax
		rangeCalc = (gunMax-gunMin) /maxDist
		closeCalc = (gunMax-gunMin) /100
	end	
	if(weaponFeatures.explosionSize)then
		artillaryHandler.explosionSize = weaponFeatures.explosionSize
	end

	if(weaponFeatures.rocketRPM) then
		weaponFeatures.rocketReload = 60/weaponFeatures.rocketRPM
	end

	firing = false
	timeToFire = weaponFeatures.timeToFire	
	fireTime = timeToFire
	magazineCapacity = weaponFeatures.magazineCapacity
	shotsLeft = magazineCapacity
	fireRate = timeToFire/shotsLeft

-- init weapon Features
	armed = weaponFeatures.armed
	hasRockets = weaponFeatures.hasRockets
	hasRocketCapacity = weaponFeatures.hasRocketCapacity
	rocketCapacity = weaponFeatures.rocketCapacity
	rocketAmmoLeft = weaponFeatures.rocketStartingAmmo
	hasMG = weaponFeatures.hasMG
	hasMGCapacity = weaponFeatures.hasMGCapacity
	MGCapacity = weaponFeatures.MGCapacity
	MGAmmoLeft = weaponFeatures.MGStartingAmmo
	rocketMode = weaponFeatures.startRockets
	displayWeaponDetails = weaponFeatures.displayWeaponDetails

	hasCoax = weaponFeatures.hasCoax

	if weaponFeatures.rocketRecoil then
		weaponFeatures.recoil = weaponFeatures.rocketRecoil
	else

		weaponFeatures.recoil =0.2
	end

	
	usingHud =weaponFeatures.usingHud 

-- sound effects
	if(weaponFeatures.MGSound) then
		shootSound=weaponFeatures.MGSound
	else
		shootSound = LoadSound("chopper-shoot")
	end
	if(weaponFeatures.rocketSound)then
		rocketSound = LoadSound(weaponFeatures.rocketSound)
	else
		rocketSound = LoadSound("tools/launcher0.ogg")

	end
	if(weaponFeatures.reloadSound)then
		reloadSound= LoadSound(weaponFeatures.reloadSound)
	end
-- smoke effects
	if weaponFeatures.smokeFactor then
		smokeFactor = weaponFeatures.smokeFactor
	else
		smokeFactor = 2
	end
	if weaponFeatures.smokeMulti then
		smokeMulti = weaponFeatures.smokeMulti
	else
		smokeMulti = 1
	end
	smokeTimer = 0	
	gunSmokedissipation = 3
	gunSmokeSize =1
	gunSmokeGravity = 2
	carDriven = false

	gunNum=0
	initTags()


end

function initTags()
	if hasRockets then
		updateRocketAmmoVals()
	else 
		RemoveTag(vehicle.reloadRockets, "interact")
	end
	if hasMG then 
		updateMGAmmoVals()
	else
		RemoveTag(vehicle.reloadMG, "interact")
	end
	if armed then
		updateGunAmmoVals()
	else
		RemoveTag(vehicle.gun,"interact")
	end
end


function gunTick(dt)
	if(armed) then
		checkAmmo(dt)
		checkAmmoSupply()
		handleGunOperation(dt)
		
		if(weaponFeatures.highVelocityShells)then
			artillaryTick(dt)
		end
	end
end



function gunUpdate(dt)

	if(not manualControl or not craneMode()) then
		if(											(GetBool("game.player.usevehicle")
													and HasTag(GetVehicleBody(GetPlayerVehicle()),vehicle.Vehiclename) ))then
			turretRotatation()

			if(vehicle.gunJoint)then
				gunAngle(0,0,-1)
			end
			if(not carDriven ) then
				carDriven = true
			end
		elseif (carDriven) then
			SetJointMotor(vehicle.CannonJoint, 0,0.1)
-- setMotor(joint,0,0)
		end
	end
	-- body
end



function inVehicleGunControl(dt)
	if ((not firing or not reloading)and not outOfAmmo) then
		firing = true
		gunStateText="Firing"
		smokeTimer = timeToFire
		--SetTag(vehicle.gun,"interact","Firing")
	end
	if(firing) then
		fireTime = fireTime - dt
		fireControl(dt)
	elseif (reloading) then
		handleReload(dt)
	end
end

function handleGunOperation(dt)

	if ((
		not firing and 
		not reloading) and 
		(
		(IsShapeOperated(vehicle.gun)) 
		or 
		(GetBool("game.player.usevehicle") 
			and  getPlayerShootInput()
			and HasTag(
						GetVehicleBody(GetPlayerVehicle())
						,vehicle.Vehiclename) )))
	then
		firing = true
		smokeTimer = timeToFire
		gunStateText = "Firing"
		--SetTag(vehicle.gun,"interact","Firing")
	end
	getPlayerShootInput()
	if(firing) then
		fireTime = fireTime - dt
		fireControl(dt)
	elseif (reloading) then
		handleReload(dt)
	end

end

function fireControl(dt)
	if(fireTime < (fireRate*shotsLeft)) then
		if rocketMode then
			if(not hasRocketCapacity or rocketAmmoLeft>0)then

				fire(rocketSound,.2,1)
				processRecoil()
				for i=1, smokeMulti do
					cannonSmoke(dt,smokeFactor)
				end
				shotsLeft 	=	shotsLeft- weaponFeatures.rocketExtraconsumption
				currentReload 	= 	currentReload	+ weaponFeatures.rocketReloadPenalty
				if(hasRocketCapacity)then
					setRocketAmmo(rocketAmmoLeft-1)
					updateRocketAmmoVals()
				end
			else
				printStr("Out of Ammo")
				
				
			end
			if(weaponFeatures.rocketReload) then
				currentReload = weaponFeatures.rocketReload
			end
		else 
			if(not hasMGCapacity or MGAmmoLeft >0) then
				fire(shootSound,0,2)
				smoke(dt,1)
				
				if(hasMGCapacity) then
					setMGAmmo(MGAmmoLeft-1)
					updateMGAmmoVals()
					
				end
			else
				printStr("Out of Ammo")
			end						
		end
		updateGunAmmoVals()
		if(not outOfAmmo) then
			shotsLeft = shotsLeft -1
			if(shotsLeft <= 0)	then
				reload()
			end
		else
			printStr("Out of Ammo")
		end
	end
end

function reload()
	shotsLeft = magazineCapacity
	fireTime = timeToFire
	firing = false
	reloading = true
	if(reloadSound)then
		PlaySound(reloadSound, GetShapeWorldTransform(vehicle.gun).pos, 5, false)
	end
	--SetTag(vehicle.gun,"interact","Reloading")
	gunStateText = "Reloading"
	updateGunAmmoVals()

end

function handleReload( dt )
	if  currentReload > 0 then
		currentReload = currentReload - dt
	else
		currentReload = reloadTime
		reloading = false
		gunStateText = "Fire"
		updateGunAmmoVals()
		-- SetTag(vehicle.gun,"interact","Fire")
	end
end

function smoke(dt,smokeFactor)
	if smokeTimer > 0 then
		local cannonLoc = GetShapeWorldTransform(vehicle.gun)
		local fwdPos = TransformToParentPoint(plyTransform, Vec(0, 0, 100))
		local direction = VecSub(fwdPos, cannonLoc.pos)
		direction = VecNormalize(direction) -- direction the player is looking
		-- local cannonLocTransform = TransformToParentPoint(cannonLoc, Vec(0, 0, 1))
		smokePos = cannonLoc.pos
		smokePos[2] =smokePos[2] +  vehicle.barrelOffset
		local smokeX = clamp(((direction[1]*360)+math.random(1,10)*0.1),-gunSmokedissipation,gunSmokedissipation)
		local smokeY = clamp((direction[3]*10)+math.random(1,10),-gunSmokedissipation,gunSmokedissipation)
		SpawnParticle("smoke", smokePos, Vec(-smokeX, 1.0+math.random(1,10)*0.1,smokeY ), (math.random(1,gunSmokeSize)*smokeFactor), math.random(1,gunSmokeGravity)*smokeFactor)
		smokeTimer = smokeTimer - dt
	end
end
function cannonSmoke(dt,smokeFactor)
	if smokeTimer > 0 then
		local cannonLoc = GetShapeWorldTransform(vehicle.gun)
		local fwdPos = TransformToParentPoint(plyTransform, Vec(0, 0, 100))
		local direction = VecSub(fwdPos, cannonLoc.pos)
		direction = VecNormalize(direction) -- direction the player is looking
		-- local cannonLocTransform = TransformToParentPoint(cannonLoc, Vec(0, 0, 1))
		smokePos = cannonLoc.pos
		smokePos[2] =smokePos[2] +  vehicle.barrelOffset
		local smokeX = clamp(((direction[1]*360)+math.random(1,10)*0.1),-gunSmokedissipation,gunSmokedissipation)
		local smokeY = clamp((direction[3]*10)+math.random(1,10),-gunSmokedissipation,gunSmokedissipation)
		SpawnParticle("smoke", smokePos, Vec(-math.random(-1,1)*smokeX, 1.0+math.random(-3,1),math.random(1,1)*smokeY ), (math.random(1,gunSmokeSize)*smokeFactor), math.random(1,gunSmokeGravity)*smokeFactor)
		smokeTimer = smokeTimer - dt
	end
end

function fire(sound,fireVec,shotType)
	local cannonLoc = GetShapeWorldTransform(vehicle.gun)


	cannonLoc.pos[2] = cannonLoc.pos[2]+  (vehicle.barrelOffset)

	RaycastRejectBody(vehicle.body)
	RaycastRejectBody(vehicle.gun)
		RaycastRejectBody(vehicle.turret)
	local fwdPos = TransformToParentPoint(cannonLoc, Vec(0,  maxDist * -1),0)
    local direction = VecSub(fwdPos, cannonLoc.pos)
     -- printloc(direction)
    direction = VecNormalize(direction)

    hit, dist = Raycast(cannonLoc.pos, direction, maxDist)
    -- printStr(dist)
    PlaySound(sound, cannonLoc.pos, 5, false)
    if hit then
		hitPos = TransformToParentPoint(cannonLoc, Vec(0, dist * -1,(dist*.1)*fireVec))
	else
		hitPos = TransformToParentPoint(cannonLoc, Vec(0,  maxDist * -1,(dist*.1)*fireVec))
	end
      	p = cannonLoc.pos

		d = VecNormalize(VecSub(hitPos, p))
		spread = 0.03
		d[1] = d[1] + ((math.random()-0.5)*2*spread)*dist/maxDist
		d[2] = d[2] + ((math.random()-0.5)*2*spread)*dist/maxDist
		d[3] = d[3] + ((math.random()-0.5)*2*spread)*dist/maxDist
		d = VecNormalize(d)
		p = VecAdd(p, VecScale(d, 0.5))

		if(weaponFeatures.highVelocityShells and shotType==1)then
			if (weaponFeatures.maxPenetration and hit) then
				cannonLoc.pos = hitPos
				pushShell(hitPos,dist,direction,maxDist-dist,cannonLoc)
			else

				pushShell(hitPos,dist)
			end
			shotType = 0
		end
		Shoot(p, d,shotType)	
end


function shellPenetration(shell)
	local fwdPos = TransformToParentPoint(shell.t_cannon, Vec(0,  shell.distance * -1),0)
    local direction = VecSub(fwdPos, shell.t_cannon.pos)
    hit, dist = Raycast(shell.t_cannon.pos, direction, shell.distance)
 --    -- printStr(dist)
    if hit then
		hitPos = TransformToParentPoint(shell.t_cannon, Vec(0, dist * -1,(dist*.1)*.2))
	else
		hitPos = TransformToParentPoint(shell.t_cannon, Vec(0,  shell.distance * -1,(dist*.1)*.2))
	end
      	p = shell.t_cannon.pos

		d = VecNormalize(VecSub(hitPos, p))
		spread = 0.03
		d[1] = d[1] + ((math.random()-0.5)*2*spread)*dist/shell.distance
		d[2] = d[2] + ((math.random()-0.5)*2*spread)*dist/shell.distance
		d[3] = d[3] + ((math.random()-0.5)*2*spread)*dist/shell.distance
		d = VecNormalize(d)
		p = VecAdd(p, VecScale(d, 0.5))
		-- printloc(shell.t_cannon.pos)
			if (hit and shell.penetrations>0) then
				shell.t_cannon.pos = hitPos
				pushShell(hitPos,dist,direction,maxDist-dist,shell.t_cannon)
			else

				pushShell(hitPos,dist)
			end
			shotType = 0
		Shoot(p, d,shotType)	
end


function artillaryTick(dt)
	local activeShells = 0
		for key,shell in ipairs( artillaryHandler.shells  )do
			 if(shell.active)then
			 	activeShells= activeShells+1
			 	if shell.timeToTarget <0 then
			 		popShell(shell)
			 		
			 	else
			 		shell.timeToTarget = shell.timeToTarget-dt
			 	end
			 end
		end
		-- printStr(activeShells)
end

function pushShell(t_hitPos,dist,t_direction,t_distance,t_cannon)
	if(dist <=0)then
		dist = maxDist
	end

	artillaryHandler.shells[getShellNum()].active = true
	artillaryHandler.shells[getShellNum()].hitPos = t_hitPos
	artillaryHandler.shells[getShellNum()].timeToTarget = dist*shellSpeed

	if(t_direction) then
		artillaryHandler.shells[getShellNum()].direction = t_direction
		artillaryHandler.shells[getShellNum()].distance = t_distance
		artillaryHandler.shells[getShellNum()].t_cannon = t_cannon
			if(not artillaryHandler.shells[getShellNum()].penetrations or artillaryHandler.shells[getShellNum()].penetrations==0) then
					
					printStr(artillaryHandler.shells[getShellNum()].penetrations)
					artillaryHandler.shells[getShellNum()].penetrations = weaponFeatures.maxPenetration

				
		else
			artillaryHandler.shells[getShellNum()].penetrations = artillaryHandler.shells[getShellNum()].penetrations-1
		end
		-- SetString("hud.notification",artillaryHandler.shells[getShellNum()].penetrations.."\n"..artillaryHandler.shells[getShellNum()].timeToTarget)

	end


	incrementShellNum()
end


function popShell(shell)
	shell.active = false
	if(shell.penetrations and shell.penetrations>0)then
		
		Explosion(shell.hitPos,0.5)
		shellPenetration(shell)
	else
		Explosion(shell.hitPos,artillaryHandler.explosionSize)
	end
	
	
	shell.timeToTarget = 100
end

function getShellNum()
	return artillaryHandler.shellNum
	
end

function incrementShellNum()
	artillaryHandler.shellNum = ((artillaryHandler.shellNum+1) % #artillaryHandler.shells)+1
end


function processRecoil()
	local bodyLoc = GetBodyTransform(FindBody(vehicle.Vehiclename,true))
	local cannonLoc = GetShapeWorldTransform(vehicle.gun)
	
	local fwdPos = TransformToParentPoint(cannonLoc, Vec(0, 1,.25))
    local direction = VecSub(fwdPos, cannonLoc.pos)

	local scaled = VecScale(VecNormalize(direction),weaponFeatures.recoil)

	bodyLoc.pos = VecAdd(bodyLoc.pos,scaled)
	SetBodyTransform(vehicle.body,bodyLoc)
end


function turretRotatation()
	
	local forward = turretAngle(0,1,0)
	local back 	  = turretAngle(0,-1,0) 
	local left 	  = turretAngle(-1,0,0)
	local right   = turretAngle(1,0,0)
	local up 	  = turretAngle(0,0,1)
	local down 	  = turretAngle(0,0,-1)

	local bias = 0.025
	if(forward<(1-bias)) then
		if(left>right+bias) then
			SetJointMotor(vehicle.CannonJoint, 0.1+1*left)
		elseif(right>left+bias) then
			SetJointMotor(vehicle.CannonJoint, -.1+(-1*right))
		else
			SetJointMotor(vehicle.CannonJoint, 0)
		end
	else
		SetJointMotor(vehicle.CannonJoint, 0)
	end 
	-- SetString("hud.notification",
	-- 	"forward: "..
	-- 	forward..
	-- 	"\nback: "..
	-- 	back..
	-- 	"\nleft: "..
	-- 	left..
	-- 	"\nright: "..
	-- 	right)
end

function turretAngle(x,y,z)
	local gunTransform = GetShapeWorldTransform(vehicle.gun)
	local fwdPos = TransformToParentPoint(GetCameraTransform(), Vec(0, 0, 1000))
	local toPlayer = VecNormalize(VecSub(fwdPos, gunTransform.pos))
	local forward = TransformToParentVec(gunTransform, Vec(x,  y, Z))
	local orientationFactor = clamp(VecDot(forward, toPlayer) * 0.7 + 0.3, 0.0, 1.0)
	return orientationFactor
end

function gunAngle(x,y,z)
	local verted = 1
	if(rocketMode)then
		targetAngle = getTargetAngle()
	else
		targetAngle = 0
	end

	-- targetAngle = targetAngle*verted
    -- SetString("hud.notification","target Angle: "..targetAngle.."\nDist: "..dist.."\nJoint at: "..GetJointMovement(vehicle.gunJoint))
    local bias = .5
    if(-GetJointMovement(vehicle.gunJoint) < (targetAngle-bias)) then
			SetJointMotor(vehicle.gunJoint, 1*bias)
	elseif(-GetJointMovement(vehicle.gunJoint) > (targetAngle+bias)) then
			SetJointMotor(vehicle.gunJoint, -1*bias)
	else
		SetJointMotor(vehicle.gunJoint	, 0)
	end 

end



function getTargetAngle( )

			local gunTransform = nil
		if(weaponFeatures.highVelocityShells) then
			 gunTransform = GetCameraTransform()
			 gunTransform.pos[2] = 20- gunTransform.pos[2]
			-- gunTransform =  GetShapeWorldTransform(vehicle.turret)
			-- gunTransform.pos[2] = gunTransform.pos[2] 
			-- gunTransform.rot = camTransform.rot
			verted	 = -1.2
		else
			gunTransform = GetShapeWorldTransform(vehicle.turret)
			gunTransform.pos[2] = gunTransform.pos[2] -.2
		end
		-- printloc(gunTransform.pos)
		if(weaponFeatures.highVelocityShells)then
			local fwdPos = TransformToParentPoint(gunTransform, Vec(0,1,maxDist *-1 ))
		else
			local fwdPos = TransformToParentPoint(gunTransform, Vec(0,maxDist *-1,.5 ))
		end
		-- printStr(vehicle.turret)
		RaycastRejectBody(vehicle.body)
		RaycastRejectBody(vehicle.turret)
		RaycastRejectBody(vehicle.gun)

	    local direction = VecSub(fwdPos, gunTransform.pos)
	     -- printloc(direction)
	    direction = VecNormalize(direction)

	    hit, dist = Raycast(gunTransform.pos, direction, maxDist)
	    if(dist == 0)then
	    	dist = maxDist
	    end

	    if dist>100 or (weaponFeatures.highVelocityShells and dist>30) then
	    	targetAngle =  (dist*rangeCalc)+1
		else
			targetAngle =  (dist*closeCalc)+1
		end
		targetAngle	=targetAngle	-5

		return targetAngle
	-- body
end



function checkAmmo(dt)
	if(hasRockets and hasMG) then
		if ((
			IsShapeOperated(vehicle.reloadRockets)or (playerInVehicle()and (GetInt("mouse.wheel") <0)) ) 
			and not rocketMode) then
			rocketMode = true
			if(hasCoax)then
				currentReload = 0
			end	 
			if(usingHud) then
				printStr("Using "..rocketFlavourText)
			end
			reload()
		elseif ((
			IsShapeOperated(vehicle.reloadRockets)or (playerInVehicle()and (GetInt("mouse.wheel") <0)) ) and rocketMode)then
			rocketMode = false	
			if(hasCoax)then
				currentReload = 0
			end 
			if(usingHud) then	
				printStr("Using "..mgFlavourtext)
			end
			reload()
		end 

	end
end

-- (GetInt("mouse.wheel") <0)
function checkAmmoSupply()
	if rocketMode then
		if (rocketHasAmmo()) then
			outOfAmmo = false
		else
			outOfAmmo = true
		end
	else
			if mgHasAmmo() then
				outOfAmmo = false
			else
				outOfAmmo = true
			end
	end
end

function  setMGAmmo(ammoVal)
	if ammoVal >= MGCapacity then
		MGAmmoLeft = MGCapacity
	elseif ammoVal <= 0 then
		MGAmmoLeft = 0
	else
		MGAmmoLeft  =ammoVal
	end
	
end
function setRocketAmmo( ammoVal)
	if ammoVal >= rocketCapacity then
		rocketAmmoLeft = rocketCapacity
	elseif ammoVal <= 0 then
		rocketAmmoLeft = 0
	else
		rocketAmmoLeft  =ammoVal
	end
end

function updateRocketAmmoVals()
	if(hasRockets) then
		if (hasRocketCapacity) then
			if(rocketAmmoLeft > 0)	then
				SetTag(vehicle.reloadRockets,"interact","Load "..rocketFlavourText.." Shells: "..rocketAmmoLeft.."/"..rocketCapacity)
			else
				SetTag(vehicle.reloadRockets,"interact","Out of Ammo: "..rocketAmmoLeft.."/"..rocketCapacity)
			end
		else
			SetTag(vehicle.reloadRockets,"interact","Load "..rocketFlavourText)	
		end
	end
end
function rocketHasAmmo()
	if hasRockets and ((hasRocketCapacity and rocketAmmoLeft>0)or (not hasRocketCapacity)) then
		return true
	else 
		return false
	end
end

function mgHasAmmo()
		if hasMG and ((hasMGCapacity and MGAmmoLeft>0)or (not hasMGCapacity)) then
			return true

		else 
			return false	
		end 
end
function updateMGAmmoVals()
	if (hasMG) then
		if (hasMGCapacity) then
			if(MGAmmoLeft >0) then
				SetTag(vehicle.reloadMG,"interact","Load "..mgFlavourtext.." rounds: "..MGAmmoLeft.."/"..MGCapacity)
			else
				SetTag(vehicle.reloadMG,"interact","Out of Ammo: "..MGAmmoLeft.."/"..MGCapacity)
			end
		else
			SetTag(vehicle.reloadMG,"interact","Load "..mgFlavourtext.." rounds")
		end
	end
end

function updateGunAmmoVals()
	if rocketMode then
		if(hasRocketCapacity and displayWeaponDetails)then 
			SetTag(vehicle.gun,"interact",gunStateText.."  "..rocketFlavourText.."! "..rocketAmmoLeft.."/"..rocketCapacity)
		elseif(hasRocketCapacity and rocketAmmoLeft <=0)then
				SetTag(vehicle.gun,"interact"," "..rocketFlavourText.."Out of Ammo")
				outOfAmmo = true
		else
			SetTag(vehicle.gun,"interact",gunStateText..rocketFlavourText.." !")
			
		end
	else
		if(hasMGCapacity and displayWeaponDetails) then
			SetTag(vehicle.gun,"interact",gunStateText.." "..mgFlavourtext.."! "..MGAmmoLeft.."/"..MGCapacity)
		elseif(hasMGCapacity and MGAmmoLeft <=0) then
			SetTag(vehicle.gun,"interact",mgFlavourtext.." Out of Ammo")
			outOfAmmo = true
		else
			SetTag(vehicle.gun,"interact",gunStateText.." "..mgFlavourtext.."!")
		end
	end

end

function getJointCondition()
	if( IsJointBroken(vehicle.CannonJoint) ) then
		SetString("hud.notification","joint broken")
	else
		SetString("hud.notification","joint okay")
	end
end

function craneMode()
	return HasTag(GetPlayerVehicle(),"crane")
	--body
end


function playerInVehicle()

	return HasTag(GetVehicleBody(GetPlayerVehicle()),vehicle.Vehiclename) 
end

function getPlayerShootInput()

	if not craneMode() then 
		return GetBool("mouse.pressed")
	else
		local newTrigger = #GetJointsConnectedToShape(vehicle.trigger)
		if(newTrigger ~= lastTrigger)then
			lastTrigger=newTrigger
			return true
		else

			return false
		end
	end
end


--UI FUNCS TO BE ADDED LATER WHEN I CAN BE BOTHERED
-- function crossHair()

	-- UiPush()
	-- 	UiAlign("center middle")
	-- 	UiTranslate(UiCenter(), UiMiddle());
	-- 	UiImage("LEVEL/hud/crosshair-gun.png")
	-- UiPop()
	-- body
-- end



function UiIsMousePressed()
	return  GetBool("mouse.pressed")
end

function quickFixCoords( pos )
	-- body
end

function clamp(val, lower, upper)
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

function addVector(vec1,vec2)

	vec1[1] = vec1[1] + vec2[1]
	vec1[2] = vec1[2] + vec2[2]
	vec1[3] = vec1[3] + vec2[3]
	return vec1
	-- body
end

function printloc(x)

	SetString("hud.notification",
	"X "..
	(x[1]*360)..
	" Y"..
	x[2]..
	" Z"..
	x[3]
	) -- this prints the coordinates top center of the screen  

end


function printRot(x)

	SetString("hud.notification",
	"X "..
	x[2]..
	"\nY"..
	x[3]..
	"\nZ"..
	x[4]
	) -- this prints the rotation top center of the screen  

end

function printStr(x)
	SetString("hud.notification",x)
end