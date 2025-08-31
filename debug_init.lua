-- bcc-vehiclefixes resource debug system (resource-scoped global)
-- DO NOT MAKE CHANGES TO THIS FILE
if not BCCVehicleFixesDebug then
    ---@class BCCVehicleFixesDebugLib
    ---@field Info fun(message: string)
    ---@field Error fun(message: string)
    ---@field Warning fun(message: string)
    ---@field Success fun(message: string)
    ---@field DevModeActive boolean
    BCCVehicleFixesDebug = {}

    BCCVehicleFixesDebug.DevModeActive = Config and Config.DevMode and Config.DevMode.active or false

    -- No-op function
    local function noop() end

    -- Function to create loggers
    local function createLogger(prefix, color)
        if BCCVehicleFixesDebug.DevModeActive then
            return function(message)
                print(('^%d[%s] ^3%s^0'):format(color, prefix, message))
            end
        else
            return noop
        end
    end

    -- Create loggers with appropriate colors
    BCCVehicleFixesDebug.Info = createLogger("INFO", 5)    -- Purple
    BCCVehicleFixesDebug.Error = createLogger("ERROR", 1)  -- Red
    BCCVehicleFixesDebug.Warning = createLogger("WARNING", 3) -- Yellow
    BCCVehicleFixesDebug.Success = createLogger("SUCCESS", 2) -- Green

    -- Make it globally available
    _G.BCCVehicleFixesDebug = BCCVehicleFixesDebug
end
