local QBCore = exports['qb-core']:GetCoreObject()

local waitTime = 5
local height = 0.22

local function IsCar(veh)
    local vc = GetVehicleClass(veh)
    return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20)
end

local function FinishJackstand(object)
    local rot = GetEntityRotation(object, 5)
    DetachEntity(object)
    FreezeEntityPosition(object, true)
    local coords = GetEntityCoords(object)
    local _, ground = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 2.0, true)
    SetEntityCoords(object, coords.x, coords.y, ground, false, false, false, false)
    PlaceObjectOnGroundProperly_2(object)
    SetEntityRotation(object, rot.x, rot.y, rot.z, 5, 0)
    SetEntityCollision(object, false, true)
end

local function AttachJackToCar(object, vehicle)
    local offset = GetOffsetFromEntityGivenWorldCoords(vehicle, GetEntityCoords(object))
    FreezeEntityPosition(object, false)
    AttachEntityToEntity(object, vehicle, 0, offset, 0.0, 0.0, 90.0, 0, 0, 0, 0, 0, 1)
end

local function RaiseCar()
    local playerPed = PlayerPedId()
    local pCoords = GetEntityCoords(playerPed)
    local vehicle, distance = QBCore.Functions.GetClosestVehicle()
if vehicle == 0 or distance > 3.0 then
    QBCore.Functions.Notify('ไม่พบรถในระยะ', 'error')
    return
end
local netId = NetworkGetNetworkIdFromEntity(vehicle)

    if not vehicle or vehicle == 0 then
        QBCore.Functions.Notify('ไม่พบรถในระยะ', 'error')
        return
    end

    if not IsEntityAVehicle(vehicle) or not IsCar(vehicle) then
        QBCore.Functions.Notify('ไม่สามารถยกรถประเภทนี้ได้', 'error')
        return
    end

    if IsPedInAnyVehicle(playerPed, false) then
        QBCore.Functions.Notify('ออกจากรถก่อน', 'error')
        return
    end

    if not IsVehicleStopped(vehicle) then
        QBCore.Functions.Notify('รถต้องจอดนิ่งก่อน', 'error')
        return
    end

    if Entity(vehicle).state.IsVehicleRaised then
        QBCore.Functions.Notify('รถถูกยกขึ้นแล้ว', 'error')
        return
    end

    if not exports['qb-inventory']:HasItem('ls_jackstand') then
        QBCore.Functions.Notify('ต้องมีแม่แรงในกระเป๋า', 'error')
        return
    end

    Citizen.CreateThread(function()
        local veh = NetworkGetEntityFromNetworkId(netId)
        NetworkRequestControlOfEntity(veh)

        local timeout = 1500
        while not NetworkHasControlOfEntity(veh) and timeout > 0 do
            Citizen.Wait(100)
            timeout = timeout - 100
        end

        if not NetworkHasControlOfEntity(veh) then
            QBCore.Functions.Notify('ไม่สามารถควบคุมรถได้ ลองใหม่อีกครั้ง', 'error')
            return
        end

        local vehpos = GetEntityCoords(veh)
        local playerCoords = GetEntityCoords(playerPed)
        local heading = GetHeadingFromVector_2d(playerCoords.x - vehpos.x, playerCoords.y - vehpos.y)
        SetEntityHeading(playerPed, heading)

        local animDict = 'amb@world_human_vehicle_mechanic@male@base'
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do Citizen.Wait(0) end
        TaskPlayAnim(playerPed, animDict, 'base', 8.0, -8.0, 1500, 1, 0, false, false, false)
        Citizen.Wait(1500)

        FreezeEntityPosition(veh, true)

        local model = 'imp_prop_axel_stand_01a'
        RequestModel(GetHashKey(model))
        while not HasModelLoaded(GetHashKey(model)) do Citizen.Wait(0) end

        local min, max = GetModelDimensions(GetEntityModel(veh))
        local width  = ((max.x - min.x) / 2) - ((max.x - min.x) / 3.3)
        local length = ((max.y - min.y) / 2) - ((max.y - min.y) / 3.3)
        local zOffset = 0.5

        local flStand = CreateObject(GetHashKey(model), vehpos.x - width, vehpos.y + length, vehpos.z - zOffset, true, true, true)
        local frStand = CreateObject(GetHashKey(model), vehpos.x + width, vehpos.y + length, vehpos.z - zOffset, true, true, true)
        local rlStand = CreateObject(GetHashKey(model), vehpos.x - width, vehpos.y - length, vehpos.z - zOffset, true, true, true)
        local rrStand = CreateObject(GetHashKey(model), vehpos.x + width, vehpos.y - length, vehpos.z - zOffset, true, true, true)

        AttachEntityToEntity(flStand, veh, 0, -width,  length, -zOffset, 0.0, 0.0, -90.0, false, false, false, false, 0, true)
        AttachEntityToEntity(frStand, veh, 0,  width,  length, -zOffset, 0.0, 0.0, -90.0, false, false, false, false, 0, true)
        AttachEntityToEntity(rlStand, veh, 0, -width, -length, -zOffset, 0.0, 0.0,  90.0, false, false, false, false, 0, true)
        AttachEntityToEntity(rrStand, veh, 0,  width, -length, -zOffset, 0.0, 0.0,  90.0, false, false, false, false, 0, true)

        FinishJackstand(flStand)
        FinishJackstand(frStand)
        FinishJackstand(rlStand)
        FinishJackstand(rrStand)

        Citizen.Wait(100)

        TriggerServerEvent('qb-mechanicjob:server:saveJacks',
            netId,
            NetworkGetNetworkIdFromEntity(flStand),
            NetworkGetNetworkIdFromEntity(frStand),
            NetworkGetNetworkIdFromEntity(rlStand),
            NetworkGetNetworkIdFromEntity(rrStand)
        )

        local addZ = 0
        while addZ < height do
            addZ = addZ + 0.001
            SetEntityCoordsNoOffset(veh, vehpos.x, vehpos.y, vehpos.z + addZ, true, true, true)
            Citizen.Wait(waitTime)
        end

        AttachJackToCar(flStand, veh)
        AttachJackToCar(frStand, veh)
        AttachJackToCar(rlStand, veh)
        AttachJackToCar(rrStand, veh)

        Citizen.Wait(1500)
        ClearPedTasks(playerPed)

        TriggerServerEvent('qb-mechanicjob:server:setVehicleRaised', netId, true)
        QBCore.Functions.Notify('ยกรถขึ้นแล้ว', 'success')
    end)
