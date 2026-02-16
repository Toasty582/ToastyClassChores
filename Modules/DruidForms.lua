local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.DruidForms = ToastyClassChores.DruidForms or {}
local DruidForms = ToastyClassChores.DruidForms

local druidFormsFrame
local frameTexture
local framesUnlocked = false

local playerClass
local knowsMoonkinForm
local knowsTreantForm
local knowsWildpowerSurge

-- Note that resto druids can use Treant Form as well, which can be in index 4 or 5 depending on if they're also specced into moonkin form.
local preferredForm = {
    [1] = 4,
    [2] = 2,
    [3] = 1,
    [4] = 0, -- Resto is here but this table is only used for the first three specs
}

local formIcons = {
    [0] = 625999,   -- Humanoid
    [1] = 132276,   -- Cat
    [2] = 132115,   -- Bear
    [3] = 132144,   -- Travel
    -- 3 or less can be treated normally, the same regardless of known spells
    [4] = 1394966,  -- Stag
    -- Add 10 if treant form is known
    [14] = 132145,  -- Treant
    [15] = 1394966, -- Stag
    -- Add 20 if moonkin form is known
    [24] = 136036,  -- Moonkin
    [25] = 1394966, -- Stag
    -- Add 30 if both extra forms are known
    [34] = 136036,  -- Moonkin
    [35] = 132145,  -- Treant
    [36] = 1394966, -- Stag
}

function ToastyClassChores:SetDruidFormsTracking(info, value)
    self.db.profile.druidFormsTracking = value
    if value then
        self:Print("Enabling Druid Form Tracking")
        DruidForms:Initialize()
    else
        self:Print("Disabling Druid Form Tracking")
        if druidFormsFrame and not framesUnlocked then
            druidFormsFrame:SetAlpha(0)
        end
    end
end

function ToastyClassChores:SetDruidFormsAlwaysShow(info, value)
    self.db.profile.druidFormsAlwaysShow = value
    if value then
        self.db.profile.druidFormsIgnoreTravel = false
    end
    DruidForms:Update()
end

function ToastyClassChores:SetDruidFormsIconSize(info, value)
    self.db.profile.druidFormsIconSize = value
    if druidFormsFrame then
        druidFormsFrame:SetSize(value, value)
    end
end

function ToastyClassChores:SetDruidFormsInCombatOnly(info, value)
    self.db.profile.druidFormsInCombatOnly = value
    DruidForms:Update()
end

function ToastyClassChores:SetDruidFormsIgnoreTravel(info, value)
    self.db.profile.druidFormsIgnoreTravel = value
    if value then
        self.db.profile.druidFormsAlwaysShow = false
    end
    DruidForms:Update()
end

function ToastyClassChores:SetDruidFormsInstanceOnly(info, value)
    self.db.profile.druidFormsInstanceOnly = value
    DruidForms:Update()
end

function ToastyClassChores:SetDruidFormsNoLegacy(info, value)
    self.db.profile.druidFormsNoLegacy = value
    DruidForms:Update()
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

        druidFormsFrame:RegisterForDrag("LeftButton")
        druidFormsFrame:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)
        druidFormsFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            ToastyClassChores.db.profile.druidFormsLocation.frameAnchorPoint, _, ToastyClassChores.db.profile.druidFormsLocation.parentAnchorPoint, ToastyClassChores.db.profile.druidFormsLocation.xPos, ToastyClassChores.db.profile.druidFormsLocation.yPos =
                druidFormsFrame:GetPoint()
        end)
    end
    if not framesUnlocked then
        druidFormsFrame:SetAlpha(0)
    end
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
    
    local _, instanceType = IsInInstance()
    
    if ToastyClassChores.db.profile.druidFormsInstanceOnly and not (instanceType == "pvp" or instanceType == "arena" or instanceType == "party" or instanceType == "raid") then
        druidFormsFrame:SetAlpha(0)
        return
    end
    if ToastyClassChores.db.profile.druidFormsNoLegacy and C_Loot.IsLegacyLootModeEnabled() then
        druidFormsFrame:SetAlpha(0)
        return
    end

    local formIndex = GetShapeshiftForm()
    local effectiveFormIndex = formIndex
    if formIndex > 3 then
        effectiveFormIndex = formIndex + 10 * knowsTreantForm + 20 * knowsMoonkinForm
    end
    frameTexture:SetTexture(formIcons[effectiveFormIndex])
    frameTexture:SetAllPoints()

    if ToastyClassChores.db.profile.druidFormsInCombatOnly and not PlayerIsInCombat() then
        druidFormsFrame:SetAlpha(0)
        return
    end

    if ToastyClassChores.db.profile.druidFormsAlwaysShow then
        druidFormsFrame:SetAlpha(1)
        return
    end

    if (formIcons[effectiveFormIndex] == 132144 or formIcons[effectiveFormIndex] == 1394966) and ToastyClassChores.db.profile.druidFormsIgnoreTravel then
        druidFormsFrame:SetAlpha(0)
        return
    end

    if IsMounted() and not framesUnlocked then
        druidFormsFrame:SetAlpha(0)
        return
    end
    if specIndex ~= 4 then -- Resto is slightly weird
        if formIndex ~= preferredForm[specIndex] then
            druidFormsFrame:SetAlpha(1)
        else
            if not framesUnlocked then
                druidFormsFrame:SetAlpha(0)
            end
        end
        if knowsWildpowerSurge == 1 and (formIndex == 1 or formIndex == 2) and not framesUnlocked then
            ToastyClassChores:Debug(knowsWildpowerSurge)
            druidFormsFrame:SetAlpha(0)
        end
    else
        local treantIndex = 4 + knowsMoonkinForm
        if formIndex ~= 0 and formIndex ~= treantIndex then
            druidFormsFrame:SetAlpha(1)
        else
            if not framesUnlocked then
                druidFormsFrame:SetAlpha(0)
            end
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
    if C_SpellBook.IsSpellKnown(441691) then
        knowsWildpowerSurge = 1
    else
        knowsWildpowerSurge = 0
    end
end

function DruidForms:ToggleFrameLock(value)
    if druidFormsFrame then
        druidFormsFrame:SetMovable(not value)
        druidFormsFrame:EnableMouse(not value)

        if not value then
            framesUnlocked = true
            druidFormsFrame:SetAlpha(1)
        else
            framesUnlocked = false
            self:Update()
        end
    end
end
