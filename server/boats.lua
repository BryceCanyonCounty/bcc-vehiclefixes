if Config.Boats.active then
    AddEventHandler('entityCreating', function(entity)
        if GetEntityType(entity) == 2 then -- Check if its a vehicle
            if GetVehicleType(entity) == "boat" then -- check if its a boat
                if GetEntityPopulationType(entity) ~= 7 and GetEntityPopulationType(entity) ~= 8 then -- If players are not driving boat, delete
                    CancelEvent()
                end
            end
        end
    end)
end