oUF_Ettan_Settings = {
    ["Raid"] = {
        Frames = {
            ["raid"] = {Width = 88, Height = 22, ManaBar = 0, Orientation = "HORIZONTAL"},
            ["tank"] = {Width = 80, Height = 15, ManaBar = 0, Orientation = "HORIZONTAL"},
        },
        Positions = {
            ["raidgroup_1"] = {"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -39, 38}, -- first raid group
            ["tank"] = {"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -253, 27},
        },
        Plugins = {
            HealComm = false,
            oUF_ReadyCheck = false,
            oUF_DebuffHighlight = false,
        },
        texture = "Interface\\Addons\\oUF_Ettan\\textures\\Caba",
        font = "Interface\\Addons\\oUF_Ettan\\fonts\\MARK.ttf",
        fsize = 9,

        Offset = 2, -- spacing between raid frames
        RaidInitialAnchor = "BOTTOMRIGHT", -- may be any of "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"
        NumRaidGroups = 5,                 -- Max amount if raid groups that will be shown

        MTT = true,                        -- spawn maintank target frames that will inherit MT frames settings
        MTTT = true,                       -- spawn maintank targettarget frames

        ClassColor = false,                -- Should health bars be colored by class?
        NameClassColor = true,             -- Should name text be colored by class?
        OwnColor = {0.25, 0.35, 0.35},     -- (if ClassColor is false) color of health bars
        PowerColorByType = true,           -- Should mana bars be colored by power type?
        OwnPowerColor = { 0.2, 0.2, 1 },   -- (if PowerColorByType is false) color of mana bars

        RaidIcon = true,                   -- show raid target icons?
        ColorAggro = true,                 -- color raidframe border if unit has aggro or at high threat
        RightClickMenu = false,
    },
}