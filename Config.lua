local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

local config = {
    name = "Toasty Class Chores",
    handler = ToastyClassChores,
    type = "group",
    args = {
        uiLock = {
            type = "execute",
            name = "Toggle Frame Locks",
            func = "ToggleFrameLock"
        },
        shadowform = {
            type = "group",
            name = "Shadowform",
            args = {
                shadowformTracking = {
                    type = "toggle",
                    name = "Enable Tracking",
                    desc = nil,
                    get = function() return ToastyClassChores.db.profile.shadowformTracking end,
                    set = "SetShadowformTracking",
                },
                shadowformIconSize = {
                    type = "range",
                    name = "Icon Size",
                    softMax = 200,
                    get = function() return ToastyClassChores.db.profile.shadowformIconSize end,
                    set = "SetShadowformIconSize",
                },
            }
        },
        raidBuff = {
            type = "group",
            name = "Raid Buffs",
            args = {
                raidBuffTracking = {
                    type = "toggle",
                    name = "Enable Tracking",
                    get = function() return ToastyClassChores.db.profile.raidBuffTracking end,
                    set = "SetRaidBuffTracking",
                },
                raidBuffIconSize = {
                    type = "range",
                    name = "Icon Size",
                    softMax = 200,
                    get = function() return ToastyClassChores.db.profile.raidBuffIconSize end,
                    set = "SetRaidBuffIconSize",
                },
            }
        },
        pets = {
            type = "group",
            name = "Pets",
            args = {
                petsTracking = {
                    type = "toggle",
                    name = "Enable Tracking",
                    get = function() return ToastyClassChores.db.profile.petsTracking end,
                    set = "SetPetsTracking",
                },
                petsIconSize = {
                    type = "range",
                    name = "Icon Size",
                    softMax = 200,
                    get = function() return ToastyClassChores.db.profile.petsIconSize end,
                    set = "SetPetsIconSize",
                },
            }
        },
        druidForms = {
            type = "group",
            name = "Druid Forms",
            args = {
                druidFormsTracking = {
                    type = "toggle",
                    name = "Enable Tracking",
                    get = function() return ToastyClassChores.db.profile.druidFormsTracking end,
                    set = "SetDruidFormsTracking",
                },
                druidFormsIconSize = {
                    type = "range",
                    name = "Icon Size",
                    softMax = 200,
                    get = function() return ToastyClassChores.db.profile.druidFormsIconSize end,
                    set = "SetDruidFormsIconSize",
                },
                druidFormsAlwaysShow = {
                    type = "toggle",
                    name = "Always Show Form",
                    desc = "Stop the frame from hiding while in the 'correct' form",
                    get = function() return ToastyClassChores.db.profile.druidFormsAlwaysShow end,
                    set = "SetDruidFormsAlwaysShow",
                    order = -1,
                },
            }
        },
        warriorStances = {
            type = "group",
            name = "Warrior Stances",
            args = {
                druidFormsTracking = {
                    type = "toggle",
                    name = "Enable Tracking",
                    get = function() return ToastyClassChores.db.profile.warriorStancesTracking end,
                    set = "SetWarriorStancesTracking",
                },
                druidFormsIconSize = {
                    type = "range",
                    name = "Icon Size",
                    softMax = 200,
                    get = function() return ToastyClassChores.db.profile.warriorStancesIconSize end,
                    set = "SetWarriorStancesIconSize",
                },
                warriorStancesProtShowsBattle = {
                    type = "toggle",
                    name = "Show Battle Stance for Prot",
                    width = "full",
                    get = function() return ToastyClassChores.db.profile.warriorStancesProtShowsBattle end,
                    set = "SetProtShowsBattle",
                    order = -2,
                },
                warriorStancesProtShowsDef = {
                    type = "toggle",
                    name = "Show Defensive Stance for Prot",
                    width = "full",
                    get = function() return ToastyClassChores.db.profile.warriorStancesProtShowsDef end,
                    set = "SetProtShowsDef",
                    order = -1,
                },
            }
        },
        paladinAuras = {
            type = "group",
            name = "Paladin Auras",
            args = {
                paladinAurasTracking = {
                    type = "toggle",
                    name = "Enable Tracking",
                    get = function() return ToastyClassChores.db.profile.paladinAurasTracking end,
                    set = "SetPaladinAurasTracking",
                },
                paladinAurasIconSize = {
                    type = "range",
                    name = "Icon Size",
                    softMax = 200,
                    get = function() return ToastyClassChores.db.profile.paladinAurasIconSize end,
                    set = "SetPaladinAurasIconSize",
                },
                paladinAurasAlwaysShow = {
                    type = "toggle",
                    name = "Show Devotion Aura",
                    get = function() return ToastyClassChores.db.profile.paladinAurasAlwaysShow end,
                    set = "SetPaladinAurasAlwaysShow",
                    order = -1,
                },
            }
        },
    },
}

local defaults = {
    profile = {
        frameLock = true,
        debug = false,
        shadowformTracking = true,
        shadowformIconSize = 100,
        shadowformLocation = {
            xPos = 0,
            yPos = 55,
            parentAnchorPoint = "CENTER",
            frameAnchorPoint = "CENTER",
        },
        raidBuffTracking = true,
        raidBuffIconSize = 100,
        raidBuffLocation = {
            xPos = 0,
            yPos = -55,
            parentAnchorPoint = "CENTER",
            frameAnchorPoint = "CENTER",
        },
        petsTracking = true,
        petsIconSize = 100,
        petsLocation = {
            xPos = 0,
            yPos = 55,
            parentAnchorPoint = "CENTER",
            frameAnchorPoint = "CENTER",
        },
        druidFormsTracking = true,
        druidFormsIconSize = 100,
        druidFormsLocation = {
            xPos = 0,
            yPos = 55,
            parentAnchorPoint = "CENTER",
            frameAnchorPoint = "CENTER",
        },
        warriorStancesAlwaysShow = false,
        warriorStancesTracking = true,
        warriorStancesIconSize = 100,
        warriorStancesLocation = {
            xPos = 0,
            yPos = 55,
            parentAnchorPoint = "CENTER",
            frameAnchorPoint = "CENTER",
        },
        warriorStancesProtShowsBattle = false,
        warriorStancesProtShowsDef = true,
        paladinAurasTracking = true,
        paladinAurasIconSize = 100,
        paladinAurasLocation = {
            xPos = 0,
            yPos = 55,
            parentAnchorPoint = "CENTER",
            frameAnchorPoint = "CENTER",
        },
    },
}

local characterDefaults = {
    profile = {
        class = "",
        --petMarksman = false,
        --sacrificeGrimoire = false,
    },
}

ToastyClassChores.config = config
ToastyClassChores.characterDefaults = characterDefaults
ToastyClassChores.defaults = defaults
