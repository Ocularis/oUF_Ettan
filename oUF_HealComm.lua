-- Credits to oUF_Freebgrid for source.
if(not oUF_Ettan_Settings["Raid"].Plugins.HealComm) then return end
local s = oUF_Ettan_Settings["Raid"]

local format = string.format

local color = {
    r = 0,
    g = 1,
    b = 0,
    a = 0.5,
}

local oUF_HealComm = {}
local healcomm = LibStub("LibHealComm-3.0")

local playerName = UnitName("player")
local playerIsCasting = false
local playerHeals = 0
local playerTarget = ""

updateHealCommBar = function(frame, unit)
    local curHP = UnitHealth(unit)
    local maxHP = UnitHealthMax(unit)
    local incHeals = select(2, healcomm:UnitIncomingHealGet(unit, GetTime())) or 0

    if(playerIsCasting) then
        for i = 1, select("#", playerTarget) do
            local target = select(i, playerTarget)
            if target == unit then
                incHeals = incHeals + playerHeals
            end
        end
    end

    if(maxHP==100 or incHeals==0) then
        frame.healText:SetText(" ")
    else
        frame.healText:SetText(format("+%.1f", incHeals / 1000))
    end
end

local updateHealCommBars = function(...)
    for i = 1, select("#", ...) do
        local unit = select(i, ...)

        for frame in pairs(oUF.units) do
            local name, server = UnitName(frame)
            if server then name = strjoin("-",name,server) end
            if name == unit and oUF.units[frame].applyHealComm then
                updateHealCommBar(oUF.units[frame],unit)
            end
        end
    end
end

local function hook(frame)
if not frame.applyHealComm then return end
    local o = frame.PostUpdateHealth
    frame.PostUpdateHealth = function(...)
        if o then o(...) end
        local name, server = UnitName(frame.unit)
        if server then name = strjoin("-",name,server) end
        updateHealCommBar(frame, name)
    end
end

for i, frame in ipairs(oUF.objects) do hook(frame) end

oUF:RegisterInitCallback(hook)

function oUF_HealComm:HealComm_DirectHealStart(event, healerName, healSize, endTime, ...)
    if healerName == playerName then
        playerIsCasting = true
        playerTarget = ... 
        playerHeals = healSize
    end
    updateHealCommBars(...)
end

function oUF_HealComm:HealComm_DirectHealUpdate(event, healerName, healSize, endTime, ...)
    updateHealCommBars(...)
end

function oUF_HealComm:HealComm_DirectHealStop(event, healerName, healSize, succeeded, ...)
    if healerName == playerName then
        playerIsCasting = false
    end
    updateHealCommBars(...)
end

function oUF_HealComm:HealComm_HealModifierUpdate(event, unit, targetName, healModifier)
    updateHealCommBars(unit)
end

healcomm.RegisterCallback(oUF_HealComm, "HealComm_DirectHealStart")
healcomm.RegisterCallback(oUF_HealComm, "HealComm_DirectHealUpdate")
healcomm.RegisterCallback(oUF_HealComm, "HealComm_DirectHealStop")
healcomm.RegisterCallback(oUF_HealComm, "HealComm_HealModifierUpdate")