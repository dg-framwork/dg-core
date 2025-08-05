DGCORE = DGCORE or {}
DGCORE.Client = DGCORE.Client or {}
DGCORE.Client.UI = DGCORE.Client.UI or {}

DGCORE.Client.UI.Debug = {}

local BASE_NUI_ACTION = "DGCORE:NUI:Debug:"

--- Helper to send a formatted NUI message.
-- @param name string The specific action name (e.g., "Show", "Config").
-- @param payload table The data to send with the message.
local function _sendNuiMessage(name, payload)
    local message = { action = BASE_NUI_ACTION .. name }
    if payload then
        for key, value in pairs(payload) do
            message[key] = value
        end
    end
    SendNUIMessage(message)
end

--- Helper to transform a table of models to their UI representation and send to NUI.
-- @param actionName string The NUI action name (e.g., "Users", "Items").
-- @param sourceTable table The table containing the models to transform.
local function _transformAndSendData(actionName, sourceTable)
    if not sourceTable or type(sourceTable) ~= "table" then
        print(("[DGCORE]Debug.%s: Source data is nil or not a table."):format(actionName))
        return
    end

    local transformedData = {}
    for _, model in pairs(sourceTable) do
        if model and type(model.toUI) == "function" then
            table.insert(transformedData, model:toUI())
        end
    end

    _sendNuiMessage(actionName, { [string.lower(actionName)] = transformedData })
end

--- Shows the debug UI.
function DGCORE.Client.UI.Debug.Show()
    _sendNuiMessage("Show")
end

--- Hides the debug UI.
function DGCORE.Client.UI.Debug.Hide()
    _sendNuiMessage("Hide")
end

function DGCORE.Client.UI.Debug.All()
    DGCORE.Client.UI.Debug.Config()
    DGCORE.Client.UI.Debug.User()
    DGCORE.Client.UI.Debug.Users()
    DGCORE.Client.UI.Debug.Items()
end

--- Sends the server configuration to the UI.
function DGCORE.Client.UI.Debug.Config()
    local config = DGCORE.Config.Server
    if not config then return end

    -- Create a new table excluding any functions to prevent JSON errors.
    local cleanConfig = {}
    for key, value in pairs(config) do
        if type(value) ~= "function" then
            cleanConfig[key] = value
        end
    end

    _sendNuiMessage("Config", { config = cleanConfig })
end

--- Sends the local player's user data to the UI.
function DGCORE.Client.UI.Debug.User()
    -- Correctly reference the cached local user
    local user = DGCORE.Client.Cache.User.Get()
    if user and type(user.toUI) == "function" then
        _sendNuiMessage("User", { user = user:toUI() })
    else
        print("[DGCORE]Debug.User: Local user object is invalid or missing.")
    end
end

--- Sends all cached users' data to the UI.
function DGCORE.Client.UI.Debug.Users()
    -- Correctly reference the global users cache
    _transformAndSendData("Users", DGCORE.Cache.Users)
end

--- Sends all cached items' data to the UI.
function DGCORE.Client.UI.Debug.Items()
    _transformAndSendData("Items", DGCORE.Cache.Items)
end

RegisterNUICallback("DGCORE:Client:UI:Debug:Refresh", function (_, cb)
    DGCORE.Client.Sync.All()
    Citizen.Wait(10)
    DGCORE.Client.UI.Debug.All()
    cb({})
end)