local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.PaladinAuras = ToastyClassChores.PaladinAuras or {}
local PaladinAuras = ToastyClassChores.PaladinAuras

local playerClass
local paladinAurasFrame
local frameTexture
local framesUnlocked = false

local auraIcons = {
    [0] = 626003, -- Missing
    [1] = 135890, -- Crusader
    [2] = 135893, -- Devotion
    [3] = 135933, -- Concentration
}

function ToastyClassChores:SetPaladinAurasTracking(info, value)
    self.db.profile.paladinAurasTracking = value
    if value then
        self:Print("Enabling Paladin Aura Tracking")
        PaladinAuras:Initialize()
    else
        self:Print("Disabling Paladin Aura Tracking")
        if paladinAurasFrame and not framesUnlocked then
            paladinAurasFrame:Hide()
        end
    end
end

function ToastyClassChores:SetPaladinAurasAlwaysShow(info, value)
    self.db.profile.paladinAurasAlwaysShow = value
    PaladinAuras:Update()
end

function ToastyClassChores:SetPaladinAurasIconSize(info, value)
    self.db.profile.paladinAurasIconSize = value
    if paladinAurasFrame then
        paladinAurasFrame:SetSize(value, value)
    end
end

function ToastyClassChores:SetPaladinAurasInCombatOnly(info, value)
    self.db.profile.paladinAurasInCombatOnly = value
    PaladinAuras:Update()
end

function ToastyClassChores:SetPaladinAurasInstanceOnly(info, value)
    self.db.profile.paladinAurasInstanceOnly = value
    PaladinAuras:Update()
end

function ToastyClassChores:SetPaladinAurasNoLegacy(info, value)
    self.db.profile.paladinAurasNoLegacy = value
    PaladinAuras:Update()
end

function ToastyClassChores:SetPaladinAurasOpacity(info, value)
    self.db.profile.paladinAurasOpacity = value
    if paladinAurasFrame then
        paladinAurasFrame:SetAlpha(value)
    end
end

function PaladinAuras:Initialize()
    playerClass = ToastyClassChores.cdb.profile.class
    if not (ToastyClassChores.db.profile.paladinAurasTracking and playerClass == "PALADIN") then
        return
    end
    if not paladinAurasFrame then
        paladinAurasFrame = CreateFrame("Frame", "Paladin Auras Reminder", UIParent)
        paladinAurasFrame:SetPoint(ToastyClassChores.db.profile.paladinAurasLocation.frameAnchorPoint, UIParent,
            ToastyClassChores.db.profile.paladinAurasLocation.parentAnchorPoint,
            ToastyClassChores.db.profile.paladinAurasLocation.xPos,
            ToastyClassChores.db.profile.paladinAurasLocation.yPos)
        paladinAurasFrame:SetSize(ToastyClassChores.db.profile.paladinAurasIconSize,
            ToastyClassChores.db.profile.paladinAurasIconSize)
        frameTexture = paladinAurasFrame:CreateTexture(nil, "BACKGROUND")
        frameTexture:SetTexture(134400) -- Question mark as default, if you see this something went wrong
        frameTexture:SetAllPoints()

        paladinAurasFrame:RegisterForDrag("LeftButton")
        paladinAurasFrame:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)
        paladinAurasFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            ToastyClassChores.db.profile.paladinAurasLocation.frameAnchorPoint, _, ToastyClassChores.db.profile.paladinAurasLocation.parentAnchorPoint, ToastyClassChores.db.profile.paladinAurasLocation.xPos, ToastyClassChores.db.profile.paladinAurasLocation.yPos =
                paladinAurasFrame:GetPoint()
        end)
    end
    paladinAurasFrame:SetAlpha(ToastyClassChores.db.profile.paladinAurasOpacity)
    if not framesUnlocked then
        paladinAurasFrame:Hide()
    end
    self:Update()
end

function PaladinAuras:Update()
    if not (ToastyClassChores.db.profile.paladinAurasTracking and playerClass == "PALADIN") then
        return
    end
    if not paladinAurasFrame then
        self:Initialize()
    end

    local _, instanceType = IsInInstance()

    if ToastyClassChores.db.profile.paladinAurasInstanceOnly and not (instanceType == "pvp" or instanceType == "arena" or instanceType == "party" or instanceType == "raid" or instanceType == "scenario") then
        paladinAurasFrame:Hide()
        return
    end
    if ToastyClassChores.db.profile.paladinAurasNoLegacy and C_Loot.IsLegacyLootModeEnabled() then
        paladinAurasFrame:Hide()
        return
    end
    if ToastyClassChores.db.profile.paladinAurasInCombatOnly and not PlayerIsInCombat() then
        paladinAurasFrame:Hide()
        return
    end

    local auraIndex = GetShapeshiftForm()
    frameTexture:SetTexture(auraIcons[auraIndex])
    frameTexture:SetAllPoints()

    if auraIndex ~= 2 then
        paladinAurasFrame:Show()
    else
        if framesUnlocked or ToastyClassChores.db.profile.paladinAurasAlwaysShow then
            paladinAurasFrame:Show()
        else
            paladinAurasFrame:Hide()
        end
    end
end

function PaladinAuras:ToggleFrameLock(value)
    if paladinAurasFrame then
        paladinAurasFrame:SetMovable(not value)
        paladinAurasFrame:EnableMouse(not value)

        if not value then
            framesUnlocked = true
            paladinAurasFrame:Show()
        else
            framesUnlocked = false
            self:Update()
        end
    end
end
