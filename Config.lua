local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.Config = ToastyClassChores.Config or {}
local Config = ToastyClassChores.Config

local config = {
    name = "Toasty Class Chores",
    handler = ToastyClassChores,
    type = "group",
    args = {
        uiLock = {
            type = "execute",
            name = "Toggle Frame Locks",
            func = "ToggleFrameLock",
            desc = "/tcc lock"
        },
        shadowform = {
            type = "group",
            name = "Shadowform",
            args = {
                tracking = {
                    type = "toggle",
                    name = "Enable Tracking",
                    desc = nil,
                    get = function() return ToastyClassChores.db.profile.shadowform.tracking end,
                    set = "SetShadowformTracking",
                    width = "full",
                },
                iconSize = {
                    type = "range",
                    name = "Icon Size",
                    softMax = 200,
                    desc = "Input number for larger icons",
                    get = function() return ToastyClassChores.db.profile.shadowform.iconSize end,
                    set = "SetShadowformIconSize",
                },
                opacity = {
                    type = "range",
                    name = "Opacity",
                    min = 0,
                    max = 1,
                    get = function() return ToastyClassChores.db.profile.shadowform.opacity end,
                    set = "SetShadowformOpacity",
                },
                combatOnly = {
                    type = "toggle",
                    name = "In Combat Only",
                    get = function() return ToastyClassChores.db.profile.shadowform.combatOnly end,
                    set = "SetShadowformCombatOnly",
                    width = "full",
                    order = -3,
                },
                instanceOnly = {
                    type = "toggle",
                    name = "Only Show in Instances",
                    get = function() return ToastyClassChores.db.profile.shadowform.instanceOnly end,
                    set = "SetShadowformInstanceOnly",
                    width = "full",
                    order = -2,
                },
                noLegacy = {
                    type = "toggle",
                    name = "Hide in Legacy Instances",
                    desc = "Hides frame whenever legacy loot rules are active",
                    get = function() return ToastyClassChores.db.profile.shadowform.noLegacy end,
                    set = "SetShadowformNoLegacy",
                    width = "full",
                    order = -1,
                },
            }
        },
        raidBuff = {
            type = "group",
            name = "Raid Buffs",
            args = {
                tracking = {
                    type = "toggle",
                    name = "Enable Tracking",
                    get = function() return ToastyClassChores.db.profile.raidBuff.tracking end,
                    set = "SetRaidBuffTracking",
                    width = "full",
                    order = 1,
                },
                iconSize = {
                    type = "range",
                    name = "Icon Size",
                    softMax = 200,
                    desc = "Input number for larger icons",
                    get = function() return ToastyClassChores.db.profile.raidBuff.iconSize end,
                    set = "SetRaidBuffIconSize",
                },
                opacity = {
                    type = "range",
                    name = "Opacity",
                    min = 0,
                    max = 1,
                    get = function() return ToastyClassChores.db.profile.raidBuff.opacity end,
                    set = "SetRaidBuffOpacity",
                },
                earlyWarning = {
                    type = "range",
                    name = "Early Warning",
                    desc =
                    "Time in minutes before expiration at which the alert appears. Note that this only tracks the buff on you, not anyone in your group.",
                    min = 0,
                    max = 60,
                    step = 1,
                    get = function() return ToastyClassChores.db.profile.raidBuff.earlyWarning end,
                    set = "SetRaidBuffEarlyWarning",
                    order = 103,
                },
                earlyWarningNoCombat = {
                    type = "toggle",
                    name = "Hide Early Warning During Combat",
                    get = function() return ToastyClassChores.db.profile.raidBuff.earlyWarningNoCombat end,
                    set = "SetRaidBuffEarlyWarningNoCombat",
                    width = "full",
                    order = 104,
                },
            }
        },
        pets = {
            type = "group",
            name = "Pets",
            args = {
                tracking = {
                    type = "toggle",
                    name = "Enable Tracking",
                    get = function() return ToastyClassChores.db.profile.pets.tracking end,
                    set = "SetPetsTracking",
                    width = "full"
                },
                iconSize = {
                    type = "range",
                    name = "Icon Size",
                    softMax = 200,
                    desc = "Input number for larger icons",
                    get = function() return ToastyClassChores.db.profile.pets.iconSize end,
                    set = "SetPetsIconSize",
                },
                opacity = {
                    type = "range",
                    name = "Opacity",
                    min = 0,
                    max = 1,
                    get = function() return ToastyClassChores.db.profile.pets.opacity end,
                    set = "SetPetsOpacity",
                },
                instanceOnly = {
                    type = "toggle",
                    name = "Only Show in Instances",
                    get = function() return ToastyClassChores.db.profile.pets.instanceOnly end,
                    set = "SetPetsInstanceOnly",
                    width = "full",
                    order = -2,
                },
                noLegacy = {
                    type = "toggle",
                    name = "Hide in Legacy Instances",
                    desc = "Hides frame whenever legacy loot rules are active",
                    get = function() return ToastyClassChores.db.profile.pets.noLegacy end,
                    set = "SetPetsNoLegacy",
                    width = "full",
                    order = -1,
                }
            }
        },
        druidForms = {
            type = "group",
            name = "Druid Forms",
            args = {
                yracking = {
                    type = "toggle",
                    name = "Enable Tracking",
                    get = function() return ToastyClassChores.db.profile.druidForms.tracking end,
                    set = "SetDruidFormsTracking",
                    width = "full",
                },
                iconSize = {
                    type = "range",
                    name = "Icon Size",
                    softMax = 200,
                    desc = "Input number for larger icons",
                    get = function() return ToastyClassChores.db.profile.druidForms.iconSize end,
                    set = "SetDruidFormsIconSize",
                },
                opacity = {
                    type = "range",
                    name = "Opacity",
                    min = 0,
                    max = 1,
                    get = function() return ToastyClassChores.db.profile.druidForms.opacity end,
                    set = "SetDruidFormsOpacity",
                },
                alwaysShow = {
                    type = "toggle",
                    name = "Always Show Form",
                    desc = "Stop the frame from hiding while in the 'correct' form",
                    get = function() return ToastyClassChores.db.profile.druidForms.alwaysShow end,
                    set = "SetDruidFormsAlwaysShow",
                    width = "full",
                    order = 101,
                },
                ignoreTravel = {
                    type = "toggle",
                    name = "Ignore Travel Form",
                    get = function() return ToastyClassChores.db.profile.druidForms.ignoreTravel end,
                    set = "SetDruidFormsIgnoreTravel",
                    width = "full",
                    order = 102,
                },
                combatOnly = {
                    type = "toggle",
                    name = "In Combat Only",
                    get = function() return ToastyClassChores.db.profile.druidForms.combatOnly end,
                    set = "SetDruidFormsCombatOnly",
                    width = "full",
                    order = 103,
                },
                instanceOnly = {
                    type = "toggle",
                    name = "Only Show in Instances",
                    get = function() return ToastyClassChores.db.profile.druidForms.instanceOnly end,
                    set = "SetDruidFormsInstanceOnly",
                    width = "full",
                    order = -2,
                },
                noLegacy = {
                    type = "toggle",
                    name = "Hide in Legacy Instances",
                    desc = "Hides frame whenever legacy loot rules are active",
                    get = function() return ToastyClassChores.db.profile.druidForms.noLegacy end,
                    set = "SetDruidFormsNoLegacy",
                    width = "full",
                    order = -1,
                }
            }
        },
        warriorStances = {
            type = "group",
            name = "Warrior Stances",
            args = {
                tracking = {
                    type = "toggle",
                    name = "Enable Tracking",
                    get = function() return ToastyClassChores.db.profile.warriorStances.tracking end,
                    set = "SetWarriorStancesTracking",
                    width = "full"
                },
                iconSize = {
                    type = "range",
                    name = "Icon Size",
                    softMax = 200,
                    desc = "Input number for larger icons",
                    get = function() return ToastyClassChores.db.profile.warriorStances.iconSize end,
                    set = "SetWarriorStancesIconSize",
                },
                opacity = {
                    type = "range",
                    name = "Opacity",
                    min = 0,
                    max = 1,
                    get = function() return ToastyClassChores.db.profile.warriorStances.opacity end,
                    set = "SetWarriorStancesOpacity",
                },
                alwaysShow = {
                    type = "toggle",
                    name = "Always Show",
                    get = function() return ToastyClassChores.db.profile.warriorStances.alwaysShow end,
                    set = "SetWarriorStancesAlwaysShow",
                    order = -4
                },
                noCombatOnly = {
                    type = "toggle",
                    name = "Out of Combat Only",
                    get = function() return ToastyClassChores.db.profile.warriorStances.noCombatOnly end,
                    set = "SetWarriorStancesNoCombatOnly",
                    width = "full",
                    order = -3,
                },
                protShowsBattle = {
                    type = "toggle",
                    name = "Show Battle Stance for Prot",
                    width = "full",
                    get = function() return ToastyClassChores.db.profile.warriorStances.protShowsBattle end,
                    set = "SetProtShowsBattle",
                    order = -2,
                },
                protShowsDef = {
                    type = "toggle",
                    name = "Show Defensive Stance for Prot",
                    width = "full",
                    get = function() return ToastyClassChores.db.profile.warriorStances.protShowsDef end,
                    set = "SetProtShowsDef",
                    order = -1,
                },
            }
        },
        paladinAuras = {
            type = "group",
            name = "Paladin Auras",
            args = {
                tracking = {
                    type = "toggle",
                    name = "Enable Tracking",
                    get = function() return ToastyClassChores.db.profile.paladinAuras.tracking end,
                    set = "SetPaladinAurasTracking",
                    width = "full",
                },
                iconSize = {
                    type = "range",
                    name = "Icon Size",
                    softMax = 200,
                    desc = "Input number for larger icons",
                    get = function() return ToastyClassChores.db.profile.paladinAuras.iconSize end,
                    set = "SetPaladinAurasIconSize",
                },
                opacity = {
                    type = "range",
                    name = "Opacity",
                    min = 0,
                    max = 1,
                    get = function() return ToastyClassChores.db.profile.paladinAuras.opacity end,
                    set = "SetPaladinAurasOpacity",
                },
                alwaysShow = {
                    type = "toggle",
                    name = "Show Devotion Aura",
                    get = function() return ToastyClassChores.db.profile.paladinAuras.alwaysShow end,
                    set = "SetPaladinAurasAlwaysShow",
                    width = "full",
                    order = 101,
                },
                combatOnly = {
                    type = "toggle",
                    name = "In Combat Only",
                    get = function() return ToastyClassChores.db.profile.paladinAuras.combatOnly end,
                    set = "SetPaladinAurasCombatOnly",
                    width = "full",
                    order = 102,
                },
                instanceOnly = {
                    type = "toggle",
                    name = "Only Show in Instances",
                    get = function() return ToastyClassChores.db.profile.paladinAuras.instanceOnly end,
                    set = "SetPaladinAurasInstanceOnly",
                    width = "full",
                    order = -2,
                },
                noLegacy = {
                    type = "toggle",
                    name = "Hide in Legacy Instances",
                    desc = "Hides frame whenever legacy loot rules are active",
                    get = function() return ToastyClassChores.db.profile.paladinAuras.noLegacy end,
                    set = "SetPaladinAurasNoLegacy",
                    width = "full",
                    order = -1,
                },
            }
        },
        sacrificeGrimoire = {
            type = "group",
            name = "Grimoire of Sacrifice",
            args = {
                tracking = {
                    type = "toggle",
                    name = "Enable Tracking",
                    get = function() return ToastyClassChores.db.profile.sacrificeGrimoire.tracking end,
                    set = "SetSacrificeGrimoireTracking",
                    width = "full",
                },
                iconSize = {
                    type = "range",
                    name = "Icon Size",
                    softMax = 200,
                    desc = "Input number for larger icons",
                    get = function() return ToastyClassChores.db.profile.sacrificeGrimoire.iconSize end,
                    set = "SetSacrificeGrimoireIconSize",
                },
                opacity = {
                    type = "range",
                    name = "Opacity",
                    min = 0,
                    max = 1,
                    get = function() return ToastyClassChores.db.profile.sacrificeGrimoire.opacity end,
                    set = "SetSacrificeGrimoireOpacity",
                },
            },
        },
        roguePoisons = {
            type = "group",
            name = "Rogue Poisons",
            args = {
                tracking = {
                    type = "toggle",
                    name = "Enable Tracking",
                    get = function() return ToastyClassChores.db.profile.roguePoisons.tracking end,
                    set = "SetRoguePoisonsTracking",
                    width = "full",
                    order = 1,
                },
                iconSize = {
                    type = "range",
                    name = "Icon Size",
                    softMax = 200,
                    desc = "Input number for larger icons",
                    get = function() return ToastyClassChores.db.profile.roguePoisons.iconSize end,
                    set = "SetRoguePoisonsIconSize",
                },
                opacity = {
                    type = "range",
                    name = "Opacity",
                    min = 0,
                    max = 1,
                    get = function() return ToastyClassChores.db.profile.roguePoisons.opacity end,
                    set = "SetRoguePoisonsOpacity",
                },
                earlyWarning = {
                    type = "range",
                    name = "Early Warning",
                    desc = "Time in minutes before expiration at which the alert appears.",
                    min = 0,
                    max = 60,
                    step = 1,
                    get = function() return ToastyClassChores.db.profile.roguePoisons.earlyWarning end,
                    set = "SetRoguePoisonsEarlyWarning",
                    order = 103,
                },
                earlyWarningNoCombat = {
                    type = "toggle",
                    name = "Hide Early Warning During Combat",
                    get = function() return ToastyClassChores.db.profile.roguePoisons.earlyWarningNoCombat end,
                    set = "SetRoguePoisonsEarlyWarningNoCombat",
                    width = "full",
                    order = 104
                }
            }
        },
        shamanShields = {
            type = "group",
            name = "Shaman Shields",
            args = {
                tracking = {
                    type = "toggle",
                    name = "Enable Tracking",
                    get = function() return ToastyClassChores.db.profile.shamanShields.tracking end,
                    set = "SetShamanShieldsTracking",
                    width = "full",
                    order = 1,
                },
                secretDisclaimer = {
                    type = "description",
                    name =
                    "Manually removing shields or Water Shield being consumed while secrets are active will not register until secrets deactivate.",
                    order = 2,
                },
                iconSize = {
                    type = "range",
                    name = "Icon Size",
                    softMax = 200,
                    desc = "Input number for larger icons",
                    get = function() return ToastyClassChores.db.profile.shamanShields.iconSize end,
                    set = "SetShamanShieldsIconSize",
                },
                opacity = {
                    type = "range",
                    name = "Opacity",
                    min = 0,
                    max = 1,
                    get = function() return ToastyClassChores.db.profile.shamanShields.opacity end,
                    set = "SetShamanShieldsOpacity",
                },
                earlyWarning = {
                    type = "range",
                    name = "Early Warning",
                    desc =
                    "Time in minutes before expiration at which the alert appears.",
                    min = 0,
                    max = 60,
                    step = 1,
                    get = function() return ToastyClassChores.db.profile.shamanShields.earlyWarning end,
                    set = "SetShamanShieldsEarlyWarning",
                    order = 103
                },
                earlyWarningNoCombat = {
                    type = "toggle",
                    name = "Hide Early Warning During Combat",
                    get = function() return ToastyClassChores.db.profile.shamanShields.earlyWarningNoCombat end,
                    set = "SetShamanShieldsEarlyWarningNoCombat",
                    width = "full",
                    order = 104
                }
            }
        },
        lightsmithRites = {
            type = "group",
            name = "Lightsmith Rites",
            args = {
                tracking = {
                    type = "toggle",
                    name = "Enable Tracking",
                    get = function() return ToastyClassChores.db.profile.lightsmithRites.tracking end,
                    set = "SetLightsmithRitesTracking",
                    width = "full",
                    order = 1,
                },
                secretDisclaimer = {
                    type = "description",
                    name =
                    "While it should not be possible, if your rite is removed early while secrets are active, it will not register until secrets deactivate.",
                    order = 2,
                },
                iconSize = {
                    type = "range",
                    name = "Icon Size",
                    softMax = 200,
                    desc = "Input number for larger icons",
                    get = function() return ToastyClassChores.db.profile.lightsmithRites.iconSize end,
                    set = "SetLightsmithRitesIconSize",
                },
                opacity = {
                    type = "range",
                    name = "Opacity",
                    min = 0,
                    max = 1,
                    get = function() return ToastyClassChores.db.profile.lightsmithRites.opacity end,
                    set = "SetLightsmithRitesOpacity",
                },
                earlyWarning = {
                    type = "range",
                    name = "Early Warning",
                    desc = "Time in minutes before expiration at which the alert appears.",
                    min = 0,
                    max = 60,
                    step = 1,
                    get = function() return ToastyClassChores.db.profile.lightsmithRites.earlyWarning end,
                    set = "SetLightsmithRitesEarlyWarning",
                    order = 103,
                },
                earlyWarningNoCombat = {
                    type = "toggle",
                    name = "Hide Early Warning During Combat",
                    get = function() return ToastyClassChores.db.profile.lightsmithRites.earlyWarningNoCombat end,
                    set = "SetLightsmithRitesEarlyWarningNoCombat",
                    width = "full",
                    order = 104
                }
            }
        },
        sourceOfMagic = {
            type = "group",
            name = "Source of Magic",
            args = {
                tracking = {
                    type = "toggle",
                    name = "Enable Tracking",
                    get = function() return ToastyClassChores.db.profile.sourceOfMagic.tracking end,
                    set = "SetSourceOfMagicTracking",
                    width = "full",
                    order = 1,
                },
                iconSize = {
                    type = "range",
                    name = "Icon Size",
                    softMax = 200,
                    desc = "Input number for larger icons",
                    get = function() return ToastyClassChores.db.profile.sourceOfMagic.iconSize end,
                    set = "SetSourceOfMagicIconSize",
                },
                opacity = {
                    type = "range",
                    name = "Opacity",
                    min = 0,
                    max = 1,
                    get = function() return ToastyClassChores.db.profile.sourceOfMagic.opacity end,
                    set = "SetSourceOfMagicOpacity",
                },
                earlyWarning = {
                    type = "range",
                    name = "Early Warning",
                    desc = "Time in minutes before expiration at which the alert appears.",
                    min = 0,
                    max = 60,
                    step = 1,
                    get = function() return ToastyClassChores.db.profile.sourceOfMagic.earlyWarning end,
                    set = "SetSourceOfMagicEarlyWarning",
                    order = 103,
                },
                earlyWarningNoCombat = {
                    type = "toggle",
                    name = "Hide Early Warning During Combat",
                    get = function() return ToastyClassChores.db.profile.sourceOfMagic.earlyWarningNoCombat end,
                    set = "SetSourceOfMagicEarlyWarningNoCombat",
                    width = "full",
                    order = 104,
                },
            }
        },
        symbioticRelationship = {
            type = "group",
            name = "Symbiotic Relationship",
            args = {
                tracking = {
                    type = "toggle",
                    name = "Enable Tracking",
                    get = function() return ToastyClassChores.db.profile.symbioticRelationship.tracking end,
                    set = "SetSymbioticRelationshipTracking",
                    width = "full",
                    order = 1,
                },
                iconSize = {
                    type = "range",
                    name = "Icon Size",
                    softMax = 200,
                    desc = "Input number for larger icons",
                    get = function() return ToastyClassChores.db.profile.symbioticRelationship.iconSize end,
                    set = "SetSymbioticRelationshipIconSize",
                },
                opacity = {
                    type = "range",
                    name = "Opacity",
                    min = 0,
                    max = 1,
                    get = function() return ToastyClassChores.db.profile.symbioticRelationship.opacity end,
                    set = "SetSymbioticRelationshipOpacity",
                },
                earlyWarning = {
                    type = "range",
                    name = "Early Warning",
                    desc = "Time in minutes before expiration at which the alert appears.",
                    min = 0,
                    max = 60,
                    step = 1,
                    get = function() return ToastyClassChores.db.profile.symbioticRelationship.earlyWarning end,
                    set = "SetSymbioticRelationshipEarlyWarning",
                    order = 103,
                },
                earlyWarningNoCombat = {
                    type = "toggle",
                    name = "Hide Early Warning During Combat",
                    get = function() return ToastyClassChores.db.profile.symbioticRelationship.earlyWarningNoCombat end,
                    set = "SetSymbioticRelationshipEarlyWarningNoCombat",
                    width = "full",
                    order = 104,
                },
            }
        },
        augAttunements = {
            type = "group",
            name = "Aug Attunements",
            args = {
                tracking = {
                    type = "toggle",
                    name = "Enable Tracking",
                    get = function() return ToastyClassChores.db.profile.augAttunements.tracking end,
                    set = "SetAugAttunementsTracking",
                    width = "full"
                },
                iconSize = {
                    type = "range",
                    name = "Icon Size",
                    softMax = 200,
                    desc = "Input number for larger icons",
                    get = function() return ToastyClassChores.db.profile.augAttunements.iconSize end,
                    set = "SetAugAttunementsIconSize",
                },
                opacity = {
                    type = "range",
                    name = "Opacity",
                    min = 0,
                    max = 1,
                    get = function() return ToastyClassChores.db.profile.augAttunements.opacity end,
                    set = "SetAugAttunementsOpacity",
                },
                combatOnly = {
                    type = "toggle",
                    name = "In Combat Only",
                    get = function() return ToastyClassChores.db.profile.augAttunements.combatOnly end,
                    set = "SetAugAttunementsCombatOnly",
                    order = -4,
                },
                noCombatOnly = {
                    type = "toggle",
                    name = "Out of Combat Only",
                    get = function() return ToastyClassChores.db.profile.augAttunements.noCombatOnly end,
                    set = "SetAugAttunementsNoCombatOnly",
                    order = -3,
                },
                showBlack = {
                    type = "toggle",
                    name = "Show Black Attunement",
                    width = "full",
                    get = function() return ToastyClassChores.db.profile.augAttunements.showBlack end,
                    set = "SetAugAttunementsShowBlack",
                    order = -2,
                },
                showBronze = {
                    type = "toggle",
                    name = "Show Bronze Attunement",
                    width = "full",
                    get = function() return ToastyClassChores.db.profile.augAttunements.showBronze end,
                    set = "SetAugAttunementsShowBronze",
                    order = -1,
                },
            }
        },
    },
}

