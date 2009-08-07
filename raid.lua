local settings = oUF_Ettan_Settings["Raid"]
local format = string.format
local select = select

--[[ Name tag ]]
oUF.TagEvents["[raidname]"] = "UNIT_NAME_UPDATE UNIT_HEALTH UNIT_TARGET"
oUF.Tags["[raidname]"] = function(u)
    local t = ""
    if(not UnitIsConnected(u)) then t = "Off"
    elseif(UnitIsGhost(u)) then t = "Ghost"
    elseif(UnitIsDead(u)) then t = "Dead"
    else t = UnitName(u) end
    return t
end

--[[ Right click menu ]]
local function menu(self)
    local unit = self.unit:gsub("(.)", string.upper, 1) 
    if _G[unit.."FrameDropDown"] then
        ToggleDropDownMenu(1, nil, _G[unit.."FrameDropDown"], "cursor")
    elseif (self.unit:match("party")) then
        ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor")
    else
        FriendsDropDown.unit = self.unit
        FriendsDropDown.id = self.id
        FriendsDropDown.initialize = RaidFrameDropDown_Initialize
        ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor")
    end
end

--[[ Name & Health update ]]
local OverrideUpdateHealth = function(self, event, unit, bar, min, max)
    if(not UnitIsConnected(unit) or UnitIsGhost(unit)) then
        bar:SetValue(0)
    end

    local r, g, b = 1, 1, 1
    if(settings.ClassColor) then
        if(UnitIsPlayer(unit)) then
            local _, englass = UnitClass(unit)
            if(self.colors.class[englass]) then
                r, g, b = unpack(self.colors.class[englass])
            end
        else
            r, g, b = UnitSelectionColor(unit)
        end
    else
        r, g, b = unpack(settings.OwnColor)
    end

    bar:SetStatusBarColor(r, g, b)
    bar.bg:SetVertexColor(r, g, b, .2)

    local text = bar.value or self.Info
    if(text and settings.NameClassColor) then
        if(not settings.ClassColor) then
            if(UnitIsPlayer(unit)) then
                local _, englass = UnitClass(unit)
                if(self.colors.class[englass]) then
                    r, g, b = unpack(self.colors.class[englass])
                end
            else
                r, g, b = UnitSelectionColor(unit)
            end
        end
        text:SetTextColor(r, g, b)
    end
end

--[[ Aggro coloring for names ]]
local aggrocolors = {
    [1] = {0.3, 0, 0}, -- not tanking but hight threat
    [2] = {0.5, 0, 0}, -- tanking, losing threat
    [3] = {0.8, 0, 0}, -- securely tanking
}

local ColorAggro = function(self, event, unit)
    if(not unit) then return end
    local bg = self.bg

    local s = UnitThreatSituation(self.unit)
    if(s and s>0) then
        local r, g, b = aggrocolors[s][1], aggrocolors[s][2], aggrocolors[s][3]
        bg:SetVertexColor(r, g, b)
    else
        bg:SetVertexColor(0, 0, 0)
    end
end

--[[ Power update ]]
local powercolors = {
    ["MANA"] = {.2, .4, 1},
    ["RAGE"] = {.9, .1, .1},
    ["FOCUS"] = {.9, .9, .1},
    ["ENERGY"] = {.9, .9, .1},
    ["RUNIC_POWER"] = {.1, .9, .9}
}

local PostUpdatePower = function(self, event, unit, bar, min, max)
    if(not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit)) then
        bar:SetValue(0)
    end

    local r, g, b = 1, 1, 1
    if(settings.PowerColorByType) then
        local _, ptype = UnitPowerType(unit)
        if(powercolors[ptype]) then
            r, g, b = unpack(powercolors[ptype])
        end
    else
        r, g, b = unpack(settings.OwnPowerColor)
    end

    bar:SetStatusBarColor(r, g, b)
    bar.bg:SetVertexColor(r, g, b, .2)
end

