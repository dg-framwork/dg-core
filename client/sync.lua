DGCORE = DGCORE or {}
DGCORE.Client = DGCORE.Client or {}
DGCORE.Client.Sync = {}

-- Private tables to store registered handlers
local ReceivingCache = {}
local Loaders = {}
local CacheTargets = {}
local KeyFields = {}
local OnBefore = {}
local OnComplete = {}

--- Helper function to safely register a handler.
-- @param handlerMap table The map to store the handler (e.g., Loaders, OnComplete).
-- @param resource string The name of the resource registering the handler.
-- @param key string The unique key for the data type.
-- @param handler function The function or table to register.
-- @param handlerType string A string name for the handler type, used for error messages.
local function registerHandler(handlerMap, resource, key, handler, handlerType)
    handlerMap[resource] = handlerMap[resource] or {}
    if handlerMap[resource][key] then
        print(("[DGCORE]A %s for resource '%s' with key '%s' is already registered."):format(handlerType, resource, key))
        return
    end
    handlerMap[resource][key] = handler
end

--- Registers a loader function to process a single data row.
function DGCORE.Client.Sync.RegisterLoader(resource, key, func)
    registerHandler(Loaders, resource, key, func, "Loader")
end

--- Registers the target table where processed data will be cached.
function DGCORE.Client.Sync.RegisterCacheTarget(resource, key, value)
    registerHandler(CacheTargets, resource, key, value, "Cache Target")
end

--- Registers the key field (e.g., "id", "license") to be used for caching.
function DGCORE.Client.Sync.RegisterKeyField(resource, key, fieldName)
    registerHandler(KeyFields, resource, key, fieldName, "Key Field")
end

--- Registers a callback function to execute before data processing begins.
function DGCORE.Client.Sync.RegisterOnBefore(resource, key, func)
    registerHandler(OnBefore, resource, key, func, "OnBefore callback")
end

--- Registers a callback function to execute after data processing is complete.
function DGCORE.Client.Sync.RegisterOnComplete(resource, key, func)
    registerHandler(OnComplete, resource, key, func, "OnComplete callback")
end

--- Processes the fully received dataset after all chunks have arrived.
-- @param resource string The resource name.
-- @param key string The data key.
local function _processReceivedData(resource, key)
    local fullData = ReceivingCache[resource] and ReceivingCache[resource][key]
    if not fullData then return end

    -- Retrieve all necessary handlers
    local loader = Loaders[resource] and Loaders[resource][key]
    local cacheTarget = CacheTargets[resource] and CacheTargets[resource][key]
    local keyField = KeyFields[resource] and KeyFields[resource][key]
    local onBeforeCallback = OnBefore[resource] and OnBefore[resource][key]
    local onCompleteCallback = OnComplete[resource] and OnComplete[resource][key]

    -- A loader, a target, and a keyField are essential for processing
    if not loader or not cacheTarget or not keyField then
        print(("[DGCORE]Cannot process data for '%s':'%s'. Missing Loader, Cache Target, or KeyField registration."):format(resource, key))
        return
    end

    if onBeforeCallback then onBeforeCallback() end

    local count = 0
    for _, row in ipairs(fullData) do
        local model = loader(row)
        if model then
            local cacheKey = model[keyField]
            if cacheKey then
                cacheTarget[cacheKey] = model
                count = count + 1
            end
        end
    end

    if onCompleteCallback then onCompleteCallback() end

    print(("[DGCORE]Synced %d items for '%s'."):format(count, key))
end

--- Receives a chunk of data from the server and processes it when complete.
-- @param resource string The resource name.
-- @param key string The data key.
-- @param chunk table A chunk of the data.
-- @param isLast boolean True if this is the final chunk.
function DGCORE.Client.Sync.chunk(resource, key, chunk, isLast)
    ReceivingCache[resource] = ReceivingCache[resource] or {}
    ReceivingCache[resource][key] = ReceivingCache[resource][key] or {}

    for _, row in ipairs(chunk) do
        table.insert(ReceivingCache[resource][key], row)
    end

    if isLast then
        _processReceivedData(resource, key)
        ReceivingCache[resource][key] = nil
    end
end

--- Requests a full data sync from the server for a specific key.
-- @param key string The key of the data to request (e.g., DGCORE.Sync.keys.users).
function DGCORE.Client.Sync.Request(key)
    local resourceName = GetCurrentResourceName()
    TriggerServerEvent(DGCORE.Events.Server.Sync.Request, resourceName, key)
end

--- Requests a full sync of all registered data types from the server.
function DGCORE.Client.Sync.All()
    print("[DGCORE]Requesting full data sync from server...")
    Citizen.CreateThread(function()
        -- Request single-object syncs first
        TriggerServerEvent(DGCORE.Events.Server.Sync.RequestConfig)
        Citizen.Wait(100)
        TriggerServerEvent(DGCORE.Events.Server.Sync.RequestUser)
        Citizen.Wait(100)

        -- Then request list-based syncs
        if DGCORE.Sync and DGCORE.Sync.keys then
            for _, key in pairs(DGCORE.Sync.keys) do
                DGCORE.Client.Sync.Request(key)
                -- A small delay between requests to avoid potential network congestion
                Citizen.Wait(100)
            end
        else
            print("[DGCORE]Cannot perform list sync: DGCORE.Sync.keys is not defined.")
        end
    end)
end