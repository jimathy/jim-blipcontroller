Config = {
    Lan = "en",
    System = {
        Debug = false,                      -- Debug mode
        EventDebug = false,                 -- Extra Debug messages
    },

    DiscoveryBlips = {
        enable = true,                      -- Set to false to disable the onDutyBlip system

        displayTime = 6000,                 -- time in ms to display the notification
        fadeInSpeed = 15,                   -- speed of fade in
        fadeOutSpeed = 2,                   -- speed of fade out

        showPopupBackground = true,         -- Adds the black background to the popup
                                            -- Could possibly be seen as "too much" so made it optional

        alwaysShowLocationName = true,     -- if enabled, will always show the location name on entering the area
    },

    onDutyBlips = {
        enable = false,                     -- Set to false to disable the onDutyBlip system

        alwaysShowblips = false,            -- If true, the blips for the locations will always show, but not show "open"
                                            -- Not recommended if you have alot of onDuty blips as the max total blips is 99
    },

    playerBlips = {
        enable = false,
    },

    blipInfo = {
        enable = false,

    }
}

-- Function for locales
-- Don't touch unless you know what you're doing
-- This needs to be here because it loads before everything else
function locale(section, string)
    if not Config.Lan or Config.Lan == "" then
        print("^1Error^7: ^3Config^7.^3Lan ^1not set^7, ^2falling back to Config.Lan = 'en'")
        Config = Config or {}
        Config.Lan = "en"
    end

    local localTable = Loc[Config.Lan]
    -- If Loc[..] doesn't exist, warn user
    if not localTable then
		print("Locale Table '"..Config.Lan.."' Not Found")
        return "Locale Table '"..Config.Lan.."' Not Found"
    end

    -- If Loc[..].section doesn't exist, warn user
    if not localTable[section] then
		print("^1Error^7: Locale Section: ['"..section.."'] Invalid")
        return "Locale Section: ['"..section.."'] Invalid"
    end

    -- If Loc[..].section.string doesn't exist, warn user
    if not localTable[section][string] then
		print("^1Error^7: Locale String: ['"..section.."']['"..string.."'] Invalid")
        return "Locale String: ['"..string.."'] Invalid"
    end

    -- If no issues, return the string
    return localTable[section][string]
end