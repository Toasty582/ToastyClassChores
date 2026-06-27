local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.PaladinAuras = ToastyClassChores.PaladinAuras or {}
local PaladinAuras = ToastyClassChores.PaladinAuras

local playerClass
local paladinAurasDB

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
    paladinAurasDB.tracking = value
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
    paladinAurasDB.alwaysShow = value
    PaladinAuras:Update()
end

function ToastyClassChores:SetPaladinAurasIconSize(info, value)
    paladinAurasDB.iconSize = value
    if paladinAurasFrame then
        paladinAurasFrame:SetSize(value, value)
    end
end

function ToastyClassChores:SetPaladinAurasCombatOnly(info, value)
    paladinAurasDB.combatOnly = value
    PaladinAuras:Update()
end

function ToastyClassChores:SetPaladinAurasInstanceOnly(info, value)
    paladinAurasDB.instanceOnly = value
    PaladinAuras:Update()
end

function ToastyClassChores:SetPaladinAurasNoLegacy(info, value)
    paladinAurasDB.noLegacy = value
    PaladinAuras:Update()
end

function ToastyClassChores:SetPaladinAurasOpacity(info, value)
    paladinAurasDB.opacity = value
    if paladinAurasFrame then
        paladinAurasFrame:SetAlpha(value)
    end
end

function PaladinAuras:Initialize()
    paladinAurasDB = ToastyClassChores.db.profile.paladinAuras
    playerClass = ToastyClassChores.cdb.profile.class
    if not (paladinAurasDB.tracking and playerClass == "PALADIN") then
        return
    end
    if not paladinAurasFrame then
        paladinAurasFrame = CreateFrame("Frame", "Paladin Auras Reminder", UIParent)
        paladinAurasFrame:SetPoint(paladinAurasDB.location.frameAnchorPoint, UIParent,
            paladinAurasDB.location.parentAnchorPoint, paladinAurasDB.location.xPos, paladinAurasDB.location.yPos)
        paladinAurasFrame:SetSize(paladinAurasDB.iconSize, paladinAurasDB.iconSize)
        frameTexture = paladinAurasFrame:CreateTexture(nil, "BACKGROUND")
        frameTexture:SetTexture(134400) -- Question mark as default, if you see this something went wrong
        frameTexture:SetAllPoints()

        paladinAurasFrame:RegisterForDrag("LeftButton")
        paladinAurasFrame:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)
        paladinAurasFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            paladinAurasDB.location.frameAnchorPoint, _, paladinAurasDB.location.parentAnchorPoint, paladinAurasDB.location.xPos, paladinAurasDB.location.yPos =
                paladinAurasFrame:GetPoint()
        end)
    end
    paladinAurasFrame:SetAlpha(paladinAurasDB.opacity)
    if not framesUnlocked then
        paladinAurasFrame:Hide()
    end
    self:Update()
end

function PaladinAuras:Update()
    if not (paladinAurasDB.tracking and playerClass == "PALADIN") then
        return
    end
    if not paladinAurasFrame then
        self:Initialize()
    end

    local _, instanceType = IsInInstance()

    if paladinAurasDB.instanceOnly and not (instanceType == "pvp" or instanceType == "arena" or instanceType == "party" or instanceType == "raid" or instanceType == "scenario") and not framesUnlocked then
        paladinAurasFrame:Hide()
        return
    end
    if paladinAurasDB.noLegacy and C_Loot.IsLegacyLootModeEnabled() and not framesUnlocked then
        paladinAurasFrame:Hide()
        return
    end
    if paladinAurasDB.combatOnly and not PlayerIsInCombat() and not framesUnlocked then
        paladinAurasFrame:Hide()
        return
    end

    local auraIndex = GetShapeshiftForm()
    frameTexture:SetTexture(auraIcons[auraIndex])
    frameTexture:SetAllPoints()

    if auraIndex ~= 2 then
        paladinAurasFrame:Show()
    else
        if framesUnlocked or paladinAurasDB.alwaysShow then
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
