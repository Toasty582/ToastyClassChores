local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.SourceOfMagic = ToastyClassChores.SourceOfMagic or {}
local SourceOfMagic = ToastyClassChores.SourceOfMagic

local sourceOfMagicFrame
local playerClass
local playerGUID
local framesUnlocked = false
local buffSpellID = 369459

local sourceOfMagicTimer

local knowsSourceOfMagic
local otherHealersInGroup
local currentToken

function ToastyClassChores:SetSourceOfMagicTracking(info, value)
    self.db.profile.sourceOfMagicTracking = value
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
    self.db.profile.sourceOfMagicIconSize = value
    if sourceOfMagicFrame then
        sourceOfMagicFrame:SetSize(value, value)
    end
end

function ToastyClassChores:SetSourceOfMagicOpacity(info, value)
    self.db.profile.sourceOfMagicOpacity = value
    if sourceOfMagicFrame then
        sourceOfMagicFrame:SetAlpha(value)
    end
end

function ToastyClassChores:SetSourceOfMagicEarlyWarning(info, value)
    self.db.profile.sourceOfMagicEarlyWarning = value
    SourceOfMagic:VerifyBuff()
end

function ToastyClassChores:SetSourceOfMagicEarlyWarningNoCombat(info, value)
    self.db.profile.sourceOfMagicEarlyWarningNoCombat = value
    SourceOfMagic:Update()
end

function SourceOfMagic:Initialize()
    playerClass = ToastyClassChores.cdb.profile.class
    playerGUID = ToastyClassChores.cdb.profile.guid
    if not playerClass == "EVOKER" then
        return
    end
    if not sourceOfMagicFrame then
        sourceOfMagicFrame = CreateFrame("Frame", "Source of Magic Reminder", UIParent)
        sourceOfMagicFrame:SetPoint(ToastyClassChores.db.profile.sourceOfMagicLocation.frameAnchorPoint, UIParent,
            ToastyClassChores.db.profile.sourceOfMagicLocation.parentAnchorPoint,
            ToastyClassChores.db.profile.sourceOfMagicLocation.xPos,
            ToastyClassChores.db.profile.sourceOfMagicLocation.yPos)
        sourceOfMagicFrame:SetSize(ToastyClassChores.db.profile.sourceOfMagicIconSize,
            ToastyClassChores.db.profile.sourceOfMagicIconSize)
        local frameTexture = sourceOfMagicFrame:CreateTexture(nil, "BACKGROUND")
        frameTexture:SetTexture(4630412)
        frameTexture:SetAllPoints()

        sourceOfMagicFrame:RegisterForDrag("LeftButton")
        sourceOfMagicFrame:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)
        sourceOfMagicFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            ToastyClassChores.db.profile.sourceOfMagicLocation.frameAnchorPoint, _, ToastyClassChores.db.profile.sourceOfMagicLocation.parentAnchorPoint, ToastyClassChores.db.profile.sourceOfMagicLocation.xPos, ToastyClassChores.db.profile.sourceOfMagicLocation.yPos =
                sourceOfMagicFrame:GetPoint()
        end)
    end
    sourceOfMagicFrame:SetAlpha(ToastyClassChores.db.profile.sourceOfMagicOpacity)
    if not framesUnlocked then
        sourceOfMagicFrame:Hide()
    end

    self:CheckGroup()
end

function SourceOfMagic:Update()
    ToastyClassChores:Debug("Update")
    if not (ToastyClassChores.db.profile.sourceOfMagicTracking and playerClass == "EVOKER") then
        return
    end
    if not sourceOfMagicFrame then
        self:Initialize()
    end
    if not otherHealersInGroup or not knowsSourceOfMagic then
        ToastyClassChores:Debug("a")
        if not framesUnlocked then
            sourceOfMagicFrame:Hide()
        end
        return
    end
    ToastyClassChores:Debug(currentToken)
    if currentToken then
        local earlyWarningThreshold = 60 * ToastyClassChores.db.profile.sourceOfMagicEarlyWarning
        if PlayerIsInCombat() and ToastyClassChores.db.profile.sourceOfMagicEarlyWarningNoCombat then
            earlyWarningThreshold = 0
        end
        if self:GetRemainingBuffTime() <= earlyWarningThreshold then
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

