-- Functions

local function RepairPart(vehicle, plate, component)
    local materials = Config.WearableParts[component].repair
    local hasItems = exports['qb-inventory']:HasItem(materials)
    if not hasItems then
        QBCore.Functions.Notify(Lang:t('warning.no_materials'), 'error')
        return
    end
    local componentLabel = Config.WearableParts[component].label or component
    ToggleHood(vehicle)
    QBCore.Functions.Progressbar('repairing_vehicle', string.format(Lang:t('progress.repairing'), componentLabel), 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'mini@repair',
        anim = 'fixing_a_player',
        flags = 1,
    }, {
        model = 'imp_prop_impexp_span_03',
        bone = 28422,
        coords = vec3(0.06, 0.01, -0.02),
        rotation = vec3(0.0, 0.0, 0.0),
    }, {}, function()
        ToggleHood(vehicle)
        QBCore.Functions.Notify(string.format(Lang:t('success.part_repaired'), componentLabel), 'success')
        for item, amount in pairs(materials) do
            TriggerServerEvent('qb-mechanicjob:server:removeItem', item, amount)
        end
        TriggerServerEvent('qb-mechanicjob:server:repairVehicleComponent', plate, component)
    end, function()
        ToggleHood(vehicle)
    end)
end

-- Events

RegisterNetEvent('qb-mechanicjob:client:PartsMenu', function()
    local vehicle, distance = QBCore.Functions.GetClosestVehicle()
    if vehicle == 0 or distance > 5.0 then return end
    if not IsNearBone(vehicle, 'engine') then return end
    local plate = QBCore.Functions.GetPlate(vehicle)
    if not plate then return end
    local vehicleClass = GetVehicleClass(vehicle)
    if Config.IgnoreClasses[vehicleClass] then return end
    QBCore.Functions.TriggerCallback('qb-mechanicjob:server:getVehicleStatus', function(status)
        if not status then return end

        local function getHealthColor(health)
            if health <= 250 then
                return 'red'
            elseif health <= 500 then
                return 'yellow'
            else
                return 'green'
            end
        end

        local engineHealth = GetVehicleEngineHealth(vehicle)
        local bodyHealth = GetVehicleBodyHealth(vehicle)
        local petrolTankHealth = GetVehiclePetrolTankHealth(vehicle)

        local vehicleMenu = {
            { header = Lang:t('menu.vehicle_stats'), isMenuHeader = true,                                                                                                                                                  icon = 'fas fa-gears' },
            { header = Lang:t('menu.engine_health'), txt = Lang:t('menu.status') .. ': ' .. '<span style="color:' .. getHealthColor(engineHealth) .. ';">' .. math.ceil((engineHealth / 1000) * 100) .. '%</span>',        isMenuHeader = true },
            { header = Lang:t('menu.body_health'),   txt = Lang:t('menu.status') .. ': ' .. '<span style="color:' .. getHealthColor(bodyHealth) .. ';">' .. math.ceil((bodyHealth / 1000) * 100) .. '%</span>',            isMenuHeader = true },
            { header = Lang:t('menu.fuel_health'),   txt = Lang:t('menu.status') .. ': ' .. '<span style="color:' .. getHealthColor(petrolTankHealth) .. ';">' .. math.ceil((petrolTankHealth / 1000) * 100) .. '%</span>', isMenuHeader = true },
        }

        -- Components
        for component, value in pairs(status) do
            local color = 'green'
            local percentage = math.ceil((value / Config.WearableParts[component].maxValue) * 100)

            if value <= Config.DamageThreshold then
                color = 'red'
            elseif value <= Config.WarningThreshold then
                color = 'yellow'
            end

            local statusText = '<span style="color:' .. color .. ';">' .. percentage .. '%</span>'

            vehicleMenu[#vehicleMenu + 1] = {
                header = Config.WearableParts[component].label or component,
                txt = Lang:t('menu.status') .. ': ' .. statusText,
                params = {
                    isAction = true,
                    event = function()
                        RepairPart(vehicle, plate, component)
                    end,
                    args = {}
                }
            }
        end
        vehicleMenu[#vehicleMenu + 1] = {
            header = Lang:t('menu.close'),
            params = {
                event = 'qb-menu:client:closeMenu'
            }
        }
        exports['qb-menu']:openMenu(vehicleMenu)
    end, plate)
end)

