local ADDON_NAME, ns = ...

ToastyClassChores = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
ns.Addon = ToastyClassChores

ToastyClassChores.versionString = C_AddOns.GetAddOnMetadata(ToastyClassChores.name, "Version")
local major, minor, patch = ToastyClassChores.versionString:match("^(%d+)%.(%d+)%.(%d+)$")
ToastyClassChores.version = tonumber(string.format("%02d%02d%02d", major, minor, patch))


local playerClass

function ToastyClassChores:OnInitialize()
    local defaults = ToastyClassChores.defaults
    local characterDefaults = ToastyClassChores.characterDefaults
    if not defaults or not characterDefaults then self:Print("Defaults not found") end
    local config = ToastyClassChores.config
    if not config then self:Print("Config not found") end

    self.db = LibStub("AceDB-3.0"):New("ToastyClassChoresDB", defaults, true)
    self.cdb = LibStub("AceDB-3.0"):New("ToastyClassChoresCharacterDB", characterDefaults, true)
    ns.db = self.db
    ns.cdb = self.cdb

    if self.db.profile.needsConfigMigration then
        self.Config:MigrateDB()
    end

    LibStub("AceConfig-3.0"):RegisterOptionsTable("ToastyClassChores", config)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ToastyClassChores", "Toasty Class Chores")
    local versionDisplay = self.optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    versionDisplay:SetPoint("TOPRIGHT", self.optionsFrame, "TOPRIGHT", -15, -55)
    versionDisplay:SetText("|cffffffffVersion " .. self.versionString .. "|r")

    if self.db.profile.lastVersion ~= self.version then
        self:CheckUpdateMessages(self.db.profile.lastVersion)
        self.db.profile.lastVersion = self.version
    end

    if not ToastyClassChores.db.profile.frameLock then
        self:ToggleFrameLock()
    end
end

local raidBuffClassList = {
    DRUID = 136078,
    EVOKER = 4622448,
    MAGE = 135932,
    PRIEST = 135987,
    SHAMAN = 4630367,
    WARRIOR = 132333
}

-- Ace3 not supporting RegisterUnitEvent is REALLY annoying


local playerEventFrame = CreateFrame("Frame")

function playerEventFrame:OnPlayerEvent(event, ...)
    self[event](self, event, ...)
end

playerEventFrame:SetScript("OnEvent", playerEventFrame.OnPlayerEvent)
playerEventFrame:RegisterUnitEvent("UNIT_AURA", "player")
playerEventFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
playerEventFrame:RegisterUnitEvent("UNIT_SPELLCAST_SENT", "player")

function ToastyClassChores:OnEnable()
    _, self.cdb.profile.class, _ = UnitClass("player")
    playerClass = self.cdb.profile.class
    self.cdb.profile.guid = UnitGUID("player")


    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("LEGACY_LOOT_RULES_CHANGED")
    self:RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED")

    if playerClass == "WARRIOR" or playerClass == "PRIEST" or playerClass == "PALADIN" or playerClass == "DRUID" or playerClass == "EVOKER" then
        self:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    end

    if playerClass == "WARRIOR" or playerClass == "PRIEST" or playerClass == "SHAMAN" then
        self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    end

    if playerClass == "HUNTER" or playerClass == "WARLOCK" or playerClass == "DEATHKNIGHT" then
        self:RegisterEvent("UNIT_PET")
    end

    if playerClass == "HUNTER" or playerClass == "WARLOCK" or playerClass == "DRUID" or playerClass == "DEATHKNIGHT" or playerClass == "PALADIN" or playerClass == "EVOKER" or playerClass == "ROGUE" then
        self:RegisterEvent("SPELLS_CHANGED")
    end

    if playerClass == "HUNTER" or playerClass == "WARLOCK" or playerClass == "DEATHKNIGHT" then
        self:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
    end

    if playerClass == "ROGUE" or raidBuffClassList[playerClass] or playerClass == "PALADIN" then
        self:RegisterEvent("PLAYER_IN_COMBAT_CHANGED")
    end

    if raidBuffClassList[playerClass] then
        self:RegisterEvent("UNIT_AURA")
    end
    --[[
    if playerClass == "ROGUE" or playerClass == "PALADIN" or playerClass == "SHAMAN" then
        self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    end

    if playerClass == "EVOKER" then
        self:RegisterEvent("UNIT_SPELLCAST_SENT")
    end]]

    if playerClass == "SHAMAN" or playerClass == "DRUID" then
        self:RegisterEvent("PLAYER_LOGOUT")
    end

    if raidBuffClassList[playerClass] then
        --self:RegisterEvent("PLAYER_FLAGS_CHANGED")
        self:RegisterEvent("UNIT_DIED")
    end

    if raidBuffClassList[playerClass] then
        self:RegisterEvent("GROUP_ROSTER_UPDATE")
    end

    self.Shadowform:Initialize()
    self.RaidBuff:Initialize()
    self.Pets:Initialize()
    self.DruidForms:Initialize()
    self.WarriorStances:Initialize()
    self.PaladinAuras:Initialize()
    self.SacrificeGrimoire:Initialize()
    self.RoguePoisons:Initialize()
    self.ShamanShields:Initialize()
    self.LightsmithRites:Initialize()
    self.SourceOfMagic:Initialize()
    self.SymbioticRelationship:Initialize()
    self.AugAttunements:Initialize()

    self:RegisterChatCommand("tcc", "SlashCommand")
