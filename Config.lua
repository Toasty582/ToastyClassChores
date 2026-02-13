local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

local config = {
    name = "Toasty Class Chores",
    handler = ToastyClassChores,
    type = "group",
    args = {
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
                    name = "Enable Pet Tracking",
                    get = function() return ToastyClassChores.db.profile.petsTracking end,
                    set = "SetPetsTracking",
                },
                petsIconSize = {
                    type = "range",
                    name = "Icon Size",
                    get = function() return ToastyClassChores.db.profile.petsIconSize end,
                    set = "SetPetsIconSize",
                },
            }
        }
    },
}

local defaults = {
    profile = {
        shadowformTracking = true,
        shadowformIconSize = 75,
        raidBuffTracking = true,
        raidBuffIconSize = 75,
        petsTracking = true,
        petsIconSize = 75,
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
