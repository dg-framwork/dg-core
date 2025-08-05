DGCORE = DGCORE or {}
DGCORE.Client = DGCORE.Client or {}
DGCORE = DGCORE or {}
DGCORE.Client = DGCORE.Client or {}
DGCORE.Client.Cache = {}

-- グローバルキャッシュテーブルが存在しない場合に初期化します
DGCORE.Cache = DGCORE.Cache or {}
DGCORE.Cache.User = DGCORE.Cache.User or {}
DGCORE.Cache.Users = DGCORE.Cache.Users or {}
DGCORE.Cache.Items = DGCORE.Cache.Items or {}

--- データセットからキャッシュテーブルを生成するためのヘルパー関数
-- @param dataset table キャッシュするデータオブジェクトのリスト
-- @param cacheTable table 格納先のキャッシュテーブル
-- @param modelLoader function データオブジェクトをモデルにロードする関数
-- @param keyField string キャッシュテーブルのキーとして使用するフィールド名
local function _populateCache(dataset, cacheTable, modelLoader, keyField)
    if not dataset or type(dataset) ~= "table" then
        return
    end

    for _, data in ipairs(dataset) do
        if data and data[keyField] then
            local model = modelLoader(data)
            if model then
                cacheTable[data[keyField]] = model
            end
        end
    end
end

-- ローカルプレイヤーのユーザーキャッシュ
DGCORE.Client.Cache.User = {}

--- ローカルプレイヤーのユーザーオブジェクトをキャッシュに設定します
-- @param data table ユーザーデータ（rawテーブルまたは既存のユーザーオブジェクト）
function DGCORE.Client.Cache.User.Set(data)
    if not data or type(data) ~= "table" then
        print("[DGCORE]ユーザーキャッシュの設定に失敗しました：無効なデータです")
        return
    end

    local user = DGCORE.Model.User.Load(data)
    if user and user._type == DGCORE.Model.types.user then
        DGCORE.Cache.User = user
    else
        print("[DGCORE]ユーザーキャッシュの設定に失敗しました：有効なユーザーオブジェクトを読み込めませんでした")
    end
end

--- キャッシュからローカルプレイヤーのユーザーオブジェクトを取得します
-- @return table キャッシュされたユーザーオブジェクト
function DGCORE.Client.Cache.User.Get()
    return DGCORE.Cache.User
end

-- 全ユーザーのキャッシュ
DGCORE.Client.Cache.Users = {}

--- ユーザーオブジェクトのセットでキャッシュを生成します
-- @param dataset table ユーザーデータのリスト
function DGCORE.Client.Cache.Users.Set(dataset)
    _populateCache(dataset, DGCORE.Cache.Users, DGCORE.Model.User.Load, "license")
end

-- 全アイテムのキャッシュ
DGCORE.Client.Cache.Items = {}

--- アイテムオブジェクトのセットでキャッシュを生成します
-- @param dataset table アイテムデータのリスト
function DGCORE.Client.Cache.Items.Set(dataset)
    _populateCache(dataset, DGCORE.Cache.Items, DGCORE.Model.Item.Load, "id")
end