--[[ Lets Start ]]
local func = function(self, unit)
    if(settings.RightClickMenu) then
        self.menu = menu
        self:EnableMouse(true)
        self:RegisterForClicks("anyup")
        self:SetAttribute("*type2", "menu")
    end
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)

    --[[ Getting settings for frames ]]
    local Raid = strsub(self:GetName(), 5, 8)=="Raid"
    local MT = self:GetParent():GetName()=="oUF_MainTank"
    local MTT = strsub(self:GetName(), 24)=="Target"
    local MTTT = strsub(self:GetName(), 24)=="TargetTarget"

    local W, H, M, O    -- Width, Height, ManaBar, Orientation
    if(Raid) then
        W, H, M, O = settings.Frames.raid.Width, settings.Frames.raid.Height, settings.Frames.raid.ManaBar, settings.Frames.raid.Orientation
    else
        W, H, M, O = settings.Frames.tank.Width, settings.Frames.tank.Height, settings.Frames.tank.ManaBar, settings.Frames.tank.Orientation
    end

    --[[ Frame sizes ]]
    self:SetAttribute("initial-width", W)
    self:SetAttribute("initial-height", H)

    --[[ Healthbar ]]
    local hp = CreateFrame("StatusBar", nil, self)
    hp:SetStatusBarTexture(settings.texture)
    hp:SetPoint("TOPLEFT")
    hp:SetOrientation(O)
    hp:SetHeight(O=="HORIZONTAL" and (M==0 and H or (H - M - 1)) or H)
    hp:SetWidth(O=="VERTICAL" and (M==0 and W or (W - M - 1)) or W)

    local hpbg = hp:CreateTexture(nil, "BACKGROUND")
    hpbg:SetTexture(settings.texture)
    hpbg:SetAllPoints(hp)

    hp.bg = hpbg
    self.Health = hp
    self.OverrideUpdateHealth = OverrideUpdateHealth

    --[[ Manabar ]]
    local pp = CreateFrame("StatusBar", nil, self)
    pp:SetStatusBarTexture(texture)
    pp:SetPoint("BOTTOMRIGHT")
    pp:SetOrientation(O)
    pp:SetHeight(O=="HORIZONTAL" and M or H)
    pp:SetWidth(O=="VERTICAL" and M or W)

    local ppbg = pp:CreateTexture(nil, "BACKGROUND")
    ppbg:SetTexture(settings.texture)
    ppbg:SetAllPoints(pp)

    pp.bg = ppbg
    self.Power = pp
    self.PostUpdatePower = PostUpdatePower
    
    --[[ Name text for raid ]]
    if(Raid) then
        local hpp = hp:CreateFontString(nil, "ARTWORK")
        hpp:SetFont(settings.font, settings.fsize, "OUTLINE")
        hpp:SetShadowColor(0, 0, 0, 0)
        hpp:SetPoint("CENTER", self, 0, 0)

        self:Tag(hpp, "[raidcolor][raidname]")
        self.Health.value = hpp
    end

	

    --[[ Info text for MT, MTT and MTTT ]]
    if(MT or MTT or MTTT) then
        local info = self.Health:CreateFontString(nil, "OVERLAY")
        info:SetFont(settings.font, settings.fsize, "OUTLINE")
        info:SetShadowColor(0, 0, 0, 0)
        info:SetPoint("LEFT", self, -2, 0)
        info:SetPoint("RIGHT", self, 2, 0)

        info.frequentUpdates = 0.1
        self:Tag(info, "[perhp] [raidname]")
        self.Info = info
    end
    
    --[[ oUF_DebuffHighlight support ]]
    if(settings.Plugins.oUF_DebuffHighlight and not MTT and IsAddOnLoaded("oUF_DebuffHighlight")) then
        local dh = self.Health:CreateTexture(nil, "OVERLAY")
        dh:SetPoint("CENTER", self.Health, "CENTER")
        dh:SetHeight(16)
        dh:SetWidth(16)

        self.DebuffHighlight = dh
        self.DebuffHighlightAlpha = 1
        self.DebuffHighlightFilter = false
        self.DebuffHighlightUseTexture = true
    end
    
    --[[ HealComm support ]]
    if(settings.Plugins.HealComm and Raid) then
        local heal = self.Health:CreateFontString(nil, "ARTWORK")
        heal:SetFont(settings.font, settings.fsize, "OUTLINE")
        heal:SetPoint("BOTTOMLEFT", self.Health, -2, 2)
        heal:SetPoint("BOTTOMRIGHT", self.Health, 2, 2)
        heal:SetShadowColor(0, 0, 0, 0)
        heal:SetTextColor(0, 1, 0)

        self.healText = heal
        self.applyHealComm = true
    end

    --[[ Raid Target Icon ]]
    if(settings.RaidIcon and (Raid or MTT)) then
        local ricon = self.Health:CreateTexture(nil, "OVERLAY")
        ricon:SetHeight(15)
        ricon:SetWidth(15)
        ricon:SetPoint("TOPRIGHT", 5, 5)
        self.RaidIcon = ricon
    end

    --[[ ReadyCheck ]]
    if(settings.Plugins.oUF_ReadyCheck and Raid and IsAddOnLoaded("oUF_ReadyCheck")) then
        local rc = self.Health:CreateTexture(nil, "OVERLAY")
        rc:SetPoint("TOPLEFT", self)
        rc:SetHeight(16)
        rc:SetWidth(16)
        rc.fadeTime = 2
        self.ReadyCheck = rc
    end

    --[[ RangeCheck ]]
    if(Raid) then
        self.Range = true 
        self.inRangeAlpha = 1.0 
        self.outsideRangeAlpha = 0.5
    end

    --[[ Aggro coloring and BG ]]
    if(settings.ColorAggro and Raid) then
        self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", ColorAggro)
        self:RegisterEvent("UNIT_TARGET", ColorAggro)
    end

    local bg = self:CreateTexture(nil, "BORDER")
    bg:SetPoint("TOPLEFT", -1, 1)
	bg:SetPoint("BOTTOMRIGHT", 1, -1)
    bg:SetTexture(0, 0, 0)

    local threatbg = self:CreateTexture(nil, "BACKGROUND")
    threatbg:SetPoint("BOTTOMRIGHT", self, 1, -1)
    threatbg:SetPoint("TOPLEFT", self, -1, 1)
    threatbg:SetTexture(1, 1, 1, 1)
    threatbg:SetVertexColor(0, 0, 0)
    
    self.bg = threatbg

    return self
