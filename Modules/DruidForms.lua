local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.DruidForms = ToastyClassChores.DruidForms or {}
local DruidForms = ToastyClassChores.DruidForms

local druidFormsFrame
local frameTexture

local playerClass
local knowsMoonkinForm
local knowsTreantForm

-- Note that resto druids can use Treant Form as well, which can be in index 4 or 5 depending on if they're also specced into moonkin form.
local preferredForm = {
    [1] = 4,
    [2] = 2,
    [3] = 1,
    [4] = 0, -- Resto is here but this table is only used for the first three specs
}

local formIcons = {
    [0] = 625999,
    [1] = 132276,
    [2] = 132115,
    [3] = 132144,
    -- 3 or less can be treated normally, the same regardless of known spells
    [4] = 1394966,
    -- Add 10 if treant form is known
    [14] = 132145,
    [15] = 1394966,
    -- Add 20 if moonkin form is known
    [24] = 136036,
    [25] = 1394966,
    -- Add 30 if both extra forms are known
    [34] = 136036,
    [35] = 132145,
    [36] = 1394966,
}

function ToastyClassChores:SetDruidFormsTracking(info, value)
    self.db.profile.druidFormsTracking = value
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

function ToastyClassChores:SetDruidFormsAlwaysShow(info, value)
    self.db.profile.druidFormsAlwaysShow = value
    DruidForms:Update()
end

function ToastyClassChores:SetDruidFormsIconSize(info, value)
    self.db.profile.druidFormsIconSize = value
    if druidFormsFrame then
        druidFormsFrame:SetSize(value, value)
    end
end

function DruidForms:Initialize()
    playerClass = ToastyClassChores.cdb.profile.class
    if not (ToastyClassChores.db.profile.druidFormsTracking and playerClass == "DRUID") then
        return
    end
    if not druidFormsFrame then
        druidFormsFrame = CreateFrame("Frame", "Druid Forms Reminder", UIParent)
        druidFormsFrame:SetPoint(ToastyClassChores.db.profile.druidFormsLocation.frameAnchorPoint, UIParent,
            ToastyClassChores.db.profile.druidFormsLocation.parentAnchorPoint,
            ToastyClassChores.db.profile.druidFormsLocation.xPos,
            ToastyClassChores.db.profile.druidFormsLocation.yPos)
        druidFormsFrame:SetSize(ToastyClassChores.db.profile.druidFormsIconSize,
            ToastyClassChores.db.profile.druidFormsIconSize)
        frameTexture = druidFormsFrame:CreateTexture(nil, "BACKGROUND")
        frameTexture:SetTexture(134400) -- Question mark as default, if you see this something went wrong
        frameTexture:SetAllPoints()
    end

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
    self:CheckForms()
    self:Update()
end

function DruidForms:Update()
    if not (ToastyClassChores.db.profile.druidFormsTracking and playerClass == "DRUID") then
        return
    end
    local specIndex = C_SpecializationInfo.GetSpecialization()
    if not druidFormsFrame then
        self:Initialize()
    end
    local formIndex = GetShapeshiftForm()
    if formIndex > 3 then
        frameTexture:SetTexture(formIcons[formIndex + 10 * knowsTreantForm + 20 * knowsMoonkinForm])
    else
        frameTexture:SetTexture(formIcons[formIndex])
    end
    frameTexture:SetAllPoints()

    if ToastyClassChores.db.profile.druidFormsAlwaysShow then
        druidFormsFrame:SetAlpha(1)
        return
    end
    if IsMounted() then
        druidFormsFrame:SetAlpha(0)
        return
    end
    if specIndex ~= 4 then -- Resto is slightly weird
        if formIndex ~= preferredForm[specIndex] then
            ToastyClassChores:Print("Wrong form")
            ToastyClassChores:Print(formIndex)
            druidFormsFrame:SetAlpha(1)
        else
            ToastyClassChores:Print("Right form")
            druidFormsFrame:SetAlpha(0)
        end
    else
        local treantIndex = 4 + knowsMoonkinForm
        if formIndex ~= 0 and formIndex ~= treantIndex then
            druidFormsFrame:SetAlpha(1)
        else
            druidFormsFrame:SetAlpha(0)
        end
    end
end

function DruidForms:CheckForms()
    if C_SpellBook.IsSpellKnown(24858) then
        knowsMoonkinForm = 1
    else
        knowsMoonkinForm = 0
    end
    if C_SpellBook.IsSpellKnown(114282) then
        knowsTreantForm = 1
    else
        knowsTreantForm = 0
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
