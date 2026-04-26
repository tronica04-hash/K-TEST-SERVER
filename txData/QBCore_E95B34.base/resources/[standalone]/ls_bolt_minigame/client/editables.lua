function IsWheelMounted(vehicle, wheelIndex)
    local bones = {'wheel_lf','wheel_rf', 'wheel_lr', 'wheel_rr'}
    local isWheelMounted = true
    local boneId = GetEntityBoneIndexByName(vehicle, bones[wheelIndex + 1])
    local boneCoords = GetWorldPositionOfEntityBone(vehicle, boneId)

    local chassisBone = GetEntityBoneIndexByName(vehicle, 'chassis_dummy')
    local chassisCoords = GetWorldPositionOfEntityBone(vehicle, chassisBone)
    local chassisWheelDistance = GetDistanceBetweenCoords(chassisCoords, boneCoords)

    if chassisWheelDistance > 10.0 then
        isWheelMounted = false
    end

    return isWheelMounted
end


function GetVehicleWheelBoneCoords(vehicle, wheelIndex)
    local bones = {'wheel_lf','wheel_rf', 'wheel_lr', 'wheel_rr'}
    local bone = GetEntityBoneIndexByName(vehicle, bones[wheelIndex + 1])
    local coords = GetWorldPositionOfEntityBone(vehicle, bone)

    return coords
end