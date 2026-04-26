lib.callback.register('cat_lockpick:getClosestVehicle', function()
    local closestVehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 2.0)

    if closestVehicle ~= nil then
        local lock = GetVehicleDoorLockStatus(closestVehicle)
        return closestVehicle, lock
    else
        return nil
    end
end)

lib.callback.register('cat_lockpick:startLockpiking', function(vehicle)
    if Config.EnableAlarm == true then
        SetVehicleAlarm(vehicle, true)
        SetVehicleAlarmTimeLeft(vehicle, Config.AlarmTimer * 1000)
        StartVehicleAlarm(vehicle)
    end

    local success = false
    if Config.UseT3Minigame then
        success = exports["t3_lockpick"]:startLockpick("lockpick", nil, nil)

        if success then
    local plate = GetVehicleNumberPlateText(vehicle)

    -- 🔑 เพิ่มตรงนี้
    TriggerEvent("vehiclekeys:client:SetOwner", plate)

    -- 🔓 ปลดล็อค
    SetVehicleDoorsLocked(vehicle, 0)
    SetVehicleDoorsLockedForAllPlayers(vehicle, false)

    Wait(100)

    -- 🚗 ขึ้นรถ
    TaskEnterVehicle(PlayerPedId(), vehicle, 5000, -1, 1.0, 1, 0)
end
    else
    success = true

    local plate = GetVehicleNumberPlateText(vehicle)

    -- 🔑 เพิ่มตรงนี้ด้วย
    TriggerEvent("vehiclekeys:client:SetOwner", plate)

    SetVehicleDoorsLocked(vehicle, 0)
    SetVehicleDoorsLockedForAllPlayers(vehicle, false)

    Wait(100)

    TaskEnterVehicle(PlayerPedId(), vehicle, 5000, -1, 1.0, 1, 0)
end

    return success
end)
