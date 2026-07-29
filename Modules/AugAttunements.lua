local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.AugAttunements = ToastyClassChores.AugAttunements or {}
local AugAttunements = ToastyClassChores.AugAttunements

local augAttunementsFrame
local frameTexture
local framesUnlocked = false

local playerClass
local augAttunementsDB

local attunementsKnown

local attunementIcons = {
    [0] = 5199626, -- Talent Icon
    [1] = 5199619, -- Black
    [2] = 5199623, -- Bronze
}

function ToastyClassChores:SetAugAttunementsTracking(info, value)
    augAttunementsDB.tracking = value
    if value then
        self:Print("Enabling Augmentation Attunement Tracking")
        AugAttunements:Initialize()
    else
        self:Print("Disabling Augmentation Attunement Tracking")
        if augAttunementsFrame then
            augAttunementsFrame:Hide()
        end
    end
end

function ToastyClassChores:SetAugAttunementsIconSize(info, value)
    augAttunementsDB.iconSize = value
    if augAttunementsFrame then
        augAttunementsFrame:SetSize(value, value)
    end
end

function ToastyClassChores:SetAugAttunementsCombatOnly(info, value)
    augAttunementsDB.combatOnly = value
    if value then
        augAttunementsDB.noCombatOnly = false
    end
    AugAttunements:Update()
end

function ToastyClassChores:SetAugAttunementsNoCombatOnly(info, value)
    augAttunementsDB.noCombatOnly = value
    if value then
        augAttunementsDB.combatOnly = false
    end
    AugAttunements:Update()
end

function ToastyClassChores:SetAugAttunementsShowBlack(info, value)
    augAttunementsDB.showBlack = value
    AugAttunements:Update()
end

function ToastyClassChores:SetAugAttunementsShowBronze(info, value)
    augAttunementsDB.showBronze = value
    AugAttunements:Update()
end

function ToastyClassChores:SetAugAttunementsOpacity(info, value)
    augAttunementsDB.opacity = value
    if augAttunementsFrame then
        augAttunementsFrame:SetAlpha(value)
    end
end

function AugAttunements:Initialize()
    augAttunementsDB = ToastyClassChores.db.profile.augAttunements
    playerClass = ToastyClassChores.cdb.profile.class
    if not (augAttunementsDB.tracking and playerClass == "EVOKER" and C_SpecializationInfo.GetSpecialization() == 3) then
        return
    end
    if not augAttunementsFrame then
        augAttunementsFrame = CreateFrame("Frame", "Augmentation Attunements Reminder", UIParent)
        augAttunementsFrame:SetPoint(augAttunementsDB.location.frameAnchorPoint, UIParent,
            augAttunementsDB.location.parentAnchorPoint, augAttunementsDB.location.xPos, augAttunementsDB.location.yPos)
        augAttunementsFrame:SetSize(augAttunementsDB.iconSize, augAttunementsDB.iconSize)
        frameTexture = augAttunementsFrame:CreateTexture(nil, "BACKGROUND")
        frameTexture:SetTexture(134400) -- Question mark as default, if you see this something went wrong
        frameTexture:SetAllPoints()
    end

    augAttunementsFrame:RegisterForDrag("LeftButton")
    augAttunementsFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    augAttunementsFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        augAttunementsDB.location.frameAnchorPoint, _, augAttunementsDB.location.parentAnchorPoint, augAttunementsDB.location.xPos, augAttunementsDB.location.yPos =
            augAttunementsFrame:GetPoint()
    end)
    augAttunementsFrame:SetAlpha(augAttunementsDB.opacity)
    if not framesUnlocked then
        augAttunementsFrame:Hide()
    end
    self:Update()
end

function AugAttunements:Update()
    if not (augAttunementsDB.tracking and playerClass == "EVOKER" and C_SpecializationInfo.GetSpecialization() == 3) then
        if augAttunementsFrame and not framesUnlocked then
            augAttunementsFrame:Hide()
        end
        return
    end

    if not augAttunementsFrame then
        self:Initialize()
    end

    if not attunementsKnown and not framesUnlocked then
        augAttunementsFrame:Hide()
    end

    if augAttunementsDB.noCombatOnly and PlayerIsInCombat() and not framesUnlocked then
        augAttunementsFrame:Hide()
        return
    end
    if augAttunementsDB.combatOnly and not PlayerIsInCombat() and not framesUnlocked then
        augAttunementsFrame:Hide()
        return
    end

    local stanceIndex = GetShapeshiftForm()

    if stanceIndex == 0 then
        frameTexture:SetTexture(attunementIcons[stanceIndex])
        frameTexture:SetAllPoints()
        augAttunementsFrame:Show()
    else
        if stanceIndex == 1 and augAttunementsDB.showBlack then
            frameTexture:SetTexture(attunementIcons[stanceIndex])
            frameTexture:SetAllPoints()
            augAttunementsFrame:Show()
        elseif stanceIndex == 2 and augAttunementsDB.showBronze then
            frameTexture:SetTexture(attunementIcons[stanceIndex])
            frameTexture:SetAllPoints()
            augAttunementsFrame:Show()
        else
            augAttunementsFrame:Hide()
        end
    end
end

function AugAttunements:CheckAttunementsKnown()
    if not (augAttunementsDB.tracking and playerClass == "EVOKER" and C_SpecializationInfo.GetSpecialization() == 3) then
        return
    end
    attunementsKnown = C_SpellBook.IsSpellKnown(403208)
    self:Update()
end

function AugAttunements:ToggleFrameLock(value)
    if augAttunementsFrame then
        augAttunementsFrame:SetMovable(not value)
        augAttunementsFrame:EnableMouse(not value)

        if not value then
            framesUnlocked = true
            augAttunementsFrame:Show()
        else
            framesUnlocked = false
            self:Update()
        end
    end
end
