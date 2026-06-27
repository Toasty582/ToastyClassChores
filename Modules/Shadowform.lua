local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.Shadowform = ToastyClassChores.Shadowform or {}
local Shadowform = ToastyClassChores.Shadowform

local shadowformFrame
local framesUnlocked = false

local playerClass
local shadowformDB


function ToastyClassChores:SetShadowformTracking(info, value)
    shadowformDB.tracking = value
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
    shadowformDB.iconSize = value
    if shadowformFrame then
        shadowformFrame:SetSize(value, value)
    end
end

function ToastyClassChores:SetShadowformCombatOnly(info, value)
    shadowformDB.combatOnly = value
    Shadowform:Update()
end

function ToastyClassChores:SetShadowformInstanceOnly(info, value)
    shadowformDB.instanceOnly = value
    Shadowform:Update()
end

function ToastyClassChores:SetShadowformNoLegacy(info, value)
    shadowformDB.noLegacy = value
    Shadowform:Update()
end

function ToastyClassChores:SetShadowformOpacity(info, value)
    shadowformDB.opacity = value
    if shadowformFrame then
        shadowformFrame:SetAlpha(value)
    end
end

function Shadowform:Initialize()
    playerClass = ToastyClassChores.cdb.profile.class
    shadowformDB = ToastyClassChores.db.profile.shadowform
    if not (shadowformDB.tracking and playerClass == "PRIEST") then
        return
    end
    if not shadowformFrame then
        shadowformFrame = CreateFrame("Frame", "Shadowform Reminder", UIParent)
        shadowformFrame:SetPoint(shadowformDB.location.frameAnchorPoint, UIParent,
            shadowformDB.location.parentAnchorPoint, shadowformDB.location.xPos, shadowformDB.location.yPos)
        shadowformFrame:SetSize(shadowformDB.iconSize, shadowformDB.iconSize)
        local frameTexture = shadowformFrame:CreateTexture(nil, "BACKGROUND")
        frameTexture:SetTexture(136200)
        frameTexture:SetAllPoints()

        shadowformFrame:RegisterForDrag("LeftButton")
        shadowformFrame:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)
        shadowformFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            shadowformDB.location.frameAnchorPoint, _, shadowformDB.location.parentAnchorPoint, shadowformDB.location.xPos, shadowformDB.location.yPos =
                shadowformFrame:GetPoint()
        end)
    end

    shadowformFrame:SetAlpha(shadowformDB.opacity)
    if not framesUnlocked then
        shadowformFrame:Hide()
    end
    self:Update()
end

function Shadowform:Update()
    if not (shadowformDB.tracking and playerClass == "PRIEST") then
        if shadowformFrame and not framesUnlocked then
            shadowformFrame:Hide()
        end
        return
    end
    if not shadowformFrame then
        self:Initialize()
    end
    local _, instanceType = IsInInstance()

    if shadowformDB.instanceOnly and not (instanceType == "pvp" or instanceType == "arena" or instanceType == "party" or instanceType == "raid" or instanceType == "scenario") and not framesUnlocked then
        shadowformFrame:Hide()
        return
    end
    if shadowformDB.noLegacy and C_Loot.IsLegacyLootModeEnabled() and not framesUnlocked then
        shadowformFrame:Hide()
        return
    end

    if shadowformDB.combatOnly and not PlayerIsInCombat() and not framesUnlocked then
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
