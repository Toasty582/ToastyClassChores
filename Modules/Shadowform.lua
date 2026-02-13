local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.Shadowform = ToastyClassChores.Shadowform or {}
local Shadowform = ToastyClassChores.Shadowform

local active
local shadowformFrame
local playerClass


function ToastyClassChores:SetShadowformTracking(info, value)
    self.db.profile.shadowformTracking = value
    if value then
        self:Print("Enabling Shadowform Tracking")
        Shadowform:Initialize()
    else
        self:Print("Disabling Shadowform Tracking")
        if shadowformFrame then
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
    ToastyClassChores:Print(playerClass == "PRIEST")
    if not (ToastyClassChores.db.profile.shadowformTracking and playerClass == "PRIEST") then
        return
    end
    active = GetShapeshiftForm()
    shadowformFrame = CreateFrame("Frame", "Shadowform Reminder", UIParent)
    shadowformFrame:SetPoint("CENTER")
    shadowformFrame:SetSize(ToastyClassChores.db.profile.shadowformIconSize, ToastyClassChores.db.profile.shadowformIconSize)
    local frameTexture = shadowformFrame:CreateTexture(nil, "BACKGROUND")
    frameTexture:SetTexture(136200)
    frameTexture:SetAllPoints()
    if C_SpecializationInfo.GetSpecialization() == 3 then
        if active == 1 then
            shadowformFrame:SetAlpha(0)
        else
            shadowformFrame:SetAlpha(1)
        end
    else
        shadowformFrame:SetAlpha(0)
    end
end

function Shadowform:Update()
    if not (ToastyClassChores.db.profile.shadowformTracking and playerClass == "PRIEST") then
        return
    end
    if not shadowformFrame then
        self:Initialize()
    end
    if C_SpecializationInfo.GetSpecialization() ~= 3 then
        return
    end
    if active == GetShapeshiftForm() then
        return
    end
    
    active = GetShapeshiftForm()

    if active == 1 then
        shadowformFrame:SetAlpha(0)
    else
        shadowformFrame:SetAlpha(1)
    end
end

function Shadowform:UpdateSpec()
    if not (ToastyClassChores.db.profile.shadowformTracking and playerClass == "PRIEST") then
        return
    end
    if not shadowformFrame then
        self:Initialize()
    end
    active = 0
    if C_SpecializationInfo.GetSpecialization() == 3 then
        shadowformFrame:SetAlpha(1)
    else
        shadowformFrame:SetAlpha(0)
    end
end
