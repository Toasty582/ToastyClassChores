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
        }
    },
}

local defaults = {
    profile = {
        frameLock = true,
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
            yPos = 0,
            parentAnchorPoint = "CENTER",
            frameAnchorPoint = "CENTER",
        },
    },
}

local characterDefaults = {
    profile = {
        class = "",
        petMarksman = false,
        sacrificeGrimoire = false,
    },
}

ToastyClassChores.config = config
ToastyClassChores.characterDefaults = characterDefaults
ToastyClassChores.defaults = defaults