end

function ToastyClassChores:PLAYER_ENTERING_WORLD()
    if playerClass == "PRIEST" and self.db.profile.shadowform.instanceOnly then
        self.Shadowform:Update()
    end
    if playerClass == "PALADIN" and self.db.profile.paladinAuras.instanceOnly then
        self.PaladinAuras:Update()
    end
    if playerClass == "DRUID" and self.db.profile.druidForms.instanceOnly then
        self.DruidForms:Update()
    end
    if (playerClass == "HUNTER" or playerClass == "WARLOCK" or playerClass == "DEATHKNIGHT") and self.db.profile.pets.instanceOnly then
        self.Pets:Update()
    end
    -- Because for some reason durationObjects do not load properly until a frame after PLAYER_ENTERING_WORLD
    if playerClass == "ROGUE" then
        RunNextFrame(function() self.RoguePoisons:Update() end)
    end
    if playerClass == "SHAMAN" then
        RunNextFrame(function() self.ShamanShields:Update() end)
    end
    if raidBuffClassList[playerClass] then
        RunNextFrame(function() self.RaidBuff:Update() end)
    end
    if playerClass == "PALADIN" and C_ClassTalents.GetActiveHeroTalentSpec() == 49 then
        RunNextFrame(function() self.LightsmithRites:Update() end)
    end
    if playerClass == "DRUID" then
        RunNextFrame(function() self.SymbioticRelationship:Update() end)
    end
end

function ToastyClassChores:LEGACY_LOOT_RULES_CHANGED()
    if playerClass == "PRIEST" and self.db.profile.shadowform.noLegacy then
        self.Shadowform:Update()
    end
    if playerClass == "PALADIN" and self.db.profile.paladinAuras.noLegacy then
        self.PaladinAuras:Update()
    end
    if playerClass == "DRUID" and self.db.profile.druidForms.noLegacy then
        self.DruidForms:Update()
    end
    if (playerClass == "HUNTER" or playerClass == "WARLOCK" or playerClass == "DEATHKNIGHT") and self.db.profile.pets.noLegacy then
        self.Pets:Update()
    end
end

function ToastyClassChores:UPDATE_SHAPESHIFT_FORM()
    self.Shadowform:Update()
    self.DruidForms:Update()
    self.WarriorStances:Update()
    self.PaladinAuras:Update()
    self.AugAttunements:Update()
end

function ToastyClassChores:PLAYER_SPECIALIZATION_CHANGED()
    self.Shadowform:Update()
    self.WarriorStances:Update()
    self.ShamanShields:Update()
    self.AugAttunements:Update()
end

function ToastyClassChores:PLAYER_MOUNT_DISPLAY_CHANGED()
    if playerClass == "HUNTER" or playerClass == "WARLOCK" or playerClass == "DEATHKNIGHT" then
        self.Pets:MountCheck()
    end
end

function ToastyClassChores:UNIT_PET()
    if playerClass == "HUNTER" or playerClass == "WARLOCK" or playerClass == "DEATHKNIGHT" then
        self.Pets:Update()
    end
end

