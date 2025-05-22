if Config.playerBlips.enable then

    local cachePlayerData = {}
    local blipCache = {}

    playerBlips = {}

    -- STATE BAG HANDLERS --

    -- Handler to recieve global statebag data from the server
    AddStateBagChangeHandler("playerBlipsData", nil, function(bagName, key, value, _unused)
        --debugPrint("^5Statebag^7: ^2Player Duty received from server^7")
        if type(value) == "table" then
            local player = getPlayer()
            if PlayerBlips[player.job] and player.onDuty then
                cachePlayerData = playerBlips.scanForEntity(value.data, player.job)
                playerBlips.updateBlips()
            else
                for src, data in pairs(blipCache) do
                    if data.blip and DoesBlipExist(data.blip) then
                        RemoveBlip(data.blip)
                    end
                end
                blipCache = {}
                cachePlayerData = {}
            end
        end
    end)

    playerBlips.scanForEntity = function(data, playerJob)
        local function ensureEnt(entNetID)
            --debugPrint("^5Debug^7: ^3ensureNetToEnt^7: ^2Requesting NetworkDoesNetworkIdExist^7(^6"..entNetID.."^7)")
            local timeout = 50
            while not NetworkDoesNetworkIdExist(entNetID) and timeout > 0 do
                timeout -= 1
                Wait(10)
            end
            if not NetworkDoesNetworkIdExist(entNetID) then return 0 end
            timeout = 100
            local entity = NetworkGetEntityFromNetworkId(entNetID)
            while not DoesEntityExist(entity) and entity ~= 0 and timeout > 0 do
                timeout -= 1
                Wait(10)
            end
            if not DoesEntityExist(entity) then return 0 end
            return entity
        end

        if not data then return nil end
        local cacheData = data
        --jsonPrint(cacheData)
        for job in pairs(cacheData) do
            if PlayerBlips[playerJob].canAlsoSee[job] then
                for k, v in pairs(cacheData[job]) do
                    if v.ped then
                        local netEnt = ensureEnt(v.ped)
                        if netEnt and netEnt ~= 0 and DoesEntityExist(netEnt) then
                            cacheData[job][k].ped = netEnt
                        else
                            cacheData[job][k].ped = nil
                        end
                    end
                end
            else
                cacheData[job] = nil
            end
        end
        return cacheData
    end

    local updatingBlips = false
    playerBlips.updateBlips = function()
        local ped = PlayerPedId()
        local mySrc = GetPlayerServerId(PlayerId())
        local seenSrcs = {}

        if not updatingBlips then
            updatingBlips = true
        else
            while updatingBlips do
                debugPrint("Waiting for previous sync to finish")
                Wait(1000)
            end
        end
        for job, players in pairs(cachePlayerData) do
            for k, v in pairs(players) do
                local src = v.src
                if not src or src == mySrc then goto skip end
                seenSrcs[src] = true

                local existing = blipCache[src]
                local vCoords = vec3(v.coords.x, v.coords.y, v.coords.z)
                local dist = #(GetEntityCoords(ped) - vCoords)

                -- ENTITY BLIPS
                if dist < 200.0 and v.ped then
                    -- Switch to entity blip if not already
                    if not existing or existing.type ~= "entity" then
                        if existing and DoesBlipExist(existing.blip) then
                            RemoveBlip(existing.blip)
                        end
                        local blip = makeEntityBlip({
                            entity = v.ped,
                            sprite = 1,
                            col = PlayerBlips[job].color,
                            scale = 1.0,
                            name = job,
                            category = 0,
                        })
                        SetBlipAsShortRange(blip, true)
                        ShowHeadingIndicatorOnBlip(blip, true)
                        blipCache[src] = { blip = blip, type = "entity" }
                    end
                else
                    -- Switch to coord blip if not already
                    if not existing or existing.type ~= "coord" then
                        if existing and DoesBlipExist(existing.blip) then
                            RemoveBlip(existing.blip)
                        end
                        local blip = makeBlip({
                            coords = v.coords,
                            sprite = 1,
                            col = PlayerBlips[job].color,
                            scale = 1.0,
                            name = job,
                            category = 0,
                        })
                        SetBlipAsShortRange(blip, true)
                        ShowHeadingIndicatorOnBlip(blip, true)
                        SetBlipRotation(blip, math.ceil(v.coords.w))
                        blipCache[src] = { blip = blip, type = "coord", lastCoords = vCoords }
                    elseif existing.lastCoords and #(existing.lastCoords - vCoords) > 2.0 then
                        -- Update coords if moved significantly
                        SetBlipRotation(existing.blip, math.ceil(v.coords.w))
                        SetBlipCoords(existing.blip, vCoords)
                        blipCache[src].lastCoords = vCoords
                    end
                end

                ::skip::
            end
        end
        -- Cleanup unused blips
        for src, data in pairs(blipCache) do
            if not seenSrcs[src] then
                if data.blip and DoesBlipExist(data.blip) then
                    RemoveBlip(data.blip)
                end
                blipCache[src] = nil
            end
        end

        updatingBlips = false
    end

end