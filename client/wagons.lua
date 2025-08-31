---@type BCCVehicleFixesDebugLib
local DBG = BCCVehicleFixesDebug or {
    Info = function() end,
    Error = function() end,
    Warning = function() end,
    Success = function() end
}

local function RequestAndDeleteEntity(entity, entityName)
    if not DoesEntityExist(entity) then return false end

    NetworkRequestControlOfEntity(entity)
    local attempts = 0
    local maxAttempts = 50
    while not NetworkHasControlOfEntity(entity) and attempts < maxAttempts do
        Wait(10)
        attempts = attempts + 1
    end

    if attempts >= maxAttempts then
        DBG.Warning('Failed to gain control of ' .. entityName)
        return false
    end

    DeleteEntity(entity)
    return true
end

if Config.Wagons.active then
    CreateThread(function()
        local time = Config.Wagons.checkInterval * 1000 or 1000

        while true do
            local vehiclePool = GetGamePool('CVehicle') or {}
            for _, wagon in ipairs(vehiclePool) do
                if not DoesEntityExist(wagon) or not IsEntityAVehicle(wagon) or not IsVehicleStopped(wagon) or IsEntityAMissionEntity(wagon) then
                    goto continue
                end

                -- Get the horse attached to the wagon
                local horse = Citizen.InvokeNative(0xA8BA0BAE0173457B, wagon, 0) -- GetPedInDraftHarness
                if not DoesEntityExist(horse) then
                    DBG.Warning('Wagon has no horse or failed to get horse')
                    goto continue
                end
                if not IsPedWalking(horse) then
                    goto continue
                end

                -- Get the driver of the wagon
                local driver = Citizen.InvokeNative(0x2963B5C1637E8A27, wagon) -- GetDriverOfVehicle
                if driver == PlayerPedId() then
                    goto continue
                end

                -- Delete the driver if it exists
                if DoesEntityExist(driver) then
                    if RequestAndDeleteEntity(driver, 'driver') then
                        DBG.Success('Deleted wagon driver')
                    else
                        DBG.Warning('Failed to delete wagon driver')
                    end
                end

                -- Delete the horse if it exists
                if DoesEntityExist(horse) then
                    if RequestAndDeleteEntity(horse, 'horse') then
                        DBG.Success('Deleted wagon horse')
                    else
                        DBG.Warning('Failed to delete wagon horse')
                    end
                end

                -- Remove any prop sets from the wagon
                Citizen.InvokeNative(0xE31C0CB1C3186D40,wagon) -- RemoveVehicleLightPropSets
                Citizen.InvokeNative(0x3BCF32FF37EA9F1D,wagon) -- RemoveVehiclePropSets

                -- Prepare the wagon for deletion
                SetEntityAsNoLongerNeeded(wagon)
                SetEntityAsMissionEntity(wagon, true, true)
                -- Delete the wagon
                if RequestAndDeleteEntity(wagon, 'wagon') then
                    DBG.Success('Deleted stuck wagon')
                end

                ::continue::
            end
            Wait(time)
        end
    end)
end
