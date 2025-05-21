local BLIP_INFO_DATA = {}
local DISPLAY_INDEX = 1
local _labels = 0
local _entries = 0

BlipInfo = {
    infoType = {},
    helper = {}
}

-- Default blip structure
BlipInfo.ensureBlipInfo = function(blip)
    if not blip then blip = 0 end
    SetBlipAsMissionCreatorBlip(blip, true)
    BLIP_INFO_DATA[blip] = BLIP_INFO_DATA[blip] or {
        title = "",
        rockstarVerified = false,
        info = {},
        money = "",
        rp = "",
        dict = "",
        tex = ""
    }
    return BLIP_INFO_DATA[blip]
end

-- Exportable setters
BlipInfo.ResetBlipInfo = function(blip)
    BLIP_INFO_DATA[blip] = nil
end

BlipInfo.SetBlipInfoTitle = function(blip, title, rockstarVerified)
    local data = BlipInfo.ensureBlipInfo(blip)
    data.title = title or ""
    data.rockstarVerified = rockstarVerified or false
end

BlipInfo.SetBlipInfoImage = function(blip, dict, tex)
    local data = BlipInfo.ensureBlipInfo(blip)
    data.dict = dict or ""
    data.tex = tex or ""
end

BlipInfo.SetBlipInfoEconomy = function(blip, rp, money)
    local data = BlipInfo.ensureBlipInfo(blip)
    data.rp = tostring(rp or "")
    data.money = tostring(money or "")
end

BlipInfo.SetBlipInfo = function(blip, info)
    BlipInfo.ensureBlipInfo(blip).info = info or {}
end

-- Info line types
BlipInfo.infoType.addInfo = function(blip, typeId, left, right, iconId, iconColor, checked)
    local data = BlipInfo.ensureBlipInfo(blip)
    table.insert(data.info, {typeId, left or "", right or "", iconId, iconColor, checked})
end

BlipInfo.infoType.AddBlipInfoText = function(blip, left, right)
    BlipInfo.infoType.addInfo(blip, right and 1 or 5, left, right)
end

BlipInfo.infoType.AddBlipInfoName = function(blip, left, right)
    BlipInfo.infoType.addInfo(blip, 3, left, right)
end

BlipInfo.infoType.AddBlipInfoHeader = function(blip, left, right)
    BlipInfo.infoType.addInfo(blip, 4, left, right)
end

BlipInfo.infoType.AddBlipInfoIcon = function(blip, left, right, icon, color, checked)
    BlipInfo.infoType.addInfo(blip, 2, left, right, icon or 0, color or 0, checked or false)
end

-- Scaleform helpers
BlipInfo.helper.label = function(text)
    local lbl = "LBL" .. _labels
    AddTextEntry(lbl, text)
    _labels += 1
    return lbl
end

BlipInfo.helper.pushLabel = function(text)
    BeginTextCommandScaleformString(text)
    EndTextCommandScaleformString()
end

