weaponOverrides = {
					name 	= "name",
					weaponType 				= "weaponType",
					default = "default",
					magazines 				= {
												name = "name",
												magazineCapacity = "magazineCapacity",
												magazineCount 	= "magazineCount"

												},
					loadedMagazine 			= "loadedMagazine",
					barrels 				= 
												{
													x="x",
													y="y",
													z="z",
												},
					backBlast 				= {
												z = "z",
												force = "force"

												},
					sight					= {
													x="x",
													y="y",
													z="z",
												},
					multiBarrel 			= "multiBarrel",
					canZoom					= "canZoom",
					fireControlComputer		= "fireControlComputer",
					zoomSight				= "zoomSight",
					aimForwards				= "aimForwards",
					aimReticle 				= "aimReticle",
					highVelocityShells		= "highVelocityShells",
					cannonBlast 			= "cannonBlast",
					RPM 					= "RPM",
					reload 					= "reload",
					recoil 					= "recoil",
					dispersion 				= "dispersion",
					gunRange				= "gunRange",
					gunBias 				= "gunBias",
					elevationSpeed			= "elevationSpeed",
					smokeFactor 			= "smokeFactor",
					smokeMulti				= "smokeMulti",
					soundFile				= "soundFile",
					mouseDownSoundFile 		= "mouseDownSoundFile",
					loopSoundFile 			= "loopSoundFile",
					tailOffSound	 		= "tailOffSound",
					reloadSound 			= "reloadSound",
					reloadPlayOnce 			= "reloadPlayOnce",

}

weaponDefaults = {
	reloadSound = "MOD/sounds/weaponReload",
	refillingAmmo = "MOD/sounds/refillingAmmo",
}


