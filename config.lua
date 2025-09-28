Config = {

    DevMode = {
        active = true -- Shows Debug Prints in Client Console
    },
    -----------------------------------------------------

    Boats = {
        active = true -- Remove NPC Boats
    },
    -----------------------------------------------------

    Wagons = {
        active = true, -- Enable/disable stuck wagon removal
        checkInterval = 1, -- How often to check for stuck wagons (seconds)

        -- Detection distances (in game units) - adjust these to fine-tune detection if needed
        distances = {
            objectSearch = 10.0,      -- Max distance to search for objects around wagon
            knownComponent = 3.0,     -- Distance to check for known wagon components  
            proximityComponent = 2.0, -- Distance for potential components (aggressive removal)
            pedSearch = 5.0,          -- Distance to search for wagon passengers/guards
        },

        -- Network control settings - usually don't need to change these
        networkControl = {
            maxAttempts = 50,  -- Max attempts to gain network control before giving up
            waitTime = 10,     -- Milliseconds to wait between control attempts
        },

        -- Known wagon component models - add new ones as you discover them in-game
        -- These will be specifically targeted for removal when near wagons
        components = {
            's_wagonprison_lock',
            's_coachlock02x',
            'p_wagonprison_lock01x',
            'p_wagonprison_chain01x',
        }
    }
    -----------------------------------------------------
}
