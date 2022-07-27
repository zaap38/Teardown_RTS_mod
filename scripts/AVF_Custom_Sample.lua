

vehicleParts = {
	chassis = {

	},
	turrets = {

		["turret1"] = {
			smokeLauncher = {launcherType="t90_smoke_turret", group="smoke"}

		}

	},
	guns = {
		["tankCannon1"] = {	
			name="Bad_Boy_Disco",
			magazines = {
						[1] = {name="APHE",
						maxPenDepth = 1.2,
					},
						[2] = {name="HE-I",
						maxPenDepth = 1.2,
						payload = "HE-I",
					},
					--- makes third shell very slow and not effected by dispersion or gravity
					[3] = {
											velocity = 20,
											gravityCoef=0,
											dispersionCoef=0,				

											
											},
			},
			barrels		= {
							[1] = {
								x = 0,
								y = 0,
								z = 0,
							},

			
				zoomSight 				= "LEVEL/T90/gfx/tpd-k1m_7.png"
			}
			},
		["tankCoax1"] = {
					name						= "KPV",
					magazines 					= {
											[1] = {
												name = "14.5×114mm",
												maxPenDepth = 0.8,
												calibre = 14.5,
												maxPenDepth = 0.5,
												payload = "HE-I",
												magazineCapacity = 500,
												rpm= 100,
												tracer 					= 1,
												tracerL					= 3,
												tracerW					= 2,
												tracerR					= 1.0,
												tracerG					= 1.9, 
												tracerB					= 1.0,				

												
												},
											},
											soundFile 				=	"LEVEL/T90/sounds/HeavyMG0",
											mouseDownSoundFile 		=	"LEVEL/T90/sounds/HeavyMG4",		
		}

	},
	}

	---- magazine num _ val
	---- barrels num value

vehicle = {

}



function init()
	local sceneVehicle = FindVehicle("cfg")
		local value = GetTagValue(sceneVehicle, "cfg")
		if(value == "vehicle") then
			vehicle.id = sceneVehicle

			local status,retVal = pcall(initVehicle)
			if status then 
				-- utils.printStr("no errors")
			else
				DebugPrint(retVal)
			end
			-- initVehicle()
		end

		SetTag(sceneVehicle,"AVF_Custom","unset")


end


function initVehicle()
	if unexpected_condition then error() end
	vehicle.body = GetVehicleBody(vehicle.id)
	vehicle.transform =  GetBodyTransform(vehicle.body)
	vehicle.shapes = GetBodyShapes(vehicle.body)
	local totalShapes = ""
	for i=1,#vehicle.shapes do
		local value = GetTagValue(vehicle.shapes[i], "component")
		if(value~= "")then
			if(value=="chassis") then
				for key,val in pairs(vehicleParts.chassis) do 
					if(HasTag(vehicle.shapes[i],key)) then
						addItems(vehicle.shapes[i],val)
					end
				end
			end
			totalShapes = totalShapes..value.." "
			local test = GetShapeJoints(vehicle.shapes[i])
				for j=1,#test do 
					local val2 = GetTagValue(test[j], "component")
					if(val2~= "")then

						
						totalShapes = totalShapes..val2.." "

						if(val2=="turretJoint")then

							totalShapes = totalShapes..traverseTurret(test[j], vehicle.shapes[i])

						elseif val2=="gunJoint" then
							

							totalShapes = totalShapes..addGun(test[j], vehicle.shapes[i])

						end
					end
				end
		end	
	end
end

function traverseTurret(turretJoint,attatchedShape)
	local outString = ""
	local turret = GetJointOtherShape(turretJoint, attatchedShape)
	local joints = GetShapeJoints(turret)

	for j=1,#joints do 
		if(joints[j]~=turretJoint)then
			local val2 = GetTagValue(joints[j], "component")

			-- DebugPrint("turret shapes:"..val2)
			if(val2=="turretJoint")then

				totalShapes = totalShapes..traverseTurret(joints[j], turret)

			elseif val2=="gunJoint" then
				outString = outString..addGun(joints[j], turret)
			end
		end
	end
	for key,val in pairs(vehicleParts.turrets) do 
		if(HasTag(turret,val)) then
			addItems(turret,key)
		end
	end
	return outString
end

function addGun(gunJoint,attatchedShape)
	local gun = GetJointOtherShape(gunJoint, attatchedShape)
	for key,val in pairs(vehicleParts.guns) do 
		
		if(HasTag(gun,key)) then
			-- DebugPrint(key)
			addItems(gun,val)
		end
	end
	local val3 = GetTagValue(gun, "component")
	return val3
end
-- @magazine1_tracer
function addItems(shape,values)
	for key,val in pairs(values) do 
			if(type(val)== 'table') then
				for subKey,subVal in pairs(val) do 
					if(type(subVal)== 'table') then
						for subKey2,subVal2 in pairs(subVal) do 
							-- DebugPrint( "@"..string.sub(key,1,-2)..subKey.."_"..subKey2.."="..subVal2)
							if key == "magazines" then
								
								SetTag(shape, "@"..string.sub(key,1,-2)..subKey.."_"..subKey2, subVal2)
							else
								SetTag(shape, "@"..key..subKey..subKey2, subVal2)
							end

						end
					else
						if key == "magazines" then
							SetTag(shape, "@"..string.sub(key,1,-2).."_"..subKey, subVal)
						else
							SetTag(shape, "@"..key..subKey, subVal)
						end
					end
				end
			else
				SetTag(shape, "@"..key,val)
			end		
	end
end

-- function tick(dt)


-- end
utils = {
	contains = function(set,key)
		return set[key] ~= nil
		-- body
	end,
	}