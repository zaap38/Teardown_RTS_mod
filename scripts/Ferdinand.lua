

vehicleParts = {
	chassis = {

	},
	turrets = {


	},
	guns = {
		["mainCannon"] = {	
			name="88 mm Pak 43/2 L/71",
			magazines = {
						[1] = {
						name = "PzGr39",
						caliber 				= 88,
						velocity				= 400,
						explosionSize			= .8,
						maxPenDepth 			= 1.5,
						timeToLive 				= 7,
						launcher				= "cannon",
						payload					= "HE",
						shellWidth				= 0.8,
						r						= 0.3,
						g						= 0.8, 
						b						= 0.3, 
						shellSpriteName			= "MOD/gfx/shellModel2.png",
						shellSpriteRearName		= "MOD/gfx/shellRear2.png",
					}, 
						[2] = {
						name = "Sprgr. 34 ",
						caliber 				= 88,
						velocity				= 480,
						explosionSize			= 1.4,
						maxPenDepth 			= 0.1,
						timeToLive 				= 7,
						launcher				= "cannon",
						payload					= "HE",
						shellWidth				= 0.8,
						shellHeight				= 1.5,
						r						= 0.8,
						g						= 0.3, 
						b						= 0.3, 
						shellSpriteName			= "MOD/gfx/shellModel2.png",
						shellSpriteRearName		= "MOD/gfx/shellRear2.png",
					}, 
			},
			sight					= {
										[1] = {x=0.2,y=0.2,z=-0.3},
										},
										-- aimForwards = true,
			barrels		= {
							[1] = {
												x = 3,
												y = 1.3,
												z = 0.3,
								}

							},
			},
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