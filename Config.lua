local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

local config = {
    name = "Toasty Class Chores",
    handler = ToastyClassChores,
    type = "group",
    args = {
        shadowformTracking = {
            type = "toggle",
            name = "Enable Shadowform Tracking",
            get = function() return ToastyClassChores.db.profile.shadowformTracking end,
            set = "SetShadowformTracking",
        },
        shadowformIconSize = {
            type = "range",
            name = "Shadowform Icon Size",
            min = 0,
            max = 1000,
            softmax = 100,
            get = function() return ToastyClassChores.db.profile.shadowformIconSize end,
            set = "SetShadowformIconSize"
        },
        raidBuffTracking = {
            type = "toggle",
            name = "Enable Raid Buff Tracking",
            get = function() return ToastyClassChores.db.profile.raidBuffTracking end,
            set = "SetRaidBuffTracking",
        },
        petsTracking = {
            type = "toggle",
            name = "Enable Pet Tracking",
            get = function() return ToastyClassChores.db.profile.petsTracking end,
            set = "SetPetsTracking",
        },
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