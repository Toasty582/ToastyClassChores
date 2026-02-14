local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.WarriorStances = ToastyClassChores.WarriorStances or {}
local WarriorStances = ToastyClassChores.WarriorStances

local warriorStancesFrame
local frameTexture
local framesUnlocked = false

local playerClass

local preferredStance = {
    [1] = 2,
    [2] = 2,
    [3] = 2,
}

local stanceIcons = {
    [1] = 132341,
    [2] = 132349,
    -- Fury adds 10 to the index
    [11] = 132341,
    [12] = 132275,
}

function ToastyClassChores:SetWarriorStancesTracking(info, value)
    self.db.profile.warriorStancesTracking = value
    if value then
        self:Print("Enabling Warrior Stance Tracking")
        WarriorStances:Initialize()
    else
        self:Print("Disabling Warrior Stance Tracking")
        if warriorStancesFrame then
            warriorStancesFrame:SetAlpha(0)
        end
    end
end

function ToastyClassChores:SetWarriorStancesIconSize(info, value)
    self.db.profile.warriorStancesIconSize = value
    if warriorStancesFrame then
        warriorStancesFrame:SetSize(value, value)
    end
end

function ToastyClassChores:SetProtShowsDef(info, value)
    self.db.profile.warriorStancesProtShowsDef = value
    WarriorStances:Update()
end

function ToastyClassChores:SetProtShowsBattle(info, value)
    self.db.profile.warriorStancesProtShowsBattle = value
    WarriorStances:Update()
end

function WarriorStances:Initialize()
    playerClass = ToastyClassChores.cdb.profile.class
    if not (ToastyClassChores.db.profile.warriorStancesTracking and playerClass == "WARRIOR") then
        return
    end
    if not warriorStancesFrame then
        warriorStancesFrame = CreateFrame("Frame", "Warrior Stances Reminder", UIParent)
        warriorStancesFrame:SetPoint(ToastyClassChores.db.profile.warriorStancesLocation.frameAnchorPoint, UIParent,
            ToastyClassChores.db.profile.warriorStancesLocation.parentAnchorPoint,
            ToastyClassChores.db.profile.warriorStancesLocation.xPos,
            ToastyClassChores.db.profile.warriorStancesLocation.yPos)
        warriorStancesFrame:SetSize(ToastyClassChores.db.profile.warriorStancesIconSize,
            ToastyClassChores.db.profile.warriorStancesIconSize)
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
        ToastyClassChores.db.profile.warriorStancesLocation.frameAnchorPoint, _, ToastyClassChores.db.profile.warriorStancesLocation.parentAnchorPoint, ToastyClassChores.db.profile.warriorStancesLocation.xPos, ToastyClassChores.db.profile.warriorStancesLocation.yPos =
            warriorStancesFrame:GetPoint()
    end)

    warriorStancesFrame:SetAlpha(0)
    self:Update()
end

function WarriorStances:Update()
    if not (ToastyClassChores.db.profile.warriorStancesTracking and playerClass == "WARRIOR") then
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

    if specIndex ~= 3 then
        if stanceIndex ~= 2 then
            warriorStancesFrame:SetAlpha(1)
        else
            if not framesUnlocked then
                warriorStancesFrame:SetAlpha(0)
            end
        end
    else
        if stanceIndex == 1 and ToastyClassChores.db.profile.warriorStancesProtShowsDef then
            warriorStancesFrame:SetAlpha(1)
        elseif stanceIndex == 2 and ToastyClassChores.db.profile.warriorStancesProtShowsBattle then
            warriorStancesFrame:SetAlpha(1)
        else
            if not framesUnlocked then
                warriorStancesFrame:SetAlpha(0)
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
            warriorStancesFrame:SetAlpha(1)
        else
            framesUnlocked = false
            self:Update()
        end
    end
end