function ToastyClassChores:SPELLS_CHANGED()
    if not PlayerIsInCombat() then
        if playerClass == "HUNTER" or playerClass == "DEATHKNIGHT" then
            self.Pets:CheckAnomaly()
        end
        if playerClass == "DRUID" then
            self.DruidForms:CheckForms()
            self.SymbioticRelationship:CheckSymbioticRelationshipKnown()
        end
        if playerClass == "WARLOCK" then
            self.Pets:CheckAnomaly()
            self.SacrificeGrimoire:Update()
        end
        if playerClass == "PALADIN" then
            self.LightsmithRites:Update()
        end
        if playerClass == "EVOKER" then
            self.SourceOfMagic:CheckSourceOfMagicKnown()
            self.AugAttunements:CheckAttunementsKnown()
        end
        if playerClass == "ROGUE" then
            self.RoguePoisons:CheckDoublePoison()
        end
    end
end

function ToastyClassChores:PLAYER_IN_COMBAT_CHANGED()
    if playerClass == "PRIEST" and self.db.profile.shadowform.combatOnly then
        self.Shadowform:Update()
    end
    if playerClass == "DRUID" and self.db.profile.druidForms.combatOnly then
        self.DruidForms:Update()
    end
    if playerClass == "PALADIN" and self.db.profile.paladinAuras.combatOnly then
        self.PaladinAuras:Update()
    end
    if playerClass == "WARRIOR" and self.db.profile.warriorStances.noCombatOnly then
        self.WarriorStances:Update()
    end

    if playerClass == "ROGUE" and self.db.profile.roguePoisons.earlyWarningNoCombat then
        self.RoguePoisons:Update()
    end
    if raidBuffClassList[playerClass] and self.db.profile.raidBuff.earlyWarningNoCombat then
        self.RaidBuff:Update()
    end
    if playerClass == "SHAMAN" and self.db.profile.shamanShields.earlyWarningNoCombat then
        self.ShamanShields:Update()
    end
    if playerClass == "PALADIN" and C_ClassTalents.GetActiveHeroTalentSpec() == 49 and self.db.profile.lightsmithRites.earlyWarningNoCombat then
        self.LightsmithRites:Update()
    end
    if playerClass == "EVOKER" and self.db.profile.sourceOfMagic.earlyWarningNoCombat then
        self.SourceOfMagic:Update()
    end
    if playerClass == "DRUID" and self.db.profile.symbioticRelationship.earlyWarningNoCombat then
        self.SymbioticRelationship:Update()
    end
    
    if playerClass == "EVOKER" and self.db.profile.augAttunements.noCombatOnly or self.db.profile.augAttunements.combatOnly then
        self.AugAttunements:Update()
    end
end

function ToastyClassChores:ADDON_RESTRICTION_STATE_CHANGED()
    if playerClass == "SHAMAN" then
        self.ShamanShields:Update()
    end
    if playerClass == "DRUID" then
        self.SymbioticRelationship:Update()
    end
end

function ToastyClassChores:UNIT_AURA(event, unitTarget, updateInfo)
    if raidBuffClassList[playerClass] then
        if UnitIsPlayer(unitTarget) then
            self.RaidBuff:CheckBuff(unitTarget)
        end
    end
    if playerClass == "EVOKER" then
        if UnitIsPlayer(unitTarget) then
            self.SourceOfMagic:Update()
        end
    end
end

function playerEventFrame:UNIT_AURA()
    if playerClass == "ROGUE" then
        ToastyClassChores.RoguePoisons:Update()
    end
    if playerClass == "SHAMAN" then
        ToastyClassChores.ShamanShields:Update()
    end
    if playerClass == "PALADIN" and C_ClassTalents.GetActiveHeroTalentSpec() == 49 then
        ToastyClassChores.LightsmithRites:Update()
    end
    if playerClass == "DRUID" then
        ToastyClassChores.SymbioticRelationship:Update()
    end
end

function playerEventFrame:UNIT_SPELLCAST_SUCCEEDED(event, unitTarget, castGUID, spellID, castBarID)
    if playerClass == "SHAMAN" then
        ToastyClassChores.ShamanShields:ShieldCast(spellID)
    end
    if playerClass == "PALADIN" and C_ClassTalents.GetActiveHeroTalentSpec() == 49 then
        RunNextFrame(function() ToastyClassChores.LightsmithRites:RiteCast(spellID) end) -- Aura info is not immediately correct for lightsmith rites
    end
    if playerClass == "DRUID" then
        ToastyClassChores.SymbioticRelationship:RegisterCast(spellID)
    end
end

function playerEventFrame:UNIT_SPELLCAST_SENT(event, unitTarget, target, castGUID, spellID)
    if playerClass == "EVOKER" then
        RunNextFrame(function() ToastyClassChores.SourceOfMagic:RegisterCast(spellID, target) end)
    end
