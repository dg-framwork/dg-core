DGCORE = DGCORE or {}
DGCORE.Model = DGCORE.Model or {}

DGCORE.Model.User = {}

-- Helper to safely decode a field that might be a JSON string or a table
local function _tryDecodeJson(value)
    if type(value) == "table" then
        return value
    end
    if type(value) == "string" and value ~= "" then
        local success, decoded = pcall(json.decode, value)
        if success and type(decoded) == "table" then
            return decoded
        else
            print("[DGCORE]DGCORE.Model.User: JSON decoding failed for value: " .. tostring(value))
        end
    end
    return {} -- Return empty table as a fallback
end

function DGCORE.Model.User.new(data)
    local self = {}

    -- Copy properties from data table, applying defaults for nil values
    self.id             = data.id
    self.license        = data.license
    self.username       = data.username or "Unknown"
    self.is_admin       = data.is_admin or 0
    self.is_ban         = data.is_ban or 0
    self.ban_reason     = data.ban_reason or ""
    self.is_whitelist   = data.is_whitelist or 0

    -- Decode position and metadata from JSON string or use as table
    self.position       = _tryDecodeJson(data.position)
    self.metadata       = _tryDecodeJson(data.metadata)

    -- Set runtime properties with defaults
    self._type          = DGCORE.Model.types.user
    self.health         = data.health or 0
    self.armour         = data.armour or 0
    self.stamina        = data.stamina or 0
    self.is_online      = data.is_online or false
    self.is_restrained  = data.is_restrained or false
    self.source         = data.source or nil

    -- 両方用関数
    function self:SetSelfHealth(value)
        if value and type(value) == "number" then self.health = value; return true end
        return false
    end

    function self:SetSelfArmour(value)
        if value and type(value) == "number" then self.armour = value; return true end
        return false
    end

    function self:SetSelfStamina(value)
        if value and type(value) == "number" then self.stamina = value; return true end
        return false
    end
    function self:SetOnline() self.is_online = true; return true end
    function self:SetOffline() self.is_online = false; return true end
    function self:IsOnline() return self.is_online end
    function self:SetPosition(x, y, z)
        if type(x) == "number" and type(y) == "number" and type(z) == "number" then
            self.position = { x = x, y = y, z = z }
            return true
        end
        return false
    end
    function self:SetMetadata(key, value) self.metadata[key] = value; return true end

    if IsDuplicityVersion() then
        -- サーバー用関数
        function self:GrantAdmin() self.is_admin = 1; return true end
        function self:RevokeAdmin() self.is_admin = 0; return true end
        function self:GrantWhitelist() self.is_whitelist = 1; return true end
        function self:RevokeWhitelist() self.is_whitelist = 0; return true end

        function self:SetBan(reason)
            if reason and type(reason) == "string" then
                self.is_ban, self.ban_reason = 1, reason
                return true
            end
            return false
        end

        function self:UnBan() self.is_ban, self.ban_reason = 0, ""; return true end

        function self:SetRestrained(value)
            if type(value) == "boolean" then self.is_restrained = value
            elseif type(value) == "number" then self.is_restrained = value == 1 end
        end

        function self:IsRestrained() return self.is_restrained end

        function self:SetResourceStatus(resource, key, value)
            if not resource or not key or value == nil then return false end

            self.metadata[resource] = self.metadata[resource] or {}
            self.metadata[resource][key] = value
        end

        function self:GetResourceStatus(resource, key)
            if self.metadata[resource] and self.metadata[resource][key] then
                return self.metadata[resource][key]
            end
            return nil
        end

        function self:GetResourceMetadata(resource)
            if self.metadata[resource] then
                return self.metadata[resource]
            end
            return nil
        end

        function self:toInsert()
            return {
                self.id, self.license, self.username,
                json.encode(self.position or {}), self.health, self.armour, self.is_admin, self.is_ban,
                self.ban_reason, self.is_whitelist, json.encode(self.metadata or {})
            }
        end

        function self:toUpdate()
            return {
                self.username, json.encode(self.position or {}), self.health, self.armour, self.is_admin,
                self.is_ban, self.ban_reason, self.is_whitelist,
                json.encode(self.metadata or {}), self.id
            }
        end

        function self:toClient()
            return {
                id = self.id, license = self.license, username = self.username,
                position = self.position, health = self.health, armour = self.armour, is_admin = self.is_admin, is_ban = self.is_ban,
                ban_reason = self.ban_reason, is_whitelist = self.is_whitelist, metadata = self.metadata
            }
        end

        function self:Save(cb)
            if DGCORE.Config.Server.UseAsyncQuery then
                DGCORE.Server.Database.User.SelectById(self.id, function (results)
                    if #results == 0 then DGCORE.Server.Database.User.Insert(self, cb)
                    else DGCORE.Server.Database.User.Update(self, cb) end
                end)
            else
                local success, results = DGCORE.Server.Database.User.SelectById(self.id)
                if success then
                    if results and #results == 0 then
                        DGCORE.Server.Database.User.Insert(self)
                    else
                        DGCORE.Server.Database.User.Update(self)
                    end
                end
                if cb then cb() end
            end
        end
    else
        -- クライアント用関数
        function self:GetPedId() return PlayerPedId() end

        function self:SetHealth(value)
            if type(value) == "number" then
                local health = math.max(value, 0) + 100
                local s, e = pcall(SetEntityHealth, self:GetPedId(), health)
                if not s then print(("[DGCORE]SetHealth Error: %s"):format(e)) end
                return s
            end
            return false
        end

        function self:GetCurrentHealth() return GetEntityHealth(self:GetPedId()) - 100 end
        function self:FullHealth() return self:SetHealth(100) end

        function self:HealthHeal(value)
            if type(value) == "number" then return self:SetHealth(math.min(self:GetCurrentHealth() + value, 100)) end
            return false
        end

        function self:SetArmour(value)
            if type(value) == "number" then
                local s, e = pcall(SetPedArmour, self:GetPedId(), value)
                if not s then print(("[DGCORE]SetArmour Error: %s"):format(e)) end
                return s
            end
            return false
        end

        function self:GetCurrentArmour() return GetPedArmour(self:GetPedId()) end
        function self:FullArmour() return self:SetArmour(100) end

        function self:ArmourHeal(value)
            if type(value) == "number" then return self:SetArmour(math.min(self:GetCurrentArmour() + value, 100)) end
            return false
        end

        function self:SetSelfStamina(value) if type(value) == "number" then self.stamina = value; return true end; return false end

        function self:GetStamina()
            local s, r = pcall(GetPlayerSprintStaminaRemaining, self:GetPedId())
            if s then return r * 100 else print(("[DGCORE]GetStamina Error: %s"):format(r)) end
            return false
        end

        function self:GetPosition()
            local s, pos = pcall(GetEntityCoords, self:GetPedId())
            if s then return { x = pos.x, y = pos.y, z = pos.z } else print(("[DGCORE]GetPosition Error: %s"):format(pos)) end
            return nil
        end

        function self:toServer()
            return {
                id = self.id, license = self.license, username = self.username, position = self.position,
                is_admin = self.is_admin, is_ban = self.is_ban, ban_reason = self.ban_reason,
                is_whitelist = self.is_whitelist, metadata = self.metadata
            }
        end

        function self:toUI()
            return {
                id = self.id, license = self.license, username = self.username, position = self.position,
                is_admin = self.is_admin, is_ban = self.is_ban, ban_reason = self.ban_reason,
                is_whitelist = self.is_whitelist, metadata = self.metadata, health = self.health, armour = self.armour,
                stamina = self.stamina, is_online = self.is_online, is_restrained = self.is_restrained, source = self.source
            }
        end

        function self:SetRestrained(value)
            if type(value) == "boolean" then self.is_restrained = value
            elseif type(value) == "number" then self.is_restrained = value == 1 end
        end

        function self:IsDead()
            local s, r = pcall(IsEntityDead, self:GetPedId())
            if not s then print(("[DGCORE]IsDead Error: %s"):format(r)) end
            return r or false
        end

        function self:FreezePlayer() FreezeEntityPosition(self:GetPedId(), true); ClearPedTasksImmediately(self:GetPedId()) end

        function self:Teleport(x, y, z)
            if type(x) == "number" and type(y) == "number" and type(z) == "number" then
                local s, e = pcall(SetEntityCoords, self:GetPedId(), x, y, z, false, false, false, true)
                if not s then print(("[DGCORE]Teleport Error: %s"):format(e)) end
                return s
            end
            return false
        end

        function self:PlayAnimation(dict, anim, flag, duration)
            local ped = self:GetPedId()
            if not HasAnimDictLoaded(dict) then RequestAnimDict(dict); while not HasAnimDictLoaded(dict) do Citizen.Wait(10) end end
            TaskPlayAnim(ped, dict, anim, 8.0, -8.0, duration or -1, flag or 1, 0, false, false, false)
        end

        function self:ClearAnimations() ClearPedTasksImmediately(self:GetPedId()) end

        function self:RevivePlayer()
            local ped = self:GetPedId()
            if IsEntityDead(ped) then
                ResurrectPed(ped); ClearPedTasksImmediately(ped); SetEntityHealth(ped, 200)
                NetworkResurrectLocalPlayer(GetEntityCoords(ped), GetEntityHeading(ped), true, false)
                ClearPedBloodDamage(ped)
            end
        end

        function self:KnockoutPlayer()
            local ped = self:GetPedId()
            if not IsEntityDead(ped) then
                self:PlayAnimation("missarmenian2", "drunk_loop", 1, -1)
                SetPedToRagdoll(ped, 5000, 5000, 0, false, false, false)
            end
        end

        function self:SitOnGround() self:PlayAnimation("anim@heists@fleeca_bank@ig_7", "kneel_loop_p", 1, -1) end
        function self:LayDown() self:PlayAnimation("missfinale_c1@ledouard@base", "dead_idle", 1, -1) end
        function self:Surrender() self:PlayAnimation("random@arrests", "idle_2_hands_up", 1, -1) end
        function self:GetUp() self:ClearAnimations() end

        function self:RequestCarryNearPlayer()
            local ped, playerCoords = self:GetPedId(), GetEntityCoords(self:GetPedId())
            local closestPlayer, closestDist = nil, 3.0
            for _, playerId in ipairs(GetActivePlayers()) do
                local targetPed = GetPlayerPed(playerId)
                if targetPed ~= ped then
                    local dist = #(playerCoords - GetEntityCoords(targetPed))
                    if dist < closestDist then closestPlayer, closestDist = playerId, dist end
                end
            end
            if closestPlayer then TriggerServerEvent(DGCORE.Events.Server.User.carry, GetPlayerServerId(closestPlayer))
            else print("[DGCORE]Near No Player !!") end
        end

        function self:BeCarriedBy(carrierSrc)
            local targetPlayer = GetPlayerFromServerId(carrierSrc)
            if targetPlayer == -1 then return end
            local targetPed = GetPlayerPed(targetPlayer)
            AttachEntityToEntity(self:GetPedId(), targetPed, 0, 0.27, 0.15, 0.63, 0.0, 0.0, 0.0, true, true, false, true, 2, true)
        end

        function self:DetachFromCarrier() DetachEntity(self:GetPedId(), true, false) end
    end

    return self
