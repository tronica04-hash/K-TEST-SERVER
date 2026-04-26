-- ====================================================
-- wheel.lua - ระบบถอดใส่ล้อสำหรับ mechanic
-- ====================================================

local heldWheelProp    = nil
local heldWheelIndex   = nil
local heldWheelVehicle = nil
local isDoingMinigame  = false

-- ====================================================
-- Job Check
-- ====================================================

local function IsAllowedJob()
    local jobType = PlayerData.job and PlayerData.job.type or nil
    if not jobType then return false end
    for _, allowed in pairs(Config.WheelSystem.allowedJobTypes) do
        if jobType == allowed then return true end
    end
    return false
end

-- ====================================================
-- Attach prop ล้อติดมือ
-- ====================================================

local function AttachWheelToHands()
    local ped    = PlayerPedId()
    local coords = GetEntityCoords(ped)

    RequestModel(Config.WheelSystem.wheelModel)
    while not HasModelLoaded(Config.WheelSystem.wheelModel) do
        Wait(10)
    end

    local wheel = CreateObject(
        GetHashKey(Config.WheelSystem.wheelModel),
        coords.x, coords.y, coords.z,
        true, true, true
    )

    local boneIndex = GetPedBoneIndex(ped, Config.WheelSystem.wheelBone)
    local loc       = Config.WheelSystem.wheelLoc
    local rot       = Config.WheelSystem.wheelRot

    AttachEntityToEntity(
        wheel, ped, boneIndex,
        loc.x, loc.y, loc.z,
        rot.x, rot.y, rot.z,
        true, false, false, false, 2, true
    )

    RequestAnimDict('anim@heists@box_carry@')
    while not HasAnimDictLoaded('anim@heists@box_carry@') do
        Wait(10)
    end
    TaskPlayAnim(ped, 'anim@heists@box_carry@', 'idle', 5.0, 1.0, -1, 49, 0.0, false, false, false)

    return wheel
end

-- ====================================================
-- วางล้อลงพื้น (กด X)
-- ====================================================

local function DropWheelToGround()
    if not heldWheelProp then return end

    DetachEntity(heldWheelProp, true, true)
    SetEntityDynamic(heldWheelProp, true)
    ActivatePhysics(heldWheelProp)
    PlaceObjectOnGroundProperly(heldWheelProp)
    ClearPedTasksImmediately(PlayerPedId())

    local droppedProp    = heldWheelProp
    local droppedIndex   = heldWheelIndex
    local droppedVehicle = heldWheelVehicle

    heldWheelProp    = nil
    heldWheelIndex   = nil
    heldWheelVehicle = nil

    -- qb-target ที่ prop ที่วางลงพื้น
    exports['qb-target']:AddTargetEntity(droppedProp, {
        options = {
            {
                label = 'หยิบล้อ',
                icon  = 'fas fa-circle',
                action = function()
                    if heldWheelProp then
                        QBCore.Functions.Notify('มือเต็มอยู่แล้ว', 'error')
                        return
                    end

                    exports['qb-target']:RemoveTargetEntity(droppedProp)

                    heldWheelProp    = droppedProp
                    heldWheelIndex   = droppedIndex
                    heldWheelVehicle = droppedVehicle

                    local ped       = PlayerPedId()
                    local boneIndex = GetPedBoneIndex(ped, Config.WheelSystem.wheelBone)
                    local loc       = Config.WheelSystem.wheelLoc
                    local rot       = Config.WheelSystem.wheelRot

                    AttachEntityToEntity(
                        droppedProp, ped, boneIndex,
                        loc.x, loc.y, loc.z,
                        rot.x, rot.y, rot.z,
                        true, false, false, false, 2, true
                    )

                    RequestAnimDict('anim@heists@box_carry@')
                    while not HasAnimDictLoaded('anim@heists@box_carry@') do
                        Wait(10)
                    end
                    TaskPlayAnim(ped, 'anim@heists@box_carry@', 'idle', 5.0, 1.0, -1, 49, 0.0, false, false, false)
                end
            }
        },
        distance = 2.0
    })
end

-- ====================================================
-- หาล้อที่หายไปที่ใกล้ผู้เล่นที่สุด
-- ====================================================

