DGCORE = DGCORE or {}

DGCORE.Utils = {}

if IsDuplicityVersion() then
    -- サーバー側のみ
    function DGCORE.Utils.GetUsername(src)
        local success, result = pcall(GetPlayerName, src)
        if success then
            return result
        else
            print(("[DGCORE]DGCORE.Utils.GetUsername: Error: %s"):format(result))
        end
        return false
    end

    function DGCORE.Utils.GetLicense(src)
        local success, result = pcall(GetPlayerIdentifierByType, src, "license")
        if success then
            return result
        else
            print(("[DGCORE]DGCORE.Utils.GetLicense: Error: %s"):format(result))
        end
        return false
    end

    function DGCORE.Utils.GetResourceName()
        return GetCurrentResourceName()
    end
end