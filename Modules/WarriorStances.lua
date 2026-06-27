local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.WarriorStances = ToastyClassChores.WarriorStances or {}
local WarriorStances = ToastyClassChores.WarriorStances

local warriorStancesFrame
local frameTexture
local framesUnlocked = false

local playerClass
local warriorStancesDB

local preferredStance = {
    [1] = 2,
    [2] = 2,
    [3] = 2,
}

local stanceIcons = {
    [1] = 132341,  -- Defensive
    [2] = 132349,  -- Battle
    -- Fury adds 10 to the index
    [11] = 132341, -- Defensive
    [12] = 132275, -- Berserker
}

function ToastyClassChores:SetWarriorStancesTracking(info, value)
    warriorStancesDB.tracking = value
    if value then
        self:Print("Enabling Warrior Stance Tracking")
        WarriorStances:Initialize()
    else
        self:Print("Disabling Warrior Stance Tracking")
        if warriorStancesFrame then
            warriorStancesFrame:Hide()
        end
    end
end

function ToastyClassChores:SetWarriorStancesIconSize(info, value)
    warriorStancesDB.iconSize = value
    if warriorStancesFrame then
        warriorStancesFrame:SetSize(value, value)
    end
end

function ToastyClassChores:SetWarriorStancesNoCombatOnly(info, value)
    warriorStancesDB.noCombatOnly = value
    WarriorStances:Update()
end

function ToastyClassChores:SetProtShowsDef(info, value)
    warriorStancesDB.protShowsDef = value
    WarriorStances:Update()
end

function ToastyClassChores:SetProtShowsBattle(info, value)
    warriorStancesDB.protShowsBattle = value
    WarriorStances:Update()
end

function ToastyClassChores:SetWarriorStancesOpacity(info, value)
    warriorStancesDB.opacity = value
    if warriorStancesFrame then
        warriorStancesFrame:SetAlpha(value)
    end
end

function WarriorStances:Initialize()
    warriorStancesDB = ToastyClassChores.db.profile.warriorStances
    playerClass = ToastyClassChores.cdb.profile.class
    if not (warriorStancesDB.tracking and playerClass == "WARRIOR") then
        return
    end
    if not warriorStancesFrame then
        warriorStancesFrame = CreateFrame("Frame", "Warrior Stances Reminder", UIParent)
        warriorStancesFrame:SetPoint(warriorStancesDB.location.frameAnchorPoint, UIParent,
            warriorStancesDB.location.parentAnchorPoint, warriorStancesDB.location.xPos, warriorStancesDB.location.yPos)
        warriorStancesFrame:SetSize(warriorStancesDB.iconSize, warriorStancesDB.iconSize)
        frameTexture = warriorStancesFrame:CreateTexture(nil, "BACKGROUND")
        frameTexture:SetTexture(134400) -- Question mark as default, if you see this something went wrong
        frameTexture:SetAllPoints()
    end

    warriorStancesFrame:RegisterForDrag("LeftButton")
    warriorStancesFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    warriorStancesFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        warriorStancesDB.location.frameAnchorPoint, _, warriorStancesDB.location.parentAnchorPoint, warriorStancesDB.location.xPos, warriorStancesDB.location.yPos =
            warriorStancesFrame:GetPoint()
    end)
    warriorStancesFrame:SetAlpha(warriorStancesDB.opacity)
    if not framesUnlocked then
        warriorStancesFrame:Hide()
    end
    self:Update()
end

function WarriorStances:Update()
    if not (warriorStancesDB.tracking and playerClass == "WARRIOR") then
        return
    end
    if not warriorStancesFrame then
        self:Initialize()
    end
    local specIndex = C_SpecializationInfo.GetSpecialization()
    local stanceIndex = GetShapeshiftForm()

    if specIndex == 2 then
        frameTexture:SetTexture(stanceIcons[stanceIndex + 10])
    else
        frameTexture:SetTexture(stanceIcons[stanceIndex])
    end
    frameTexture:SetAllPoints()

    
    if warriorStancesDB.noCombatOnly and PlayerIsInCombat() and not framesUnlocked then
        warriorStancesFrame:Hide()
        return
    end

    if specIndex ~= 3 then
        if stanceIndex ~= 2 then
            warriorStancesFrame:Show()
        else
            if not framesUnlocked then
                warriorStancesFrame:Hide()
            end
        end
    else
        if stanceIndex == 1 and warriorStancesDB.protShowsDef then
            warriorStancesFrame:Show()
        elseif stanceIndex == 2 and warriorStancesDB.protShowsBattle then
            warriorStancesFrame:Show()
        else
            if not framesUnlocked then
                warriorStancesFrame:Hide()
            end
        end
    end
end

function WarriorStances:ToggleFrameLock(value)
    if warriorStancesFrame then
        warriorStancesFrame:SetMovable(not value)
        warriorStancesFrame:EnableMouse(not value)

        if not value then
            framesUnlocked = true
            warriorStancesFrame:Show()
        else
            framesUnlocked = false
            self:Update()
        end
    end
end
