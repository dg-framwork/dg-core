RegisterNetEvent(DGCORE.Events.Server.Sync.Request)
AddEventHandler(DGCORE.Events.Server.Sync.Request, function (resource, key)
    DGCORE.Server.Sync.syncRequest(source, resource, key)
end)

RegisterNetEvent(DGCORE.Events.Server.Sync.RequestConfig)
AddEventHandler(DGCORE.Events.Server.Sync.RequestConfig, function ()
    DGCORE.Server.Sync.Config(source)
end)

RegisterNetEvent(DGCORE.Events.Server.Sync.RequestUser)
AddEventHandler(DGCORE.Events.Server.Sync.RequestUser, function ()
    local user = DGCORE.User.GetBySource(source)
    if user then
        DGCORE.Server.Sync.User(user)
    end
end)