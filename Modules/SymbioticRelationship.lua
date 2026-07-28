local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.SymbioticRelationship = ToastyClassChores.SymbioticRelationship or {}
local SymbioticRelationship = ToastyClassChores.SymbioticRelationship

local symbioticRelationshipFrame
local frameTexture
local framesUnlocked = false

local symbioticDuration
local symbioticTimer

local playerClass
local symbioticRelationshipDB

local knowsSymbioticRelationship
local relationshipSpellID = 474750
local relationshipAuraID = 474754

function ToastyClassChores:SetSymbioticRelationshipTracking(info, value)
    symbioticRelationshipDB.tracking = value
    if value then
        self:Print("Enabling Symbiotic Relationship Tracking")
        SymbioticRelationship:Initialize()
    else
        self:Print("Disabling Symbiotic Relationship Tracking")
        if symbioticRelationshipFrame then
            symbioticRelationshipFrame:Hide()
        end
        if symbioticDuration then
            symbioticDuration:Reset()
        end
        if symbioticTimer then
            symbioticTimer:Cancel()
        end
    end
end

function ToastyClassChores:SetSymbioticRelationshipIconSize(info, value)
    symbioticRelationshipDB.iconSize = value
    if symbioticRelationshipFrame then
        symbioticRelationshipFrame:SetSize(value, value)
    end
end

function ToastyClassChores:SetSymbioticRelationshipOpacity(info, value)
    symbioticRelationshipDB.opacity = value
    if symbioticRelationshipFrame then
        symbioticRelationshipFrame:SetAlpha(value)
    end
end

function ToastyClassChores:SetSymbioticRelationshipEarlyWarning(info, value)
    symbioticRelationshipDB.earlyWarning = value
    SymbioticRelationship:Update()
end

function ToastyClassChores:SetSymbioticRelationshipEarlyWarningNoCombat(info, value)
    symbioticRelationshipDB.earlyWarningNoCombat = value
    SymbioticRelationship:Update()
end

function SymbioticRelationship:Initialize()
    symbioticRelationshipDB = ToastyClassChores.db.profile.symbioticRelationship
    playerClass = ToastyClassChores.cdb.profile.class
    if not (symbioticRelationshipDB.tracking and playerClass == "DRUID") then
        return
    end
    if not symbioticRelationshipFrame then
        symbioticRelationshipFrame = CreateFrame("Frame", "Shaman Shield Reminder", UIParent)
        symbioticRelationshipFrame:SetPoint(symbioticRelationshipDB.location.frameAnchorPoint, UIParent,
            symbioticRelationshipDB.location.parentAnchorPoint, symbioticRelationshipDB.location.xPos, symbioticRelationshipDB.location.yPos)
        symbioticRelationshipFrame:SetSize(symbioticRelationshipDB.iconSize, symbioticRelationshipDB.iconSize)
        frameTexture = symbioticRelationshipFrame:CreateTexture(nil, "BACKGROUND")
        frameTexture:SetTexture(1408837)
        frameTexture:SetAllPoints()
    end

    symbioticRelationshipFrame:RegisterForDrag("LeftButton")
    symbioticRelationshipFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    symbioticRelationshipFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        symbioticRelationshipDB.location.frameAnchorPoint, _, symbioticRelationshipDB.location.parentAnchorPoint, symbioticRelationshipDB.location.xPos, symbioticRelationshipDB.location.yPos =
            symbioticRelationshipFrame:GetPoint()
    end)
    symbioticRelationshipFrame:SetAlpha(symbioticRelationshipDB.opacity)
    if not framesUnlocked then
        symbioticRelationshipFrame:Hide()
    end
    symbioticDuration = C_DurationUtil.CreateDuration()
    self:CheckSymbioticRelationshipKnown()
end

