--- Handles the resource start event to register necessary data synchronization handlers.
local function onClientResourceStart(resource)
    -- Only proceed if the event is for this resource.
    if resource ~= GetCurrentResourceName() then
        return
    end

    local resourceName = resource

    -- Helper to create a safe loader function for a given model.
    -- This ensures that the model and its .Load method exist before use.
    local function createModelLoader(model)
        return function(row)
            if model and model.Load then
                return model.Load(row)
            end
            return nil
        end
    end

    -- Register handlers for User data synchronization.
    DGCORE.Client.Sync.RegisterLoader(resourceName, DGCORE.Sync.keys.users, createModelLoader(DGCORE.Model.User))
    DGCORE.Client.Sync.RegisterCacheTarget(resourceName, DGCORE.Sync.keys.users, DGCORE.Cache.Users)
    DGCORE.Client.Sync.RegisterKeyField(resourceName, DGCORE.Sync.keys.users, "license")

    -- Register handlers for Item data synchronization.
    DGCORE.Client.Sync.RegisterLoader(resourceName, DGCORE.Sync.keys.items, createModelLoader(DGCORE.Model.Item))
    DGCORE.Client.Sync.RegisterCacheTarget(resourceName, DGCORE.Sync.keys.items, DGCORE.Cache.Items)
    DGCORE.Client.Sync.RegisterKeyField(resourceName, DGCORE.Sync.keys.items, "id")
end

-- Listen for the client resource start event.
RegisterNetEvent(DGCORE.Events.Client.Core.onClientResourceStart)
AddEventHandler(DGCORE.Events.Client.Core.onClientResourceStart, onClientResourceStart)

Citizen.CreateThread(function ()
    while not NetworkIsSessionStarted() do
        Citizen.Wait(100)
    end

    TriggerServerEvent(DGCORE.Events.Server.Core.Ready)
end)