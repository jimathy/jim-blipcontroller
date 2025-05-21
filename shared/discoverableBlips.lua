DiscoverableBlips = {
    ["example_fivem1"] = {
        coords = vec3(-206.07, -1321.77, 30.89),
        name = "Benny's Original Motor Works",
        --description = "Fix and upgrade your vehicle here.",  -- This is optional
        sprite = 72,
        color = 47,
        discoverRadius = 30.0
    },
    ["example_redm1"] = {
        coords = vec3(1193.48, -1218.85, 74.32),
        name = "Benny's Original Motor Works",
        description = "Fix and upgrade your vehicle here.",  -- This is optional
        sprite = `blip_ambient_death`,
        discoverRadius = 30.0
    },
}


-- RedM only
-- Auto convert to var strings as these seem to be more efficient in RedM
if gameName == "rdr3" then
    for id in pairs(DiscoverableBlips) do
        DiscoverableBlips[id].name = VarString(10, "LITERAL_STRING", DiscoverableBlips[id].name)
        if DiscoverableBlips[id].description then
            DiscoverableBlips[id].description = VarString(10, "LITERAL_STRING", DiscoverableBlips[id].description)
        end
    end
end