if Config.Wagons.active then
    Citizen.CreateThread(function()
        local vehiclePool = {}
        local wagon = 0
        local driver = 0
        local horse = 0
        while true do
            vehiclePool = GetGamePool('CVehicle') -- Get the list of vehicles (entities) from the pool
            for i = 1, #vehiclePool do -- loop through each vehicle (entity)
                wagon = vehiclePool[i]
                -- Is wagon stopped
                if IsEntityAVehicle(wagon) and IsVehicleStopped(wagon) then
                    -- Get the horse
                    horse = Citizen.InvokeNative(0xA8BA0BAE0173457B,wagon,0)
                    -- If vehicle stopped but the horse walks = buggy wagon
                    if IsPedWalking(horse) then
                        -- Delete driver & wagon
                        driver = Citizen.InvokeNative(0x2963B5C1637E8A27,wagon)
                        if driver ~= PlayerPedId() then -- Ensure the driver is not a player
                            if driver then
                                DeleteEntity(driver) -- Delete driver from wagon if there is one
                            end
                            DeleteEntity(wagon) -- Delete buggy wagon
                        end
                    end
                end
            end
            Citizen.Wait(1000)
        end
    end)
end
