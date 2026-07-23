local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.SourceOfMagic = ToastyClassChores.SourceOfMagic or {}
local SourceOfMagic = ToastyClassChores.SourceOfMagic

local sourceOfMagicFrame

local playerClass
local sourceOfMagicDB
local framesUnlocked = false
local buffSpellID = 369459

local knowsSourceOfMagic
local otherHealersInGroup
local currentToken

function ToastyClassChores:SetSourceOfMagicTracking(info, value)
    sourceOfMagicDB.tracking = value
    if value then
        self:Print("Enabling Source of Magic Tracking")
        SourceOfMagic:Initialize()
    else
        self:Print("Disabling Source of Magic Tracking")
        if sourceOfMagicFrame then
            sourceOfMagicFrame:Hide()
        end
    end
end

function ToastyClassChores:SetSourceOfMagicIconSize(info, value)
    sourceOfMagicDB.iconSize = value
    if sourceOfMagicFrame then
        sourceOfMagicFrame:SetSize(value, value)
    end
end

function ToastyClassChores:SetSourceOfMagicOpacity(info, value)
    sourceOfMagicDB.opacity = value
    if sourceOfMagicFrame then
        sourceOfMagicFrame:SetAlpha(value)
    end
end

function ToastyClassChores:SetSourceOfMagicEarlyWarning(info, value)
    sourceOfMagicDB.earlyWarning = value
    SourceOfMagic:Update()
end

function ToastyClassChores:SetSourceOfMagicEarlyWarningNoCombat(info, value)
    sourceOfMagicDB.earlyWarningNoCombat = value
    SourceOfMagic:Update()
end

function SourceOfMagic:Initialize()
    sourceOfMagicDB = ToastyClassChores.db.profile.sourceOfMagic
    playerClass = ToastyClassChores.cdb.profile.class
    if not playerClass == "EVOKER" then
        return
    end
    if not sourceOfMagicFrame then
        sourceOfMagicFrame = CreateFrame("Frame", "Source of Magic Reminder", UIParent)
        sourceOfMagicFrame:SetPoint(sourceOfMagicDB.location.frameAnchorPoint, UIParent,
            sourceOfMagicDB.location.parentAnchorPoint, sourceOfMagicDB.location.xPos, sourceOfMagicDB.location.yPos)
        sourceOfMagicFrame:SetSize(sourceOfMagicDB.iconSize, sourceOfMagicDB.iconSize)
        local frameTexture = sourceOfMagicFrame:CreateTexture(nil, "BACKGROUND")
        frameTexture:SetTexture(4630412)
        frameTexture:SetAllPoints()


        sourceOfMagicFrame:RegisterForDrag("LeftButton")
        sourceOfMagicFrame:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)
        sourceOfMagicFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            sourceOfMagicDB.location.frameAnchorPoint, _, sourceOfMagicDB.location.parentAnchorPoint, sourceOfMagicDB.location.xPos, sourceOfMagicDB.location.yPos =
                sourceOfMagicFrame:GetPoint()
        end)
    end
    sourceOfMagicFrame:SetAlpha(sourceOfMagicDB.opacity)
    if not framesUnlocked then
        sourceOfMagicFrame:Hide()
    end

    self:CheckSourceOfMagicKnown()
    self:CheckGroup()
end

function SourceOfMagic:Update()
    ToastyClassChores:Debug("Update")
    if not (sourceOfMagicDB.tracking and playerClass == "EVOKER") then
        if sourceOfMagicFrame and not framesUnlocked then
            sourceOfMagicFrame:Hide()
        end
        return
    end
    if not sourceOfMagicFrame then
        self:Initialize()
    end
    if not otherHealersInGroup or not knowsSourceOfMagic then
        currentToken = nil
        if not framesUnlocked then
            sourceOfMagicFrame:Hide()
        end
        return
    end
    if currentToken then
        local earlyWarningThreshold = 60 * sourceOfMagicDB.earlyWarning
        if PlayerIsInCombat() and sourceOfMagicDB.earlyWarningNoCombat then
            earlyWarningThreshold = 0
        end
        if self:VerifyBuff() <= earlyWarningThreshold then
            sourceOfMagicFrame:Show()
        else
            if not framesUnlocked then
                sourceOfMagicFrame:Hide()
            end
        end
    else
        sourceOfMagicFrame:Show()
    end
end

