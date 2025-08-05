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
    },
    Config = {
        Closed = {
            get = "DGCORE:Server:Config:Closed:get",
            update = "DGCORE:Server:Config:Closed:update",
        },
        Whitelist = {
            get = "DGCORE:Server:Config:Whitelist:get",
            update = "DGCORE:Server:Config:Whitelist:update",
        },
        Redis = {
            get = "DGCORE:Server:Config:Redis:get",
            update = "DGCORE:Server:Config:Redis:update",
        },
        ChunkSize = {
            get = "DGCORE:Server:Config:ChunkSize:get",
            update = "DGCORE:Server:Config:ChunkSize:update",
        },
        UseAsyncQuery = {
            get = "DGCORE:Server:Config:UseAsyncQuery:get",
            update = "DGCORE:Server:Config:UseAsyncQuery:update",
        },
        MaxQueries = {
            get = "DGCORE:Server:Config:MaxQueries:get",
            update = "DGCORE:Server:Config:MaxQueries:update",
        },
        Debug = {
            get = "DGCORE:Server:Config:Debug:get",
            update = "DGCORE:Server:Config:Debug:update",
        },
    },
}