function SymbioticRelationship:Update()
    if not (symbioticRelationshipDB.tracking and playerClass == "DRUID") then
        if symbioticRelationshipFrame and not framesUnlocked then
            symbioticRelationshipFrame:Hide()
        end
        return
    end
    if not symbioticRelationshipFrame then
        self:Initialize()
    end

    if not IsInGroup() or not knowsSymbioticRelationship then
        if symbioticDuration then
            symbioticDuration:Reset()
        end
        if symbioticTimer then
            symbioticTimer:Cancel()
        end
        ToastyClassChores.cdb.profile.remainingSymbioticRelationshipTime = 0
        if symbioticRelationshipFrame and not framesUnlocked then
            symbioticRelationshipFrame:Hide()
        end
        return
    end

    self:CheckDurations()
    local earlyWarningThreshold = 60 * symbioticRelationshipDB.earlyWarning
    if PlayerIsInCombat() and symbioticRelationshipDB.earlyWarningNoCombat then
        earlyWarningThreshold = 0
    end
    if symbioticDuration:GetRemainingDuration() <= earlyWarningThreshold or symbioticDuration:GetRemainingDuration() == nil then
        symbioticRelationshipFrame:Show()
        return
    else
        if not framesUnlocked then
            symbioticRelationshipFrame:Hide()
        end
        return
    end
end

function SymbioticRelationship:CheckDurations()
    if not (symbioticRelationshipDB.tracking and playerClass == "DRUID") then
        return
    end
    if C_Secrets.ShouldAurasBeSecret() then
        if symbioticDuration:GetStartTime() == 0 then
            symbioticDuration:SetTimeFromEnd(GetTime() + ToastyClassChores.cdb.profile.remainingSymbioticRelationshipTime, ToastyClassChores.cdb.profile.remainingSymbioticRelationshipTime)
            if symbioticTimer then
                symbioticTimer:Cancel()
            end
            if symbioticDuration:GetRemainingDuration() - 60 * symbioticRelationshipDB.earlyWarning > 0 then
                symbioticTimer = C_Timer.NewTimer(
                    symbioticDuration:GetRemainingDuration() - 60 * symbioticRelationshipDB.earlyWarning,
                    function() self:Update() end)
            end
        end
    else
        local buffFound = false
        local aura = C_UnitAuras.GetPlayerAuraBySpellID(relationshipAuraID)
        if aura then
            symbioticDuration:SetTimeFromEnd(aura.expirationTime, 3600)
            if symbioticTimer then
                symbioticTimer:Cancel()
            end
            if symbioticDuration:GetRemainingDuration() - 60 * symbioticRelationshipDB.earlyWarning > 0 then
                symbioticTimer = C_Timer.NewTimer(
                    symbioticDuration:GetRemainingDuration() - 60 * symbioticRelationshipDB.earlyWarning,
                    function() self:Update() end)
            end
            buffFound = true
        end
        if not buffFound then
            symbioticDuration:Reset()
            if symbioticTimer then
                symbioticTimer:Cancel()
            end
        end
    end
    self:StoreDurations()
end

function SymbioticRelationship:StoreDurations()
    if not (symbioticRelationshipDB.tracking and playerClass == "DRUID") then
        return
    end
    if symbioticDuration then
        ToastyClassChores.cdb.profile.remainingSymbioticRelationshipTime = symbioticDuration:GetRemainingDuration()
    else
        ToastyClassChores.cdb.profile.remainingSymbioticRelationshipTime = 0
    end
end

function SymbioticRelationship:RegisterCast(spellID)
    if not (symbioticRelationshipDB.tracking and playerClass == "DRUID") then
        return
    end
    if spellID == relationshipSpellID then
        symbioticDuration:SetTimeFromEnd(GetTime() + 3600, 3600)
        if symbioticTimer then
            symbioticTimer:Cancel()
        end
        symbioticTimer = C_Timer.NewTimer(3600 - 60 * symbioticRelationshipDB.earlyWarning,
            function() self:Update() end)
    end
    self:Update()
end

function SymbioticRelationship:CheckSymbioticRelationshipKnown()
    if not (symbioticRelationshipDB.tracking and playerClass == "DRUID") then
        return
    end
    knowsSymbioticRelationship = C_SpellBook.IsSpellKnown(relationshipSpellID)
    self:Update()
end

function SymbioticRelationship:ToggleFrameLock(value)
    if symbioticRelationshipFrame then
        symbioticRelationshipFrame:SetMovable(not value)
        symbioticRelationshipFrame:EnableMouse(not value)

        if not value then
            framesUnlocked = true
            symbioticRelationshipFrame:Show()
        else
            framesUnlocked = false
            self:Update()
        end
    end
end
