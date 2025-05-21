if Config.onDutyBlips.enable then

    local cacheDutyData = {}
    local blipCache = {}

    onDutyBlips = {}

    onPlayerLoaded(function()
        -- Wait until statebag exists, then trigger local handler
        CreateThread(function()

            -- Ensure synced JobBlips table on load in
            while not GlobalState.syncJobBlipData do Wait(100) end
            JobBlips =  GlobalState.syncJobBlipData

            -- Receive synced duty cache
            while not GlobalState.onDutyBlipsData do Wait(100) end
            cacheDutyData =  GlobalState.onDutyBlipsData
            onDutyBlips.updateBlips()
        end)
    end, true)

    -- STATE BAG HANDLERS --

    -- Recieved synced JobBlips table
    AddStateBagChangeHandler("syncJobBlipData", nil, function(bagName, key, value, _unused)
        debugPrint("^5tatebag^7: ^2Job Blip Data received from server^7")
        if type(value) == "table" then
            debugPrint("^5Statebag^7: ^2Syncing 6JobBlip ^2Data^7")

            JobBlips = value
        end
    end)

    -- Handler to recieve global statebag data from the server
    AddStateBagChangeHandler("onDutyBlipsData", nil, function(bagName, key, value, _unused)
        debugPrint("^5Statebag^7: ^2Duty Data received from server^7")
        if type(value) == "table" then
            local acceptChange = false
            -- Check if new job has been added
            for job in pairs(value) do
                if not cacheDutyData[job] then
                    acceptChange = true
                    debugPrint("^5Statebag^7: ^2Accepting change from server^7")
                    break
                end
            end
            -- Check if duty change
            for job, duty in pairs(cacheDutyData) do
                if value[job] ~= duty then
                    acceptChange = true
                    debugPrint("^5Statebag^7: ^2Accepting change from server^7")
                    break
                end
            end
            if acceptChange then
                cacheDutyData = value
                onDutyBlips.updateBlips()
            else
                debugPrint("^5StateBag^7: ^2No changes needed^7, ^2not accepting change^7")
            end
        end
    end)

    local updatingBlips = false
    onDutyBlips.updateBlips = function()
        if not updatingBlips then
            updatingBlips = true
        else
            while updatingBlips do
                debugPrint("Waiting for previous sync to finish")
                Wait(1000)
            end
        end
        -- Clear blip cache and its blips
        for k, v in pairs(blipCache) do
            RemoveBlip(blipCache[k])
        end
        blipCache = {}

        for k, v in pairs(cacheDutyData) do
            if v <= 1 then
                blipCache[#blipCache+1] = makeBlip({
                    coords = JobBlips[k].coords,
                    sprite = JobBlips[k].sprite,
                    col = JobBlips[k].col,
                    scale = JobBlips[k].scale,
                    disp = JobBlips[k].disp,
                    category = JobBlips[k].category,
                    name = "(~g~"..locale("onDutyBlips", "open").."~w~) "..JobBlips[k].label,
                    preview = JobBlips[k].preview
                })
            else
                if Config.onDutyBlips.alwaysShowblips or JobBlips[k].alwaysShow then
                    blipCache[#blipCache+1] = makeBlip({
                        coords = JobBlips[k].coords,
                        sprite = JobBlips[k].sprite,
                        col = 40,
                        scale = JobBlips[k].scale,
                        disp = JobBlips[k].disp,
                        category = JobBlips[k].category,
                        name = "(~r~"..locale("onDutyBlips", "closed").."~w~) "..JobBlips[k].label,
                        preview = JobBlips[k].preview
                    })
                end
            end
        end
        updatingBlips = false
    end

end