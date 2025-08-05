DGCORE = DGCORE or {}
DGCORE.Server = DGCORE.Server or {}
DGCORE.Server.Database = DGCORE.Server.Database or {}

local activeQueries = 0
local queryQueue = {}

--[[--------------------------------------------------------------------------
    Private: Queue Processing
    Manages the execution of asynchronous database queries, respecting the
    maximum number of concurrent queries defined in the config.
---------------------------------------------------------------------------]]
local function processQueue()
    if activeQueries >= DGCORE.Config.Server.MaxQueries or #queryQueue == 0 then
        return
    end

    local q = table.remove(queryQueue, 1)
    activeQueries = activeQueries + 1

    Citizen.CreateThread(function()
        local success, result = pcall(q.func, table.unpack(q.args))

        activeQueries = activeQueries - 1

        if q.cb then
            if success then
                q.cb(result)
            else
                print(string.format("[DGCORE] SQL Error: %s", tostring(result)))
                q.cb(nil) -- Ensure callback receives nil on error
            end
        end

        processQueue() -- Attempt to process the next item in the queue
    end)
end

local function enqueue(func, args, cb)
    table.insert(queryQueue, { func = func, args = args, cb = cb })

    if #queryQueue % 100 == 0 then
        print(string.format("[DGCORE] Warning: The database query queue has over %d pending items!", #queryQueue))
    end

    processQueue()
end

--[[--------------------------------------------------------------------------
    Private: API Method Factory
    Creates the public database functions (fetch, insert, etc.) by wrapping
    the core oxmysql functions with our sync/async logic.
---------------------------------------------------------------------------]]
-- Helper to ensure fetch results are always in a consistent table format.
local function _formatFetchResult(result)
    if not result then return {} end
    -- Wrap a single row result in a table to match multi-row results
    if type(result) == "table" and not result[1] then return { result } end
    return result
end

-- Factory function to generate our public API methods.
local function _createDbApiMethod(mysqlFunc, options)
    options = options or {}

    return function(query, params, cb)
        if options.debugName and DGCORE.Config.Server.Debug then
            print(string.format("[DGCORE] DB:%s called (async: %s)", options.debugName, tostring(DGCORE.Config.Server.UseAsyncQuery)))
        end

        -- The core function to execute, with an optional result processor.
        local executor = function(q, p)
            local result = mysqlFunc(q, p)
            if options.resultProcessor then
                return options.resultProcessor(result)
            end
            return result
        end

        if DGCORE.Config.Server.UseAsyncQuery then
            enqueue(executor, { query, params }, cb)
        else
            local success, result = pcall(executor, query, params)
            if success then
                return true, result
            else
                print(string.format("[DGCORE] SQL Error: %s", tostring(result)))
                return false, result
            end
        end
    end
end

--[[--------------------------------------------------------------------------
    Public API
    The public interface for all database interactions.
---------------------------------------------------------------------------]]
-- Selects data from the database.
DGCORE.Server.Database.fetch = _createDbApiMethod(MySQL.prepare.await, {
    debugName = "fetch",
    resultProcessor = _formatFetchResult
})

-- Inserts a new record into the database.
DGCORE.Server.Database.insert = _createDbApiMethod(MySQL.insert.await, { debugName = "insert" })

-- Updates an existing record in the database.
DGCORE.Server.Database.update = _createDbApiMethod(MySQL.update.await, { debugName = "update" })

-- Executes a query that does not return data (e.g., DELETE).
DGCORE.Server.Database.execute = _createDbApiMethod(MySQL.execute, { debugName = "execute" })
