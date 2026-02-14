local ADDON_NAME, ns = ...

ToastyClassChores = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0")
ns.Addon = ToastyClassChores

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

    LibStub("AceConfig-3.0"):RegisterOptionsTable("ToastyClassChores", config)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ToastyClassChores", "ToastyClassChores")

    if not ToastyClassChores.db.profile.frameLock then
        self:ToggleFrameLock()
    end
end

function ToastyClassChores:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("PLAYER_DEAD")
    self:RegisterEvent("UNIT_AURA")
    self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
    self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")
    self:RegisterEvent("UNIT_PET")
    self:RegisterEvent("SPELLS_CHANGED")
    self:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

    self:RegisterChatCommand("tcc", "SlashCommand")
    self:RegisterChatCommand("chores", "SlashCommand")
end

function ToastyClassChores:PLAYER_ENTERING_WORLD()
    _, self.cdb.profile.class, _ = UnitClass("player")
    playerClass = self.cdb.profile.class
    self.Shadowform:Initialize()
    self.RaidBuff:Initialize()
    self.Pets:Initialize()
    self.DruidForms:Initialize()
    self.WarriorStances:Initialize()
end

function ToastyClassChores:PLAYER_SPECIALIZATION_CHANGED()
    self.Shadowform:Update()
    self.WarriorStances:Update()
end

function ToastyClassChores:PLAYER_DEAD()
end

function ToastyClassChores:UNIT_AURA(event, unitTarget, updateInfo)
    if playerClass == "PRIEST" then
        if unitTarget == "player" and (updateInfo.addedAuras or updateInfo.removedAuraInstanceIDs) then
            self.Shadowform:Update()
        end
    end
    if playerClass == "DRUID" then
        if unitTarget == "player" and (updateInfo.addedAuras or updateInfo.removedAuraInstanceIDs) then
            self.DruidForms:Update()
        end
    end
end

function ToastyClassChores:PLAYER_MOUNT_DISPLAY_CHANGED()
    if playerClass == "HUNTER" or playerClass == "WARLOCK" then
        self.Pets:MountCheck()
    end
end

function ToastyClassChores:SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(event, spellID)
    self.RaidBuff:GlowShow(spellID)
end

function ToastyClassChores:SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(event, spellID)
    self.RaidBuff:GlowHide(spellID)
end

function ToastyClassChores:UNIT_PET()
    if playerClass == "HUNTER" or playerClass == "WARLOCK" then
        self.Pets:Update()
    end
end

function ToastyClassChores:SPELLS_CHANGED()
    if not PlayerIsInCombat() then
        if playerClass == "HUNTER" or playerClass == "WARLOCK" then
            self.Pets:CheckAnomaly()
        end
        if playerClass == "DRUID" then
            self.DruidForms:CheckForms()
        end
    end
end

function ToastyClassChores:UNIT_SPELLCAST_SUCCEEDED(event, unitTarget, castGUID, spellID, castBarID)
    if playerClass == "WARRIOR" and unitTarget == "player" then
        if spellID == 386196 or spellID == 386208 or spellID == 386164 then
            self.WarriorStances:Update()
        end
    end
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
end

function ToastyClassChores:SlashCommand(msg)
    if msg == "ping" then
        self:Print("pong!")
    else
        self:Print("Hi! Please report any bugs you find!")
    end
end
