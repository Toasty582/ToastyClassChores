local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.Pets = ToastyClassChores.Pets or {}
local Pets = ToastyClassChores.Pets

local petsFrame
local framesUnlocked = false

local playerClass
local petsDB

local isPetMarksman
local isSacrificeGrimoire

local petExistsBeforeMounting

local petClasses = {
    HUNTER = 132161,
    WARLOCK = 136218,
    DEATHKNIGHT = 1100170,
}

function ToastyClassChores:SetPetsTracking(info, value)
    petsDB.tracking = value
    if value then
        self:Print("Enabling Pet Tracking")
        Pets:Initialize()
    else
        self:Print("Disabling Pet Tracking")
        if petsFrame and not framesUnlocked then
            petsFrame:Hide()
        end
    end
end

function ToastyClassChores:SetPetsIconSize(info, value)
    petsDB.iconSize = value
    if petsFrame then
        petsFrame:SetSize(value, value)
    end
end

function ToastyClassChores:SetPetsInstanceOnly(info, value)
    petsDB.instanceOnly = value
    Pets:Update()
end

function ToastyClassChores:SetPetsNoLegacy(info, value)
    petsDB.noLegacy = value
    Pets:Update()
end

function ToastyClassChores:SetPetsOpacity(info, value)
    petsDB.opacity = value
    if petsFrame then
        petsFrame:SetAlpha(value)
    end
end

function Pets:Initialize()
    petsDB = ToastyClassChores.db.profile.pets
    playerClass = ToastyClassChores.cdb.profile.class
    if not (petsDB.tracking and petClasses[playerClass]) then
        return
    end
    if not petsFrame then
        petsFrame = CreateFrame("Frame", "Pet Reminder", UIParent)
        petsFrame:SetPoint(petsDB.location.frameAnchorPoint, UIParent, petsDB.location.parentAnchorPoint,
            petsDB.location.xPos, petsDB.location.yPos)
        petsFrame:SetSize(petsDB.iconSize, petsDB.iconSize)
        local frameTexture = petsFrame:CreateTexture(nil, "BACKGROUND")
        frameTexture:SetTexture(petClasses[ToastyClassChores.cdb.profile.class])
        frameTexture:SetAllPoints()

        petsFrame:RegisterForDrag("LeftButton")
        petsFrame:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)
        petsFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            petsDB.location.frameAnchorPoint, _, petsDB.location.parentAnchorPoint, petsDB.location.xPos, petsDB.location.yPos =
                petsFrame:GetPoint()
        end)
    end
    petsFrame:SetAlpha(petsDB.opacity)
    if not framesUnlocked then
        petsFrame:Hide()
    end
    self:CheckAnomaly()
    self:Update()
end

function Pets:Update()
    if not (petsDB.tracking and petClasses[playerClass]) then
        if petsFrame and not framesUnlocked then
            petsFrame:Hide()
        end
        return
    end
    if not petsFrame then
        self:Initialize()
    end

    local _, instanceType = IsInInstance()

    if petsDB.instanceOnly and not (instanceType == "pvp" or instanceType == "arena" or instanceType == "party" or instanceType == "raid" or instanceType == "scenario") and not framesUnlocked then
        petsFrame:Hide()
        return
    end
    if petsDB.noLegacy and C_Loot.IsLegacyLootModeEnabled() and not framesUnlocked then
        petsFrame:Hide()
        return
    end

    if IsMounted() and not framesUnlocked then
        if petExistsBeforeMounting then -- Pets despawn when you start flying, this will pretend they don't
            petsFrame:Hide()
            return
        end
    end
    local hasUI, isHunterPet = HasPetUI()
    if playerClass == "HUNTER" and not isPetMarksman and not framesUnlocked then
        petsFrame:Hide()
        return
    end
    if playerClass == "WARLOCK" and isSacrificeGrimoire and not framesUnlocked then
        petsFrame:Hide()
        return
    end
    if playerClass == "DEATHKNIGHT" and C_SpecializationInfo.GetSpecialization() ~= 3 and not framesUnlocked then
        petsFrame:Hide()
        return
    end
    if not hasUI then
        petsFrame:Show()
    else
        if playerClass == "HUNTER" and isHunterPet and not framesUnlocked then
            petsFrame:Hide()
        elseif (playerClass == "WARLOCK" or playerClass == "DEATHKNIGHT") and not isHunterPet and not framesUnlocked then
            petsFrame:Hide()
        else
            ToastyClassChores:Print("Invalid pet detected, hiding pet reminder")
            if not framesUnlocked then
                petsFrame:Hide()
            end
        end
    end
end

function Pets:CheckAnomaly()
    if playerClass == "HUNTER" then
        if C_SpecializationInfo.GetSpecialization() == 2 then
            isPetMarksman = C_SpellBook.IsSpellKnown(1223323)
        else
            isPetMarksman = false
        end
    elseif playerClass == "WARLOCK" then
        if C_SpecializationInfo.GetSpecialization() ~= 2 then
            isSacrificeGrimoire = C_SpellBook.IsSpellKnown(108503)
        else
            isSacrificeGrimoire = false
        end
    end
    self:Update()
end

function Pets:MountCheck()
    if not petsDB.tracking then
        if petsFrame and not framesUnlocked then
            petsFrame:Hide()
        end
        return
    end
    if IsMounted() then
        local hasUI, _ = HasPetUI()
        petExistsBeforeMounting = hasUI
    else
        petExistsBeforeMounting = false
        C_Timer.After(0.5, function() self:Update() end) -- Wait to update until pet has had time to spawn in after dismounting
    end
end

function Pets:ToggleFrameLock(value)
    if petsFrame then
        petsFrame:SetMovable(not value)
        petsFrame:EnableMouse(not value)

        if not value then
            framesUnlocked = true
            petsFrame:Show()
        else
            framesUnlocked = false
            self:Update()
        end
    end
end
