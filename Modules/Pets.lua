local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.Pets = ToastyClassChores.Pets or {}
local Pets = ToastyClassChores.Pets

local petsFrame

local petClasses = {
    HUNTER = 132161,
    WARLOCK = 136218
}

function ToastyClassChores:SetPetTracking(info, value)
    self.db.profile.petTracking = value
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

function Pets:Initialize()
    if not (ToastyClassChores.db.profile.petTracking and petClasses[ToastyClassChores.cdb.profile.class]) then
        return
    end
    petsFrame = CreateFrame("Frame", "Pet Reminder", ToastyClassChores.choreFrame)
    petsFrame:SetPoint("CENTER")
    petsFrame:SetSize(100, 100)
    ToastyClassChores.petsFrame = petsFrame
    local frameTexture = petsFrame:CreateTexture(nil, "BACKGROUND")
    frameTexture:SetTexture(petClasses[ToastyClassChores.cdb.profile.class])
    frameTexture:SetAllPoints()
    petsFrame:SetAlpha(0)
    self:Update()
end

function Pets:Update()
    if not (ToastyClassChores.db.profile.petTracking and petClasses[ToastyClassChores.cdb.profile.class]) then
        return
    end
    if not petsFrame then
        self:Initialize()
    end
    local hasUI, isHunterPet = HasPetUI()
    if ToastyClassChores.cdb.profile.class == "HUNTER" and not ToastyClassChores.cdb.profile.petMarksman and C_SpecializationInfo.GetSpecialization() == 2 then
        petsFrame:SetAlpha(0)
        return
    end
    if ToastyClassChores.cdb.profile.class == "WARLOCK" and ToastyClassChores.cdb.profile.sacrificeGrimoire and C_SpecializationInfo.GetSpecialization() ~= 2 then
        petsFrame:SetAlpha(0)
        return
    end
    if not hasUI then
        petsFrame:SetAlpha(1)
        return
    else
        if ToastyClassChores.cdb.profile.class == "HUNTER" and isHunterPet then
            petsFrame:SetAlpha(0)
            return
        elseif ToastyClassChores.cdb.profile.class == "WARLOCK" and not isHunterPet then
            petsFrame:SetAlpha(0)
            return
        end
    end
    ToastyClassChores:Print("Invalid pet detected, hiding pet reminder")
    petsFrame:SetAlpha(0)
end

function Pets:CheckAnomaly()
    if ToastyClassChores.cdb.profile.class == "HUNTER" and C_SpecializationInfo.GetSpecialization() == 2 then
        if C_SpellBook.IsSpellKnown(1223323) then
            ToastyClassChores.cdb.profile.petMarksman = true
        else
            ToastyClassChores.cdb.profile.petMarksman = false
        end
    elseif ToastyClassChores.cdb.profile.class == "WARLOCK" and C_SpecializationInfo.GetSpecialization() ~= 2 then
        if C_SpellBook.IsSpellKnown(108503) then
            ToastyClassChores.cdb.profile.sacrificeGrimoire = true
        else
            ToastyClassChores.cdb.profile.sacrificeGrimoire = false
        end
    end
    self:Update()
end