RegisterNetEvent('qb-mechanicjob:client:repairVehicle', function()
    local vehicle, distance = QBCore.Functions.GetClosestVehicle()
    if vehicle == 0 or distance > 5.0 then return end
    if not IsNearBone(vehicle, 'engine') then return end
    local engineHealth = GetVehicleEngineHealth(vehicle)
    local bodyHealth = GetVehicleBodyHealth(vehicle)
    ToggleHood(vehicle)
    QBCore.Functions.Progressbar('repairing_vehicle', Lang:t('progress.repair_vehicle'), 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'mini@repair',
        anim = 'fixing_a_player',
        flags = 1,
    }, {
        model = 'imp_prop_impexp_span_03',
        bone = 28422,
        coords = vec3(0.06, 0.01, -0.02),
        rotation = vec3(0.0, 0.0, 0.0),
    }, {}, function()
        SetVehicleEngineHealth(vehicle, engineHealth + 100)
        SetVehicleBodyHealth(vehicle, bodyHealth + 100)
        ToggleHood(vehicle)
        QBCore.Functions.Notify(Lang:t('success.repaired'), 'success')
        TriggerServerEvent('qb-mechanicjob:server:removeItem', 'repairkit')
    end, function()
        ToggleHood(vehicle)
    end)
end)

RegisterNetEvent('qb-mechanicjob:client:repairVehicleFull', function()
    local vehicle, distance = QBCore.Functions.GetClosestVehicle()
    if vehicle == 0 or distance > 5.0 then return end
    if not IsNearBone(vehicle, 'engine') then return end
    ToggleHood(vehicle)
    QBCore.Functions.Progressbar('repairing_vehicle', Lang:t('progress.repair_vehicle'), 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'mini@repair',
        anim = 'fixing_a_player',
        flags = 1,
    }, {
        model = 'imp_prop_impexp_span_03',
        bone = 28422,
        coords = vec3(0.06, 0.01, -0.02),
        rotation = vec3(0.0, 0.0, 0.0),
    }, {}, function()
        SetVehicleEngineHealth(vehicle, 1000.0)
        SetVehicleBodyHealth(vehicle, 1000.0)
        SetVehicleDeformationFixed(vehicle)
        SetVehiclePetrolTankHealth(vehicle, 1000.0)
        SetVehicleFixed(vehicle)
        ToggleHood(vehicle)
        QBCore.Functions.Notify(Lang:t('success.repaired'), 'success')
        TriggerServerEvent('qb-mechanicjob:server:removeItem', 'advancedrepairkit')
    end, function()
        ToggleHood(vehicle)
    end)
end)

