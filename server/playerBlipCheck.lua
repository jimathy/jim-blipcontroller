if Config.playerBlips.enable then

    onResourceStart(function()
        Wait(1000)
        makePlayerList()
    end, true)

    onResourceStop(function()
        GlobalState.playerBlipsData = nil
    end, true)

    function makePlayerList()
        -- make fresh list
        local onDutyAmount = {}
        for job in pairs(PlayerBlips) do
            onDutyAmount[job] = {}
        end
        debugPrint("^5Debug^7: ^3makeList^7: ^2Creating fresh duty list^7")
        -- Scan online players to get their job data
        for _, src in pairs(GetPlayers()) do
            local Player = getPlayer(src)
            if Player then
                for job in pairs(PlayerBlips) do
                    if Player.job == job then
                        if Player.onDuty then
                            onDutyAmount[job] = onDutyAmount[job] or {}
                            -- if player is on duty, add it to cache pool
                            local coords = GetEntityCoords(GetPlayerPed(src))
                            local heading = GetEntityHeading(GetPlayerPed(src))

                            onDutyAmount[job][#onDutyAmount[job]+1] = {
                                coords = vec4(coords.x, coords.y, coords.z, heading),
                                src = tonumber(src),
                                ped = NetworkGetNetworkIdFromEntity(GetPlayerPed(src)),
                            }
                        end
                    end
                end
            end
        end

        jsonPrint(onDutyAmount)
        -- Update global statebag to sync with players
        GlobalState.playerBlipsData = { data = onDutyAmount, ensure = keyGen() }

        -- Loop it so constant data isn't sent back and forth when players change job or duty
        debugPrint("^5Debug^7: ^2Player Duty scan complete^7, ^2checking again in 30s^7")
        SetTimeout(3000, function()
            makePlayerList()
        end)
    end

end

exports("isPlayerBlipEnabled", function()
    return Config.playerBlips.enable
end)