function SourceOfMagic:VerifyBuff()
    if not (sourceOfMagicDB.tracking and playerClass == "EVOKER") then
        return 0
    end
    if not UnitIsVisible(currentToken) then
        return 0
    end

    -- This is a remnant from old code that shouldn't ever actually trigger but I'm keeping it as a failsafe
    -- Ok actually follower dungeon healers trip the UnitIsPlayer check so I'm just skipping this check if you're in a follower dungeon
    if not (UnitIsPlayer(currentToken) or C_LFGInfo.IsInLFGFollowerDungeon()) or not (UnitInRaid(currentToken) or UnitInParty(currentToken)) then
        currentToken = nil
        return 0
    end
    if not UnitGroupRolesAssigned(currentToken) == "HEALER" then
        currentToken = nil
        return 0
    end
    if currentToken then
        local aura = C_UnitAuras.GetUnitAuraBySpellID(currentToken, buffSpellID)
        if aura then
            if UnitIsUnit(aura.sourceUnit, "player") then
                return (aura.expirationTime - GetTime())
            else
                currentToken = nil
            end
        else
            currentToken = nil
        end
    end
    return 0
end

function SourceOfMagic:CheckBuff(unit)
    if not (sourceOfMagicDB.tracking and playerClass == "EVOKER") then
        return
    end

    if not UnitIsVisible(unit) then
        return
    end
    -- This is a remnant from old code that shouldn't ever actually trigger but I'm keeping it as a failsafe
    -- Ok actually follower dungeon healers trip the UnitIsPlayer check so I'm just skipping this check if you're in a follower dungeon
    if not (UnitIsPlayer(unit) or C_LFGInfo.IsInLFGFollowerDungeon()) or not (UnitInRaid(unit) or UnitInParty(unit)) then
        if currentToken then
            if UnitIsUnit(unit, currentToken) then
                currentToken = nil
            end
        end
        return
    end
    if not UnitGroupRolesAssigned(unit) == "HEALER" then
        if currentToken then
            if UnitIsUnit(unit, currentToken) then
                currentToken = nil
            end
        end
        return
    end
    if unit then
        local aura = C_UnitAuras.GetUnitAuraBySpellID(unit, buffSpellID)
        if aura then
            if UnitIsUnit(aura.sourceUnit, "player") then
                currentToken = unit
            else
                if currentToken then
                    if UnitIsUnit(unit, currentToken) then
                        currentToken = nil
                    end
                end
            end
        else
            if currentToken then
                if UnitIsUnit(unit, currentToken) then
                    currentToken = nil
                end
            end
        end
    end
end

function SourceOfMagic:RegisterCast(spellID, target)
    if not (sourceOfMagicDB.tracking and playerClass == "EVOKER") then
        return
    end
    if spellID == buffSpellID then
        local groupType
        local groupSize
        if IsInRaid() then
            groupType = "raid"
            groupSize = GetNumGroupMembers()
        else
            groupType = "party"
            groupSize = GetNumSubgroupMembers()
        end
        for i = 1, groupSize do
            if UnitGroupRolesAssigned(groupType .. i) == "HEALER" and not UnitIsUnit("player", groupType .. i) then
                ToastyClassChores:Debug("Seeing " .. groupType .. i)
                if UnitIsUnit(target, groupType .. i) then
                    ToastyClassChores:Debug("Checking " .. groupType .. i)
                    self:CheckBuff(groupType .. i)
                end
            end
        end
    end
end

function SourceOfMagic:CheckGroup()
    if not (sourceOfMagicDB.tracking and playerClass == "EVOKER") then
        return
    end
    if not IsInGroup() then
        otherHealersInGroup = false
        currentToken = nil
        return
    end
    local healerCount = 0
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
        if UnitGroupRolesAssigned(groupType .. i) == "HEALER" and not UnitIsUnit("player", groupType .. i) then
            healerCount = healerCount + 1
            ToastyClassChores:Debug(groupType .. i)
            self:CheckBuff(groupType .. i)
        end
    end
    if healerCount > 0 then
        otherHealersInGroup = true
    else
        otherHealersInGroup = false
    end
    if currentToken then
        if not (UnitInParty(currentToken) or UnitInRaid(currentToken)) then
            currentToken = nil
        end
    end
    self:Update()
end

function SourceOfMagic:CheckSourceOfMagicKnown()
    if not (sourceOfMagicDB.tracking and playerClass == "EVOKER") then
        return
    end
    knowsSourceOfMagic = C_SpellBook.IsSpellKnown(369459)
    if currentToken then
        self:Update()
    end
end

function SourceOfMagic:ToggleFrameLock(value)
    if sourceOfMagicFrame then
        sourceOfMagicFrame:SetMovable(not value)
        sourceOfMagicFrame:EnableMouse(not value)

        if not value then
            framesUnlocked = true
            sourceOfMagicFrame:Show()
        else
            framesUnlocked = false
            self:Update()
        end
    end
end
