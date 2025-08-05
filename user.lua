DGCORE = DGCORE or {}

DGCORE.User = {}

function DGCORE.User.GetByLicense(license)
    return DGCORE.Cache.Users[license]
end

if IsDuplicityVersion() then
    function DGCORE.User.GetBySource(src)
        local license = DGCORE.Utils.GetLicense(src) or GetPlayerIdentifierByType(src, "license")
        return DGCORE.User.GetByLicense(license)
    end
end