function SourceOfMagic:CheckBuff(unit)
    if not (ToastyClassChores.db.profile.sourceOfMagicTracking and playerClass == "EVOKER") then
        return
    end
    if not UnitIsPlayer(unit) or not UnitIsVisible(unit) or not (UnitInRaid(unit) or UnitInParty(unit)) then
        return
    end
    if not UnitGroupRolesAssigned(unit) == "HEALER" then
        if currentToken then
            if UnitGUID(currentToken) == UnitGUID(unit) then
                currentToken = nil
            end
        end
        return
    end
    if unit then
        local aura = C_UnitAuras.GetUnitAuraBySpellID(unit, buffSpellID)
        if aura then
            if UnitGUID(aura.sourceUnit) == playerGUID then
                currentToken = unit
            else
                if currentToken then
                    if UnitGUID(currentToken) == UnitGUID(unit) then
                        currentToken = nil
                    end
                end
            end
        else
            if currentToken then
                if UnitGUID(currentToken) == UnitGUID(unit) then
                    currentToken = nil
                end
            end
        end
    end
    self:Update()
end

function SourceOfMagic:VerifyBuff()
    if not (ToastyClassChores.db.profile.sourceOfMagicTracking and playerClass == "EVOKER") then
        return
    end
    if not UnitIsVisible(currentToken) then
        return
    end
    if not UnitIsPlayer(currentToken) or not (UnitInRaid(currentToken) or UnitInParty(currentToken)) then
        currentToken = nil
        return
    end
    if not UnitGroupRolesAssigned(currentToken) == "HEALER" then
        currentToken = nil
        return
    end
    if currentToken then
        local aura = C_UnitAuras.GetUnitAuraBySpellID(currentToken, buffSpellID)
        if aura then
            if UnitGUID(aura.sourceUnit) == playerGUID then
                return
            else
                currentToken = nil
            end
        else
            currentToken = nil
        end
    end

    self:Update()
end

function SourceOfMagic:RegisterBuff(spellID, target)
    if not (ToastyClassChores.db.profile.sourceOfMagicTracking and playerClass == "EVOKER") then
        return
    end
    if spellID == buffSpellID then
        ToastyClassChores:Debug("a")
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
            if UnitGroupRolesAssigned(groupType .. i) == "HEALER" and UnitGUID(groupType .. i) ~= playerGUID then
                ToastyClassChores:Debug("Seeing " .. groupType .. i)
                if UnitGUID(target) == UnitGUID(groupType .. i) then
                    ToastyClassChores:Debug("Checking " .. groupType .. i)
                    RunNextFrame(function() self:CheckBuff(groupType .. i) end)
                end
            end
        end
    end
end

function SourceOfMagic:GetRemainingBuffTime()
    if not (ToastyClassChores.db.profile.sourceOfMagicTracking and playerClass == "EVOKER") then
        return
    end
    local aura
    if currentToken then
        aura = C_UnitAuras.GetUnitAuraBySpellID(currentToken, buffSpellID)
    end
    if aura then
        return (aura.expirationTime - GetTime())
    else
        if currentToken then
            self:VerifyBuff()
        end
        return 0
    end
end

function SourceOfMagic:CheckSourceOfMagicKnown()
    if not (ToastyClassChores.db.profile.sourceOfMagicTracking and playerClass == "EVOKER") then
        return
    end
    knowsSourceOfMagic = C_SpellBook.IsSpellKnown(369459)
    if currentToken then
        self:VerifyBuff()
    end
end

function SourceOfMagic:CheckGroup()
    if not (ToastyClassChores.db.profile.sourceOfMagicTracking and playerClass == "EVOKER") then
        return
    end
    self:CountHealers()
    if currentToken then
        if not (UnitInParty(currentToken) or UnitInRaid(currentToken)) then
            currentToken = nil
        end
    end
    if currentToken then
        self:VerifyBuff()
    end
    self:Update()
end

function SourceOfMagic:CountHealers()
    if not IsInGroup() then
        otherHealersInGroup = false
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
        if UnitGroupRolesAssigned(groupType .. i) == "HEALER" and UnitGUID(groupType .. i) ~= playerGUID then
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
