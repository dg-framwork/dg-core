DGCORE = DGCORE or {}
DGCORE.Server = DGCORE.Server or {}
DGCORE.Server.Database = DGCORE.Server.Database or {}
DGCORE.Server.Database.User = {}

--[[--------------------------------------------------------------------------
    Configuration
    Defines the table name and all SQL queries for the user model.
---------------------------------------------------------------------------]]
local tableName = "user"

local queries = {
    SelectAll = string.format("SELECT * FROM %s", tableName),
    SelectById = string.format("SELECT * FROM %s WHERE id = ?", tableName),
    Insert = string.format("INSERT INTO %s (id, license, username, position, health, armour, is_admin, is_ban, ban_reason, is_whitelist, metadata) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", tableName),
    Update = string.format("UPDATE %s SET username = ?, position = ?, health = ?, armour = ?, is_admin = ?, is_ban = ?, ban_reason = ?, is_whitelist = ?, metadata = ? WHERE id = ?", tableName),
    DeleteById = string.format("DELETE FROM %s WHERE id = ?", tableName)
}

--[[--------------------------------------------------------------------------
    Public API
    Functions to interact with the user table. These functions wrap the
    core database API, providing a clean interface for user-specific operations.
---------------------------------------------------------------------------]]

-- Selects all users from the database.
function DGCORE.Server.Database.User.SelectAll(cb)
    return DGCORE.Server.Database.fetch(queries.SelectAll, {}, cb)
end

-- Selects a single user by their unique ID.
function DGCORE.Server.Database.User.SelectById(id, cb)
    return DGCORE.Server.Database.fetch(queries.SelectById, { id }, cb)
end

-- Inserts a new user record into the database.
-- Expects a user object that has a `toInsert` method.
function DGCORE.Server.Database.User.Insert(user, cb)
    return DGCORE.Server.Database.insert(queries.Insert, user:toInsert(), cb)
end

-- Updates an existing user record in the database.
-- Expects a user object that has a `toUpdate` method.
function DGCORE.Server.Database.User.Update(user, cb)
    return DGCORE.Server.Database.update(queries.Update, user:toUpdate(), cb)
end

-- Deletes a user record from the database by their unique ID.
function DGCORE.Server.Database.User.DeleteById(id, cb)
    return DGCORE.Server.Database.execute(queries.DeleteById, { id }, cb)
end