local function FindMissingWheelNearPlayer(vehicle)
    local ped         = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)
    local bones       = { 'wheel_lf', 'wheel_rf', 'wheel_lr', 'wheel_rr' }
    local closestIndex = nil
    local closestDist  = 9999

    for i = 0, 3 do
        if GetVehicleWheelXOffset(vehicle, i) > 300 then
            local boneIdx  = GetEntityBoneIndexByName(vehicle, bones[i + 1])
            if boneIdx ~= -1 then
                local boneCoords = GetWorldPositionOfEntityBone(vehicle, boneIdx)
                local dist       = #(playerCoords - boneCoords)
                if dist < closestDist then
                    closestDist  = dist
                    closestIndex = i
                end
            end
        end
    end

    return closestIndex
end

-- ====================================================
-- Main Thread
-- ====================================================

CreateThread(function()
    while true do
        Wait(0)

        if not IsAllowedJob() or isDoingMinigame then
            Wait(1000)
            goto continue
        end

        local ped              = PlayerPedId()
        local vehicle, distance = QBCore.Functions.GetClosestVehicle()

        if vehicle == 0 or distance > 2.5 then
            Wait(500)
            goto continue
        end

        -- โหมดใส่ล้อคืน (ถือล้ออยู่)
        if heldWheelProp then
            local missingIndex = FindMissingWheelNearPlayer(vehicle)

            if missingIndex then
                local bones    = { 'wheel_lf', 'wheel_rf', 'wheel_lr', 'wheel_rr' }
                local boneIdx  = GetEntityBoneIndexByName(vehicle, bones[missingIndex + 1])
                local wheelPos = GetWorldPositionOfEntityBone(vehicle, boneIdx)
                local dist     = #(GetEntityCoords(ped) - wheelPos)

                if dist < 2.0 then
                    Draw3DText(wheelPos.x, wheelPos.y, wheelPos.z + 0.3, 'กด [E] เพื่อใส่ล้อคืน')

                    if IsControlJustReleased(0, 38) then
                        isDoingMinigame = true
                        local success = exports['ls_bolt_minigame']:BoltMinigame(vehicle, missingIndex, true, true, nil)

                        if success then
                            SetVehicleWheelXOffset(vehicle, missingIndex, 0.0)
                            DeleteEntity(heldWheelProp)
                            ClearPedTasksImmediately(ped)
                            heldWheelProp    = nil
                            heldWheelIndex   = nil
                            heldWheelVehicle = nil
                            QBCore.Functions.Notify('ใส่ล้อเรียบร้อย', 'success')
                        else
                            QBCore.Functions.Notify('ใส่ล้อไม่สำเร็จ ลองใหม่อีกครั้ง', 'error')
                        end

                        isDoingMinigame = false
                    end
                end
            end

        -- โหมดถอดล้อ (ไม่ได้ถือล้อ)
        else
            local closestWheel = GetClosestWheel(vehicle)

            if closestWheel then
                local bones    = { 'wheel_lf', 'wheel_rf', 'wheel_lr', 'wheel_rr' }
                local boneIdx  = GetEntityBoneIndexByName(vehicle, bones[closestWheel + 1])
                local wheelPos = GetWorldPositionOfEntityBone(vehicle, boneIdx)

                Draw3DText(wheelPos.x, wheelPos.y, wheelPos.z + 0.3, 'กด [E] เพื่อถอดล้อ')

                if IsControlJustReleased(0, 38) then
                    isDoingMinigame = true
                    local success = exports['ls_bolt_minigame']:BoltMinigame(vehicle, closestWheel, false, true, nil)

                    if success then
                        SetVehicleWheelXOffset(vehicle, closestWheel, 9999999.0)
                        heldWheelIndex   = closestWheel
                        heldWheelVehicle = vehicle
                        heldWheelProp    = AttachWheelToHands()
                        QBCore.Functions.Notify('ถอดล้อเรียบร้อย', 'success')
                    else
                        QBCore.Functions.Notify('ถอดล้อไม่สำเร็จ ลองใหม่อีกครั้ง', 'error')
                    end

                    isDoingMinigame = false
                end
            end
        end

        ::continue::
    end
end)

-- ====================================================
-- Thread กด X วางล้อลงพื้น
-- ====================================================

CreateThread(function()
    while true do
        if heldWheelProp then
            Wait(0)
            if IsControlJustReleased(0, 73) then -- X
                DropWheelToGround()
            end
        else
            Wait(500)
        end
    end
end)