local discoveredBlips = {}
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
        while showingBlipNotif == true do
            Wait(1000)
        end
        showingBlipNotif = true
    else showingBlipNotif = true end
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
    --jsonPrint(data)
    local screenX, screenY = 0.5, 0.1
    local discY, nameY, descY = -0.065, -0.045, 0.015
    local boxWidth, boxHeight = 0.22, 0.14
    local titleScale = 0.75
    local textScale = 0.35

    if not data.description then nameY = -0.02 end

    if gameName ~= "rdr3" then
        -- Draw background box
        DrawSprite("timerbars", "all_black_bg", screenX - (boxWidth / 4) + 0.00045, screenY, (boxWidth / 2), boxHeight, 0.0, 255, 255, 255, fadeAlpha)
        DrawSprite("timerbars", "all_black_bg", screenX + (boxWidth / 4) - 0.00045, screenY, (boxWidth / 2), boxHeight, 180.0, 255, 255, 255, fadeAlpha)

        -- Draw Discovered
        SetTextFont(0)
        SetTextJustification(0)
        SetTextScale(textScale, textScale)
        SetTextColour(200, 200, 200, fadeAlpha)
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentSubstringPlayerName("Discovered")
        DrawText(screenX, screenY + discY)

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
        DrawSprite("generic_textures", "inkroller_1a", screenX, screenY, boxWidth, boxHeight, 180.0, 50, 0, 0, fadeAlpha)

        -- Draw Discovered
        --SetTextFontForCurrentCommand(6)
        --SetTextScale(textScale, textScale)
        --SetTextColor(200, 200, 200, fadeAlpha)
        --SetTextJustification(0)
        --SetTextDropshadow(1, 0, 0, 0, fadeAlpha)
        --DisplayText(discoveredStr, screenX, screenY + discY)

        -- Draw name
        SetTextFontForCurrentCommand(1)
        SetTextScale(titleScale, titleScale)
        SetTextColor(255, 255, 255, fadeAlpha)
        SetTextJustification(0)
        SetTextDropshadow(1, 0, 0, 0, fadeAlpha)
        DisplayText(data.name, screenX, screenY + nameY)

        if data.description ~= nil then
            -- Draw description
            SetTextFontForCurrentCommand(6)
            SetTextScale(textScale, textScale)
            SetTextColor(200, 200, 200, fadeAlpha)
            SetTextJustification(0)
            SetTextDropshadow(1, 0, 0, 0, fadeAlpha)
            DisplayText(data.description, screenX, screenY + descY)
        end
    end
end

Discover.isBlipDiscovered = function(id)
    debugPrint("^5Debug^7: ^2Checking if blip is discovered^7: ^3"..id)
    return GetResourceKvpInt("blip_discovered_" .. id) == 1
end

Discover.setBlipDiscovered = function(id)
    debugPrint("^5Debug^7: ^2Setting blip as discovered^7: ^3"..id)
    SetResourceKvpInt("blip_discovered_" .. id, debugMode and 0 or 1)
    discoveredBlips[id] = true
end

onPlayerLoaded(function()
    for id, blip in pairs(DiscoverableBlips) do
        local discovered = Discover.isBlipDiscovered(id)
        -- If player has "discovered" the blip, create it at player load in
        if discovered then
            if debugMode then
                -- if debugMode set all the blips to undiscovered
                debugPrint("^5Debug^7: ^2Debug mode is on^7, ^2setting blip ^7'^3"..id.."^7' ^2to undiscovered^7")
                SetResourceKvpInt("blip_discovered_" .. id, 0)
            end
            discoveredBlips[id] = true
            makeBlip(blip)
        end
        -- If player has not found blips, create a discovery polyzone
        if not discovered then
            local Poly = nil
            Poly = createCirclePoly({
                name = id,
                coords = blip.coords,
                radius = blip.discoverRadius,
                onEnter = function()
                    debugPrint("^5Debug^7: ^2Entered Blip Discovery Zone^7: ^3"..id.."^7")

                    Discover.setBlipDiscovered(id)

                    makeBlip(blip)

                    loadTextureDict(gameName ~= "rdr3" and "timerBars" or "generic_textures")

                    Discover.ShowBlipDiscoveryNotification({
                        id = id,
                        name = blip.name,
                        description = blip.description,
                    })

                    removePolyZone(Poly)
                end,
                onExit = function()

                end,
            })
        end
    end
end, true)