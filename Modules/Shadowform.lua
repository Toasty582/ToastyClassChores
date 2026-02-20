local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.Shadowform = ToastyClassChores.Shadowform or {}
local Shadowform = ToastyClassChores.Shadowform

local voidformQueued
local shadowformFrame
local playerClass
local framesUnlocked = false


function ToastyClassChores:SetShadowformTracking(info, value)
    self.db.profile.shadowformTracking = value
    if value then
        self:Print("Enabling Shadowform Tracking")
        Shadowform:Initialize()
    else
        self:Print("Disabling Shadowform Tracking")
        if shadowformFrame and not framesUnlocked then
            shadowformFrame:Hide()
        end
    end
end

function ToastyClassChores:SetShadowformIconSize(info, value)
    self.db.profile.shadowformIconSize = value
    if shadowformFrame then
        shadowformFrame:SetSize(value, value)
    end
end

function ToastyClassChores:SetShadowformInCombatOnly(info, value)
    self.db.profile.shadowformInCombatOnly = value
    Shadowform:Update()
end

function ToastyClassChores:SetShadowformInstanceOnly(info, value)
    self.db.profile.shadowformInstanceOnly = value
    Shadowform:Update()
end

function ToastyClassChores:SetShadowformNoLegacy(info, value)
    self.db.profile.shadowformNoLegacy = value
    Shadowform:Update()
end

function ToastyClassChores:SetShadowformOpacity(info, value)
    self.db.profile.shadowformOpacity = value
    if shadowformFrame then
        shadowformFrame:SetAlpha(value)
    end
end

function Shadowform:Initialize()
    playerClass = ToastyClassChores.cdb.profile.class
    if not (ToastyClassChores.db.profile.shadowformTracking and playerClass == "PRIEST") then
        return
    end
    if not shadowformFrame then
        shadowformFrame = CreateFrame("Frame", "Shadowform Reminder", UIParent)
        shadowformFrame:SetPoint(ToastyClassChores.db.profile.shadowformLocation.frameAnchorPoint, UIParent,
            ToastyClassChores.db.profile.shadowformLocation.parentAnchorPoint,
            ToastyClassChores.db.profile.shadowformLocation.xPos, ToastyClassChores.db.profile.shadowformLocation.yPos)
        shadowformFrame:SetSize(ToastyClassChores.db.profile.shadowformIconSize,
            ToastyClassChores.db.profile.shadowformIconSize)
        local frameTexture = shadowformFrame:CreateTexture(nil, "BACKGROUND")
        frameTexture:SetTexture(136200)
        frameTexture:SetAllPoints()

        shadowformFrame:RegisterForDrag("LeftButton")
        shadowformFrame:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)
        shadowformFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            ToastyClassChores.db.profile.shadowformLocation.frameAnchorPoint, _, ToastyClassChores.db.profile.shadowformLocation.parentAnchorPoint, ToastyClassChores.db.profile.shadowformLocation.xPos, ToastyClassChores.db.profile.shadowformLocation.yPos =
                shadowformFrame:GetPoint()
        end)
    end

    shadowformFrame:SetAlpha(ToastyClassChores.db.profile.shadowformOpacity)
    if not framesUnlocked then
        shadowformFrame:Hide()
    end
    self:Update()
end

function Shadowform:Update()
    if not (ToastyClassChores.db.profile.shadowformTracking and playerClass == "PRIEST") then
        if shadowformFrame and not framesUnlocked then
            shadowformFrame:Hide()
        end
        return
    end
    if not shadowformFrame then
        self:Initialize()
    end
    local _, instanceType = IsInInstance()

    if ToastyClassChores.db.profile.shadowformInstanceOnly and not (instanceType == "pvp" or instanceType == "arena" or instanceType == "party" or instanceType == "raid" or instanceType == "scenario") and not framesUnlocked then
        shadowformFrame:Hide()
        return
    end
    if ToastyClassChores.db.profile.shadowformNoLegacy and C_Loot.IsLegacyLootModeEnabled() and not framesUnlocked then
        shadowformFrame:Hide()
        return
    end

    if ToastyClassChores.db.profile.shadowformInCombatOnly and not PlayerIsInCombat() and not framesUnlocked then
        shadowformFrame:Hide()
        return
    end

    if C_SpecializationInfo.GetSpecialization() ~= 3 and not framesUnlocked then
        shadowformFrame:Hide()
        return
    end

    if GetShapeshiftForm() == 1 and not framesUnlocked then
        shadowformFrame:Hide()
    elseif GetShapeshiftForm() == 0 then
        shadowformFrame:Show()
    end
end

function Shadowform:ToggleFrameLock(value)
    if shadowformFrame then
        shadowformFrame:SetMovable(not value)
        shadowformFrame:EnableMouse(not value)

        if not value then
            framesUnlocked = true
            shadowformFrame:Show()
        else
            framesUnlocked = false
            self:Update()
        end
    end
end
