local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.Pets = ToastyClassChores.Pets or {}
local Pets = ToastyClassChores.Pets

local petsFrame

local playerClass

local petExistsBeforeMounting

local petClasses = {
    HUNTER = 132161,
    WARLOCK = 136218
}

function ToastyClassChores:SetPetTracking(info, value)
    self.db.profile.petsTracking = value
    if value then
        self:Print("Enabling Pet Tracking")
        Pets:Initialize()
    else
        self:Print("Disabling Pet Tracking")
        if petsFrame then
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
    petsFrame = CreateFrame("Frame", "Pet Reminder", UIParent)
    petsFrame:SetPoint(ToastyClassChores.db.profile.petsLocation.frameAnchorPoint, UIParent, ToastyClassChores.db.profile.petsLocation.parentAnchorPoint, ToastyClassChores.db.profile.petsLocation.xPos, ToastyClassChores.db.profile.petsLocation.yPos)
    petsFrame:SetSize(ToastyClassChores.db.profile.petsIconSize, ToastyClassChores.db.profile.petsIconSize)
    ToastyClassChores.petsFrame = petsFrame
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

    petsFrame:SetAlpha(0)
    self:Update()
end

function Pets:Update()
    if not (ToastyClassChores.db.profile.petsTracking and petClasses[playerClass]) then
        return
    end
    if not petsFrame then
        self:Initialize()
    end
    if IsMounted() then
        petsFrame:SetAlpha(0)
        return
    end
    if petExistsBeforeMounting then
        petExistsBeforeMounting = false
        return
    end
    local hasUI, isHunterPet = HasPetUI()
    if playerClass == "HUNTER" and not ToastyClassChores.cdb.profile.petMarksman and C_SpecializationInfo.GetSpecialization() == 2 then
        petsFrame:SetAlpha(0)
        return
    end
    if playerClass == "WARLOCK" and ToastyClassChores.cdb.profile.sacrificeGrimoire and C_SpecializationInfo.GetSpecialization() ~= 2 then
        petsFrame:SetAlpha(0)
        return
    end
    if not hasUI then
        petsFrame:SetAlpha(1)
        return
    else
        if playerClass == "HUNTER" and isHunterPet then
            petsFrame:SetAlpha(0)
            return
        elseif playerClass == "WARLOCK" and not isHunterPet then
            petsFrame:SetAlpha(0)
            return
        end
    end
    ToastyClassChores:Print("Invalid pet detected, hiding pet reminder")
    petsFrame:SetAlpha(0)
end

function Pets:CheckAnomaly()
    if playerClass == "HUNTER" and C_SpecializationInfo.GetSpecialization() == 2 then
        if C_SpellBook.IsSpellKnown(1223323) then
            ToastyClassChores.cdb.profile.petMarksman = true
        else
            ToastyClassChores.cdb.profile.petMarksman = false
        end
    elseif playerClass == "WARLOCK" and C_SpecializationInfo.GetSpecialization() ~= 2 then
        if C_SpellBook.IsSpellKnown(108503) then
            ToastyClassChores.cdb.profile.sacrificeGrimoire = true
        else
            ToastyClassChores.cdb.profile.sacrificeGrimoire = false
        end
    end
    self:Update()
end

function Pets:MountCheck()
    if not ToastyClassChores.db.profile.petsTracking then
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
            petsFrame:SetAlpha(1)
        else
            petsFrame:Update()
        end
    end
end
