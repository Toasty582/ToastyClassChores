local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.DruidForms = ToastyClassChores.DruidForms or {}
local DruidForms = ToastyClassChores.DruidForms

local druidFormsFrame
local playerClass

-- Note that resto druids can use Treant Form as well, which can be in index 4 or 5 depending on if they're also specced into moonkin form.
local preferredForm = {
    [1] = 4,
    [2] = 2,
    [3] = 1,
    [4] = 0,
}

local formIcons = {
    [0] = "Humanoid",
    [1] = "Bear",
    [2] = "Cat",
    [3] = "Travel",
    [4] = "Moonkin/Treant/Stag",
    [5] = "Treant/Stag",
    [6] = "Stag"
}

function ToastyClassChores:SetDruidFormsTracking(info, value)
    self.db.profile.petsTracking = value
    if value then
        self:Print("Enabling Druid Form Tracking")
        DruidForms:Initialize()
    else
        self:Print("Disabling Druid Form Tracking")
        if druidFormsFrame then
            druidFormsFrame:SetAlpha(0)
        end
    end
end

function ToastyClassChores:SetDruidFormsIconSize(info, value)
    self.db.profile.druidFormsIconSize = value
    if druidFormsFrame then
        druidFormsFrame:SetSize(value, value)
    end
end

function DruidForms:Initialize()
    playerClass = ToastyClassChores.cdb.profile.class
    if not (ToastyClassChores.db.profile.petsTracking and playerClass == "DRUID") then
        return
    end
    druidFormsFrame = CreateFrame("Frame", "Druid Forms Reminder", UIParent)
    druidFormsFrame:SetPoint(ToastyClassChores.db.profile.druidFormsLocation.frameAnchorPoint, UIParent,
        ToastyClassChores.db.profile.druidFormsLocation.parentAnchorPoint, ToastyClassChores.db.profile.druidFormsLocation.xPos,
        ToastyClassChores.db.profile.druidFormsLocation.yPos)
    druidFormsFrame:SetSize(ToastyClassChores.db.profile.druidFormsIconSize, ToastyClassChores.db.profile.druidFormsIconSize)
    local frameTexture = druidFormsFrame:CreateTexture(nil, "BACKGROUND")
    frameTexture:SetTexture(42069) -- CHANGE THIS AT SOME POINT --------------------------------------------------------------------
    frameTexture:SetAllPoints()

    druidFormsFrame:RegisterForDrag("LeftButton")
    druidFormsFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    druidFormsFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        ToastyClassChores.db.profile.druidFormsLocation.frameAnchorPoint, _, ToastyClassChores.db.profile.druidFormsLocation.parentAnchorPoint, ToastyClassChores.db.profile.druidFormsLocation.xPos, ToastyClassChores.db.profile.druidFormsLocation.yPos =
            druidFormsFrame:GetPoint()
    end)

    druidFormsFrame:SetAlpha(0)
    self:Update()
end

function DruidForms:Update()
    if not (ToastyClassChores.db.profile.petsTracking and playerClass == "DRUID") then
        return
    end
    if GetShapeshiftForm() ~= preferredForm[C_SpecializationInfo.GetSpecialization()] then
        druidFormsFrame:SetAlpha(1)
    else
        druidFormsFrame:SetAlpha(0)
    end
end

function DruidForms:ToggleFrameLock(value)
    if druidFormsFrame then
        druidFormsFrame:SetMovable(not value)
        druidFormsFrame:EnableMouse(not value)

        if not value then
            druidFormsFrame:SetAlpha(1)
        else
            self:Update()
        end
    end
end