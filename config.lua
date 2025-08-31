Config = {

    -- Do Not Enable on Live Server
    DevMode = {
        active = false -- Shows Debug Prints in Client Console
    },
    -----------------------------------------------------

    Boats = {
        active = true -- Remove NPC Boats
    },
    -----------------------------------------------------

    Wagons = {
        active = true, -- Remove Stuck NPC Wagons
        checkInterval = 1 -- Default: 1 / Check interval in seconds
    }
    -----------------------------------------------------
}
