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
local currentGUID

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
    SourceOfMagic:CheckBuff("player")
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
    if not (ToastyClassChores.db.profile.sourceOfMagicTracking and playerClass == "EVOKER") then
        return
    end
    if not sourceOfMagicFrame then
        self:Initialize()
    end
    if not otherHealersInGroup or not knowsSourceOfMagic then
        if not framesUnlocked then
            sourceOfMagicFrame:Hide()
        end
        return
    end
    if currentGUID then
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
    local unitGUID = UnitGUID(unit)
    if not UnitIsPlayer(unit) or not UnitIsVisible(unit) or not (UnitInRaid(unit) or UnitInParty(unit)) then
        return
    end
    if not UnitGroupRolesAssigned(unit) == "HEALER" then
        if currentGUID == unitGUID then
            currentGUID = nil
        end
        return
    end
    local aura = C_UnitAuras.GetUnitAuraBySpellID(unit, buffSpellID)
    if aura then
        if UnitGUID(aura.sourceUnit) == playerGUID then
            currentGUID = unitGUID
        else
            if currentGUID == unitGUID then
                currentGUID = nil
            end
        end
    else
        if currentGUID == unitGUID then
            currentGUID = nil
        end
    end
    self:Update()
end

function SourceOfMagic:GetRemainingBuffTime()
    if not (ToastyClassChores.db.profile.sourceOfMagicTracking and playerClass == "EVOKER") then
        return
    end
    local aura
    if currentGUID and not issecretvalue(currentGUID) then
        aura = C_UnitAuras.GetUnitAuraBySpellID(UnitTokenFromGUID(currentGUID), buffSpellID)
    end
    if aura then
        return (aura.expirationTime - GetTime())
    else
        if currentGUID and not issecretvalue(currentGUID) then
            self:CheckBuff(UnitTokenFromGUID(currentGUID))
        end
        return 0
    end
end

function SourceOfMagic:CheckSourceOfMagicKnown()
    if not (ToastyClassChores.db.profile.sourceOfMagicTracking and playerClass == "EVOKER") then
        return
    end
    knowsSourceOfMagic = C_SpellBook.IsSpellKnown(369459)
    if currentGUID and not issecretvalue(currentGUID) then
        self:CheckBuff(UnitTokenFromGUID(currentGUID))
    end
end

function SourceOfMagic:CheckGroup()
    if not (ToastyClassChores.db.profile.sourceOfMagicTracking and playerClass == "EVOKER") then
        return
    end
    self:CountHealers()
    if not issecretvalue(currentGUID) and currentGUID then
        if not (UnitInParty(UnitTokenFromGUID(currentGUID)) or UnitInRaid(UnitTokenFromGUID(currentGUID))) then
            currentGUID = nil
        end
    else
        currentGUID = nil
    end
    if currentGUID and not issecretvalue(currentGUID) then
        self:CheckBuff(UnitTokenFromGUID(currentGUID))
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
