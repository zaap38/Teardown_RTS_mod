
sampleGun = {
	["sample"]  = {
					name 	= "sample Name",
					weaponType 				= "cannon",
					caliber 				= 125,
					magazines 					= {
											[1] = {
													name = "125mm_HEAT",
													magazineCapacity = 1,
													ammoCount = 0,
													magazineCount = 10,

												},
											[2] = {
													name = "125mm_APFSDS",
													magazineCapacity = 1,
													ammoCount = 0,
													magazineCount = 10,
												},
											[3] = {
													name = "125mm_HE",
													magazineCapacity = 1,
													ammoCount = 0,
													magazineCount = 10,
												}, 
											},
					loadedMagazine 			= 1,
					barrels 				= 
												{
													[1] = {x=0.2,y=0.2,z=-0.3},
												},
					sight					= {
												[1] = {
												x=3,
												y=1.3,
												z=0.3,
													},
												},
					backBlast				= 
												{
													[1] = {z=1.45,force=5},
												},
					canZoom					= true,
					zoomSight 				= "LEVEL/YOURTANK/gfx/1G46Sight.png",
					multiBarrel 			= 1,
					highVelocityShells		= true,
					cannonBlast 			= 10,
					RPM 					= 30,
					reload 					= 2,
					recoil 					= 1.6,
					dispersion 				= 1,
					gunRange				= 500,
					gunBias 				= -1,
					elevationSpeed			= .5,
					smokeFactor 			= 2,
					smokeMulti				= 5,
					soundFile				= "LEVEL/YOURTANK/sounds/tankshot0",
					reloadSound				= "LEVEL/YOURTANK/sounds/AltTankReload",
					mouseDownSoundFile 		= "LEVEL/YOURTANK/sounds/bmpAutoFire",
					loopSoundFile 			= "LEVEL/YOURTANK/sounds/autoFirealt",
					tailOffSound	 		= "LEVEL/YOURTANK/sounds/altTailOff",
					reloadSound				= "LEVEL/YOURTANK/sounds/AltTankReload",

				},


}


SampleShell = {
	["125mm_HEAT"] = {
				name = "125mm HEAT",
				caliber 				= 125,
				velocity				= 220,
				explosionSize			= 1.2,
				maxPenDepth 			= 1.2,
				timeToLive 				= 7,
				launcher				= "cannon",
				payload					= "explosive",
				shellWidth				= 0.5,
				shellHeight				= 1.5,
				r						= 0.3,
				g						= 0.6, 
				b						= 0.3,
				tracer 					= 1,
				tracerL					= 3,
				tracerW					= 2,
				tracerR					= 1.8,
				tracerG					= 1.0, 
				tracerB					= 1.0,  
				shellSpriteName			= "LEVEL/YOURTANK/gfx/shellModel2.png",
				shellSpriteRearName		= "LEVEL/YOURTANK/gfx/shellRear2.png",
					
			},

	
}