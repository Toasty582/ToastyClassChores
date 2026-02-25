local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.RaidBuff = ToastyClassChores.RaidBuff or {}
local RaidBuff = ToastyClassChores.RaidBuff

local raidBuffFrame
local playerClass
local glowing = false
local framesUnlocked = false

local raidBuffTimer

local unitsMissingBuff = {}
function RaidBuff:CountUnitsMissingBuff()
    local count = 0
    for _, _ in pairs(unitsMissingBuff) do
        count = count + 1
    end
    return count
end

local raidBuffSpellList = {
    [1126] = "DRUID",
    [364342] = "EVOKER",
    [1459] = "MAGE",
    [21562] = "PRIEST",
    [462854] = "SHAMAN",
    [6673] = "WARRIOR"
}

-- Evoker has a different spellID for the aura and the spell
local raidBuffAuraList = {
    [1126] = "DRUID",
    [381748] = "EVOKER",
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

local raidBuffAurasByClass = {
    DRUID = 1126,
    MAGE = 1459,
    PRIEST = 21562,
    SHAMAN = 462854,
    WARRIOR = 6673,
    EVOKER = {
        DEATHKNIGHT = 381732,
        DEMONHUNTER = 381741,
        DRUID = 381746,
        EVOKER = 381748,
        HUNTER = 381749,
        MAGE = 381750,
        MONK = 381751,
        PALADIN = 381752,
        PRIEST = 381753,
        ROGUE = 381754,
        SHAMAN = 381756,
        WARLOCK = 381757,
        WARRIOR = 381758
    }
}

function ToastyClassChores:SetRaidBuffTracking(info, value)
    self.db.profile.raidBuffTracking = value
    if value then
        self:Print("Enabling Raid Buff Tracking")
        RaidBuff:Initialize()
    else
        self:Print("Disabling Raid Buff Tracking")
        if raidBuffFrame then
            raidBuffFrame:Hide()
        end
    end
end

function ToastyClassChores:SetRaidBuffIconSize(info, value)
    self.db.profile.raidBuffIconSize = value
    if raidBuffFrame then
        raidBuffFrame:SetSize(value, value)
    end
end

function ToastyClassChores:SetRaidBuffOpacity(info, value)
    self.db.profile.raidBuffOpacity = value
    if raidBuffFrame then
        raidBuffFrame:SetAlpha(value)
    end
end

function ToastyClassChores:SetRaidBuffEarlyWarning(info, value)
    self.db.profile.raidBuffEarlyWarning = value
    RaidBuff:CheckBuff("player")
end

function ToastyClassChores:SetRaidBuffEarlyWarningNoCombat(info, value)
    self.db.profile.raidBuffEarlyWarningNoCombat = value
    RaidBuff:Update()
end

function RaidBuff:Initialize()
    playerClass = ToastyClassChores.cdb.profile.class
    if not (ToastyClassChores.db.profile.raidBuffTracking and raidBuffIconList[playerClass]) then
        return
    end
    if not raidBuffFrame then
        raidBuffFrame = CreateFrame("Frame", "Raid Buffs Reminder", UIParent)
        raidBuffFrame:SetPoint(ToastyClassChores.db.profile.raidBuffLocation.frameAnchorPoint, UIParent,
            ToastyClassChores.db.profile.raidBuffLocation.parentAnchorPoint,
            ToastyClassChores.db.profile.raidBuffLocation.xPos, ToastyClassChores.db.profile.raidBuffLocation.yPos)
        raidBuffFrame:SetSize(ToastyClassChores.db.profile.raidBuffIconSize,
            ToastyClassChores.db.profile.raidBuffIconSize)
        local frameTexture = raidBuffFrame:CreateTexture(nil, "BACKGROUND")
        frameTexture:SetTexture(raidBuffIconList[playerClass])
        frameTexture:SetAllPoints()

        raidBuffFrame:RegisterForDrag("LeftButton")
        raidBuffFrame:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)
        raidBuffFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            ToastyClassChores.db.profile.raidBuffLocation.frameAnchorPoint, _, ToastyClassChores.db.profile.raidBuffLocation.parentAnchorPoint, ToastyClassChores.db.profile.raidBuffLocation.xPos, ToastyClassChores.db.profile.raidBuffLocation.yPos =
                raidBuffFrame:GetPoint()
        end)
    end
    raidBuffFrame:SetAlpha(ToastyClassChores.db.profile.raidBuffOpacity)
    if not framesUnlocked then
        raidBuffFrame:Hide()
    end

    self:CheckWholeRaid()