local defaults = {
    profile = {
        needsConfigMigration = true,
        frameLock = true,
        debug = false,
        lastVersion = 10907, -- Will change this about a week after patch, this is only hardcoded because this variable is absent completely in 1.X.X and would then think anyone updating would be updating from 2.0.0 and not from 1.X.X
        shadowform = {
            tracking = true,
            iconSize = 100,
            combatOnly = false,
            instanceOnly = false,
            noLegacy = false,
            opacity = 1,
            location = {
                xPos = 0,
                yPos = 55,
                parentAnchorPoint = "CENTER",
                frameAnchorPoint = "CENTER",
            },
        },
        raidBuff = {
            tracking = true,
            iconSize = 100,
            opacity = 1,
            earlyWarning = 0,
            earlyWarningNoCombat = false,
            location = {
                xPos = 0,
                yPos = -55,
                parentAnchorPoint = "CENTER",
                frameAnchorPoint = "CENTER",
            },
        },
        pets = {
            tracking = true,
            iconSize = 100,
            instanceOnly = false,
            noLegacy = false,
            opacity = 1,
            location = {
                xPos = 0,
                yPos = 55,
                parentAnchorPoint = "CENTER",
                frameAnchorPoint = "CENTER",
            },
        },
        druidForms = {
            alwaysShow = false,
            tracking = true,
            iconSize = 100,
            combatOnly = false,
            ignoreTravel = false,
            instanceOnly = false,
            noLegacy = false,
            opacity = 1,
            location = {
                xPos = 0,
                yPos = 55,
                parentAnchorPoint = "CENTER",
                frameAnchorPoint = "CENTER",
            },
        },
        warriorStances = {
            alwaysShow = false,
            tracking = true,
            iconSize = 100,
            noCombatOnly = false,
            protShowsBattle = false,
            protShowsDef = true,
            opacity = 1,
            location = {
                xPos = 0,
                yPos = 55,
                parentAnchorPoint = "CENTER",
                frameAnchorPoint = "CENTER",
            },
        },
        paladinAuras = {
            alwaysShow = false,
            tracking = true,
            iconSize = 100,
            combatOnly = false,
            instanceOnly = false,
            noLegacy = false,
            opacity = 1,
            location = {
                xPos = 0,
                yPos = 55,
                parentAnchorPoint = "CENTER",
                frameAnchorPoint = "CENTER",
            },
        },
        sacrificeGrimoire = {
            tracking = true,
            iconSize = 100,
            opacity = 1,
            location = {
                xPos = 0,
                yPos = -55,
                parentAnchorPoint = "CENTER",
                frameAnchorPoint = "CENTER",
            },
        },
        roguePoisons = {
            tracking = true,
            iconSize = 100,
            opacity = 1,
            earlyWarning = 0,
            earlyWarningNoCombat = false,
            location = {
                xPos = 0,
                yPos = -55,
                parentAnchorPoint = "CENTER",
                frameAnchorPoint = "CENTER",
            },
        },
        shamanShields = {
            tracking = true,
            iconSize = 100,
            opacity = 1,
            earlyWarning = 0,
            earlyWarningNoCombat = false,
            location = {
                xPos = 0,
                yPos = 55,
                parentAnchorPoint = "CENTER",
                frameAnchorPoint = "CENTER",
            },
        },
        lightsmithRites = {
            tracking = true,
            iconSize = 100,
            opacity = 1,
            earlyWarning = 0,
            earlyWarningNoCombat = false,
            location = {
                xPos = 0,
                yPos = -55,
                parentAnchorPoint = "CENTER",
                frameAnchorPoint = "CENTER",
            },
        },
        sourceOfMagic = {
            tracking = true,
            iconSize = 100,
            opacity = 1,
            earlyWarning = 0,
            earlyWarningNoCombat = false,
            location = {
                xPos = 0,
                yPos = 55,
                parentAnchorPoint = "CENTER",
                frameAnchorPoint = "CENTER",
            },
        },
        symbioticRelationship = {
            tracking = true,
            iconSize = 100,
            opacity = 1,
            earlyWarning = 0,
            earlyWarningNoCombat = false,
            location = {
                xPos = 105,
                yPos = 0,
                parentAnchorPoint = "CENTER",
                frameAnchorPoint = "CENTER",
            },
        },
        augAttunements = {
            tracking = true,
            iconSize = 100,
            combatOnly = false,
            noCombatOnly = false,
            showBlack = false,
            showBronze = true,
            opacity = 1,
            location = {
                xPos = 105,
                yPos = 0,
                parentAnchorPoint = "CENTER",
                frameAnchorPoint = "CENTER",
            },
        },
    },
}

