DGCORE = DGCORE or {}
DGCORE.Client = DGCORE.Client or {}

DGCORE.Client.User = {}

function DGCORE.Client.User.GetLocalUser()
    return DGCORE.Cache.User
end

function DGCORE.Client.User.GetLocalUsers()
    return DGCORE.Cache.Users
end