end

oUF:RegisterStyle("ALZA_Raid", func)
oUF:SetActiveStyle("ALZA_Raid")

--[[ Spawning ]]
local raid = {}
local o = settings.Offset + 4
local a = settings.RaidInitialAnchor

for i = 1, settings.NumRaidGroups do
    local raidgroup = oUF:Spawn("header", "oUF_Raid"..i)
    raidgroup:SetManyAttributes("groupFilter", tostring(i), "showRaid", true, "yOffSet", -5)
    raid[i] = raidgroup

    if(i==1) then
        raidgroup:SetPoint(unpack(settings.Positions["raidgroup_1"]))
    else
        if(a=="BOTTOMRIGHT") then raidgroup:SetPoint("BOTTOMRIGHT", raid[i-1], "BOTTOMLEFT", -o, 0)
        elseif(a=="BOTTOM") then raidgroup:SetPoint("BOTTOM", raid[i-1], "TOP", 0, o)
        elseif(a=="BOTTOMLEFT") then raidgroup:SetPoint("BOTTOMLEFT", raid[i-1], "BOTTOMRIGHT", o, 0)
        elseif(a=="LEFT") then raidgroup:SetPoint("LEFT", raid[i-1], "RIGHT", o, 0)
        elseif(a=="TOPLEFT") then raidgroup:SetPoint("TOPLEFT", raid[i-1], "TOPRIGHT", o, 0)
        elseif(a=="TOP") then raidgroup:SetPoint("TOP", raid[i-1], "BOTTOM", 0, -o)
        elseif(a=="TOPRIGHT") then raidgroup:SetPoint("TOPRIGHT", raid[i-1], "TOPLEFT", -o, 0)
        elseif(a=="RIGHT") then raidgroup:SetPoint("RIGHT", raid[i-1], "LEFT", -o, 0) end
    end
    raidgroup:Show()
end

local tank = oUF:Spawn("header", "oUF_MainTank")
tank:SetManyAttributes("showRaid", true, "groupFilter", "MAINTANK", "yOffset", -5)
tank:SetPoint(unpack(settings.Positions["tank"]))
if(settings.MTT) then
    tank:SetAttribute("template", "oUF_aMTTtemplate")
    if(settings.MTTT) then
        tank:SetAttribute("template", "oUF_aMTTTtemplate")
    end
end
tank:Show()