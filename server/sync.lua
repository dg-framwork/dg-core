DGCORE = DGCORE or {}
DGCORE.Server = DGCORE.Server or {}

DGCORE.Server.Sync = {}

local syncDataResource = {}

--- 外部リソースから同期対象のデータを登録します
-- @param resource string 登録元のリソース名
-- @param key string データを一意に識別するためのキー
-- @param value table 同期するデータが含まれるテーブル
function DGCORE.Server.Sync.RegisterDataResource(resource, key, value)
    syncDataResource[resource] = syncDataResource[resource] or {}
    syncDataResource[resource][key] = value
end

--- データをチャンクに分割してクライアントに送信します
-- @param src number ターゲットクライアントのソースID
-- @param resource string データに関連するリソース名
-- @param key string データキー
-- @param dataList table 送信するデータのリスト
local function sendChunkedData(src, resource, key, dataList)
    local chunkSize = DGCORE.Config.Server.ChunkSize or 500
    for i = 1, #dataList, chunkSize do
        local chunk = {}
        local chunkEnd = math.min(i + chunkSize - 1, #dataList)
        for j = i, chunkEnd do
            table.insert(chunk, dataList[j])
        end

        local isLast = (chunkEnd == #dataList)
        TriggerClientEvent(DGCORE.Events.Client.Sync.syncChunk, src, resource, key, chunk, isLast)
        
        -- クライアント側の負荷を軽減するために待機します
        Citizen.Wait(50)
    end
end

--- クライアントからのデータ同期リクエストを処理します
-- @param src number リクエスト元のクライアントのソースID
-- @param resource string 要求されたデータのリソース名
-- @param key string 要求されたデータのキー
function DGCORE.Server.Sync.syncRequest(src, resource, key)
    local resourceData = syncDataResource[resource]
    if not resourceData or not resourceData[key] then
        return
    end

    local dataSource = resourceData[key]
    local dataToSend = {}
    for _, row in pairs(dataSource) do
        -- toClientメソッドを持つオブジェクトのみを対象とします
        if type(row.toClient) == "function" then
            table.insert(dataToSend, row:toClient())
        end
    end

    if #dataToSend > 0 then
        sendChunkedData(src, resource, key, dataToSend)
    end
end

function DGCORE.Server.Sync.Config(src)
    TriggerClientEvent(DGCORE.Events.Client.Sync.Config, src, DGCORE.Config.Server)
end

--- 単一のユーザーデータを対応するクライアントに同期します
-- @param user table 同期するユーザーオブジェクト
function DGCORE.Server.Sync.User(user)
    if not user or not user.source then return end
    TriggerClientEvent(DGCORE.Events.Client.Sync.User, user.source, user:toClient())
end

--- 特定のクライアントに対して全ユーザーデータの同期を開始します
-- @param src number ターゲットクライアントのソースID
function DGCORE.Server.Sync.Users(src)
    DGCORE.Server.Sync.syncRequest(src, DGCORE.Utils.GetResourceName(), DGCORE.Sync.keys.users)
end

--- 特定のクライアントに対して全アイテムデータの同期を開始します
-- @param src number ターゲットクライアントのソースID
function DGCORE.Server.Sync.Items(src)
    DGCORE.Server.Sync.syncRequest(src, DGCORE.Utils.GetResourceName(), DGCORE.Sync.keys.items)
end
