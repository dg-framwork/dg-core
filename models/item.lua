DGCORE = DGCORE or {}
DGCORE.Model = DGCORE.Model or {}

DGCORE.Model.Item = {}

local function _tryDecodeJson(value)
    if type(value) == "table" then
        return value
    end
    if type(value) == "string" and value ~= "" then
        local success, decode = pcall(json.decode, value)
        if success and type(decode) == "table" then
            return decode
        else
            print("[DGCORE]DGCORE.Model.Item: JSON decoding failed for value: " .. tostring(value))
        end
    end
    return {}
end

function DGCORE.Model.Item.new(data)
    local self = {}

    self.id             = data.id
    self.label          = data.label
    self.description    = data.description
    self.category       = data.category
    self.image          = data.image
    self.is_stack       = data.is_stack
    self.max_stack      = data.max_stack
    self.unique         = data.unique
    self.hash           = data.hash
    
    self.metadata       = _tryDecodeJson(data.metadata)

    self._type = DGCORE.Model.types.item

    if IsDuplicityVersion() then
        -- サーバー用関数
        function self:toInsert()
            return {
                self.id, self.label, self.description, self.category,
                self.image, self.is_stack, self.max_stack, self.unique,
                self.hash, json.encode(self.metadata)
            }
        end

        function self:toUpdate()
            return {
                self.label, self.description, self.category,
                self.image, self.is_stack, self.max_stack, self.unique,
                self.hash, json.encode(self.metadata), self.id
            }
        end

        function self:toClient()
            return {
                id = self.id,
                label = self.label,
                description = self.description,
                category = self.category,
                image = self.image,
                is_stack = self.is_stack,
                max_stack = self.max_stack,
                unique = self.unique,
                hash = self.hash,
                metadata = self.metadata
            }
        end

        function self:Save(cb)
            if DGCORE.Config.Server.UseAsyncQuery then
                DGCORE.Server.Database.Item.SelectById(self.id, function (results)
                    if #results == 0 then DGCORE.Server.Database.Item.Insert(self, cb)
                    else DGCORE.Server.Database.Item.Update(self, cb) end
                end)
            else
                local success, results = DGCORE.Server.Database.Item.SelectById(self.id)
                if success then
                    if results and #results == 0 then
                        DGCORE.Server.Database.Item.Insert(self)
                    else
                        DGCORE.Server.Database.Item.Update(self)
                    end
                end
                if cb then cb() end
            end
        end
    else
        -- クライアント側関数
        function self:toServer()
            return {
                self.id, self.label, self.description, self.category,
                self.image, self.is_stack, self.max_stack, self.unique,
                self.hash, json.encode(self.metadata)
            }
        end

        function self:toUI()
            return {
                id = self.id,
                label = self.label,
                description = self.description,
                category = self.category,
                image = self.image,
                is_stack = self.is_stack,
                max_stack = self.max_stack,
                unique = self.unique,
                hash = self.hash,
                metadata = self.metadata
            }
        end
    end

    return self
end

function DGCORE.Model.Item.Load(data)
    if data and type(data) == "table" then
        return DGCORE.Model.Item.new(data)
    end
    return false
end

if IsDuplicityVersion() then
    function DGCORE.Model.Item.Create(label, description, category, image, is_stack, max_stack, unique, hash, cb)
        if not label and not description and not category and not image and not is_stack and not max_stack and not unique and not hash then
            if cb then return cb(false, "[DGCORE]引数にnilが含まれています") else return false, "[DGCORE]引数にnilが含まれています" end
        end

        local function _onIdGenerated(id)
            local item = DGCORE.Model.Item.new({
                id = id,
                label = label,
                description = description,
                category = category,
                image = image,
                is_stack = is_stack,
                max_stack = max_stack,
                unique = unique,
                hash = hash,
                metadata = {}
            })

            if cb then
                item:Save(function() cb(item, nil) end)
            else
                item:Save()
                return item, nil
            end
        end

        if DGCORE.Config.Server.UseAsyncQuery then
            DGCORE.Model.Item.GenerateUUID(function(id) _onIdGenerated(id) end)
        else
            return _onIdGenerated(DGCORE.Model.Item.GenerateUUID())
        end
    end

    function DGCORE.Model.Item.GenerateUUID(cb)
        local id = DGCORE.Utils.GenerateUUID()

        if DGCORE.Config.Server.UseAsyncQuery then
            DGCORE.Server.Database.Item.SelectById(id, function (results)
                if #results == 0 then cb(id)
                else DGCORE.Model.Item.GenerateUUID(cb) end
            end)
        else
            local results = DGCORE.Server.Database.Item.SelectById(id)
            if #results == 0 then return id
            else return DGCORE.Model.Item.GenerateUUID() end
        end
    end
end
