local discoveredBlips = {}
local externalZones = {}
local showingBlipNotif = false
local fadeAlpha = 0
local fadeState = "in"
local discoveredStr = gameName == "rdr3" and CreateVarString(10, "LITERAL_STRING", "Discovered") or "Discovered"

Discover = {}

-- Custom scaleform for blip discovery notification
Discover.ShowBlipDiscoveryNotification = function(data)
    debugPrint("^5Debug^7: ^2Showing blip discovery hud for^7: "..data.id.."^7")
    jsonPrint(data)

    fadeAlpha = 0
    fadeState = "in"
    if showingBlipNotif then
        showingBlipNotif = false
        Wait(1000)
        showingBlipNotif = true
    else
        showingBlipNotif = true
    end
    CreateThread(function()
        local startTime = GetGameTimer()

        while showingBlipNotif do
            Wait(0)
            Discover.DrawBlipDiscoveryNotification(data)

            if fadeState == "in" then
                fadeAlpha = math.min(fadeAlpha + Config.DiscoveryBlips.fadeInSpeed, 255)
                if fadeAlpha == 255 and GetGameTimer() - startTime >= Config.DiscoveryBlips.displayTime then
                    fadeState = "out"
                end
            elseif fadeState == "out" then
                fadeAlpha = math.max(fadeAlpha - Config.DiscoveryBlips.fadeOutSpeed, 0)
                if fadeAlpha == 0 then
                    showingBlipNotif = false
                end
            end
        end
    end)
end

Discover.DrawBlipDiscoveryNotification = function(data)
    jsonPrint(data)
    local screenX, screenY = 0.5, 0.1
    local discY, nameY, descY = -0.060, -0.040, 0.015
    local boxWidth, boxHeight = 0.22, 0.12
    local titleScale = 0.75
    local textScale = 0.35

    if not data.description then
        discY = descY
    end

    if gameName ~= "rdr3" then
        -- Draw background box
        --DrawSprite("timerbars", "all_black_bg", screenX - (boxWidth / 4) + 0.00045, screenY, (boxWidth / 2), boxHeight, 0.0, 255, 255, 255, fadeAlpha)
        --DrawSprite("timerbars", "all_black_bg", screenX + (boxWidth / 4) - 0.00045, screenY, (boxWidth / 2), boxHeight, 180.0, 255, 255, 255, fadeAlpha)

        -- Draw Discovered
        if data.alreadyDiscovered == false then
            SetTextFont(0)
            SetTextJustification(0)
            SetTextScale(textScale, textScale)
            SetTextColour(200, 200, 200, fadeAlpha)
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentSubstringPlayerName("Discovered")
            DrawText(screenX, screenY + discY)
        end

        -- Draw name
        SetTextFont(1)
        SetTextJustification(0)
        SetTextScale(titleScale, titleScale)
        SetTextColour(255, 255, 255, fadeAlpha)
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentSubstringPlayerName(data.name)
        DrawText(screenX, screenY + nameY)

        if data.description then
            -- Draw description
            SetTextFont(0)
            SetTextJustification(0)
            SetTextOutline()
            SetTextScale(textScale, textScale)
            SetTextColour(200, 200, 200, fadeAlpha)
            SetTextEntry("STRING")
            AddTextComponentSubstringPlayerName(data.description)
            DrawText(screenX, screenY + descY)
        end
    else
        --DrawSprite("generic_textures", "inkroller_1a", screenX, screenY, boxWidth, boxHeight, 180.0, 50, 0, 0, fadeAlpha)

        if not data.description then
            discY = descY
        end

        -- Draw name
        SetTextFontForCurrentCommand(1)
        SetTextScale(titleScale, titleScale)
        SetTextColor(255, 255, 255, fadeAlpha)
        SetTextJustification(0)
        SetTextDropshadow(1, 0, 0, 0, fadeAlpha)
        DisplayText(data.name, screenX, screenY + nameY)

        if data.description then
            -- Draw description
            SetTextFontForCurrentCommand(6)
            SetTextScale(textScale, textScale)
            SetTextColor(200, 200, 200, fadeAlpha)
            SetTextJustification(0)
            SetTextDropshadow(1, 0, 0, 0, fadeAlpha)
            DisplayText(data.description, screenX, screenY + descY)
        else
            if data.alreadyDiscovered == false then
                -- if not, just show "Discovered"
                discY = descY
                SetTextFontForCurrentCommand(6)
                SetTextScale(textScale, textScale)
                SetTextColor(200, 200, 200, fadeAlpha)
                SetTextJustification(0)
                SetTextDropshadow(1, 0, 0, 0, fadeAlpha)
                DisplayText(discoveredStr, screenX, screenY + discY)
            end
        end
    end