end

local function LowerVehicle()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local veh, distance = QBCore.Functions.GetClosestVehicle()
if veh == 0 or distance > 5.0 then
    QBCore.Functions.Notify('ไม่พบรถในระยะ', 'error')
    return
end
    local netId = NetworkGetNetworkIdFromEntity(veh)
    if not veh or veh == 0 then
        QBCore.Functions.Notify('ไม่พบรถในระยะ', 'error')
        return
    end

    if not Entity(veh).state.IsVehicleRaised then
        QBCore.Functions.Notify('รถไม่ได้ถูกยกอยู่', 'error')
        return
    end

    NetworkRequestControlOfEntity(veh)
    local timeout = 2000
    while not NetworkHasControlOfEntity(veh) and timeout > 0 do
        Citizen.Wait(100)
        timeout = timeout - 100
    end

    local vehpos = GetEntityCoords(veh)
    local removeZ = 0
    while removeZ < height do
        removeZ = removeZ + 0.001
        SetEntityCoordsNoOffset(veh, vehpos.x, vehpos.y, vehpos.z - removeZ, true, true, true)
        Citizen.Wait(waitTime)
    end

    FreezeEntityPosition(veh, true)

    for i = 1, 4 do
        if Entity(veh).state['jackStand' .. i] then
            TriggerServerEvent('qb-mechanicjob:server:deleteJackStand', Entity(veh).state['jackStand' .. i])
        end
    end

    Citizen.Wait(100)
    FreezeEntityPosition(veh, false)
    TriggerServerEvent('qb-mechanicjob:server:setVehicleRaised', netId, false)
    QBCore.Functions.Notify('ลดรถลงแล้ว', 'success')
end

RegisterCommand('liftup', function()
    RaiseCar()
end, false)

RegisterCommand('liftdown', function()
    LowerVehicle()
end, false)