BlipInfo.helper.scaleform = function(title, desc, typeId)
    ScaleformMovieMethodAddParamInt(DISPLAY_INDEX)
    ScaleformMovieMethodAddParamInt(_entries)
    ScaleformMovieMethodAddParamInt(65)
    ScaleformMovieMethodAddParamInt(3)
    ScaleformMovieMethodAddParamInt(typeId or 0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    BlipInfo.helper.pushLabel(title)
    BlipInfo.helper.pushLabel(desc)
    EndScaleformMovieMethod()
end

BlipInfo.helper.setIcon = function(title, desc, icon, color, checked)
    BeginScaleformMovieMethodOnFrontend("SET_DATA_SLOT")
    ScaleformMovieMethodAddParamInt(DISPLAY_INDEX)
    ScaleformMovieMethodAddParamInt(_entries)
    ScaleformMovieMethodAddParamInt(65)
    ScaleformMovieMethodAddParamInt(3)
    ScaleformMovieMethodAddParamInt(2)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(1)
    BlipInfo.helper.pushLabel(title)
    BlipInfo.helper.pushLabel(desc)
    ScaleformMovieMethodAddParamInt(icon)
    ScaleformMovieMethodAddParamInt(color)
    ScaleformMovieMethodAddParamBool(checked)
    EndScaleformMovieMethod()
end

BlipInfo.helper.clearDisplay = function()
    BeginScaleformMovieMethodOnFrontend("SET_DATA_SLOT_EMPTY")
    ScaleformMovieMethodAddParamInt(DISPLAY_INDEX)
    EndScaleformMovieMethod()
    _labels = 0
    _entries = 0
end

BlipInfo.helper.showColumn = function(state)
    BeginScaleformMovieMethodOnFrontend("SHOW_COLUMN")
    ScaleformMovieMethodAddParamInt(DISPLAY_INDEX)
    ScaleformMovieMethodAddParamBool(state)
    EndScaleformMovieMethod()
end

BlipInfo.helper.updateDisplay = function()
    BeginScaleformMovieMethodOnFrontend("DISPLAY_DATA_SLOT")
    ScaleformMovieMethodAddParamInt(DISPLAY_INDEX)
    EndScaleformMovieMethod()
end

BlipInfo.helper.setTitle = function(data)
    BeginScaleformMovieMethodOnFrontend("SET_COLUMN_TITLE")
    ScaleformMovieMethodAddParamInt(DISPLAY_INDEX)
    BlipInfo.helper.pushLabel("")
    BlipInfo.helper.pushLabel(BlipInfo.helper.label(data.title))
    ScaleformMovieMethodAddParamInt(data.rockstarVerified and 1 or 0)
    ScaleformMovieMethodAddParamTextureNameString(data.dict)
    ScaleformMovieMethodAddParamTextureNameString(data.tex)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    if data.rp == "" then
        ScaleformMovieMethodAddParamBool(0)
    else
        BlipInfo.helper.pushLabel(BlipInfo.helper.label(data.rp))
    end
    if data.money == "" then
        ScaleformMovieMethodAddParamBool(0)
    else
        BlipInfo.helper.pushLabel(BlipInfo.helper.label(data.money))
    end
    EndScaleformMovieMethod()
end

BlipInfo.helper.displayBlipInfo = function(blip)
    local data = BlipInfo.ensureBlipInfo(blip)
    TakeControlOfFrontend()
    BlipInfo.helper.clearDisplay()
    BlipInfo.helper.setTitle(data)
    for _, info in ipairs(data.info) do
        if info[1] == 2 then
            BlipInfo.helper.setIcon(BlipInfo.helper.label(info[2]), BlipInfo.helper.label(info[3]), info[4], info[5], info[6])
        else
            BlipInfo.helper.scaleform(BlipInfo.helper.label(info[2]), BlipInfo.helper.label(info[3]), info[1])
        end
        _entries += 1
    end
    BlipInfo.helper.showColumn(true)
    BlipInfo.helper.updateDisplay()
    ReleaseControlOfFrontend()
end

-- Main runtime display thread
CreateThread(function()
    local currentBlip = nil
    local wait = 1000
    while true do
        if IsFrontendReadyForControl() and IsHoveringOverMissionCreatorBlip() then
            wait = 50
            local blip = GetNewSelectedMissionCreatorBlip()
            if DoesBlipExist(blip) and currentBlip ~= blip then
                currentBlip = blip
                if BLIP_INFO_DATA[blip] then
                    BlipInfo.helper.displayBlipInfo(blip)
                else
                    BlipInfo.helper.showColumn(false)
                end
            end
        elseif currentBlip then
            wait = 1000
            currentBlip = nil
            BlipInfo.helper.showColumn(false)
        end
        Wait(wait)
    end
end)

-- Add or update a blip's tooltip info
function ShowBlipInfo(blip, data)
    if not DoesBlipExist(blip) then return end

    SetBlipAsMissionCreatorBlip(blip, true)
    BlipInfo.ResetBlipInfo(blip)

    BlipInfo.SetBlipInfoTitle(blip, data.title or "", data.verified or false)
    BlipInfo.SetBlipInfoImage(blip, data.dict or "", data.tex or "")
    BlipInfo.SetBlipInfoEconomy(blip, data.rp or "", data.money or "")

    if data.entries then
        for _, entry in ipairs(data.entries) do
            if entry.type == "text" then
                BlipInfo.infoType.AddBlipInfoText(blip, entry.left, entry.right)
            elseif entry.type == "name" then
                BlipInfo.infoType.AddBlipInfoName(blip, entry.left, entry.right)
            elseif entry.type == "header" then
                BlipInfo.infoType.AddBlipInfoHeader(blip, entry.left, entry.right)
            elseif entry.type == "icon" then
                BlipInfo.infoType.AddBlipInfoIcon(blip, entry.left, entry.right, entry.icon, entry.color, entry.checked)
            end
        end
    end
end

exports("ShowBlipInfo", ShowBlipInfo)

function RemoveBlipInfo(blip)
    BlipInfo.ResetBlipInfo(blip)
end

exports("RemoveBlipInfo", RemoveBlipInfo)