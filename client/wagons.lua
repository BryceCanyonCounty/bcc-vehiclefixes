---@type BCCVehicleFixesDebugLib
local DBG = BCCVehicleFixesDebug

-- Access config values with fallback defaults for safety
local wagonConfig = Config.Wagons or {}
local distances = wagonConfig.distances or {}
local networkControl = wagonConfig.networkControl or {}
local wagonComponents = wagonConfig.components or {}

---Request network control and delete an entity safely
---@param entity number The entity to delete
---@param entityName string Description of the entity for logging
---@return boolean success Whether the entity was successfully deleted
local function RequestAndDeleteEntity(entity, entityName)
    if not DoesEntityExist(entity) then
        return false
    end

    NetworkRequestControlOfEntity(entity)
    local attempts = 0

    while not NetworkHasControlOfEntity(entity) and attempts < (networkControl.maxAttempts or 50) do
        Wait(networkControl.waitTime or 10)
        attempts = attempts + 1
    end

    if attempts >= (networkControl.maxAttempts or 50) then
        DBG.Warning('Failed to gain control of ' .. entityName)
        return false
    end

    DeleteEntity(entity)
    return true
end

---Check if an entity is a known wagon component
---@param modelHash number The model hash to check
---@return boolean isComponent Whether the model is a known component
local function IsKnownWagonComponent(modelHash)
    for _, componentName in ipairs(wagonComponents) do
        if modelHash == GetHashKey(componentName) then
            return true
        end
    end
    return false
end

---Remove all horses attached to a wagon
---@param wagon number The wagon entity
---@return number count Number of horses removed
local function RemoveWagonHorses(wagon)
    local horsesRemoved = 0

    for i = 0, 5 do -- Check up to 6 harness positions
        local horse = Citizen.InvokeNative(0xA8BA0BAE0173457B, wagon, i) -- GetPedInDraftHarness
        if DoesEntityExist(horse) and horse ~= 0 then
            if RequestAndDeleteEntity(horse, 'harness horse ' .. i) then
                DBG.Success('Deleted harness horse ' .. i)
                horsesRemoved = horsesRemoved + 1
            end
        end
    end

    return horsesRemoved
end

---Remove objects near or attached to a wagon
---@param wagon number The wagon entity
---@param wagonPos vector3 The wagon's position
---@return number count Number of objects removed
local function RemoveWagonObjects(wagon, wagonPos)
    local objectsRemoved = 0
    local objectPool = GetGamePool('CObject') or {}

    for _, obj in ipairs(objectPool) do
        if DoesEntityExist(obj) and not IsEntityAMissionEntity(obj) then
            local objPos = GetEntityCoords(obj)
            local distance = #(wagonPos - objPos)

            if distance <= (distances.objectSearch or 10.0) then
                local objModel = GetEntityModel(obj)
                local removed = false

                -- Check if directly attached
                if IsEntityAttachedToEntity(obj, wagon) then
                    if RequestAndDeleteEntity(obj, 'attached object') then
                        DBG.Success('Deleted attached object (model: ' .. objModel .. ')')
                        removed = true
                    end
                -- Check if it's a known component within range
                elseif distance <= (distances.knownComponent or 3.0) and IsKnownWagonComponent(objModel) then
                    if RequestAndDeleteEntity(obj, 'known wagon component') then
                        DBG.Success('Deleted known wagon component (hash: ' .. objModel .. ')')
                        removed = true
                    else
                        DBG.Warning('Failed to delete known wagon component (hash: ' .. objModel .. ')')
                    end
                -- Check for very close objects (potential components)
                elseif distance <= (distances.proximityComponent or 2.0) then
                    if RequestAndDeleteEntity(obj, 'potential wagon component') then
                        DBG.Success('Deleted potential wagon component (model hash: ' .. objModel .. ')')
                        removed = true
                    else
                        DBG.Warning('Failed to delete potential wagon component (model hash: ' .. objModel .. ')')
                    end
                end

                if removed then
                    objectsRemoved = objectsRemoved + 1
                end
            end
        end
    end

    return objectsRemoved
end

---Remove peds (passengers, guards) from a wagon
---@param wagon number The wagon entity
---@param wagonPos vector3 The wagon's position
---@return number count Number of peds removed
local function RemoveWagonPeds(wagon, wagonPos)
    local pedsRemoved = 0
    local pedPool = GetGamePool('CPed') or {}

    for _, ped in ipairs(pedPool) do
        if DoesEntityExist(ped) and ped ~= PlayerPedId() then
            local pedPos = GetEntityCoords(ped)
            local distance = #(wagonPos - pedPos)

            if distance <= (distances.pedSearch or 5.0) then
                local pedInVehicle = GetVehiclePedIsIn(ped, false)
                if pedInVehicle == wagon or IsEntityAttachedToEntity(ped, wagon) then
                    if RequestAndDeleteEntity(ped, 'wagon occupant') then
                        DBG.Success('Deleted wagon occupant')
                        pedsRemoved = pedsRemoved + 1
                    end
                end
            end
        end
    end

    return pedsRemoved
end

---Remove all components associated with a wagon
---@param wagon number The wagon entity
local function RemoveWagonComponents(wagon)
    if not DoesEntityExist(wagon) then return end

    local wagonPos = GetEntityCoords(wagon)
    local totalRemoved = 0

    -- Remove horses
    totalRemoved = totalRemoved + RemoveWagonHorses(wagon)

    -- Remove objects (padlocks, cargo, etc.)
    totalRemoved = totalRemoved + RemoveWagonObjects(wagon, wagonPos)

    -- Remove peds (passengers, guards, etc.)
    totalRemoved = totalRemoved + RemoveWagonPeds(wagon, wagonPos)

    DBG.Info('Removed ' .. totalRemoved .. ' wagon components')