end

Discover.isBlipDiscovered = function(id)
    debugPrint("^5Debug^7: ^2Checking if blip is discovered^7: ^3"..id)
    return GetResourceKvpInt("blip_discovered_" .. id) == 1
end

Discover.setBlipDiscovered = function(id)
    debugPrint("^5Debug^7: ^2Setting blip as discovered^7: ^3"..id)
    -- if debugmode, it won't save the blip as discovered
    SetResourceKvpInt("blip_discovered_" .. id, debugMode and 0 or 1)
end

Discover.createBlipZone = function(id, blip)
    local discovered = Discover.isBlipDiscovered(id)
    -- If player has "discovered" the blip, create it at player load in
    if discovered then
        if debugMode then
            -- if debugMode is on set all the blips to undiscovered
            debugPrint("^5Debug^7: ^2Debug mode is on^7, ^2setting blip ^7'^3"..id.."^7' ^2to undiscovered^7")
            SetResourceKvpInt("blip_discovered_" .. id, 0)
        end
        discoveredBlips[id] = makeBlip(blip)
        if Config.DiscoveryBlips.alwaysShowLocationName then
            local Poly = nil
            debugPrint("^5Debug^7: ^2Creating always name zone^7: ^3"..id.."^7", formatCoord(blip.coords))
            Poly = createCirclePoly({
                name = id,
                coords = blip.coords,
                radius = blip.discoverRadius or 30.0,
                onEnter = function()
                    Discover.ShowBlipDiscoveryNotification({
                        id = id,
                        name = blip.name,
                        description = blip.description,
                        alreadyDiscovered = true,
                    })
                end,
                onExit = function()

                end,
            })
            return Poly
        end
        return true
    end
    -- If player has not found blips, create a discovery polyzone
    if not discovered then
        local Poly = nil
        debugPrint("^5Debug^7: ^2Creating blip discovery zone^7: ^3"..id.."^7", formatCoord(blip.coords))
        Poly = createCirclePoly({
            name = id,
            coords = blip.coords,
            radius = blip.discoverRadius or 30.0,
            onEnter = function()
                debugPrint("^5Debug^7: ^2Entered Blip Discovery Zone^7: ^3"..id.."^7")
                Discover.setBlipDiscovered(id)
                discoveredBlips[id] = makeBlip(blip)
                Discover.ShowBlipDiscoveryNotification({
                    id = id,
                    name = blip.name,
                    description = blip.description,
                })
                removePolyZone(Poly)
                if Config.DiscoveryBlips.alwaysShowLocationName then
                    Discover.createBlipZone(id, blip)
                    debugPrint("^5Debug^7: ^2Creating always name zone^7: ^3"..id.."^7", formatCoord(blip.coords))
                end
            end,
            onExit = function()

            end,
        })
        return Poly
    end
end

-- When the script loads, loop through through the preset blips
onPlayerLoaded(function()
    for id, blip in pairs(DiscoverableBlips) do
        Discover.createBlipZone(id, blip)
    end
end, true)

-- Export to receive blips from other scripts

exports("discoverBlip", function(id, blip)
    -- Get script name of the resource that is calling this function
    local InvokingResource = GetInvokingResource()
    externalZones[InvokingResource] = externalZones[InvokingResource] or {}

    debugPrint("^5Debug^7: ^2Creating blip discovery zone^7: ^3"..id.."^7", formatCoord(blip.coords))
    -- Create zone to discover the location blip
    -- If they already have discovered it, it will create the blip
    -- If not, it will create a polyzone to discover the blip
    local zone = Discover.createBlipZone(id, blip)

    -- Add created zone to cache
    -- If already discovered, it will be "true"
    -- If not it will be a a polyzone object
    externalZones[InvokingResource][id] = zone
end)

AddEventHandler('onResourceStop', function(resourceName)
    if externalZones[resourceName] then
        for id, zone in ipairs(externalZones[resourceName]) do
            if discoveredBlips[id] then
                debugPrint("^5Debug^7: ^2Removing discovered blip^7: ^3"..id.."^7")
                RemoveBlip(discoveredBlips[id])
                discoveredBlips[id] = nil
            end
            if zone ~= true then
                debugPrint("^5Debug^7: ^2Removing blip discovery zone^7: ^3"..id.."^7")
                removePolyZone(zone)
            end
        end
        externalZones[resourceName] = nil
    end
end)