RegisterNetEvent('qb-mechanicjob:client:repairTire', function()
    local vehicle, distance = QBCore.Functions.GetClosestVehicle()
    if vehicle == 0 or distance > 5.0 then return end

    if not Entity(vehicle).state.IsVehicleRaised then
        QBCore.Functions.Notify('ต้องยกรถขึ้นก่อน', 'error')
        return
    end

    local bones = { 'wheel_lf', 'wheel_rf', 'wheel_lr', 'wheel_rr' }
    local wheels = {
        { x = 'min', y = 'max' },
        { x = 'max', y = 'max' },
        { x = 'min', y = 'min' },
        { x = 'max', y = 'min' },
    }

    local function FindNearestWheelLocal()
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)
        local min, max = GetModelDimensions(GetEntityModel(vehicle))
        local closestDist = 9999
        local closestIndex = nil
        local closestPos = nil

        local wheelOffsets = {
            { x = min.x, y = max.y - 0.7, z = min.z },
            { x = max.x, y = max.y - 0.7, z = min.z },
            { x = min.x, y = min.y + 0.7, z = min.z },
            { x = max.x, y = min.y + 0.7, z = min.z },
        }

        for i, w in ipairs(wheelOffsets) do
            local wCoords = GetOffsetFromEntityInWorldCoords(vehicle, w.x, w.y, w.z)
            local d = #(pCoords - wCoords)
            if d < closestDist then
                closestDist = d
                closestIndex = i - 1
                closestPos = wCoords
            end
        end

        -- หา bone coords จริง
        local boneId = GetEntityBoneIndexByName(vehicle, bones[closestIndex + 1])
        if boneId == -1 then return nil, nil, nil end
        local realPos = GetWorldPositionOfEntityBone(vehicle, boneId)

        return closestIndex, realPos, closestDist
    end

    CreateThread(function()
        while true do
            Wait(0)

            local wheelIndex, wheelPos, dist = FindNearestWheelLocal()

            -- ออกไปไกลเกิน 4 เมตรจากรถ ยกเลิก
            local pedCoords = GetEntityCoords(PlayerPedId())
            local vehCoords = GetEntityCoords(vehicle)
            if #(pedCoords - vehCoords) > 4.0 then
                QBCore.Functions.Notify('ยกเลิกการซ่อมยาง', 'error')
                return
            end

            if wheelIndex and wheelPos and dist < 2.5 then
                Draw3DText(wheelPos.x, wheelPos.y, wheelPos.z + 0.3, 'Press [E] to Repair Tire')

                if IsControlJustReleased(0, 38) then
                     FreezeEntityPosition(vehicle, true)
                    local success = exports['ls_bolt_minigame']:BoltMinigame(vehicle, wheelIndex, false, true, wheelPos)
                     FreezeEntityPosition(vehicle, true)

                    if success then

                        NetworkRequestControlOfEntity(vehicle)
                     local timeout = 1500
                    while not NetworkHasControlOfEntity(vehicle) and timeout > 0 do
                     Wait(100)
                       timeout = timeout - 100
                 end
                     SetVehicleTyreFixed(vehicle, wheelIndex)
                     SetVehicleWheelHealth(vehicle, wheelIndex, 1000.0)
                     FreezeEntityPosition(vehicle, false)
                     TriggerServerEvent('qb-mechanicjob:server:removeItem', 'tirerepairkit', 1)
    QBCore.Functions.Notify('ซ่อมยางเรียบร้อย', 'success')
                    else
                        QBCore.Functions.Notify('ซ่อมยางไม่สำเร็จ ลองใหม่อีกครั้ง', 'error')
                    end

                    return
                end
            end
        end
    end)
end)
RegisterNetEvent('qb-mechanicjob:client:cleanVehicle', function()
    local vehicle, distance = QBCore.Functions.GetClosestVehicle()
    if vehicle == 0 or distance > 5.0 then return end
    QBCore.Functions.Progressbar('cleaning_vehicle', Lang:t('progress.cleaning'), 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'amb@world_human_maid_clean@',
        anim = 'base',
        flags = 1,
    }, {
        model = 'prop_sponge_01',
        bone = 28422,
        coords = vec3(0.0, 0.0, -0.01),
        rotation = vec3(90.0, 0.0, 0.0),
    }, {}, function()
        SetVehicleDirtLevel(vehicle, 0.0)
        QBCore.Functions.Notify(Lang:t('success.cleaned'), 'success')
        TriggerServerEvent('qb-mechanicjob:server:removeItem', 'cleaningkit')
    end)
end)

RegisterNetEvent('qb-mechanicjob:client:fixEverything', function()
    QBCore.Functions.TriggerCallback('qb-mechanicjob:server:hasPermission', function(hasPermission)
        if not hasPermission then return end
        local vehicle = GetVehiclePedIsUsing(PlayerPedId())
        SetVehicleUndriveable(vehicle, false)
        WashDecalsFromVehicle(vehicle, 1.0)
        SetVehicleEngineHealth(vehicle, 1000.0)
        SetVehicleBodyHealth(vehicle, 1000.0)
        SetVehiclePetrolTankHealth(vehicle, 1000.0)
        SetVehicleDirtLevel(vehicle, 0.0)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleFixed(vehicle)
        for i = 0, 5 do
            SetVehicleTyreFixed(vehicle, i)
        end
        for i = 0, 7 do
            FixVehicleWindow(vehicle, i)
        end
        exports[Config.FuelResource]:SetFuel(vehicle, 100)
        QBCore.Functions.Notify(Lang:t('success.repaired'), 'success')
    end)
end)
