local function onResourceStart(resource)
    if resource == GetCurrentResourceName() then
        DGCORE.Server.Cache.All()
        DGCORE.Server.Sync.RegisterDataResource(DGCORE.Utils.GetResourceName(), DGCORE.Sync.keys.users, DGCORE.Cache.Users)
        DGCORE.Server.Sync.RegisterDataResource(DGCORE.Utils.GetResourceName(), DGCORE.Sync.keys.items, DGCORE.Cache.Items)
    end
end

local function processPlayerLogin(user, reason, src, deferrals)
    if not user then
        return deferrals.done(("[DGCORE]ユーザー登録に失敗しました： %s"):format(reason or "不明なエラー"))
    end

    if DGCORE.Config.Server.Closed and user.is_admin == 0 then
        return deferrals.done("[DGCORE]メンテナンスモード起動中…（管理者のみ参加可能です）")
    end

    if DGCORE.Config.Server.Whitelist and not user.is_whitelist then
        return deferrals.done("[DGCORE]ホワイトリストに登録されていません")
    end

    if user.is_ban == 1 then
        return deferrals.done(("[DGCORE]あなたは Ban されています： %s"):format(user.reason))
    end

    user:SetOnline()
    DGCORE.Server.Cache.Users.Update(user)

    print(("[DGCORE]%s が参加しました（ライセンス： %s）"):format(user.username, user.license))
    deferrals.done()
end

local function playerConnecting(src, deferrals)
    Citizen.Wait(0)

    local username = DGCORE.Utils.GetUsername(src)
    local license = DGCORE.Utils.GetLicense(src)

    if not username or not license then
        return deferrals.done("[DGCORE]ユーザー名またはライセンスの取得に失敗しました")
    end

    local user = DGCORE.User.GetByLicense(license)
    if user then
        return processPlayerLogin(user, nil, src, deferrals)
    end

    if DGCORE.Config.Server.UseAsyncQuery then
        DGCORE.Model.User.Create(license, username, function(newUser, reason)
            processPlayerLogin(newUser, reason, src, deferrals)
        end)
    else
        local newUser, reason = DGCORE.Model.User.Create(license, username)
        processPlayerLogin(newUser, reason, src, deferrals)
    end
end

local function playerDropped(src)
    local license = DGCORE.Utils.GetLicense(src)
    if not license then return end

    local user = DGCORE.User.GetByLicense(license)
    if not user then return end

    local ped = GetPlayerPed(src)
    if ped and DoesEntityExist(ped) then
        local coords = GetEntityCoords(ped)
        user:SetPosition(coords.x, coords.y, coords.z)
        user:SetSelfHealth(GetEntityHealth(ped))
        user:SetSelfArmour(GetEntityArmour(ped))
    end
    user:SetOffline()
    DGCORE.Server.Cache.Users.Delete(user)

    local function onSave()
        print(("[DGCORE]%s (%s)が退出しました"):format(user.username, user.license))
    end

    if DGCORE.Config.Server.UseAsyncQuery then
        user:Save(onSave)
    else
        user:Save()
        onSave()
    end
end

RegisterNetEvent(DGCORE.Events.Server.Core.onResourceStart)
AddEventHandler(DGCORE.Events.Server.Core.onResourceStart, function (resource)
    onResourceStart(resource)
end)

RegisterNetEvent(DGCORE.Events.Server.Core.playerConnecting)
AddEventHandler(DGCORE.Events.Server.Core.playerConnecting, function (_, _, deferrals)
    playerConnecting(source, deferrals)
end)

RegisterNetEvent(DGCORE.Events.Server.Core.playerDropped)
AddEventHandler(DGCORE.Events.Server.Core.playerDropped, function ()
    playerDropped(source)
end)

RegisterNetEvent(DGCORE.Events.Server.Core.Ready)
AddEventHandler(DGCORE.Events.Server.Core.Ready, function ()
    local src = source
    local user = DGCORE.User.GetBySource(src)

    if not user then
        print(("[DGCORE]Ready Event: Could not find user for source %s."):format(src))
        return
    end

    -- The 'source' from playerConnecting is temporary. We now have the permanent ID,
    -- so we update it in the user's cache object before syncing.
    user.source = src
    DGCORE.Server.Cache.Users.Update(user)

    -- Sync all necessary data to the newly ready client
    DGCORE.Server.Sync.Config(src)
    DGCORE.Server.Sync.User(user)
    DGCORE.Server.Sync.Users(src)
    DGCORE.Server.Sync.Items(src)
end)
