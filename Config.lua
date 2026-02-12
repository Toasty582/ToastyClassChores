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
        raidBuffTracking = {
            type = "toggle",
            name = "Enable Raid Buff Tracking",
            get = function() return ToastyClassChores.db.profile.raidBuffTracking end,
            set = "SetRaidBuffTracking",
        }
    },
}

local defaults = {
    profile = {
        shadowformTracking = true,
        raidBuffTracking = true
    },
}

local characterDefaults = {
    profile = {
        class = "",
    },
}

ToastyClassChores.config = config
ToastyClassChores.characterDefaults = characterDefaults
ToastyClassChores.defaults = defaults