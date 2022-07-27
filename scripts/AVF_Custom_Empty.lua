

vehicleParts = {
	chassis = {

	},
	turrets = {


	},
	guns = {

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