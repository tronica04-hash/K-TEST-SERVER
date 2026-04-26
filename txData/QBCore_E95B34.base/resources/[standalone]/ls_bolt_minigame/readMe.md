# IMPORTANT NOTE

This script requires `wheelBoneCoords` to properly spawn the bolts.
**Once you remove the wheel, the bone of the wheel will be removed too.**

*If you plan on mounting a wheel back on to the car, you first need to save the wheel's bone coordinates*

Example code:

```lua
-- Check if wheel is attached to the vehicle
if GetVehicleWheelXOffset(vehicle, wheelIndex) < 2.0 and GetVehicleWheelXOffset(vehicle, wheelIndex) > -2.0  then
    local wheelBoneCoords = GetVehicleWheelBoneCoords(vehicle, wheelIndex)
end

function GetVehicleWheelBoneCoords(vehicle, wheelIndex)
    local bones = {'wheel_lf','wheel_rf', 'wheel_lr', 'wheel_rr'}
    local bone = GetEntityBoneIndexByName(vehicle, bones[wheelIndex + 1])
    local coords = GetWorldPositionOfEntityBone(vehicle, bone)

    return coords
end
```
