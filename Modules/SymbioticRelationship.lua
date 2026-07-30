local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.SymbioticRelationship = ToastyClassChores.SymbioticRelationship or {}
local SymbioticRelationship = ToastyClassChores.SymbioticRelationship

local symbioticRelationshipFrame
local frameTexture
local framesUnlocked = false

local playerClass
local symbioticRelationshipDB
local updateTimer

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
    self:CheckSymbioticRelationshipKnown()

    -- Hard code to check every 3 seconds for the case where the player is just sitting around without throwing UNIT_AURA
    updateTimer = ToastyClassChores:ScheduleRepeatingTimer("ForceSymbioticRelationshipUpdate", 3)
end

function ToastyClassChores:ForceSymbioticRelationshipUpdate()
    SymbioticRelationship:Update()
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
        if symbioticRelationshipFrame and not framesUnlocked then
            symbioticRelationshipFrame:Hide()
        end
        return
    end

    local remainingTime = 0
    local aura = C_UnitAuras.GetPlayerAuraBySpellID(relationshipAuraID)
    if aura then
        remainingTime = aura.expirationTime - GetTime()
    end

    local earlyWarningThreshold = 60 * symbioticRelationshipDB.earlyWarning
    if PlayerIsInCombat() and symbioticRelationshipDB.earlyWarningNoCombat then
        earlyWarningThreshold = 0
    end
    if remainingTime <= earlyWarningThreshold then
        symbioticRelationshipFrame:Show()
        return
    else
        if not framesUnlocked then
            symbioticRelationshipFrame:Hide()
        end
        return
    end
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
