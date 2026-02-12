local ADDON_NAME, ns = ...

ToastyClassChores = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0")
ns.Addon = ToastyClassChores

function ToastyClassChores:OnInitialize()
    local defaults = ToastyClassChores.defaults
    local characterDefaults = ToastyClassChores.characterDefaults
    if not defaults or not characterDefaults then
        self:Print("Defaults not loaded!")
    end
    local config = ToastyClassChores.config
    if not config then
        self:Print("Config not loaded!")
    end

    self.db = LibStub("AceDB-3.0"):New("ToastyClassChoresDB", defaults, true)
    self.cdb = LibStub("AceDB-3.0"):New("ToastyClassChoresCharacterDB", characterDefaults, true)
    ns.db = self.db
    ns.cdb = self.cdb

    LibStub("AceConfig-3.0"):RegisterOptionsTable("ToastyClassChores", config)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ToastyClassChores", "ToastyClassChores")

    ToastyClassChores.choreFrame = CreateFrame("Frame", "Chore Frame", UIParent)
    ToastyClassChores.choreFrame:SetPoint("CENTER")
    ToastyClassChores.choreFrame:SetSize(500, 500)
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

    self:RegisterChatCommand("tcc", "SlashCommand")
    self:RegisterChatCommand("chores", "SlashCommand")
end

function ToastyClassChores:PLAYER_ENTERING_WORLD()
    _, self.cdb.profile.class, _ = UnitClass("player")
    self.Shadowform.Initialize()
    self.RaidBuffs.Initialize()
    self.Pets:Initialize()
end

function ToastyClassChores:PLAYER_SPECIALIZATION_CHANGED()
    self.Shadowform.UpdateSpec()
end

function ToastyClassChores:PLAYER_DEAD()
    self.Shadowform.Update()
end

function ToastyClassChores:UNIT_AURA(event, unitTarget, updateInfo)
    if self.cdb.profile.class == "PRIEST" then
        if unitTarget == "player" and (updateInfo.addedAuras or updateInfo.removedAuraInstanceIDs) then
            self.Shadowform.Update()
        end
    end
end

function ToastyClassChores:SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(event, spellID)
    self.RaidBuffs:GlowShow(spellID)
end

function ToastyClassChores:SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(event, spellID)
    self.RaidBuffs:GlowHide(spellID)
end

function ToastyClassChores:UNIT_PET()
    if self.cdb.profile.class == "HUNTER" or self.cdb.profile.class == "WARLOCK" then
        self.Pets:Update()
    end
end

function ToastyClassChores:SPELLS_CHANGED()
    if not PlayerIsInCombat() then
        if self.cdb.profile.class == "HUNTER" or self.cdb.profile.class == "WARLOCK" then
            self.Pets:CheckAnomaly()
        end
    end
end

function ToastyClassChores:SlashCommand(msg)
    if msg == "ping" then
        self:Print("pong!")
    else
        self:Print("Hi! Please report any bugs you find!")
    end
end
