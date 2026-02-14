local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.Shadowform = ToastyClassChores.Shadowform or {}
local Shadowform = ToastyClassChores.Shadowform

local active
local shadowformFrame
local playerClass
local alphaBeforeUnlock
local framesUnlocked = false


function ToastyClassChores:SetShadowformTracking(info, value)
    self.db.profile.shadowformTracking = value
    if value then
        self:Print("Enabling Shadowform Tracking")
        Shadowform:Initialize()
    else
        self:Print("Disabling Shadowform Tracking")
        if shadowformFrame and not framesUnlocked then
            shadowformFrame.SetAlpha(0)
        end
    end
end

function ToastyClassChores:SetShadowformIconSize(info, value)
    self.db.profile.shadowformIconSize = value
    if shadowformFrame then
        shadowformFrame:SetSize(value, value)
    end
end

function Shadowform:Initialize()
    playerClass = ToastyClassChores.cdb.profile.class
    if not (ToastyClassChores.db.profile.shadowformTracking and playerClass == "PRIEST") then
        return
    end
    active = GetShapeshiftForm()
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
    end

    shadowformFrame:RegisterForDrag("LeftButton")
    shadowformFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    shadowformFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        ToastyClassChores.db.profile.shadowformLocation.frameAnchorPoint, _, ToastyClassChores.db.profile.shadowformLocation.parentAnchorPoint, ToastyClassChores.db.profile.shadowformLocation.xPos, ToastyClassChores.db.profile.shadowformLocation.yPos =
            shadowformFrame:GetPoint()
    end)

    shadowformFrame:SetAlpha(0)
    self:Update()
end

function Shadowform:Update()
    if not (ToastyClassChores.db.profile.shadowformTracking and playerClass == "PRIEST") then
        if shadowformFrame and not framesUnlocked then
            shadowformFrame:SetAlpha(0)
        end
        return
    end
    if not shadowformFrame then
        self:Initialize()
    end
    if C_SpecializationInfo.GetSpecialization() ~= 3 then
        shadowformFrame:SetAlpha(0)
        return
    end
    if GetShapeshiftForm() == 1 and not framesUnlocked then
        shadowformFrame:SetAlpha(0)
    else
        shadowformFrame:SetAlpha(1)
    end
end

function Shadowform:ToggleFrameLock(value)
    if shadowformFrame then
        shadowformFrame:SetMovable(not value)
        shadowformFrame:EnableMouse(not value)

        if not value then
            framesUnlocked = true
            shadowformFrame:SetAlpha(1)
        else
            framesUnlocked = false
            self:Update()
        end
    end
end
