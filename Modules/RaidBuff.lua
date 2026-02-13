local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.RaidBuff = ToastyClassChores.RaidBuff or {}
local RaidBuff = ToastyClassChores.RaidBuff

local raidBuffFrame
local playerClass

local raidBuffClassList = {
    [1126] = "DRUID",
    [364342] = "EVOKER",
    [1459] = "MAGE",
    [21562] = "PRIEST",
    [462854] = "SHAMAN",
    [6673] = "WARRIOR"
}

local raidBuffIconList = {
    DRUID = 136078,
    EVOKER = 4622448,
    MAGE = 135932,
    PRIEST = 135987,
    SHAMAN = 4630367,
    WARRIOR = 132333
}

function ToastyClassChores:SetRaidBuffTracking(info, value)
    self.db.profile.raidBuffTracking = value
    if value then
        self:Print("Enabling Raid Buff Tracking")
        RaidBuff:Initialize()
    else
        self:Print("Disabling Raid Buff Tracking")
        if raidBuffFrame then
            raidBuffFrame:SetAlpha(0)
        end
    end
end

function ToastyClassChores:SetRaidBuffIconSize(info, value)
    self.db.profile.raidBuffIconSize = value
    if raidBuffFrame then
        raidBuffFrame:SetSize(value, value)
    end
end

function RaidBuff:Initialize()
    playerClass = ToastyClassChores.cdb.profile.class
    if not (ToastyClassChores.db.profile.raidBuffTracking and raidBuffIconList[playerClass]) then
        return
    end
    raidBuffFrame = CreateFrame("Frame", "Raid Buffs Reminder", UIParent)
    raidBuffFrame:SetPoint("CENTER")
    raidBuffFrame:SetSize(ToastyClassChores.db.profile.raidBuffIconSize, ToastyClassChores.db.profile.raidBuffIconSize)
    ToastyClassChores.raidBuffFrame = raidBuffFrame
    local frameTexture = raidBuffFrame:CreateTexture(nil, "BACKGROUND")
    frameTexture:SetTexture(raidBuffIconList[playerClass])
    frameTexture:SetAllPoints()
    raidBuffFrame:SetAlpha(0)
end

function RaidBuff:GlowShow(spellID)
    if not (ToastyClassChores.db.profile.raidBuffTracking and raidBuffIconList[playerClass]) then
        return
    end
    if not raidBuffFrame then
        self:Initialize()
    end
    if raidBuffClassList[spellID] == playerClass then
        raidBuffFrame:SetAlpha(0.5)
    end
end

function RaidBuff:GlowHide(spellID)
    if not (ToastyClassChores.db.profile.raidBuffTracking and raidBuffIconList[playerClass]) then
        return
    end
    if not raidBuffFrame then
        self:Initialize()
    end
    if raidBuffClassList[spellID] == playerClass then
        raidBuffFrame:SetAlpha(0)
    end
end