end

function ToastyClassChores:PLAYER_LOGOUT()
    if playerClass == "SHAMAN" then
        self.ShamanShields:StoreDurations()
    end
    if playerClass == "DRUID" then
        self.SymbioticRelationship:StoreDurations()
    end
end

--[[function ToastyClassChores:PLAYER_FLAGS_CHANGED(event, unitTarget)
    self.RaidBuff:CheckBuff(unitTarget)
end]]

function ToastyClassChores:UNIT_DIED(event, unitGUID)
    if not issecretvalue(unitGUID) then
        if C_PlayerInfo.GUIDIsPlayer(unitGUID) and IsGUIDInGroup(unitGUID) then
            self.RaidBuff:PlayerDeath(unitGUID)
        end
    end
end

function ToastyClassChores:GROUP_ROSTER_UPDATE()
    self.RaidBuff:CheckWholeRaid()
    self.SourceOfMagic:CheckGroup()
end

function ToastyClassChores:ToggleFrameLock()
    ToastyClassChores.db.profile.frameLock = not ToastyClassChores.db.profile.frameLock
    local value = ToastyClassChores.db.profile.frameLock
    if value then
        self:Print("Locking Frames")
    else
        self:Print("Unlocking Frames")
    end
    self.Shadowform:ToggleFrameLock(value)
    self.RaidBuff:ToggleFrameLock(value)
    self.Pets:ToggleFrameLock(value)
    self.DruidForms:ToggleFrameLock(value)
    self.WarriorStances:ToggleFrameLock(value)
    self.PaladinAuras:ToggleFrameLock(value)
    self.SacrificeGrimoire:ToggleFrameLock(value)
    self.RoguePoisons:ToggleFrameLock(value)
    self.ShamanShields:ToggleFrameLock(value)
    self.LightsmithRites:ToggleFrameLock(value)
    self.SourceOfMagic:ToggleFrameLock(value)
    self.SymbioticRelationship:ToggleFrameLock(value)
    self.AugAttunements:ToggleFrameLock(value)
end

function ToastyClassChores:SlashCommand(msg)
    if msg == "debug" then
        self.db.profile.debug = not self.db.profile.debug
        if self.db.profile.debug then
            self:Print("Debug Mode on!")
        else
            self:Print("Debug Mode off!")
        end
    elseif msg == "lock" then
        self:ToggleFrameLock()
    elseif msg == "" then
        C_SettingsUtil.OpenSettingsPanel(self.optionsFrame.name)
    else
        self:Print("Hi! Please report any bugs you find!")
    end
end

-- debug function because I keep leaving debug messages in releases
function ToastyClassChores:Debug(msg)
    if self.db.profile.debug then
        self:Print(msg)
    end
end

function ToastyClassChores:ForceSecrets()
    SetCVar("addonChatRestrictionsForced", 1)
    SetCVar("addonChallengeModeRestrictionsForced", 1)
    SetCVar("addonCombatRestrictionsForced", 1)
    SetCVar("addonEncounterRestrictionsForced", 1)
    SetCVar("addonMapRestrictionsForced", 1)
    SetCVar("addonPvPMatchRestrictionsForced", 1)
end

function ToastyClassChores:UnForceSecrets()
    SetCVar("addonChatRestrictionsForced", 0)
    SetCVar("addonChallengeModeRestrictionsForced", 0)
    SetCVar("addonCombatRestrictionsForced", 0)
    SetCVar("addonEncounterRestrictionsForced", 0)
    SetCVar("addonMapRestrictionsForced", 0)
    SetCVar("addonPvPMatchRestrictionsForced", 0)
end

function ToastyClassChores:AreSecretsForced()
    print(GetCVar("addonChatRestrictionsForced"))
    print(GetCVar("addonChallengeModeRestrictionsForced"))
    print(GetCVar("addonCombatRestrictionsForced"))
    print(GetCVar("addonEncounterRestrictionsForced"))
    print(GetCVar("addonMapRestrictionsForced"))
    print(GetCVar("addonPvPMatchRestrictionsForced"))
end

function ToastyClassChores:CheckUpdateMessages(lastVersion)
    if self.versionString == "@project-version@" then
        return
    end
    if lastVersion < 20000 then
        self:Print("Welcome to Toasty Class Chores version " .. self.versionString .. "! Due to some fairly significant under the hood changes, some of your settings may have been reset to default. Apologies for the inconvenience!")
    end
end