weapons = {
	--- cannons

	["customcannon"]  = {
					name 	= "custom cannon",
					weaponType 				= "cannon",
					caliber 				= 125,
					magazines 					= {
											[1] = {
													name = "customShell",
													magazineCapacity = 1,
													ammoCount = 0,
													magazineCount = 10,

												},
											},
					loadedMagazine 			= 1,
					barrels 				= 
												{
													[1] = {x=0.0,y=0.0,z=0.0},
												},
					sight					= {
												[1] = {
												x=0,
												y=0.0,
												z=0.0,
													},
												},
					canZoom					= true,
					zoomSight 				= "MOD/gfx/1G46Sight.png",
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
					soundFile				= "MOD/sounds/tankshot0",
					reloadSound				= "MOD/sounds/AltTankReload",

				},


	["2A46M"]  = {
					name 	= "2A46 125 mm gun",
					weaponType 				= "cannon",
					caliber 				= 125,
					default = "125mm_HEAT",
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
					canZoom					= true,
					zoomSight 				= "MOD/gfx/1G46Sight.png",
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
					soundFile				= "MOD/sounds/tankshot0",
					reloadSound				= "MOD/sounds/AltTankReload",

				},
	["D81"]  = {
					name 	= "D81 125 mm gun",
					weaponType 				= "cannon",
					caliber 				= 125,
					default = "125mm_APFSDS",
					magazines 					= {
											[1] = {
													name = "125mm_APFSDS",
													magazineCapacity = 1,
													ammoCount = 0,
													magazineCount = 20,
												},
											[2] = {
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
					multiBarrel 			= 1,
					sight					= {
												[1] = {
												x = 3,
												y = 1.3,
												z = 0.3,
													},

												},
					canZoom					= true,
					zoomSight 				= "MOD/gfx/tpd-k1m_7.png",
					highVelocityShells		= true,
					cannonBlast 			= 10,
					RPM 					= 25,
					reload 					= 2,
					recoil 					= 1.6,
					dispersion 				= 2,
					gunRange				= 500,
					gunBias 				= -1,
					elevationSpeed			= .5,
					smokeFactor 			= 3,
					smokeMulti				= 10,
					soundFile				= "MOD/sounds/tankshot0",
					reloadSound				= "MOD/sounds/AltTankReload",

				},


	["L30A1"]  = {
					name 	= "L30A1 120 mm gun",
					weaponType 				= "cannon",
					caliber 				= 120,
					magazines 					= {
											[1] = {
													name = "L23A1",
													magazineCapacity = 1,
													ammoCount = 0,
													magazineCount = 29,
												},
											[2] = {
													name = "L31A7",
													magazineCapacity = 1,
													ammoCount = 0,
													magazineCount = 15,
												}, 
											[3] = {
													name = "L34A2",
													magazineCapacity = 1,
													ammoCount = 0,
													magazineCount = 5,
												}, 
											},
					loadedMagazine 			= 1,
					barrels 				= 
												{
													[1] = {x=0.2,y=0.2,z=-0.3},
												},
					sight					= {
												[1] = {
												x=1.9,
												y=1.3,
												z=0.3,
													},
												},
					canZoom					= true,
					zoomSight 				= "MOD/gfx/1G46Sight.png",
					multiBarrel 			= 1,
					highVelocityShells		= true,
					cannonBlast 			= 10,
					RPM 					= 20,
					reload 					= 2,
					recoil 					= 1.6,
					dispersion 				= 1,
					gunRange				= 500,
					gunBias 				= -1,
					elevationSpeed			= .5,
					smokeFactor 			= 2,
					smokeMulti				= 5,
					soundFile				= "MOD/sounds/tankshot0",
					reloadSound				= "MOD/sounds/AltTankReload",

				},
	["KWK37"]  = {
					name 	= "75mm KwK 37 gun",
					weaponType 				= "cannon",
					caliber 				= 75,
					default = "125mm_APFSDS",
					magazines 					= {
											[1] = {
													name = "PzGr39",
													magazineCapacity = 1,
													ammoCount = 0,
													magazineCount = 20,
												},
											[2] = {
													name = "Sprgr34",
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
					multiBarrel 			= 1,
					sight					= {
												[1] = {
												x = 3,
												y = 1.3,
												z = 0.3,
											},


												},
					canZoom					= true,
					highVelocityShells		= true,
					cannonBlast 			= 10,
					RPM 					= 30,
					reload 					= 2,
					recoil 					= 2,
					dispersion 				= 4,
					gunRange				= 500,
					gunBias 				= -1,
					elevationSpeed			= .5,
					smokeFactor 			= 3,
					smokeMulti				= 20,
					soundFile				= "MOD/sounds/Relic700KwK37",

				},
	["KWK37RL"]  = {
					name 	= "75mm KwK 37 gun",
					weaponType 				= "cannon",
					caliber 				= 75,
					default = "PzGr39",
					magazines 					= {
											[1] = {
													name = "PzGr39",
													magazineCapacity = 1,
													ammoCount = 0,
													magazineCount = 20,
												},
											[2] = {
													name = "Sprgr34",
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
					multiBarrel 			= 1,
					sight					= {
												[1] = {
												x = 3,
												y = 1.3,
												z = 0.3,
												},

												},
					canZoom					= true,
					highVelocityShells		= true,
					cannonBlast 			= 10,
					RPM 					= 30,
					reload 					= 2,
					recoil 					= 2,
					dispersion 				= 4,
					gunRange				= 500,
					gunBias 				= -1,
					elevationSpeed			= .5,
					smokeFactor 			= 3,
					smokeMulti				= 20,
					soundFile				= "MOD/sounds/Relic700KwK37",
					reloadSound				= "MOD/sounds/Relic700KwKReload",
					reloadPlayOnce			= true,

				},
	
	--- howitzers

	["M10HowitzerRL"]  = {
					name 	= "152mm M-10T howitzer _rl",
					weaponType 				= "cannon",
					caliber 				= 152,
					default = "152mm_HE",
					magazines 					= {
											[1] = {
													name = "152mm_HE",
													magazineCapacity = 1,
													ammoCount = 0,
													magazineCount = 15,
												},
											},
					loadedMagazine 			= 1,
					barrels 				= 
												{
													[1] = {x=0.2,y=0.2,z=-0.3},
												},
					multiBarrel 			= 1,
					sight					= {
												[1] = {
												x = 3,
												y = 1.3,
												z = 0.3,
												},

												},
					canZoom					= true,
					highVelocityShells		= true,
					cannonBlast 			= 10,
					RPM 					= 10,
					reload 					= 2,
					recoil 					= 2.5,
					dispersion 				= 20,
					gunRange				= 500,
					gunBias 				= -1,
					elevationSpeed			= .5,
					smokeFactor 			= 3,
					smokeMulti				= 20,
					soundFile				= "MOD/sounds/Relic_700_KV2Fire",
					reloadSound				= "MOD/sounds/Relic_700_tankReload",
					reloadPlayOnce			= true,
				},
	["M10Howitzer"]  = {
					name 	= "152mm M-10T howitzer",
					weaponType 				= "cannon",
					caliber 				= 152,
					default = "152mm_HE",
					magazines 					= {
											[1] = {
													name = "152mm_HE",
													magazineCapacity = 1,
													ammoCount = 0,
													magazineCount = 15,
												},
											},
					loadedMagazine 			= 1,
					barrels 				= 
												{
													[1] = {x=0.2,y=0.2,z=-0.3},
												},
					multiBarrel 			= 1,
					sight					= {
												[1] = {
												x = 3,
												y = 1.3,
												z = 0.3,
													},

												},
					canZoom					= true,
					highVelocityShells		= true,
					cannonBlast 			= 10,
					RPM 					= 10,
					reload 					= 2,
					recoil 					= 2.5,
					dispersion 				= 20,
					gunRange				= 500,
					gunBias 				= -1,
					elevationSpeed			= .5,
					smokeFactor 			= 3,
					smokeMulti				= 20,
					soundFile				= "MOD/sounds/Relic_700_KV2Fire",
				},
	["MB440mm"]  = {
					name 	= "440mm Track loaded gun",
					weaponType 				= "cannon",
					caliber 				= 152,
					default = "440mm_HE",
					magazines 					= {
											[1] = {
													name = "440mm_HE",
													magazineCapacity = 1,
													ammoCount = 0,
													magazineCount = 15,
												},
											},
					loadedMagazine 			= 1,
					barrels 				= 
												{
													[1] = {x=0.2,y=0.2,z=-0.3},
												},
					multiBarrel 			= 1,
					sight					= {
												[1] = {
												x = 3,
												y = 2,
												z = 0.3,
													},

												},
					canZoom					= true,
					highVelocityShells		= true,
					cannonBlast 			= 1000,
					RPM 					= 10,
					reload 					= 5,
					recoil 					= 2.5,
					dispersion 				= 20,
					gunRange				= 500,
					gunBias 				= -1,
					elevationSpeed			= .5,
					smokeFactor 			= 8,
					smokeMulti				= 20,
					soundFile				= "MOD/sounds/Relic_700_KV2Fire",
				},

	--- autocannons

	["2A42"]  = {
					name 	= "2A42 30 mm autocannon",
					weaponType 				= "cannon",
					caliber 				= 30,
					default = "3UOF8",
					magazines 					= {
											[1] = {
													name = "3UOF8",
													magazineCapacity = 500,
													ammoCount = 0,
													magazineCount = 2,

												},
											[2] = {
													name = "3UBR8",
													magazineCapacity = 500,
													ammoCount = 0,
													magazineCount = 2,
												},
											-- [3] = {
											-- 		name = "125mm_HE",
											-- 		magazineCapacity = 1,
											-- 		ammoCount = 0,
											-- 		magazineCount = 10,
											-- 	}, 
											},
					loadedMagazine 			= 1,
					barrels 				= 
												{
													[1] = {x=0.2,y=0.1,z=-0.5},
												},
					multiBarrel 			= 1,
					sight					= {
												[1] = {
												x = 3,
												y = 1.3,
												z = 0.3,
												},

												},
					canZoom					= true,
					zoomSight 				= "MOD/gfx/BPK-2-42.png",
					highVelocityShells		= true,
					cannonBlast 			= 10,
					RPM 					= 200,
					reload 					= 15,
					recoil 					= .6,
					dispersion 				= 20,
					gunRange				= 500,
					gunBias 				= -1,
					elevationSpeed			= .5,
					smokeFactor 			= 1,
					smokeMulti				= 3,
					soundFile   = "MOD/sounds/BMPsingle",
					mouseDownSoundFile 		=	"MOD/sounds/bmpAutoFire",
					loopSoundFile 			=	"MOD/sounds/autoFirealt",
					tailOffSound	 		=	"MOD/sounds/altTailOff",
					reloadSound				= "MOD/sounds/AltTankReload",

				},
	["OFAB-250"]  = {
					name 	= "OFAB-250",
					weaponType 				= "cannon",
					caliber 				= 325,
					magazines 					= {
											[1] = {
													name = "OFAB-250",
													magazineCapacity = 1,
													ammoCount = 0,
													magazineCount = 15,
												},
											},
					loadedMagazine 			= 1,
					barrels 				= 
												{
													[1] = {x=0,y=-1.5,z=-0.3},
												},
					multiBarrel 			= 1,
					sight					= {
												[1] = {
												x = 0,
												y = 0,
												z = -0.3,
													},

												},
					zoomSight 				= "MOD/gfx/crosshair-gun.png",
					highVelocityShells		= true,
					cannonBlast 			= 0,
					RPM 					= 5,
					reload 					= 15,
					recoil 					= 0.1,
					dispersion 				= 20,
					gunRange				= 500,
					gunBias 				= -1,
					elevationSpeed			= .5,
					smokeFactor 			= 0,
					smokeMulti				= 0,
					soundFile				= "MOD/sounds/bombRelease0",
				},

	["2A7"]  = {
					name = "23 mm 2A7 autocannons",
					weaponType 				= "cannon",
					caliber 				= 23,
					default = "B_23mm_AA",
					magazines 					= {
											[1] = {
													name = "B_23mm_AA",
													magazineCapacity = 200,
													ammoCount = 0,
													magazineCount = 10,
												},
											[2] = {
													name = "B_23mm_AA_AP",
													magazineCapacity = 200,
													ammoCount = 0,
													magazineCount = 10,
												},
											},
					loadedMagazine 			= 1,
					barrels = 
								{
									[1] = {x=.6,y=.6,z=-1.2},
									[2] = {x=0.2,y=.1,z=-1.2},
									[3] = {x=.2,y=.6,z=-1.2},
									[4] = {x=0.6,y=.1,z=-1.2},
								},
					multiBarrel 			= 1,
					sight					= {
												[1] = {
												x = 3,
												y = 1.3,
												z = 0.3,
											},


												},
					canZoom					= true,
					zoomSight 				= "MOD/gfx/zsuDUBLAR2.png",
					highVelocityShells		= true,
					RPM 					= 700,
					reload 					= 4,
					recoil 					= 0.2,
					dispersion 				= 10,
					gunRange				= 500,
					gunBias 				= -1,
					smokeFactor 			= .5,
					smokeMulti				= 1,
					soundFile   = "MOD/sounds/zsuSingle",
					mouseDownSoundFile 		=	"MOD/sounds/zsuMulti0",
					loopSoundFile 			=	"MOD/sounds/zsuFiring_long-2.ogg",
					tailOffSound	 		=	"MOD/sounds/zsuSingle",

				},
	["2A14"]  = {
					name = "23 mm 2A14 autocannons",
					weaponType 				= "cannon",
					caliber 				= 23,
					default = "B_23mm_AA",
					magazines 					= {
											[1] = {
													name = "B_23mm_AA",
													magazineCapacity = 100,
													ammoCount = 0,
													magazineCount = 10,
												},
											[2] = {
													name = "B_23mm_AA_AP",
													magazineCapacity = 200,
													ammoCount = 0,
													magazineCount = 10,
												},
											},
					loadedMagazine 			= 1,
					barrels = 
								{
									[1] = {x=0.2,y=.1,z=-1.2},
									[2] = {x=0.6,y=.1,z=-1.2},
								},
					multiBarrel 			= 1,
					sight					= {
												[1] = {
												x = 1.2,
												y = 1.3,
												z = 0.3,
												},


												},
					canZoom					= false,
					highVelocityShells		= true,
					RPM 					= 350,
					reload 					= 4,
					recoil 					= 1,
					dispersion 				= 20,
					gunRange				= 500,
					gunBias 				= -1,
					smokeFactor 			= .5,
					smokeMulti				= 1,
					soundFile   = "MOD/sounds/zsuSingle",
					mouseDownSoundFile 		=	"MOD/sounds/zsuMulti1",
					loopSoundFile 			=	"MOD/sounds/zsuFiring_long-2.ogg",
					tailOffSound	 		=	"MOD/sounds/zsuSingle",

				},	
	["M230"]  = {
					name = "30 mm M230",
					weaponType 				= "cannon",
					caliber 				= 30,
					magazines 					= {
											[1] = {
													name = "B_30x113mm_M789_HEDP",
													magazineCapacity = 250,
													ammoCount = 0,
													magazineCount = 10,
												},
											},
					loadedMagazine 			= 1,
					barrels = 
								{
									[1] = {x=0,y=-.3,z=-0.5},
								},
					multiBarrel 			= 1,
					sight					= {
												[1] = {
												x = 0,
												y = 0.5,
												z = 0.8,
												},


												},
					canZoom					= true,
					zoomSight 				= "MOD/gfx/chopperScope12.png",
					fireControlComputer		= "MOD/gfx/TEDAC1.png",
					highVelocityShells		= true,
					RPM 					= 420,
					reload 					= 4,
					recoil 					= 1,
					dispersion 				= 4,
					gunRange				= 500,
					gunBias 				= -1,
					smokeFactor 			= .5,
					smokeMulti				= 1,
					soundFile   = "MOD/sounds/autoCannonSingle",
					loopSoundFile 			=	"MOD/sounds/autoCannon420RPM.ogg",
					tailOffSound	 		=	"MOD/sounds/autocannonTailOff",

				},	["GSh-30-2"]  = {
					name = "30 mm GSh-30-2 autocannon",
					weaponType 				= "cannon",
					caliber 				= 23,
					magazines 					= {
											[1] = {
													name = "OFZ_30mm_HE",
													magazineCapacity = 100,
													ammoCount = 0,
													magazineCount = 10,
												},
											[2] = {
													name = "BR_30mm_AP",
													magazineCapacity = 200,
													ammoCount = 0,
													magazineCount = 10,
												},
											},
					loadedMagazine 			= 1,
					barrels = 
								{
									[1] = {x=0.2,y=.3,z=-0.5},
									[2] = {x=0.2,y=.5,z=-0.5},
								},
					multiBarrel 			= 1,
					sight					= {
												[1] = {
												x = 0 ,
												y = 0,
												z = -0.6,
												},


												},
					canZoom					= true,
					zoomSight 				= "MOD/gfx/chopperScope.png",
					highVelocityShells		= true,
					RPM 					= 420,
					reload 					= 4,
					recoil 					= 1,
					dispersion 				= 4,
					gunRange				= 500,
					gunBias 				= -1,
					smokeFactor 			= .5,
					smokeMulti				= 1,
					soundFile   = "MOD/sounds/autoCannonSingle",
					loopSoundFile 			=	"MOD/sounds/autoCannon420RPM.ogg",
					tailOffSound	 		=	"MOD/sounds/autocannonTailOff",

				},
		["SPG9"]  = {
					name 	= "SPG-9",
					weaponType 				= "rocket",
					caliber 				= 73,
					magazines 					= {
											[1] = {
													name = "PG9_AT",
													magazineCapacity = 1,
													ammoCount = 0,
													magazineCount = 10,

												},
											[2] = {
													name = "OG9_HE",
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
					multiBarrel 			= 1,
					sight					= {
												[1] = {
												x = 0.6,
												y = 1.8,
												z = 0.2,
													},


												},
					backBlast				= 
												{
													[1] = {z=4.3,force=5},
												},
					canZoom					= true,
					zoomSight 				= "MOD/gfx/spg9-sight.png",
					highVelocityShells		= true,
					RPM 					= 20,
					reload 					= 2,
					recoil 					= 0.2,
					dispersion 				= 20,
					gunRange				= 500,
					gunBias 				= -1,
					elevationSpeed			= .5,
					smokeFactor 			= 2,
					smokeMulti				= 10,
					soundFile				= "MOD/sounds/recoilessRifle0",

				},	
		["LowVelRocket"]  = {
					name 	= "SPG-9",
					weaponType 				= "rocket",
					caliber 				= 73,
					magazines 					= {
											[1] = {
													name = "PG9_AT",
													magazineCapacity = 1,
													ammoCount = 0,
													magazineCount = 10,

												},
											[2] = {
													name = "OG9_HE",
													magazineCapacity = 1,
													ammoCount = 0,
													magazineCount = 10,
												},

											[3] = {
													name = "RocketLowVelocity",
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
					multiBarrel 			= 1,
					sight					= {
												[1] = {
												x = 0.6,
												y = 1.8,
												z = 0.2,
													},


												},
					backBlast				= 
												{
													[1] = {z=4.3,force=5},
												},
					canZoom					= true,
					zoomSight 				= "MOD/gfx/spg9-sight.png",
					highVelocityShells		= true,
					RPM 					= 20,
					reload 					= 2,
					recoil 					= 0.2,
					dispersion 				= 20,
					gunRange				= 500,
					gunBias 				= -1,
					elevationSpeed			= .8,
					smokeFactor 			= 2,
					smokeMulti				= 10,
					soundFile				= "MOD/sounds/recoilessRifle0",

				},	
		["9M133"]  = {
					name 	= "9M133 Kornet",
					weaponType 				= "atgm",
					caliber 				= 73,
					magazines 					= {
											[1] = {
													name = "9M133M-2",
													magazineCapacity = 1,
													ammoCount = 0,
													magazineCount = 10,

												},
											},
					loadedMagazine 			= 1,
					barrels 				= 
												{
													[1] = {x=0.3,y=0.2,z=-0.3},
												},
					multiBarrel 			= 1,
					sight					= {
												[1] = {
												x = 0.6,
												y = 1.2,
												z = -.7,
													},


												},
					backBlast				= 
												{
													[1] = {z=1.3,force=5},
												},
					canZoom					= true,
					aimForwards				= true,
					zoomSight 				= "MOD/gfx/KORNETsight.png",
					highVelocityShells		= true,
					RPM 					= 20,
					reload 					= 2,
					recoil 					= 0,
					dispersion 				= 20,
					gunRange				= 500,
					gunBias 				= -1,
					elevationSpeed			= 0.8,
					smokeFactor 			= 2,
					smokeMulti				= 10,
					soundFile				= "MOD/sounds/atgm00",
				},
		["HellfireLauncher"]  = {
					name 	= "Hellfire Launcher",
					weaponType 				= "atgm",
					caliber 				= 180,
					magazines 					= {
											[1] = {
													name = "M_Hellfire_AT",
													magazineCapacity = 1,
													ammoCount = 0,
													magazineCount = 8,

												},
											[2] = {
													name = "M_Hellfire_AP",
													magazineCapacity = 1,
													ammoCount = 0,
													magazineCount = 8,

												},
											},
					loadedMagazine 			= 1,
					barrels 				= 
												{
													[1] = {x=0.2,y=0.1,z=-1.5},
													[2] = {x=0.3,y=0.1,z=-1.5},
													[3] = {x=0.2,y=0.2,z=-1.5},
													[4] = {x=0.3,y=0.2,z=-1.5},
												},
					multiBarrel 			= 1,
					backBlast				= 
												{
													[1] = {z=1.45,force=5},
													[2] = {z=1.45,force=5},
													[3] = {z=1.45,force=5},
													[4] = {z=1.43,force=5},
												},
					sight					= {
												[1] = {
												x = 0.2,
												y = 0.5,
												z = 0.8,
											},


												},
					canZoom					= true,
					zoomSight 				= "MOD/gfx/chopperScope9.png",
					fireControlComputer		= "MOD/gfx/TEDAC1.png",
					aimForwards				= true,
					highVelocityShells		= true,
					RPM 					= 6,
					reload 					= 15,
					recoil 					= 0,
					dispersion 				= 20,
					gunRange				= 500,
					gunBias 				= -1,
					elevationSpeed			= 0.8,
					smokeFactor 			= 2,
					smokeMulti				= 10,
					soundFile				= "MOD/sounds/atgm00",
				},					
		["UB32"]  = {
					name 	= "UB-32",
					weaponType 				= "rocket",
					caliber 				= 55,
					magazines 					= {
											[1] = {
													name = "S-5M",
													magazineCapacity = 32,
													ammoCount = 0,
													magazineCount = 10,

												},
											},
					loadedMagazine 			= 1,
					barrels 				= 
												{
													[1] = {x=0.2,y=0.1,z=-0.5},
													[2] = {x=0.3,y=0.1,z=-0.5},
													[3] = {x=0.2,y=0.2,z=-0.5},
													[4] = {x=0.3,y=0.2,z=-0.5},
													[5] = {x=0.2,y=0.3,z=-0.5},
													[6] = {x=0.3,y=0.3,z=-0.5},
													[7] = {x=0.2,y=0.4,z=-0.5},
													[8] = {x=0.3,y=0.4,z=-0.5},
													[9] = {x=0.2,y=0.5,z=-0.5},
													[10] = {x=0.2,y=0.5,z=-0.5},
													[11] = {x=0.2,y=0.4,z=-0.5},
													[12] = {x=0.3,y=0.5,z=-0.5},
													[13] = {x=0.3,y=0.4,z=-0.5},
													[14] = {x=0.4,y=0.5,z=-0.5},
													[15] = {x=0.4,y=0.4,z=-0.5},
													[16] = {x=0.5,y=0.5,z=-0.5},
													[17] = {x=0.5,y=0.4,z=-0.5},
													[18] = {x=0.6,y=0.5,z=-0.5},
													[19] = {x=0.6,y=0.4,z=-.5},
													[20] = {x=0.5,y=0.4,z=-.5},
													[21] = {x=0.4,y=0.3,z=-.5},
													[22] = {x=0.5,y=0.3,z=-.5},
													[23] = {x=0.4,y=0.2,z=-.5},
													[24] = {x=0.5,y=0.2,z=-.5},
													[25] = {x=0.4,y=0.1,z=-.5},
													[26] = {x=0.5,y=0.2,z=-.5},
													[27] = {x=0.6,y=0.1,z=-.5},
													[28] = {x=0.5,y=0.2,z=-.5},
													[29] = {x=0.5,y=0.1,z=-.5},
													[30] = {x=0.4,y=0.2,z=-.5},
													[31] = {x=0.4,y=0.1,z=-.5},
													[32] = {x=0.3,y=0.2,z=-.5},
												},
					multiBarrel 			= 1,
					backBlast				= 
												{
													[1] = {z=1.45,force=5},
													[2] = {z=1.45,force=5},
													[3] = {z=1.45,force=5},
													[4] = {z=1.43,force=5},
													[5] = {z=1.43,force=5},
													[6] = {z=1.43,force=5},
													[7] = {z=1.43,force=5},
													[8] = {z=1.43,force=5},
													[9] = {z=1.43,force=5},
													[10] = {z=1.43,force=5},
													[11] = {z=1.43,force=5},
													[12] = {z=1.43,force=5},
													[13] = {z=1.43,force=5},
													[14] = {z=1.43,force=5},
													[15] = {z=1.45,force=5},
													[16] = {z=1.45,force=5},
													[17] = {z=1.45,force=5},
													[18] = {z=1.43,force=5},
													[19] = {z=1.43,force=5},
													[20] = {z=1.43,force=5},
													[21] = {z=1.43,force=5},
													[22] = {z=1.43,force=5},
													[23] = {z=1.43,force=5},
													[24] = {z=1.43,force=5},
													[25] = {z=1.43,force=5},
													[26] = {z=1.43,force=5},
													[27] = {z=1.43,force=5},
													[28] = {z=1.43,force=5},
													[29] = {z=1.43,force=5},
													[30] = {z=1.43,force=5},
													[31] = {z=1.43,force=5},
													[32] = {z=1.43,force=5},
												},
					sight					= {
												[1] = {
												x = 0 ,
												y = 0,
												z = -0.6,
											},


												},
					canZoom					= true,
					zoomSight 				= "MOD/gfx/chopperScope.png",
					highVelocityShells		= true,
					RPM 					= 400,
					reload 					= 5,
					recoil 					= 0.5,
					dispersion 				= 30,
					gunRange				= 500,
					gunBias 				= -1,
					elevationSpeed			= 9.5,
					smokeFactor 			= 1,
					smokeMulti				= 3,
					soundFile				= "MOD/sounds/recoilessRifle0",

				},			
		["B-8M1"]  = {
					name 	= "B-8M1",
					weaponType 				= "rocket",
					caliber 				= 80,
					magazines 					= {
											[1] = {
													name = "S-5",
													magazineCapacity = 20,
													ammoCount = 0,
													magazineCount = 10,

												},
											},
					loadedMagazine 			= 1,
					barrels 				= 
												{
													[1] = {x=0.2,y=0.1,z=-0.5},
													[2] = {x=0.3,y=0.1,z=-0.5},
													[3] = {x=0.2,y=0.2,z=-0.5},
													[4] = {x=0.3,y=0.2,z=-0.5},
													[5] = {x=0.2,y=0.3,z=-0.5},
													[6] = {x=0.3,y=0.3,z=-0.5},
													[7] = {x=0.2,y=0.4,z=-0.5},
													[8] = {x=0.3,y=0.4,z=-0.5},
													[9] = {x=0.2,y=0.5,z=-0.5},
													[10] = {x=0.2,y=0.5,z=-0.5},
													[11] = {x=0.2,y=0.4,z=-0.5},
													[12] = {x=0.3,y=0.5,z=-0.5},
													[13] = {x=0.3,y=0.4,z=-0.5},
													[14] = {x=0.4,y=0.5,z=-0.5},
													[15] = {x=0.4,y=0.4,z=-0.5},
													[16] = {x=0.5,y=0.5,z=-0.5},
													[17] = {x=0.5,y=0.4,z=-0.5},
													[18] = {x=0.6,y=0.5,z=-0.5},
													[19] = {x=0.6,y=0.4,z=-.5},
													[20] = {x=0.5,y=0.4,z=-.5},
												},
					multiBarrel 			= 1,
					backBlast				= 
												{
													[1] = {z=1.45,force=5},
													[2] = {z=1.45,force=5},
													[3] = {z=1.45,force=5},
													[4] = {z=1.43,force=5},
													[5] = {z=1.43,force=5},
													[6] = {z=1.43,force=5},
													[7] = {z=1.43,force=5},
													[8] = {z=1.43,force=5},
													[9] = {z=1.43,force=5},
													[10] = {z=1.43,force=5},
													[11] = {z=1.43,force=5},
													[12] = {z=1.43,force=5},
													[13] = {z=1.43,force=5},
													[14] = {z=1.43,force=5},
													[15] = {z=1.45,force=5},
													[16] = {z=1.45,force=5},
													[17] = {z=1.45,force=5},
													[18] = {z=1.43,force=5},
													[19] = {z=1.43,force=5},
													[20] = {z=1.43,force=5},
												},
					sight					= {
												[1] = {
												x = 2.2,
												y = 1.3,
												z = 0.3,
											},


												},
					canZoom					= true,
					zoomSight 				= "MOD/gfx/chopperScope.png",
					highVelocityShells		= true,
					RPM 					= 400,
					reload 					= 5,
					recoil 					= 0.5,
					dispersion 				= 30,
					gunRange				= 500,
					gunBias 				= -1,
					elevationSpeed			= 9.5,
					smokeFactor 			= 1,
					smokeMulti				= 3,
					soundFile				= "MOD/sounds/recoilessRifle0",

				},				
		["B-13L1"]  = {
					name 	= "B-13L1",
					weaponType 				= "rocket",
					caliber 				= 122,
					magazines 					= {
											[1] = {
													name = "S-13",
													magazineCapacity = 5,
													ammoCount = 0,
													magazineCount = 10,

												},
											},
					loadedMagazine 			= 1,
					barrels 				= 
												{
													[1] = {x=0.2,y=0.1,z=-0.5},
													[2] = {x=0.3,y=0.1,z=-0.5},
													[3] = {x=0.2,y=0.2,z=-0.5},
													[4] = {x=0.3,y=0.2,z=-0.5},
													[5] = {x=0.2,y=0.3,z=-0.5},
												},
					multiBarrel 			= 1,
					backBlast				= 
												{
													[1] = {z=1.45,force=5},
													[2] = {z=1.45,force=5},
													[3] = {z=1.45,force=5},
													[4] = {z=1.43,force=5},
													[5] = {z=1.43,force=5},
												},
					sight					= {
												[1] = {
												x = 0,
												y = 0,
												z = -0.7,
											},


												},
					canZoom					= true,
					zoomSight 				= "MOD/gfx/chopperScope.png",
					highVelocityShells		= true,
					RPM 					= 300,
					reload 					= 5,
					recoil 					= 0.5,
					dispersion 				= 30,
					gunRange				= 500,
					gunBias 				= -1,
					elevationSpeed			= 9.5,
					smokeFactor 			= 2,
					smokeMulti				= 6,
					soundFile				= "MOD/sounds/recoilessRifle0",

				},			
		["M261"]  = {
					name 	= "M261",
					weaponType 				= "rocket",
					caliber 				= 80,
					magazines 					= {
											[1] = {
													name = "R_Hydra_HE",
													magazineCapacity = 19,
													ammoCount = 0,
													magazineCount = 10,

												},
											},
					loadedMagazine 			= 1,
					barrels 				= 
												{
													[1] = {x=0.2,y=0.4,z=-0.5},
													[2] = {x=0.3,y=0.4,z=-0.5},
													[3] = {x=0.2,y=0.5,z=-0.5},
													[4] = {x=0.3,y=0.5,z=-0.5},
													[5] = {x=0.2,y=0.6,z=-0.5},
													[6] = {x=0.3,y=0.6,z=-0.5},
													[7] = {x=0.2,y=0.7,z=-0.5},
													[8] = {x=0.3,y=0.7,z=-0.5},
													[9] = {x=0.2,y=0.8,z=-0.5},
													[10] = {x=0.2,y=0.8,z=-0.5},
													[11] = {x=0.2,y=0.7,z=-0.5},
													[12] = {x=0.3,y=0.8,z=-0.5},
													[13] = {x=0.3,y=0.7,z=-0.5},
													[14] = {x=0.4,y=0.8,z=-0.5},
													[15] = {x=0.4,y=0.7,z=-0.5},
													[16] = {x=0.5,y=0.8,z=-0.5},
													[17] = {x=0.5,y=0.6,z=-0.5},
													[18] = {x=0.6,y=0.5,z=-0.5},
													[19] = {x=0.6,y=0.4,z=-.5},
												},
					multiBarrel 			= 1,
					backBlast				= 
												{
													[1] = {z=1.45,force=5},
													[2] = {z=1.45,force=5},
													[3] = {z=1.45,force=5},
													[4] = {z=1.43,force=5},
													[5] = {z=1.43,force=5},
													[6] = {z=1.43,force=5},
													[7] = {z=1.43,force=5},
													[8] = {z=1.43,force=5},
													[9] = {z=1.43,force=5},
													[10] = {z=1.43,force=5},
													[11] = {z=1.43,force=5},
													[12] = {z=1.43,force=5},
													[13] = {z=1.43,force=5},
													[14] = {z=1.43,force=5},
													[15] = {z=1.45,force=5},
													[16] = {z=1.45,force=5},
													[17] = {z=1.45,force=5},
													[18] = {z=1.43,force=5},
													[19] = {z=1.43,force=5},
												},
					sight					= {
												[1] = {
												x = 0,
												y = 0.5,
												z = 0.8,
											},


												},
					canZoom					= true,
					zoomSight 				= "MOD/gfx/chopperScope9.png",
					fireControlComputer		= "MOD/gfx/TEDAC1.png",
					highVelocityShells		= true,
					RPM 					= 400,
					reload 					= 5,
					recoil 					= 0.5,
					dispersion 				= 30,
					gunRange				= 500,
					gunBias 				= -1,
					elevationSpeed			= 9.5,
					smokeFactor 			= 1,
					smokeMulti				= 2,
					soundFile				= "MOD/sounds/recoilessRifle0",

				},			


		["TYPE63"]  = {
					name 	= "Type 63",
					weaponType 				= "rocket",
					caliber 				= 106.7,
					magazines 					= {
											[1] = {
													name = "107_HE_Close",
													magazineCapacity = 14,
													ammoCount = 0,
													magazineCount = 10,

												},
											[2] = {
													name = "107_HE_Mid",
													magazineCapacity = 14,
													ammoCount = 0,
													magazineCount = 10,
												},
											[3] = {
													name = "107_HE_long",
													magazineCapacity = 14,
													ammoCount = 0,
													magazineCount = 10,

												},
											},
					loadedMagazine 			= 1,
					barrels 				= 
												{
													[1] = {x=0.2,y=0.2,z=-0.3},
													[2] = {x=0.4,y=0.2,z=-0.3},
													[3] = {x=0.6,y=0.2,z=-0.3},
													[4] = {x=0.8,y=0.2,z=-0.3},
													[5] = {x=1.0,y=0.2,z=-0.3},
													[6] = {x=1.2,y=0.2,z=-0.3},
													[7] = {x=1.4,y=0.2,z=-0.3},
													[8] = {x=0.2,y=0.5,z=-0.3},
													[9] = {x=0.4,y=0.5,z=-0.3},
													[10] = {x=0.6,y=0.5,z=-0.3},
													[11] = {x=0.8,y=0.5,z=-0.3},
													[12] = {x=1.0,y=0.5,z=-0.3},
													[13] = {x=1.2,y=0.5,z=-0.3},
													[14] = {x=1.4,y=0.5,z=-0.3},
												},
					multiBarrel 			= 1,
					backBlast				= 
												{
													[1] = {z=1.45,force=5},
													[2] = {z=1.45,force=5},
													[3] = {z=1.45,force=5},
													[4] = {z=1.43,force=5},
													[5] = {z=1.43,force=5},
													[6] = {z=1.43,force=5},
													[7] = {z=1.43,force=5},
													[8] = {z=1.43,force=5},
													[9] = {z=1.43,force=5},
													[10] = {z=1.43,force=5},
													[11] = {z=1.43,force=5},
													[12] = {z=1.43,force=5},
													[13] = {z=1.43,force=5},
													[14] = {z=1.43,force=5},
												},
					sight					= {
												[1] = {
												x = 2.2,
												y = 1.3,
												z = 0.3,
											},


												},
					canZoom					= true,
					highVelocityShells		= true,
					RPM 					= 400,
					reload 					= 5,
					recoil 					= 0.5,
					dispersion 				= 30,
					gunRange				= 500,
					gunBias 				= -1,
					elevationSpeed			= 9.5,
					smokeFactor 			= 2,
					smokeMulti				= 10,
					soundFile				= "MOD/sounds/recoilessRifle0",

				},
		["BM13"]  = {
					name 	= "BM-13",
					weaponType 				= "rocket",
					caliber 				= 132,
					magazines 					= {
											[1] = {
													name = "132mm_HE",
													magazineCapacity = 16,
													ammoCount = 0,
													magazineCount = 10,

												},
											},
					loadedMagazine 			= 1,
					barrels 				= 
												{
													[1] = {x=0.0,y=1.5,z=-0.6},
													[2] = {x=0.3,y=1.5,z=-0.6},
													[3] = {x=0.6,y=1.5,z=-0.6},
													[4] = {x=0.9,y=1.5,z=-0.6},
													[5] = {x=1.1,y=1.5,z=-0.6},
													[6] = {x=1.5,y=1.5,z=-0.6},
													[7] = {x=1.8,y=1.5,z=-0.6},
													[8] = {x=2.2,y=1.5,z=-0.6},
													[9] = {x=0.0,y=1.7,z=-0.6},
													[10] = {x=0.3,y=1.7,z=-0.6},
													[11] = {x=0.6,y=1.7,z=-0.6},
													[12] = {x=0.8,y=1.7,z=-0.6},
													[13] = {x=1.1,y=1.7,z=-0.6},
													[14] = {x=0.4,y=1.7,z=-0.6},
													[15] = {x=1.7,y=1.7,z=-0.6},
													[16] = {x=2.2,y=1.7,z=-0.6},
												},
					multiBarrel 			= 1,
					backBlast				= 
												{
													[1] = {z=5.0,force=5},
													[2] = {z=5.0,force=5},
													[3] = {z=5.0,force=5},
													[4] = {z=5.0,force=5},
													[5] = {z=5.0,force=5},
													[6] = {z=5.0,force=5},
													[7] = {z=5.0,force=5},
													[8] = {z=5.0,force=5},
													[9] = {z=5.0,force=5},
													[10] = {z=5.0,force=5},
													[11] = {z=5.0,force=5},
													[12] = {z=5.0,force=5},
													[13] = {z=5.0,force=5},
													[14] = {z=5.0,force=5},
												},
					sight					= {
												[1] = {
												x = 2.3,
												y = 2.3,
												z = 0.3,
													},


												},
					canZoom					= true,
					highVelocityShells		= true,
					RPM 					= 150,
					reload 					= 5,
					recoil 					= 0.3,
					dispersion 				= 30,
					gunRange				= 500,
					gunBias 				= -1,
					elevationSpeed			= 0.5,
					smokeFactor 			= 2,
					smokeMulti				= 10,
					soundFile				= "MOD/sounds/mlrs",

				},
		["BM14"]  = {
					name 	= "BM-14",
					weaponType 				= "rocket",
					caliber 				= 122,
					magazines 					= {
											[1] = {
													name = "122mm_HE_Close",
													magazineCapacity = 14,
													ammoCount = 0,
													magazineCount = 10,

												},
											[2] = {
													name = "122mm_HE_Mid",
													magazineCapacity = 14,
													ammoCount = 0,
													magazineCount = 10,

												},
											[3] = {
													name = "122mm_HE_long",
													magazineCapacity = 14,
													ammoCount = 0,
													magazineCount = 10,

												},
											},
					loadedMagazine 			= 1,
					barrels 				= 
												{
													[1] = {x=0.2,y=0.5,z=-0.6},
													[2] = {x=0.4,y=0.5,z=-0.6},
													[3] = {x=0.6,y=0.5,z=-0.6},
													[4] = {x=0.8,y=0.5,z=-0.6},
													[5] = {x=1.0,y=0.5,z=-0.6},
													[6] = {x=1.2,y=0.5,z=-0.6},
													[7] = {x=1.4,y=0.5,z=-0.6},
													[8] = {x=0.2,y=0.7,z=-0.6},
													[9] = {x=0.4,y=0.7,z=-0.6},
													[10] = {x=0.6,y=0.7,z=-0.6},
													[11] = {x=0.8,y=0.7,z=-0.6},
													[12] = {x=1.0,y=0.7,z=-0.6},
													[13] = {x=1.2,y=0.7,z=-0.6},
													[14] = {x=1.4,y=0.7,z=-0.6},
												},
					multiBarrel 			= 1,
					backBlast				= 
												{
													[1] = {z=3.0,force=5},
													[2] = {z=3.0,force=5},
													[3] = {z=3.0,force=5},
													[4] = {z=3.0,force=5},
													[5] = {z=3.0,force=5},
													[6] = {z=3.0,force=5},
													[7] = {z=3.0,force=5},
													[8] = {z=3.0,force=5},
													[9] = {z=3.0,force=5},
													[10] = {z=3.0,force=5},
													[11] = {z=3.0,force=5},
													[12] = {z=3.0,force=5},
													[13] = {z=3.0,force=5},
													[14] = {z=3.0,force=5},
												},
					sight					= {
												[1] = {
												x = 2.3,
												y = 1.3,
												z = 0.3,
													},


												},
					canZoom					= true,
					highVelocityShells		= true,
					RPM 					= 100,
					reload 					= 5,
					recoil 					= 0.8,
					dispersion 				= 25,
					gunRange				= 500,
					gunBias 				= -1,
					elevationSpeed			= 3.3,
					smokeFactor 			= 2,
					smokeMulti				= 10,
					soundFile				= "MOD/sounds/mlrs",

				},
	["PKT"]		= {
					name 	= "PKT",
					caliber 				= 7.62,
					weaponType 				= "MGun",
					loadedMagazine 			= 1,
					magazines 					= {
											[1] = {
													name = "B_762x54_Ball",
													magazineCapacity = 250,
													ammoCount = 0,
													magazineCount = 20,
												},
											},

				barrels 				= 
											{
												[1] = {x=0,y=0.2,z=-0.6},
											},
				multiBarrel 			= 1,
				sight					= {
												[1] = {
											x = 0.4,
											y = 1,
											z = 2,
												},


											},
				canZoom					= false,
				RPM 					= 750,
				reload 					= 4,
				magazineCapacity 		= 100,
				recoil 					= 0.02,
				dispersion 				= 3,
				gunRange				= 1000,
				elevationSpeed			= 3,
				smokeFactor 			= .5,
				smokeMulti				= 1,
				soundFile 				=	"MOD/sounds/lmgSingle0",
				mouseDownSoundFile 		=	"MOD/sounds/lmgBurst0",

				},
	["DSHK"]		= {
					name 	= "DSHK",
					caliber 				= 12.7,
					weaponType 				= "MGun",
					loadedMagazine 			= 1,
					magazines 					= {
											[1] = {
													name = "B_127x107_Ball",
													magazineCapacity = 50,
													ammoCount = 0,
													magazineCount = 5,
												},
											},

				barrels 				= 
											{
												[1] = {x=0,y=0.2,z=-0.6},
											},
				multiBarrel 			= 1,

				sight					= {
												[1] = {
											x = .25,
											y = 2.,
											z = 1.8,
												},


											},
				canZoom					= false,
				RPM 					= 360,
				reload 					= 4,
				magazineCapacity 		= 100,
				recoil 					= 0.2,
				dispersion 				= 6,
				gunRange				= 3000,
				smokeFactor 			= .5,
				smokeMulti				= 1,
				soundFile 				=	"MOD/sounds/HeavySingleShot",
				mouseDownSoundFile 		=	"MOD/sounds/HeavyAutoFire",
				loopSoundFile			= 	"MOD/sounds/HeavyAutoFire",
				tailOffSound	 		=	"MOD/sounds/HeavySingleShot",				
				},
	["KORD"]		= {
					name 	= "KORD",
					caliber 				= 12.7,
					weaponType 				= "MGun",
					loadedMagazine 			= 1,
					magazines 					= {
											[1] = {
													name = "B_127x107_Ball",
													magazineCapacity = 150,
													ammoCount = 0,
													magazineCount = 5,
												},
											[2] = {
													name = "B_127x107_Ball_INC",
													magazineCapacity = 150,
													ammoCount = 0,
													magazineCount = 5,
												},
											},

				barrels 				= 
											{
												[1] = {x=0.3,y=0.5,z=-0.6},
											},
				multiBarrel 			= 1,

				sight					= {
												[1] = {
											x = .25,
											y = 1.2,
											z = 1.8,
												},


											},
				canZoom					= false,
				aimForwards				= true,
				RPM 					= 550,
				reload 					= 4,
				magazineCapacity 		= 100,
				recoil 					= 0.2,
				dispersion 				= 12,
				gunRange				= 3000,
				elevationSpeed			= 3.4,
				smokeFactor 			= .5,
				smokeMulti				= 1,
				soundFile 				=	"MOD/sounds/HeavySingleShot",
				mouseDownSoundFile 		=	"MOD/sounds/HeavyAutoFire",
				loopSoundFile			= 	"MOD/sounds/HeavyAutoFire",
				tailOffSound	 		=	"MOD/sounds/HeavySingleShot",				
				},

	["t90_smoke_turret"] = {
				name 					= "Smoke Dischargers",
				type 					= "projector",
				barrels = {	
					[1] = {x=3.8,y=0.2,z=1.3		,x_angle = 0,y_angle = -15},
					[2] = {x=3.8,y=0.3,z=1.5		,x_angle = 15,y_angle = -20},
					[3] = {x=3.8,y=0.4,z=1.6	,x_angle = 30,y_angle = -25},
					[4] = {x=-0.0,y=0.2,z=1.6	,x_angle = -0,y_angle = -15},
					[5] = {x=-0.0,y=0.3,z=1.6	,x_angle = -15,y_angle = -20},
					[6] = {x=-0.0,y=0.4,z=1.6	,x_angle = -30,y_angle = -25},

				},
				multiBarrel = 1,
				RPM 					= 100,
				maxDist					= 10,
				velocity 				= 3,
				magazineCapacity 		= 6,
				reload 					= 10,
				smokeFactor 			= 4,
				smokeMulti				= 3,




		},
	["t72_smokeGenerator"] = {
				name 					= "Smoke Generator",
				type 					= "generator",
				barrels = {	

					[1] = {x=2.1,y=1.6,z=-1.5,x_angle = 90,y_angle = 15,z_angle = 0,},

				},
				RPM 					= 100,
				maxDist					= 10,
				velocity 				= 3,
				magazineCapacity 		= 6,
				reload 					= 10,
				smokeFactor 			= 4,
				smokeMulti				= 3,
				smokeTime 				= 10,




		},
	}