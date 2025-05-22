if Config.onDutyBlips.enable then

    onResourceStart(function()
        Wait(1000)
        makeDutyList()

        GlobalState.syncJobBlipData = JobBlips
    end, true)

    onResourceStop(function()
        GlobalState.syncJobBlipData = nil
        GlobalState.onDutyBlipsData = nil
    end, true)

    function makeDutyList()
        -- make fresh list
        local onDutyAmount = {}
        for job in pairs(JobBlips) do
            onDutyAmount[job] = 0
        end
        debugPrint("^5Debug^7: ^3makeList^7: ^2Creating fresh duty list^7")
        -- Scan online players to get their job data
        for _, src in pairs(GetPlayers()) do
            local Player = getPlayer(src)
            if Player then
                for l in pairs(JobBlips) do
                    if Player.job == l then
                        if Player.onDuty then
                            -- if player is on duty, add it to cache pool
                            onDutyAmount[l] += 1
                        end
                    end
                end
            end
        end

        jsonPrint(onDutyAmount)
        -- Update global statebag to sync with players
        GlobalState.onDutyBlipsData = onDutyAmount

        -- Loop it so constant data isn't sent back and forth when players change job or duty
        debugPrint("^4Debug^7: ^2Job scan complete^7, ^2checking again in 30s^7")
        SetTimeout(30000, function()
            makeDutyList()
        end)
    end

    onResourceStop(function()
        -- Ensure clean global state data
        GlobalState.syncJobBlipData = nil
        GlobalState.onDutyBlipsData = nil
    end)

    function addDutyBlip(data, job)
        debugPrint("^4Export^7: ^2Recieving blip from^7: ^3"..GetInvokingResource().." ^2for job^7: ^4"..job.."^7")
        if data ~= nil and type(data) == "table" then
            jsonPrint(data)
            -- if data already found for this job role, don't accept it
            if JobBlips[job] then
                return print("^1Error^7: ^2Job already has blip data stored^7")
            end
            -- if "data" is missing any of this data, don't accept it
            for k, v in pairs({"label", "coords", "col", "sprite"}) do
                if not data[v] then
                    return print("^1Error^7: ^2Missing required blip data^7: ^3"..v.."^7")
                end
            end
            JobBlips[job] = data
            GlobalState.syncJobBlipData = JobBlips
        end
    end

    exports("addDutyBlip", addDutyBlip)

end

exports("isOnDutyEnabled", function()
    return Config.onDutyBlips.enable
end)
