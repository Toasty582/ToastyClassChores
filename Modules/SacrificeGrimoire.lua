local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.SacrificeGrimoire = ToastyClassChores.SacrificeGrimoire or {}
local SacrificeGrimoire = ToastyClassChores.SacrificeGrimoire

local grimoireFrame

local framesUnlocked = false
local playerClass

local sacrificeGrimoireDB

function ToastyClassChores:SetSacrificeGrimoireTracking(info, value)
    sacrificeGrimoireDB.tracking = value
    if value then
        self:Print("Enabling Grimoire of Sacrifice Tracking")
        SacrificeGrimoire:Initialize()
    else
        self:Print("Disabling Grimoire of Sacrifice Tracking")
        if grimoireFrame and not framesUnlocked then
            grimoireFrame:Hide()
        end
    end
end

function ToastyClassChores:SetSacrificeGrimoireIconSize(info, value)
    sacrificeGrimoireDB.iconSize = value
    if grimoireFrame then
        grimoireFrame:SetSize(value, value)
    end
end

function ToastyClassChores:SetSacrificeGrimoireOpacity(info, value)
    sacrificeGrimoireDB.opacity = value
    if grimoireFrame then
        grimoireFrame:SetAlpha(value)
    end
end

function SacrificeGrimoire:Initialize()
    sacrificeGrimoireDB = ToastyClassChores.db.profile.sacrificeGrimoire
    playerClass = ToastyClassChores.cdb.profile.class
    if not (sacrificeGrimoireDB.tracking and playerClass == "WARLOCK") then
        return
    end
    if not C_SpellBook.IsSpellInSpellBook(108503) then
        return
    end
    if not grimoireFrame then
        grimoireFrame = CreateFrame("Frame", "Sacrifice Grimoire Reminder", UIParent)
        grimoireFrame:SetPoint(sacrificeGrimoireDB.location.frameAnchorPoint, UIParent,
            sacrificeGrimoireDB.location.parentAnchorPoint, sacrificeGrimoireDB.location.xPos, sacrificeGrimoireDB.location.yPos)
        grimoireFrame:SetSize(sacrificeGrimoireDB.iconSize, sacrificeGrimoireDB.iconSize)
        local frameTexture = grimoireFrame:CreateTexture(nil, "BACKGROUND")
        frameTexture:SetTexture(538443)
        frameTexture:SetAllPoints()

        grimoireFrame:RegisterForDrag("LeftButton")
        grimoireFrame:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)
        grimoireFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            sacrificeGrimoireDB.location.frameAnchorPoint, _, sacrificeGrimoireDB.location.parentAnchorPoint, sacrificeGrimoireDB.location.xPos, sacrificeGrimoireDB.location.yPos =
                grimoireFrame:GetPoint()
        end)
    end
    grimoireFrame:SetAlpha(sacrificeGrimoireDB.opacity)
    if not framesUnlocked then
        grimoireFrame:Hide()
    end
    self:Update()
end

function SacrificeGrimoire:Update()
    if not (sacrificeGrimoireDB.tracking and playerClass == "WARLOCK") then
        if grimoireFrame and not framesUnlocked then
            grimoireFrame:Hide()
        end
        return
    end
    if not grimoireFrame then
        self:Initialize()
    end

    if not C_SpellBook.IsSpellInSpellBook(108503) and not framesUnlocked then
        if grimoireFrame then
            grimoireFrame:Hide()
        end
        return
    end
    if (C_SpellBook.IsSpellInSpellBook(132411) or C_SpellBook.IsSpellInSpellBook(132413) or C_SpellBook.IsSpellInSpellBook(132409) or C_SpellBook.IsSpellInSpellBook(261589)) and not framesUnlocked then
        grimoireFrame:Hide()
    else
        grimoireFrame:Show()
    end
end

function SacrificeGrimoire:ToggleFrameLock(value)
    if grimoireFrame then
        grimoireFrame:SetMovable(not value)
        grimoireFrame:EnableMouse(not value)

        if not value then
            framesUnlocked = true
            grimoireFrame:Show()
        else
            framesUnlocked = false
            self:Update()
        end
    end
end