end

---Check if a wagon should be considered for removal
---@param wagon number The wagon entity
---@return boolean shouldRemove Whether the wagon should be removed
---@return string|nil reason The reason for skipping (if shouldRemove is false)
local function ShouldRemoveWagon(wagon)
    -- Basic entity checks
    if not DoesEntityExist(wagon) then
        return false
    end

    if not IsEntityAVehicle(wagon) then
        return false
    end

    if not IsVehicleStopped(wagon) then
        return false
    end

    if IsEntityAMissionEntity(wagon) then
        return false
    end

    -- Check for horse and if it's walking (indicating stuck)
    local horse = Citizen.InvokeNative(0xA8BA0BAE0173457B, wagon, 0) -- GetPedInDraftHarness
    if not DoesEntityExist(horse) then
        return false
    end

    if not IsPedWalking(horse) then
        return false, "horse is not walking"
    end

    -- Check if player is driving
    local driver = Citizen.InvokeNative(0x2963B5C1637E8A27, wagon) -- GetDriverOfVehicle
    if driver == PlayerPedId() then
        return false
    end

    return true
end

---Prepare wagon for deletion by removing prop sets and setting flags
---@param wagon number The wagon entity
local function PrepareWagonForDeletion(wagon)
    -- Remove prop sets
    Citizen.InvokeNative(0xE31C0CB1C3186D40, wagon) -- RemoveVehicleLightPropSets
    Citizen.InvokeNative(0x3BCF32FF37EA9F1D, wagon) -- RemoveVehiclePropSets

    -- Additional cleanup
    Citizen.InvokeNative(0x16B5E274BDE402F8, wagon, false) -- SetVehicleUndriveable
    Citizen.InvokeNative(0x7D6F9A3EF26136A0, wagon, false, false) -- SetVehicleDoorsLocked

    -- Prepare for deletion
    SetEntityAsNoLongerNeeded(wagon)
    SetEntityAsMissionEntity(wagon, true, true)
end

---Process and remove a stuck wagon and all its components
---@param wagon number The wagon entity to process
local function ProcessStuckWagon(wagon)
    DBG.Info('Found stuck wagon, beginning removal process...')

    -- Remove all wagon components
    RemoveWagonComponents(wagon)

    -- Handle the driver separately (might not be caught by component removal)
    local driver = Citizen.InvokeNative(0x2963B5C1637E8A27, wagon) -- GetDriverOfVehicle
    if DoesEntityExist(driver) then
        if RequestAndDeleteEntity(driver, 'wagon driver') then
            DBG.Success('Deleted wagon driver')
        else
            DBG.Warning('Failed to delete wagon driver')
        end
    end

    -- Prepare wagon for deletion
    PrepareWagonForDeletion(wagon)

    -- Delete the wagon
    if RequestAndDeleteEntity(wagon, 'stuck wagon') then
        DBG.Success('Successfully deleted stuck wagon and all components')
    else
        DBG.Warning('Failed to delete wagon, but components were removed')
    end
end

---Remove orphaned wagon components that exist in the world without a parent wagon
---@return number count Number of orphaned components removed
local function RemoveOrphanedWagonComponents()
    local orphansRemoved = 0
    local objectPool = GetGamePool('CObject') or {}
    local vehiclePool = GetGamePool('CVehicle') or {}

    for _, obj in ipairs(objectPool) do
        if DoesEntityExist(obj) and not IsEntityAMissionEntity(obj) then
            local objModel = GetEntityModel(obj)

            -- Check if this is a known wagon component
            if IsKnownWagonComponent(objModel) then
                local objPos = GetEntityCoords(obj)
                local isAttachedToWagon = false

                -- Check if it's attached to or near any existing wagon
                for _, wagon in ipairs(vehiclePool) do
                    if DoesEntityExist(wagon) and IsEntityAVehicle(wagon) then
                        local wagonPos = GetEntityCoords(wagon)
                        local distance = #(objPos - wagonPos)

                        if IsEntityAttachedToEntity(obj, wagon) or distance <= (distances.knownComponent or 3.0) then
                            isAttachedToWagon = true
                            break
                        end
                    end
                end

                -- If not attached to any wagon, it's orphaned - remove it
                if not isAttachedToWagon then
                    if RequestAndDeleteEntity(obj, 'orphaned wagon component') then
                        DBG.Success('Deleted orphaned wagon component (hash: ' .. objModel .. ')')
                        orphansRemoved = orphansRemoved + 1
                    else
                        DBG.Warning('Failed to delete orphaned wagon component (hash: ' .. objModel .. ')')
                    end
                end
            end
        end
    end

    if orphansRemoved > 0 then
        DBG.Info('Removed ' .. orphansRemoved .. ' orphaned wagon components')
    end

    return orphansRemoved
end

-- MAIN THREAD - Stuck wagon detection
if Config.Wagons.active then
    CreateThread(function()
        local checkInterval = (Config.Wagons.checkInterval or 1) * 1000

        while true do
            local vehiclePool = GetGamePool('CVehicle') or {}

            for _, wagon in ipairs(vehiclePool) do
                local shouldRemove = ShouldRemoveWagon(wagon)

                if shouldRemove then
                    ProcessStuckWagon(wagon)
                end
            end

            Wait(checkInterval)
        end
    end)

    -- ORPHAN CLEANUP THREAD - Remove wagon components that lost their parent wagon
    CreateThread(function()
        -- Run less frequently than stuck wagon check (every 5 seconds)
        local orphanCheckInterval = 5000

        while true do
            Wait(orphanCheckInterval)
            RemoveOrphanedWagonComponents()
        end
    end)
end
