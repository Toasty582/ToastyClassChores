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
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ToastyClassChores", "Toasty Class Chores")

    if not ToastyClassChores.db.profile.frameLock then
        self:ToggleFrameLock()
    end
end

function ToastyClassChores:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
    self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")
    self:RegisterEvent("UNIT_PET")
    self:RegisterEvent("SPELLS_CHANGED")
    self:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
    self:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    self:RegisterEvent("SPELL_UPDATE_USABLE")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

    self:RegisterChatCommand("tcc", "SlashCommand")
    self:RegisterChatCommand("chores", "SlashCommand")
end

function ToastyClassChores:SPELL_UPDATE_USABLE()
    if playerClass == "DEATHKNIGHT" then
        self.Pets:Update()
    end
end

function ToastyClassChores:PLAYER_ENTERING_WORLD()
    _, self.cdb.profile.class, _ = UnitClass("player")
    playerClass = self.cdb.profile.class
    self.Shadowform:Initialize()
    self.RaidBuff:Initialize()
    self.Pets:Initialize()
    self.DruidForms:Initialize()
    self.WarriorStances:Initialize()
    self.PaladinAuras:Initialize()
end

function ToastyClassChores:UPDATE_SHAPESHIFT_FORM()
    self.Shadowform:Update()
    self.DruidForms:Update()
    self.WarriorStances:Update()
    self.PaladinAuras:Update()
end

function ToastyClassChores:PLAYER_SPECIALIZATION_CHANGED()
    self.Shadowform:Update()
    self.WarriorStances:Update()
    self.Pets:CheckAnomaly()
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
    if unitTarget == "player" and spellID == 1247378 then
        if playerClass == "DEATHKNIGHT" then
            self.Pets:Update()
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
    self.PaladinAuras:ToggleFrameLock(value)
end

function ToastyClassChores:SlashCommand(msg)
    if msg == "debug" then
        self.db.profile.debug = not self.db.profile.debug
        if self.db.profile.debug then
            self:Print("Debug Mode on!")
        else
            self:Print("Debug Mode off!")
        end
    elseif msg == "ping" then
        self:Print("pong!")
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
