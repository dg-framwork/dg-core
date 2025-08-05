RegisterNetEvent(DGCORE.Events.Client.Sync.Config)
AddEventHandler(DGCORE.Events.Client.Sync.Config, function (data)
    if not data then return end
    DGCORE.Config.Server.Set(data)
end)

RegisterNetEvent(DGCORE.Events.Client.Sync.User)
AddEventHandler(DGCORE.Events.Client.Sync.User, function (data)
    if not data then return end
    DGCORE.Client.Cache.User.Set(data)
end)

RegisterNetEvent(DGCORE.Events.Client.Sync.syncChunk)
AddEventHandler(DGCORE.Events.Client.Sync.syncChunk, function (resource, key, chunk, isLast)
    DGCORE.Client.Sync.chunk(resource, key, chunk, isLast)
end)
