DGCORE = DGCORE or {}

--[[--------------------------------------------------------------------------
    Dynamically creates admin commands to get and update server configurations.
    Commands are generated based on the DGCORE.Events.Server.Config table.

    Examples:
    /config_get_closed       - Prints the current value of DGCORE.Config.Server.Closed
    /config_update_closed true - Sets DGCORE.Config.Server.Closed to true
---------------------------------------------------------------------------]]

-- Helper function to create a command that prints a config value.
local function createGetterCommand(commandName, configKey)
    RegisterCommand(commandName, function(source, args, rawCommand)
        local value = DGCORE.Config.Server[configKey]
        print(string.format("[DGCORE] Config '%s' is currently: %s", configKey, tostring(value)))
    end, true) -- restricted = true (admin only)
end

-- Helper function to create a command that updates a config value.
local function createUpdaterCommand(commandName, configKey)
    RegisterCommand(commandName, function(source, args, rawCommand)
        local valueStr = args[1]
        if not valueStr then
            print(string.format("[DGCORE] Usage: /%s <value>", commandName))
            return
        end

        local currentValue = DGCORE.Config.Server[configKey]
        local updatedValue

        -- Convert the input string to the correct type (boolean, number, etc.)
        if type(currentValue) == "boolean" then
            updatedValue = (valueStr == "true" or valueStr == "1")
        elseif type(currentValue) == "number" then
            updatedValue = tonumber(valueStr)
            if not updatedValue then
                print(string.format("[DGCORE] Invalid value for %s: '%s'. Expected a number.", configKey, valueStr))
                return
            end
        else
            -- For any other type, just use the string value.
            updatedValue = valueStr
        end

        DGCORE.Config.Server[configKey] = updatedValue
        print(string.format("[DGCORE] Config '%s' has been updated to: %s", configKey, tostring(updatedValue)))

    end, true) -- restricted = true (admin only)
end

-- Iterate over the server config events and create commands for each.
for key, _ in pairs(DGCORE.Events.Server.Config) do
    -- key is "Closed", "Whitelist", "Debug", etc.
    local lowerKey = string.lower(key)

    -- Create the getter command (e.g., /config_get_closed)
    createGetterCommand("config_get_" .. lowerKey, key)

    -- Create the updater command (e.g., /config_update_closed)
    createUpdaterCommand("config_update_" .. lowerKey, key)
end

print("[DGCORE] Admin commands for configuration have been loaded.")
