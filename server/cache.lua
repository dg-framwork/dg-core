DGCORE = DGCORE or {}
DGCORE.Server = DGCORE.Server or {}

DGCORE.Server.Cache = {}

--[[
    Private Caching Functions
]]

local function _cachedUsers(users)
    if not users or type(users) ~= "table" then
        return 0
    end

    local count = 0
    DGCORE.Cache.Users = {}

    for _, row in ipairs(users) do
        local user = DGCORE.Model.User.Load(row)
        if user and user._type == DGCORE.Model.types.user then
            DGCORE.Cache.Users[user.license] = user
            count = count + 1
        end
    end
    return count
end

local function _cachedItems(items)
    if not items or type(items) ~= "table" then
        return 0
    end

    local count = 0
    DGCORE.Cache.Items = {}
    for _, row in ipairs(items) do
        local item = DGCORE.Model.Item.Load(row)
        if item and item._type == DGCORE.Model.types.item then
            DGCORE.Cache.Items[item.id] = item
            count = count + 1
        end
    end
    return count
end

-- Generic loader to reduce code duplication
local function loadCache(options)
    local dbSelectAll = options.dbSelectAll
    local cacheProcessor = options.cacheProcessor
    local entityName = options.entityName

    -- Async callback
    local function onComplete(results)
        if not results then
            print(("[DGCORE]%s情報のキャッシュ化処理に失敗しました（データ取得エラー）"):format(entityName))
            return
        end
        local count = cacheProcessor(results)
        print(("[DGCORE]%d 件の%s情報をキャッシュ化処理に成功しました"):format(count, entityName))
    end

    if DGCORE.Config.Server.UseAsyncQuery then
        dbSelectAll(onComplete)
    else
        local success, results = dbSelectAll()
        if success and results then
            onComplete(results)
        else
            print(("[DGCORE]%s情報のキャッシュ化処理に失敗しました"):format(entityName))
            print(("[DGCORE]Error details: %s"):format(tostring(results)))
        end
    end
end

--[[
    Public API
]]

function DGCORE.Server.Cache.All()
    DGCORE.Server.Cache.Users.Load()
    DGCORE.Server.Cache.Items.Load()
end

-- User Cache
DGCORE.Server.Cache.Users = {}
function DGCORE.Server.Cache.Users.Load()
    loadCache({
        dbSelectAll = DGCORE.Server.Database.User.SelectAll,
        cacheProcessor = _cachedUsers,
        entityName = "ユーザー"
    })
end

function DGCORE.Server.Cache.Users.Update(user)
    if user and user.license then
        DGCORE.Cache.Users[user.license] = user
    else
        print("[DGCORE]ユーザー情報キャッシュの更新に失敗しました：無効なユーザーデータです")
    end
end

function DGCORE.Server.Cache.Users.Delete(user)
    if user and user.license then
        DGCORE.Cache.Users[user.license] = nil
    else
        print("[DGCORE]ユーザー情報キャッシュの削除に失敗しました：無効なユーザーデータです")
    end
end

-- Item Cache
DGCORE.Server.Cache.Items = {}
function DGCORE.Server.Cache.Items.Load()
    loadCache({
        dbSelectAll = DGCORE.Server.Database.Item.SelectAll,
        cacheProcessor = _cachedItems,
        entityName = "アイテム"
    })
end

function DGCORE.Server.Cache.Items.Update(item)
    if item and item.id then
        DGCORE.Cache.Items[item.id] = item
    else
        print("[DGCORE]アイテム情報キャッシュの更新に失敗しました：無効なアイテムデータです")
    end
end

function DGCORE.Server.Cache.Items.Delete(item)
    if item and item.id then
        DGCORE.Cache.Items[item.id] = nil
    else
        print("[DGCORE]アイテム情報キャッシュの更新に失敗しました：無効なアイテムデータです")
    end
end