end

function DGCORE.Model.User.Load(data)
    if data and type(data) == "table" then
        return DGCORE.Model.User.new(data)
    end
    return false
end

-- サーバー用関数
if IsDuplicityVersion() then
    function DGCORE.Model.User.Create(license, username, cb)
        if not username or not license then
            if cb then return cb(false, "[DGCORE]ユーザー名またはライセンスがnilです") else return false, "[DGCORE]ユーザー名またはライセンスがnilです" end
        end

        if not license:match("^license:[%x]+$") then
            if cb then return cb(false, "[DGCORE]不正なライセンスフォーマットです") else return false, "[DGCORE]不正なライセンスフォーマットです" end
        end

        local function _onIdGenerated(id)
            local user = DGCORE.Model.User.new({
                id = id,
                license = license,
                username = username,
                position = DGCORE.Config.User.DefaultSpawnPosition,
                health = DGCORE.Config.User.DefaultHealth,
                armour = DGCORE.Config.User.DefaultArmour,
                is_admin = 0,
                is_ban = 0,
                ban_reason = "",
                is_whitelist = 0,
                metadata = {}
            })

            if cb then
                user:Save(function() cb(user, nil) end)
            else
                user:Save()
                return user, nil
            end
        end

        if DGCORE.Config.Server.UseAsyncQuery then
            DGCORE.Model.User.GenerateUUID(function(id) _onIdGenerated(id) end)
        else
            return _onIdGenerated(DGCORE.Model.User.GenerateUUID())
        end
    end

    function DGCORE.Model.User.GenerateUUID(cb)
        local id = DGCORE.Utils.GenerateUUID()

        if DGCORE.Config.Server.UseAsyncQuery then
            DGCORE.Server.Database.User.SelectById(id, function (results)
                if #results == 0 then cb(id)
                else DGCORE.Model.User.GenerateUUID(cb) end
            end)
        else
            local results = DGCORE.Server.Database.User.SelectById(id)
            if #results == 0 then return id
            else return DGCORE.Model.User.GenerateUUID() end
        end
    end
end