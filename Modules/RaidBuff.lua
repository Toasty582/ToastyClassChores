local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.RaidBuff = ToastyClassChores.RaidBuff or {}
local RaidBuff = ToastyClassChores.RaidBuff

local raidBuffFrame
local updateTimer

local playerClass
local raidBuffDB

local framesUnlocked = false

local unitsMissingBuff = {}
function RaidBuff:CountUnitsMissingBuff()
    local count = 0
    for _, _ in pairs(unitsMissingBuff) do
        count = count + 1
    end
    return count
end

-- Purely a debug function, separate so as to not make debug mode unusable
function RaidBuff:PrintUnitsMissingBuff()
    for key, _ in pairs(unitsMissingBuff) do
        ToastyClassChores:Debug(key)
    end
end

local raidBuffSpellList = {
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
    raidBuffDB.tracking = value
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
    raidBuffDB.iconSize = value
    if raidBuffFrame then
        raidBuffFrame:SetSize(value, value)
    end
end

function ToastyClassChores:SetRaidBuffOpacity(info, value)
    raidBuffDB.opacity = value
    if raidBuffFrame then
        raidBuffFrame:SetAlpha(value)
    end
end

function ToastyClassChores:SetRaidBuffEarlyWarning(info, value)
    raidBuffDB.earlyWarning = value
    RaidBuff:CheckBuff("player")
end

function ToastyClassChores:SetRaidBuffEarlyWarningNoCombat(info, value)
    raidBuffDB.earlyWarningNoCombat = value
    RaidBuff:Update()
end

function RaidBuff:Initialize()
    raidBuffDB = ToastyClassChores.db.profile.raidBuff
    playerClass = ToastyClassChores.cdb.profile.class
    if not (raidBuffDB.tracking and raidBuffIconList[playerClass]) then
        return
    end
    if not raidBuffFrame then
        raidBuffFrame = CreateFrame("Frame", "Raid Buffs Reminder", UIParent)
        raidBuffFrame:SetPoint(raidBuffDB.location.frameAnchorPoint, UIParent,
            raidBuffDB.location.parentAnchorPoint, raidBuffDB.location.xPos, raidBuffDB.location.yPos)
        raidBuffFrame:SetSize(raidBuffDB.iconSize, raidBuffDB.iconSize)
        local frameTexture = raidBuffFrame:CreateTexture(nil, "BACKGROUND")
        frameTexture:SetTexture(raidBuffIconList[playerClass])
        frameTexture:SetAllPoints()

        raidBuffFrame:RegisterForDrag("LeftButton")
        raidBuffFrame:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)
        raidBuffFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            raidBuffDB.location.frameAnchorPoint, _, raidBuffDB.location.parentAnchorPoint, raidBuffDB.location.xPos, raidBuffDB.location.yPos =
                raidBuffFrame:GetPoint()
        end)
    end
    raidBuffFrame:SetAlpha(raidBuffDB.opacity)
    if not framesUnlocked then
        raidBuffFrame:Hide()
    end

    self:CheckWholeRaid()
    -- Hard code to check every 3 seconds for the case where the player is just sitting around without throwing UNIT_AURA
    updateTimer = ToastyClassChores:ScheduleRepeatingTimer("ForceRaidBuffUpdate", 5)
end

function ToastyClassChores:ForceRaidBuffUpdate()
    RaidBuff:Update()
end

function RaidBuff:Update()
    if not (raidBuffDB.tracking and raidBuffIconList[playerClass]) then
        return
    end
    if not raidBuffFrame then
        self:Initialize()
    end
    local earlyWarningThreshold = 60 * raidBuffDB.earlyWarning
    if PlayerIsInCombat() and raidBuffDB.earlyWarningNoCombat then
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

function RaidBuff:CheckBuff(unit)
    if not (raidBuffDB.tracking and raidBuffIconList[playerClass]) then
        return
    end
    if not (UnitInRaid(unit) or UnitInParty(unit) or unit == "player") then
        return
    end
    -- NPCs in follower dungeons or delves will trip this, I'm not skipping it like I do in Source of Magic because in my testing the aura check 
    -- didn't work properly on them, they seem to use different spellIDs for raid buffs. Regardless it's a small enough thing that I don't really care
    if not UnitIsPlayer(unit) or UnitIsDead(unit) or not UnitIsVisible(unit) then
        for key, token in pairs(unitsMissingBuff) do
            if issecretvalue(UnitIsUnit(token, unit)) then
                unitsMissingBuff[key] = nil
            elseif UnitIsUnit(token, unit) then
                unitsMissingBuff[key] = nil
            end
        end
        return
    end
    local buffSpellID = raidBuffAurasByClass[playerClass]
    if playerClass == "EVOKER" then
        local _, unitClass, _ = UnitClass(unit)
        buffSpellID = buffSpellID[unitClass]
    end
    local aura = C_UnitAuras.GetUnitAuraBySpellID(unit, buffSpellID)
    if aura then
        for key, token in pairs(unitsMissingBuff) do
            if issecretvalue(UnitIsUnit(token, unit)) then
                unitsMissingBuff[key] = nil
            elseif UnitIsUnit(token, unit) then
                unitsMissingBuff[key] = nil
            end
        end
    else
        if unit == "player" then
            unitsMissingBuff["player"] = "player"
        else
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
                if UnitIsUnit(groupType .. i, unit) then
                    unitsMissingBuff[groupType .. i] = groupType .. i
                end
            end
        end
    end
    self:Update()
end

function RaidBuff:GetRemainingBuffTime(unit)
    local buffSpellID = raidBuffAurasByClass[playerClass]
    if playerClass == "EVOKER" then
        local _, unitClass, _ = UnitClass(unit)
        buffSpellID = buffSpellID[unitClass]
    end
    local aura = C_UnitAuras.GetUnitAuraBySpellID(unit, buffSpellID)
    if aura then
        return (aura.expirationTime - GetTime())
    else
        return 0
    end
end

function RaidBuff:PlayerDeath(unitGUID)
    if not IsInGroup() then
        self:CheckBuff("player")
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
        if UnitGUID(groupType .. i) == unitGUID then
            self:CheckBuff(groupType .. i)
        end
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
