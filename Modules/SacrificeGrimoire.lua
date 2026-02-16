local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.SacrificeGrimoire = ToastyClassChores.SacrificeGrimoire or {}
local SacrificeGrimoire = ToastyClassChores.SacrificeGrimoire

local grimoireFrame
local grimoireCastTimestamp

local framesUnlocked = false
local playerClass

function ToastyClassChores:SetSacrificeGrimoireTracking(info, value)
    self.db.profile.sacrificeGrimoireTracking = value
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
    self.db.profile.sacrificeGrimoireIconSize = value
    if grimoireFrame then
        grimoireFrame:SetSize(value, value)
    end
end

function ToastyClassChores:SetSacrificeGrimoireOpacity(info, value)
    self.db.profile.sacrificeGrimoireOpacity = value
    if grimoireFrame then
        grimoireFrame:SetAlpha(value)
    end
end

function SacrificeGrimoire:Initialize()
    playerClass = ToastyClassChores.cdb.profile.class
    if not (ToastyClassChores.db.profile.sacrificeGrimoireTracking and playerClass == "WARLOCK") then
        return
    end
    if not C_SpellBook.IsSpellInSpellBook(108503) then
        return
    end
    if not grimoireFrame then
        grimoireFrame = CreateFrame("Frame", "Sacrifice Grimoire Reminder", UIParent)
        grimoireFrame:SetPoint(ToastyClassChores.db.profile.sacrificeGrimoireLocation.frameAnchorPoint, UIParent,
            ToastyClassChores.db.profile.sacrificeGrimoireLocation.parentAnchorPoint,
            ToastyClassChores.db.profile.sacrificeGrimoireLocation.xPos,
            ToastyClassChores.db.profile.sacrificeGrimoireLocation.yPos)
        grimoireFrame:SetSize(ToastyClassChores.db.profile.sacrificeGrimoireIconSize,
            ToastyClassChores.db.profile.sacrificeGrimoireIconSize)
        local frameTexture = grimoireFrame:CreateTexture(nil, "BACKGROUND")
        frameTexture:SetTexture(538443)
        frameTexture:SetAllPoints()

        grimoireFrame:RegisterForDrag("LeftButton")
        grimoireFrame:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)
        grimoireFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            ToastyClassChores.db.profile.sacrificeGrimoireLocation.frameAnchorPoint, _, ToastyClassChores.db.profile.sacrificeGrimoireLocation.parentAnchorPoint, ToastyClassChores.db.profile.sacrificeGrimoireLocation.xPos, ToastyClassChores.db.profile.sacrificeGrimoireLocation.yPos =
                grimoireFrame:GetPoint()
        end)
    end
    grimoireFrame:SetAlpha(ToastyClassChores.db.profile.sacrificeGrimoireOpacity)
    if not framesUnlocked then
        grimoireFrame:Hide()
    end
    self:Update()
end

function SacrificeGrimoire:Update()
    if not (ToastyClassChores.db.profile.sacrificeGrimoireTracking and playerClass == "WARLOCK") then
        return
    end
    if not grimoireFrame then
        self:Initialize()
    end

    if not C_SpellBook.IsSpellInSpellBook(108503) then
        grimoireFrame:Hide()
        return
    end
    if C_SpellBook.IsSpellInSpellBook(132411) or C_SpellBook.IsSpellInSpellBook(132413) or C_SpellBook.IsSpellInSpellBook(132409) or C_SpellBook.IsSpellInSpellBook(261589) then
        local hasUI, _ = HasPetUI()
        if not hasUI then
            grimoireFrame:Hide()
            if grimoireCastTimestamp then
                grimoireCastTimestamp = nil
            end
        else
            if grimoireCastTimestamp then
                if GetSessionTime() - grimoireCastTimestamp < 20 then
                    grimoireFrame:Hide()
                else
                    grimoireFrame:Show()
                end
            else
                grimoireFrame:Show()
            end
        end
    else
        grimoireFrame:Show()
    end
end

function SacrificeGrimoire:GrimoireCast()
    if not (ToastyClassChores.db.profile.sacrificeGrimoireTracking and playerClass == "WARLOCK") then
        return
    end
    if not grimoireFrame then
        self:Initialize()
    end

    if not C_SpellBook.IsSpellInSpellBook(108503) then
        return
    end
    grimoireCastTimestamp = GetSessionTime()
    grimoireFrame:Hide()
end

function SacrificeGrimoire:Death()
    if not (ToastyClassChores.db.profile.sacrificeGrimoireTracking and playerClass == "WARLOCK") then
        return
    end
    if not grimoireFrame then
        self:Initialize()
    end

    if not C_SpellBook.IsSpellInSpellBook(108503) then
        return
    end
    grimoireFrame:Show()
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
