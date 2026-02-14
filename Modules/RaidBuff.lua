local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.RaidBuff = ToastyClassChores.RaidBuff or {}
local RaidBuff = ToastyClassChores.RaidBuff

local raidBuffFrame
local playerClass
local alphaBeforeUnlock
local glowHidWhileFramesUnlocked = false
local framesUnlocked = false

local raidBuffClassList = {
    [1126] = "DRUID",
    [364342] = "EVOKER",
    [1459] = "MAGE",
    [21562] = "PRIEST",
    [462854] = "SHAMAN",
    [6673] = "WARRIOR"
}

local raidBuffIconList = {
    DRUID = 136078,
    EVOKER = 4622448,
    MAGE = 135932,
    PRIEST = 135987,
    SHAMAN = 4630367,
    WARRIOR = 132333
}

function ToastyClassChores:SetRaidBuffTracking(info, value)
    self.db.profile.raidBuffTracking = value
    if value then
        self:Print("Enabling Raid Buff Tracking")
        RaidBuff:Initialize()
    else
        self:Print("Disabling Raid Buff Tracking")
        if raidBuffFrame then
            raidBuffFrame:SetAlpha(0)
        end
    end
end

function ToastyClassChores:SetRaidBuffIconSize(info, value)
    self.db.profile.raidBuffIconSize = value
    if raidBuffFrame then
        raidBuffFrame:SetSize(value, value)
    end
end

function RaidBuff:Initialize()
    playerClass = ToastyClassChores.cdb.profile.class
    if not (ToastyClassChores.db.profile.raidBuffTracking and raidBuffIconList[playerClass]) then
        return
    end
    if not raidBuffFrame then
        raidBuffFrame = CreateFrame("Frame", "Raid Buffs Reminder", UIParent)
        raidBuffFrame:SetPoint(ToastyClassChores.db.profile.raidBuffLocation.frameAnchorPoint, UIParent,
            ToastyClassChores.db.profile.raidBuffLocation.parentAnchorPoint,
            ToastyClassChores.db.profile.raidBuffLocation.xPos, ToastyClassChores.db.profile.raidBuffLocation.yPos)
        raidBuffFrame:SetSize(ToastyClassChores.db.profile.raidBuffIconSize,
            ToastyClassChores.db.profile.raidBuffIconSize)
        local frameTexture = raidBuffFrame:CreateTexture(nil, "BACKGROUND")
        frameTexture:SetTexture(raidBuffIconList[playerClass])
        frameTexture:SetAllPoints()

        raidBuffFrame:RegisterForDrag("LeftButton")
        raidBuffFrame:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)
        raidBuffFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            ToastyClassChores.db.profile.raidBuffLocation.frameAnchorPoint, _, ToastyClassChores.db.profile.raidBuffLocation.parentAnchorPoint, ToastyClassChores.db.profile.raidBuffLocation.xPos, ToastyClassChores.db.profile.raidBuffLocation.yPos =
                raidBuffFrame:GetPoint()
        end)
    end
    if not framesUnlocked then
        raidBuffFrame:SetAlpha(0)
    end
end

function RaidBuff:GlowShow(spellID)
    if not (ToastyClassChores.db.profile.raidBuffTracking and raidBuffIconList[playerClass]) then
        if raidBuffFrame and not framesUnlocked then
            raidBuffFrame:SetAlpha(0)
        end
        return
    end
    if not raidBuffFrame then
        self:Initialize()
    end
    if raidBuffClassList[spellID] == playerClass then
        raidBuffFrame:SetAlpha(0.5)
    end
end

function RaidBuff:GlowHide(spellID)
    if not (ToastyClassChores.db.profile.raidBuffTracking and raidBuffIconList[playerClass]) then
        if raidBuffFrame and not framesUnlocked then
            raidBuffFrame:SetAlpha(0)
        end
        return
    end
    if framesUnlocked then
        glowHidWhileFramesUnlocked = true
    end
    if not raidBuffFrame then
        self:Initialize()
    end
    if raidBuffClassList[spellID] == playerClass and not framesUnlocked then
        raidBuffFrame:SetAlpha(0)
    end
end

function RaidBuff:ToggleFrameLock(value)
    if raidBuffFrame then
        raidBuffFrame:SetMovable(not value)
        raidBuffFrame:EnableMouse(not value)

        if not value then
            framesUnlocked = true
            alphaBeforeUnlock = raidBuffFrame:GetAlpha()
            raidBuffFrame:SetAlpha(1)
        else
            framesUnlocked = false
            if glowHidWhileFramesUnlocked then
                raidBuffFrame:SetAlpha(0)
            else
                raidBuffFrame:SetAlpha(alphaBeforeUnlock)
            end
        end
    end
end
