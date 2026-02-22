local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.RaidBuff = ToastyClassChores.RaidBuff or {}
local RaidBuff = ToastyClassChores.RaidBuff

local raidBuffFrame
local playerClass
local glowing = false
local postResWarning = false
local buffDuration
local framesUnlocked = false

local raidBuffTimer

local raidBuffSpellList = {
    [1126] = "DRUID",
    [364342] = "EVOKER",
    [1459] = "MAGE",
    [21562] = "PRIEST",
    [462854] = "SHAMAN",
    [6673] = "WARRIOR"
}

local raidBuffAuraList = {
    [1126] = "DRUID",
    [381748] = "EVOKER",
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
            raidBuffFrame:Hide()
        end
    end
end

function ToastyClassChores:SetRaidBuffIconSize(info, value)
    self.db.profile.raidBuffIconSize = value
    if raidBuffFrame then
        raidBuffFrame:SetSize(value, value)
    end
end

function ToastyClassChores:SetRaidBuffOpacity(info, value)
    self.db.profile.raidBuffOpacity = value
    if raidBuffFrame then
        raidBuffFrame:SetAlpha(value)
    end
end

function ToastyClassChores:SetRaidBuffEarlyWarning(info, value)
    self.db.profile.raidBuffEarlyWarning = value
    RaidBuff:Update()
end

function ToastyClassChores:SetRaidBuffEarlyWarningNoCombat(info, value)
    self.db.profile.raidBuffEarlyWarningNoCombat = value
    RaidBuff:Update()
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
    raidBuffFrame:SetAlpha(ToastyClassChores.db.profile.raidBuffOpacity)
    if not framesUnlocked then
        raidBuffFrame:Hide()
    end
    self:CreateDurations()
    self:Update()
end

function RaidBuff:Update()
    if not (ToastyClassChores.db.profile.raidBuffTracking and raidBuffIconList[playerClass]) then
        return
    end
    if not raidBuffFrame then
        self:Initialize()
    end
    self:CheckDurations()
    if glowing or postResWarning then
        raidBuffFrame:Show()
    else
        local earlyWarningThreshold = 60 * ToastyClassChores.db.profile.raidBuffEarlyWarning
        if PlayerIsInCombat() and ToastyClassChores.db.profile.raidBuffEarlyWarningNoCombat then
            earlyWarningThreshold = 0
        end
        if buffDuration:GetRemainingDuration() <= earlyWarningThreshold or buffDuration:GetRemainingDuration() == nil then
            raidBuffFrame:Show()
            return
        else
            if not framesUnlocked then
                raidBuffFrame:Hide()
            end
            return
        end
    end
end

function RaidBuff:GlowShow(spellID)
    if not (ToastyClassChores.db.profile.raidBuffTracking and raidBuffIconList[playerClass]) then
        return
    end
    if raidBuffSpellList[spellID] then
        glowing = true
    end
    self:Update()
end

function RaidBuff:GlowHide(spellID)
    if not (ToastyClassChores.db.profile.raidBuffTracking and raidBuffIconList[playerClass]) then
        return
    end
    if raidBuffSpellList[spellID] then
        glowing = false
    end
    self:Update()
end

function RaidBuff:CreateDurations()
    if not (ToastyClassChores.db.profile.raidBuffTracking and raidBuffIconList[playerClass]) then
        return
    end
    if raidBuffIconList[playerClass] then
        buffDuration = C_DurationUtil.CreateDuration()
    end
    self:CheckDurations()
end

function RaidBuff:CheckDurations()
    if not (ToastyClassChores.db.profile.raidBuffTracking and raidBuffIconList[playerClass]) then
        return
    end
    if C_Secrets.ShouldAurasBeSecret() then
        if buffDuration:GetStartTime() == 0 or buffDuration:GetStartTime() == nil then
            buffDuration:SetTimeFromEnd(GetTime() + ToastyClassChores.cdb.profile.remainingRaidBuffTime, 3600)
            if raidBuffTimer then
                raidBuffTimer:Cancel()
            end
            if buffDuration:GetRemainingDuration() - 60 * ToastyClassChores.db.profile.raidBuffEarlyWarning > 0 then
                raidBuffTimer = C_Timer.NewTimer(
                    buffDuration:GetRemainingDuration() - 60 * ToastyClassChores.db.profile.raidBuffEarlyWarning,
                    function() self:Update() end)
            end
        end
    else
        local buffFound = false
        for spellID, _ in pairs(raidBuffAuraList) do
            if raidBuffAuraList[spellID] == playerClass then
                local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
                if aura then
                    buffDuration:SetTimeFromEnd(aura.expirationTime, 3600)
                    if raidBuffTimer then
                        raidBuffTimer:Cancel()
                    end
                    if buffDuration:GetRemainingDuration() - 60 * ToastyClassChores.db.profile.raidBuffEarlyWarning > 0 then
                        raidBuffTimer = C_Timer.NewTimer(
                            buffDuration:GetRemainingDuration() - 60 * ToastyClassChores.db.profile.raidBuffEarlyWarning,
                            function() self:Update() end)
                    end
                    buffFound = true
                end
            end
        end
        if not buffFound then
            buffDuration:Reset()
        end
    end
    self:StoreDurations()
end

function RaidBuff:StoreDurations()
    if not (ToastyClassChores.db.profile.raidBuffTracking and raidBuffIconList[playerClass]) then
        return
    end
    if buffDuration then
        ToastyClassChores.cdb.profile.remainingRaidBuffTime = buffDuration:GetRemainingDuration()
    else
        ToastyClassChores.cdb.profile.remainingRaidBuffTime = nil
    end
end

function RaidBuff:BuffCast(spellID)
    if not (ToastyClassChores.db.profile.raidBuffTracking and raidBuffIconList[playerClass]) then
        return
    end
    if raidBuffSpellList[spellID] then
        postResWarning = false
        buffDuration:SetTimeFromEnd(GetTime() + 3600, 3600)
        if raidBuffTimer then
            raidBuffTimer:Cancel()
        end
        raidBuffTimer = C_Timer.NewTimer(3600 - 60 * ToastyClassChores.db.profile.raidBuffEarlyWarning,
            function() self:Update() end)
    end
    self:Update()
end

function RaidBuff:PlayerRes()
    if not (ToastyClassChores.db.profile.raidBuffTracking and raidBuffIconList[playerClass]) then
        return
    end
    if not PlayerIsInCombat() then
        return
    end
    postResWarning = true
    C_Timer.After(ToastyClassChores.db.profile.raidBuffPostResTimer,
        function()
            postResWarning = false
            RaidBuff:Update()
        end)
    self:Update()
end

function RaidBuff:Death()
    if not (ToastyClassChores.db.profile.raidBuffTracking and raidBuffIconList[playerClass]) then
        return
    end
    if buffDuration then
        buffDuration:Reset()
    end
    if raidBuffTimer then
        raidBuffTimer:Cancel()
    end
    self:StoreDurations()

    self:Update()
end

function RaidBuff:ToggleFrameLock(value)
    if raidBuffFrame then
        raidBuffFrame:SetMovable(not value)
        raidBuffFrame:EnableMouse(not value)

        if not value then
            framesUnlocked = true
            raidBuffFrame:Show()
        else
            framesUnlocked = false
            self:Update()
        end
    end
end