end

function RaidBuff:Update()
    if not (ToastyClassChores.db.profile.raidBuffTracking and raidBuffIconList[playerClass]) then
        return
    end
    if not raidBuffFrame then
        self:Initialize()
    end
    if glowing then
        raidBuffFrame:Show()
    else
        local earlyWarningThreshold = 60 * ToastyClassChores.db.profile.raidBuffEarlyWarning
        if PlayerIsInCombat() and ToastyClassChores.db.profile.raidBuffEarlyWarningNoCombat then
            earlyWarningThreshold = 0
        end
        if self:CountUnitsMissingBuff() > 0 then
            raidBuffFrame:Show()
        else
            if self:GetRemainingBuffTime("player") <= earlyWarningThreshold then
                raidBuffFrame:Show()
            else
                if not framesUnlocked then
                    raidBuffFrame:Hide()
                end
                return
            end
        end
    end
end

function RaidBuff:GlowShow(spellID)
    if not (ToastyClassChores.db.profile.raidBuffTracking and raidBuffIconList[playerClass]) then
        return
    end
    if raidBuffSpellList[spellID] then
        glowing = true
    end
    self:Update()
end

function RaidBuff:GlowHide(spellID)
    if not (ToastyClassChores.db.profile.raidBuffTracking and raidBuffIconList[playerClass]) then
        return
    end
    if raidBuffSpellList[spellID] then
        glowing = false
    end
    self:Update()
end

function RaidBuff:CheckBuff(unit)
    if not (ToastyClassChores.db.profile.raidBuffTracking and raidBuffIconList[playerClass]) then
        return
    end
    if unit == "target" then
        return
    end
    if not UnitIsPlayer(unit) or UnitIsDead(unit) or not UnitIsVisible(unit) then
        if unitsMissingBuff[unit] then
            unitsMissingBuff[unit] = nil
        end
        return
    end
    local buffSpellID = raidBuffAurasByClass[playerClass]
    if playerClass == "EVOKER" then
        buffSpellID = buffSpellID[UnitClass(unit)]
    end
    local aura = C_UnitAuras.GetUnitAuraBySpellID(unit, buffSpellID)
    if aura then
        if unitsMissingBuff[unit] then
            unitsMissingBuff[unit] = nil
        end
        if unit == "player" then
            if raidBuffTimer then
                raidBuffTimer:Cancel()
            end
            if aura.expirationTime - GetTime() >= 60 * ToastyClassChores.db.profile.raidBuffEarlyWarning then
                raidBuffTimer = C_Timer.NewTimer(
                aura.expirationTime - GetTime() - 60 * ToastyClassChores.db.profile.raidBuffEarlyWarning,
                    function() self:Update() end)
            end
        end
    else
        if not unitsMissingBuff[unit] then
            unitsMissingBuff[unit] = unit
        end
        if unit == "player" then
            if raidBuffTimer then
                raidBuffTimer:Cancel()
            end
        end
    end
    self:Update()
end

function RaidBuff:GetRemainingBuffTime(unit)
    local buffSpellID = raidBuffAurasByClass[playerClass]
    if playerClass == "EVOKER" then
        buffSpellID = buffSpellID[UnitClass(unit)]
    end
    local aura = C_UnitAuras.GetUnitAuraBySpellID(unit, buffSpellID)
    if aura then
        return (aura.expirationTime - GetTime())
    else
        return 0
    end
end

function RaidBuff:CheckWholeRaid()
    unitsMissingBuff = {}
    self:CheckBuff("player")
    if not IsInGroup() then
        return
    end
    local groupType
    local groupSize
    if IsInRaid() then
        groupType = "raid"
        groupSize = GetNumGroupMembers() - 1
    else
        groupType = "party"
        groupSize = GetNumSubgroupMembers() - 1
    end
    for i = 1, groupSize do
        self:CheckBuff(groupType .. i)
    end
end

function RaidBuff:ToggleFrameLock(value)
    if raidBuffFrame then
        raidBuffFrame:SetMovable(not value)
        raidBuffFrame:EnableMouse(not value)

        if not value then
            framesUnlocked = true
            raidBuffFrame:Show()
        else
            framesUnlocked = false
            self:Update()
        end
    end
end
