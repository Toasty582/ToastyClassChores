local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.Pets = ToastyClassChores.Pets or {}
local Pets = ToastyClassChores.Pets

local petsFrame

local framesUnlocked = false
local playerClass
local isPetMarksman
local isSacrificeGrimoire

local petExistsBeforeMounting

local petClasses = {
    HUNTER = 132161,
    WARLOCK = 136218,
    DEATHKNIGHT = 1100170,
}

function ToastyClassChores:SetPetTracking(info, value)
    self.db.profile.petsTracking = value
    if value then
        self:Print("Enabling Pet Tracking")
        Pets:Initialize()
    else
        self:Print("Disabling Pet Tracking")
        if petsFrame and not framesUnlocked then
            petsFrame:SetAlpha(0)
        end
    end
end

function ToastyClassChores:SetPetsIconSize(info, value)
    self.db.profile.petsIconSize = value
    if petsFrame then
        petsFrame:SetSize(value, value)
    end
end

function Pets:Initialize()
    playerClass = ToastyClassChores.cdb.profile.class
    if not (ToastyClassChores.db.profile.petsTracking and petClasses[playerClass]) then
        return
    end
    if not petsFrame then
        petsFrame = CreateFrame("Frame", "Pet Reminder", UIParent)
        petsFrame:SetPoint(ToastyClassChores.db.profile.petsLocation.frameAnchorPoint, UIParent,
            ToastyClassChores.db.profile.petsLocation.parentAnchorPoint, ToastyClassChores.db.profile.petsLocation.xPos,
            ToastyClassChores.db.profile.petsLocation.yPos)
        petsFrame:SetSize(ToastyClassChores.db.profile.petsIconSize, ToastyClassChores.db.profile.petsIconSize)
        local frameTexture = petsFrame:CreateTexture(nil, "BACKGROUND")
        frameTexture:SetTexture(petClasses[ToastyClassChores.cdb.profile.class])
        frameTexture:SetAllPoints()

        petsFrame:RegisterForDrag("LeftButton")
        petsFrame:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)
        petsFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            ToastyClassChores.db.profile.petsLocation.frameAnchorPoint, _, ToastyClassChores.db.profile.petsLocation.parentAnchorPoint, ToastyClassChores.db.profile.petsLocation.xPos, ToastyClassChores.db.profile.petsLocation.yPos =
                petsFrame:GetPoint()
        end)
    end

    petsFrame:SetAlpha(0)
    self:CheckAnomaly()
    self:Update()
end

function Pets:Update()
    if not (ToastyClassChores.db.profile.petsTracking and petClasses[playerClass]) then
        if petsFrame and not framesUnlocked then
            petsFrame:SetAlpha(0)
        end
        return
    end
    if not petsFrame then
        self:Initialize()
    end
    if IsMounted() and not framesUnlocked then
        petsFrame:SetAlpha(0)
        return
    end
    if petExistsBeforeMounting then
        petExistsBeforeMounting = false
        return
    end
    local hasUI, isHunterPet = HasPetUI()
    ToastyClassChores:Debug(hasUI)
    ToastyClassChores:Debug(isHunterPet)
    if playerClass == "HUNTER" and not isPetMarksman and C_SpecializationInfo.GetSpecialization() == 2 and not framesUnlocked then
        petsFrame:SetAlpha(0)
        return
    end
    if playerClass == "WARLOCK" and isSacrificeGrimoire and C_SpecializationInfo.GetSpecialization() ~= 2 and not framesUnlocked then
        petsFrame:SetAlpha(0)
        return
    end
    if playerClass == "DEATHKNIGHT" and C_SpecializationInfo.GetSpecialization() ~= 3 and not framesUnlocked then
        petsFrame:SetAlpha(0)
        return
    end
    if not hasUI then
        petsFrame:SetAlpha(1)
        return
    else
        if playerClass == "HUNTER" and isHunterPet and not framesUnlocked then
            petsFrame:SetAlpha(0)
            return
        elseif (playerClass == "WARLOCK" or playerClass == "DEATHKNIGHT") and not isHunterPet and not framesUnlocked then
            petsFrame:SetAlpha(0)
            return
        end
    end
    ToastyClassChores:Print("Invalid pet detected, hiding pet reminder")
    if not framesUnlocked then
        petsFrame:SetAlpha(0)
    end
end

function Pets:CheckAnomaly()
    ToastyClassChores:Debug("Anomaly Checking")
    if playerClass == "HUNTER" and C_SpecializationInfo.GetSpecialization() == 2 then
        if C_SpellBook.IsSpellKnown(1223323) then
            isPetMarksman = true
        else
            isPetMarksman = false
        end
    elseif playerClass == "WARLOCK" and C_SpecializationInfo.GetSpecialization() ~= 2 then
        if C_SpellBook.IsSpellKnown(108503) then
            isSacrificeGrimoire = true
        else
            isSacrificeGrimoire = false
        end
    end
    self:Update()
end

function Pets:MountCheck()
    if not ToastyClassChores.db.profile.petsTracking then
        if petsFrame and not framesUnlocked then
            petsFrame:SetAlpha(0)
        end
        return
    end
    if IsMounted() then
        local hasUI, _ = HasPetUI()
        petExistsBeforeMounting = hasUI
    else
        self:Update()
    end
end

function Pets:ToggleFrameLock(value)
    if petsFrame then
        petsFrame:SetMovable(not value)
        petsFrame:EnableMouse(not value)

        if not value then
            framesUnlocked = true
            petsFrame:SetAlpha(1)
        else
            framesUnlocked = false
            self:Update()
        end
    end
end