local characterDefaults = {
    profile = {
        class = "",
        guid = "",
        remainingShamanShieldTime = 0,
        remainingLightsmithRiteTime = 0,
    },
}

function Config:MigrateDB()
    ToastyClassChores:Debug("Migrating DB to new format")
    local db = ToastyClassChores.db.profile
    -- old default variable that will always be truthy if it exists as a failsafe to not migrate DBs with the new format
    --if not db.shadowformIconSize then
    --    db.needsConfigMigration = false
    --    return
    --end
    db.shadowform = {
        tracking = db.shadowformTracking or db.shadowform.tracking,
        iconSize = db.shadowformIconSize or db.shadowform.iconSize,
        combatOnly = db.shadowformInCombatOnly or db.shadowform.combatOnly,
        instanceOnly = db.shadowformInstanceOnly or db.shadowform.instanceOnly,
        noLegacy = db.shadowformNoLegacy or db.shadowform.noLegacy,
        opacity = db.shadowformOpacity or db.shadowform.opacity,
        location = db.shadowformLocation or {
            xPos = db.shadowform.location.xPos,
            yPos = db.shadowform.location.yPos,
            parentAnchorPoint = db.shadowform.location.parentAnchorPoint,
            frameAnchorPoint = db.shadowform.location.frameAnchorPoint,
        }
    }
    db.shadowformTracking, db.shadowformIconSize, db.shadowformInCombatOnly, db.shadowformInstanceOnly, db.shadowformNoLegacy, db.shadowformOpacity, db.shadowformLocation = nil
    db.raidBuff = {
        tracking = db.raidBuffTracking or db.raidBuff.tracking,
        iconSize = db.raidBuffSIconSize or db.raidBuff.iconSize,
        earlyWarning = db.raidBuffEarlyWarning or db.raidBuff.earlyWarning,
        earlyWarningNoCombat = db.raidBuffEarlyWarningNoCombat or db.raidBuff.earlyWarningNoCombat,
        opacity = db.raidBuffOpacity or db.raidBuff.opacity,
        location = db.raidBuffLocation or {
            xPos = db.raidBuff.location.xPos,
            yPos = db.raidBuff.location.yPos,
            parentAnchorPoint = db.raidBuff.location.parentAnchorPoint,
            frameAnchorPoint = db.raidBuff.location.frameAnchorPoint,
        }
    }
    db.raidBuffTracking, db.raidBuffIconSize, db.raidBuffEarlyWarning, db.raidBuffEarlyWarningNoCombat, db.raidBuffOpacity, db.raidBuffLocation = nil
    db.pets = {
        tracking = db.petsTracking or db.pets.tracking,
        iconSize = db.petsIconSize or db.pets.iconSize,
        instanceOnly = db.petsInstanceOnly or db.pets.instanceOnly,
        noLegacy = db.petsNoLegacy or db.pets.noLegacy,
        opacity = db.petsOpacity or db.pets.opacity,
        location = db.petsLocation or {
            xPos = db.pets.location.xPos,
            yPos = db.pets.location.yPos,
            parentAnchorPoint = db.pets.location.parentAnchorPoint,
            frameAnchorPoint = db.pets.location.frameAnchorPoint,
        }
    }
    db.petsTracking, db.petsIconSize, db.petsInstanceOnly, db.petsNoLegacy, db.petsOpacity, db.petsLocation = nil
    db.druidForms = {
        alwaysShow = db.druidFormsAlwaysShow or db.druidForms.alwaysShow,
        tracking = db.druidFormsTracking or db.druidForms.tracking,
        iconSize = db.druidFormsIconSize or db.druidForms.iconSize,
        combatOnly = db.druidFormsInCombatOnly or db.druidForms.combatOnly,
        ignoreTravel = db.druidFormsIgnoreTravel or db.druidForms.ignoreTravel,
        instanceOnly = db.druidFormsInstanceOnly or db.druidForms.instanceOnly,
        noLegacy = db.druidFormsNoLegacy or db.druidForms.noLegacy,
        opacity = db.druidFormsOpacity or db.druidForms.opacity,
        location = db.druidFormsLocation or {
            xPos = db.druidForms.location.xPos,
            yPos = db.druidForms.location.yPos,
            parentAnchorPoint = db.druidForms.location.parentAnchorPoint,
            frameAnchorPoint = db.druidForms.location.frameAnchorPoint,
        }
    }
    db.druidFormsAlwaysShow, db.druidFormsTracking, db.druidFormsIconSize, db.druidFormsInCombatOnly, db.druidFormsIgnoreTravel, db.druidFormsInstanceOnly, db.druidFormsNoLegacy, db.druidFormsOpacity, db.druidFormsLocation = nil
    db.warriorStances = {
        alwaysShow = db.warriorStancesAlwaysShow or db.warriorStances.alwaysShow,
        tracking = db.warriorStancesTracking or db.warriorStances.tracking,
        iconSize = db.warriorStancesIconSize or db.warriorStances.iconSize,
        noCombatOnly = db.warriorStancesNoCombatOnly or db.warriorStances.noCombatOnly,
        protShowsBattle = db.warriorStancesProtShowsBattle or db.warriorStances.protShowsBattle,
        protShowsDef = db.warriorStancesProtShowsDef or db.warriorStances.protShowsDef,
        opacity = db.warriorStancesOpacity or db.warriorStances.opacity,
        location = db.warriorStancesLocation or {
            xPos = db.warriorStances.location.xPos,
            yPos = db.warriorStances.location.yPos,
            parentAnchorPoint = db.warriorStances.location.parentAnchorPoint,
            frameAnchorPoint = db.warriorStances.location.frameAnchorPoint,
        }
    }
    db.warriorStancesAlwaysShow, db.warriorStancesTracking, db.warriorStancesIconSize, db.warriorStancesNoCombatOnly, db.warriorStancesProtShowsBattle, db.warriorStancesProtShowsDef, db.warriorStancesOpacity, db.warriorStancesLocation = nil
    db.paladinAuras = {
        alwaysShow = db.paladinAurasAlwaysShow or db.paladinAuras.alwaysShow,
        tracking = db.paladinAurasTracking or db.paladinAuras.tracking,
        iconSize = db.paladinAurasIconSize or db.paladinAuras.iconSize,
        combatOnly = db.paladinAurasInCombatOnly or db.paladinAuras.combatOnly,
        instanceOnly = db.paladinAurasInstanceOnly or db.paladinAuras.instanceOnly,
        noLegacy = db.paladinAurasNoLegacy or db.paladinAuras.noLegacy,
        opacity = db.paladinAurasOpacity or db.paladinAuras.opacity,
        location = db.paladinAurasLocation or {
            xPos = db.paladinAuras.location.xPos,
            yPos = db.paladinAuras.location.yPos,
            parentAnchorPoint = db.paladinAuras.location.parentAnchorPoint,
            frameAnchorPoint = db.paladinAuras.location.frameAnchorPoint,
        }
    }
    db.paladinAurasAlwaysShow, db.paladinAurasTracking, db.paladinAurasIconSize, db.paladinAurasInCombatOnly, db.paladinAurasInstanceOnly, db.paladinAurasNoLegacy, db.paladinAurasOpacity, db.paladinAurasLocation = nil
    db.sacrificeGrimoire = {
        tracking = db.sacrificeGrimoireTracking or db.sacrificeGrimoire.tracking,
        iconSize = db.sacrificeGrimoireIconSize or db.sacrificeGrimoire.iconSize,
        opacity = db.sacrificeGrimoireOpacity or db.sacrificeGrimoire.opacity,
        location = db.sacrificeGrimoireLocation or {
            xPos = db.sacrificeGrimoire.location.xPos,
            yPos = db.sacrificeGrimoire.location.yPos,
            parentAnchorPoint = db.sacrificeGrimoire.location.parentAnchorPoint,
            frameAnchorPoint = db.sacrificeGrimoire.location.frameAnchorPoint,
        }
    }
    db.sacrificeGrimoireTracking, db.sacrificeGrimoireIconSize, db.sacrificeGrimoireOpacity, db.sacrificeGrimoireLocation = nil
    db.roguePoisons = {
        tracking = db.roguePoisonsTracking or db.roguePoisons.tracking,
        iconSize = db.roguePoisonsIconSize or db.roguePoisons.iconSize,
        earlyWarning = db.roguePoisonsEarlyWarning or db.roguePoisons.earlyWarning,
        earlyWarningNoCombat = db.roguePoisonsEarlyWarningNoCombat or db.roguePoisons.earlyWarningNoCombat,
        opacity = db.roguePoisonsOpacity or db.roguePoisons.opacity,
        location = db.roguePoisonsLocation or {
            xPos = db.roguePoisons.location.xPos,
            yPos = db.roguePoisons.location.yPos,
            parentAnchorPoint = db.roguePoisons.location.parentAnchorPoint,
            frameAnchorPoint = db.roguePoisons.location.frameAnchorPoint,
        }
    }
    db.roguePoisonsTracking, db.roguePoisonsIconSize, db.roguePoisonsEarlyWarning, db.roguePoisonsEarlyWarningNoCombat, db.roguePoisonsOpacity, db.roguePoisonsLocation = nil
    db.shamanShields = {
        tracking = db.shamanShieldsTracking or db.shamanShields.tracking,
        iconSize = db.shamanShieldsIconSize or db.shamanShields.iconSize,
        earlyWarning = db.shamanShieldsEarlyWarning or db.shamanShields.earlyWarning,
        earlyWarningNoCombat = db.shamanShieldsEarlyWarningNoCombat or db.shamanShields.earlyWarningNoCombat,
        opacity = db.shamanShieldsOpacity or db.shamanShields.opacity,
        location = db.shamanShieldsLocation or {
            xPos = db.shamanShields.location.xPos,
            yPos = db.shamanShields.location.yPos,
            parentAnchorPoint = db.shamanShields.location.parentAnchorPoint,
            frameAnchorPoint = db.shamanShields.location.frameAnchorPoint,
        }
    }
    db.shamanShieldsTracking, db.shamanShieldsIconSize, db.shamanShieldsEarlyWarning, db.shamanShieldsEarlyWarningNoCombat, db.shamanShieldsOpacity, db.shamanShieldsLocation = nil
    db.lightsmithRites = {
        tracking = db.lightsmithRitesTracking or db.lightsmithRites.tracking,
        iconSize = db.lightsmithRitesIconSize or db.lightsmithRites.iconSize,
        earlyWarning = db.lightsmithRitesEarlyWarning or db.lightsmithRites.earlyWarning,
        earlyWarningNoCombat = db.lightsmithRitesEarlyWarningNoCombat or db.lightsmithRites.earlyWarningNoCombat,
        opacity = db.lightsmithRitesOpacity or db.lightsmithRites.opacity,
        location = db.lightsmithRitesLocation or {
            xPos = db.lightsmithRites.location.xPos,
            yPos = db.lightsmithRites.location.yPos,
            parentAnchorPoint = db.lightsmithRites.location.parentAnchorPoint,
            frameAnchorPoint = db.lightsmithRites.location.frameAnchorPoint,
        }
    }
    db.lightsmithRitesTracking, db.lightsmithRitesIconSize, db.lightsmithRitesEarlyWarning, db.lightsmithRitesEarlyWarningNoCombat, db.lightsmithRitesOpacity, db.lightsmithRitesLocation = nil
    db.sourceOfMagic = {
        tracking = db.sourceOfMagicTracking or db.sourceOfMagic.tracking,
        iconSize = db.sourceOfMagicIconSize or db.sourceOfMagic.iconSize,
        earlyWarning = db.sourceOfMagicEarlyWarning or db.sourceOfMagic.earlyWarning,
        earlyWarningNoCombat = db.sourceOfMagicEarlyWarningNoCombat or db.sourceOfMagic.earlyWarningNoCombat,
        opacity = db.sourceOfMagicOpacity or db.sourceOfMagic.opacity,
        location = db.sourceOfMagicLocation or {
            xPos = db.sourceOfMagic.location.xPos,
            yPos = db.sourceOfMagic.location.yPos,
            parentAnchorPoint = db.sourceOfMagic.location.parentAnchorPoint,
            frameAnchorPoint = db.sourceOfMagic.location.frameAnchorPoint,
        }
    }
    db.sourceOfMagicTracking, db.sourceOfMagicIconSize, db.sourceOfMagicEarlyWarning, db.sourceOfMagicEarlyWarningNoCombat, db.sourceOfMagicOpacity, db.sourceOfMagicLocation = nil
    db.needsConfigMigration = false
end

ToastyClassChores.config = config
ToastyClassChores.characterDefaults = characterDefaults
ToastyClassChores.defaults = defaults
