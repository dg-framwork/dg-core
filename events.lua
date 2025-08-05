DGCORE = DGCORE or {}

DGCORE.Events = {}

DGCORE.Events.Client = {
    Core = {
        onClientResourceStart = "onClientResourceStart"
    },
    Sync = {
        Config = "DGCORE:Client:Sync:Config",
        User = "DGCORE:Client:Sync:User",
        Users = "DGCORE:Client:Sync:Users",
        Items = "DGCORE:Client:Sync:Items",
        syncChunk = "DGCORE:Client:Sync:syncChunk"
    }
}

DGCORE.Events.Server = {
    Core = {
        onResourceStart = "onResourceStart",
        playerConnecting = "playerConnecting",
        playerDropped = "playerDropped",
        Ready = "DGCORE:Server:Core:Ready"
    },
    Sync = {
        Request = "DGCORE:Server:Sync:Request",
        RequestConfig = "DGCORE:Server:Sync:RequestConfig",
        RequestUser = "DGCORE:Server:Sync:RequestUser"
    }
}