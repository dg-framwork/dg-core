DGCORE = DGCORE or {}
DGCORE.Server = DGCORE.Server or {}
DGCORE.Server.Database = DGCORE.Server.Database or {}

DGCORE.Server.Database.Item = {}

local tableName = "item"

local queries = {
    SelectAll = string.format("SELECT * FROM %s", tableName),
    SelectById = string.format("SELECT * FROM %s WHERE id = ?", tableName),
    Insert = string.format("INSERT INTO %s (id, label, description, category, image, is_stack, max_stack, unique, hash) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", tableName),
    Update = string.format("UPDATE %s SET label = ?, description = ?, category = ?, image = ?, is_stack = ?, max_stack = ?, unique = ?, hash = ? WHERE id = ?", tableName)
}

function DGCORE.Server.Database.Item.SelectAll(cb)
    return DGCORE.Server.Database.fetch(queries.SelectAll, {}, cb)
end

function DGCORE.Server.Database.Item.SelectById(id, cb)
    return DGCORE.Server.Database.fetch(queries.SelectById, { id }, cb)
end

function DGCORE.Server.Database.Item.Insert(item, cb)
    return DGCORE.Server.Database.insert(queries.Insert, item:toInsert(), cb)
end

function DGCORE.Server.Database.Item.Update(item, cb)
    return DGCORE.Server.Database.update(queries.Update, item:toUpdate(), cb)
end
