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

function locale(section, string)
	if not string then
		print(section, "string is nil")
	end
    if not Config.Lan or Config.Lan == "" then return print("Error, no langauge set") end
    local localTable = Loc[Config.Lan]
    if not localTable then return "Locale Table Not Found" end
    if not localTable[section] then return "["..section.."] Invalid" end
    if not localTable[section][string] then return "["..string.."] Invalid" end
    return localTable[section][string]
end