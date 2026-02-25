local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.RoguePoisons = ToastyClassChores.RoguePoisons or {}
local RoguePoisons = ToastyClassChores.RoguePoisons

local roguePoisonsFrame
local frameTexture
local framesUnlocked = false

local lethalTimer
local nonLethalTimer
local lethalTimerAssa
local nonLethalTimerAssa

local playerClass

local lethalIDs = {
    [8679] = 8679,     -- Wound
    [315584] = 315584, -- Instant
    [381664] = 381664, -- Amplifying
    [2823] = 2823,     -- Deadly
}

local nonLethalIDs = {
    [5761] = 5761,     -- Numbing
    [3408] = 3408,     -- Crippling
    [381637] = 381637, -- Atrophic
}

function ToastyClassChores:SetRoguePoisonsTracking(info, value)
    self.db.profile.roguePoisonsTracking = value
    if value then
        self:Print("Enabling Rogue Poison Tracking")
        RoguePoisons:Initialize()
    else
        self:Print("Disabling Rogue Poison Tracking")
        if roguePoisonsFrame then
            roguePoisonsFrame:Hide()
        end
    end
end

function ToastyClassChores:SetRoguePoisonsIconSize(info, value)
    self.db.profile.roguePoisonsIconSize = value
    if roguePoisonsFrame then
        roguePoisonsFrame:SetSize(value, value)
    end
end

function ToastyClassChores:SetRoguePoisonsOpacity(info, value)
    self.db.profile.roguePoisonsOpacity = value
    if roguePoisonsFrame then
        roguePoisonsFrame:SetAlpha(value)
    end
end

function ToastyClassChores:SetRoguePoisonsEarlyWarning(info, value)
    self.db.profile.roguePoisonsEarlyWarning = value
    RoguePoisons:Update()
end

function ToastyClassChores:SetRoguePoisonsEarlyWarningNoCombat(info, value)
    self.db.profile.roguePoisonsEarlyWarningNoCombat = value
    RoguePoisons:Update()
end

function RoguePoisons:Initialize()
    playerClass = ToastyClassChores.cdb.profile.class
    if not (ToastyClassChores.db.profile.roguePoisonsTracking and playerClass == "ROGUE") then
        return
    end
    if not roguePoisonsFrame then
        roguePoisonsFrame = CreateFrame("Frame", "Rogue Poisons Reminder", UIParent)
        roguePoisonsFrame:SetPoint(ToastyClassChores.db.profile.roguePoisonsLocation.frameAnchorPoint, UIParent,
            ToastyClassChores.db.profile.roguePoisonsLocation.parentAnchorPoint,
            ToastyClassChores.db.profile.roguePoisonsLocation.xPos,
            ToastyClassChores.db.profile.roguePoisonsLocation.yPos)
        roguePoisonsFrame:SetSize(ToastyClassChores.db.profile.roguePoisonsIconSize,
            ToastyClassChores.db.profile.roguePoisonsIconSize)
        frameTexture = roguePoisonsFrame:CreateTexture(nil, "BACKGROUND")
        frameTexture:SetTexture(132273)
        frameTexture:SetAllPoints()
    end

    roguePoisonsFrame:RegisterForDrag("LeftButton")
    roguePoisonsFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    roguePoisonsFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        ToastyClassChores.db.profile.roguePoisonsLocation.frameAnchorPoint, _, ToastyClassChores.db.profile.roguePoisonsLocation.parentAnchorPoint, ToastyClassChores.db.profile.roguePoisonsLocation.xPos, ToastyClassChores.db.profile.roguePoisonsLocation.yPos =
            roguePoisonsFrame:GetPoint()
    end)
    roguePoisonsFrame:SetAlpha(ToastyClassChores.db.profile.roguePoisonsOpacity)
    if not framesUnlocked then
        roguePoisonsFrame:Hide()
    end
    self:Update()
end

function RoguePoisons:Update()
    if not (ToastyClassChores.db.profile.roguePoisonsTracking and playerClass == "ROGUE") then
        return
    end
    if not roguePoisonsFrame then
        self:Initialize()
    end

    local lethalTime, nonLethalTime, lethalTimeAssa, nonLethalTimeAssa = self:CheckPoisons()

    local earlyWarningThreshold = 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning
    if PlayerIsInCombat() and ToastyClassChores.db.profile.roguePoisonsEarlyWarningNoCombat then
        earlyWarningThreshold = 0
    end

    if C_SpecializationInfo.GetSpecialization() == 1 then
        if lethalTime == nil or nonLethalTime == nil or lethalTimeAssa == nil or nonLethalTimeAssa == nil then
            roguePoisonsFrame:Show()
            return
        end
        if lethalTime <= earlyWarningThreshold or nonLethalTime <= earlyWarningThreshold or lethalTimeAssa <= earlyWarningThreshold or nonLethalTimeAssa <= earlyWarningThreshold then
            roguePoisonsFrame:Show()
            return
        else
            if not framesUnlocked then
                roguePoisonsFrame:Hide()
                return
            end
        end
    else
        if lethalTime == nil or nonLethalTime == nil then
            roguePoisonsFrame:Show()
            return
        end
        if lethalTime <= earlyWarningThreshold or nonLethalTime <= earlyWarningThreshold then
            roguePoisonsFrame:Show()
            return
        else
            if not framesUnlocked then
                roguePoisonsFrame:Hide()
                return
            end
        end
    end
end

function RoguePoisons:CheckPoisons()
    if not (ToastyClassChores.db.profile.roguePoisonsTracking and playerClass == "ROGUE") then
        return nil, nil, nil, nil
    end
    local lethalTime
    local nonLethalTime
    local lethalTimeAssa
    local nonLethalTimeAssa

    for _, spellID in pairs(lethalIDs) do
        local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
        if aura then
            if not lethalTime then
                lethalTime = aura.expirationTime - GetTime()
            else
                lethalTimeAssa = aura.expirationTime - GetTime()
            end
        end
    end
    for _, spellID in pairs(nonLethalIDs) do
        local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
        if aura then
            if not nonLethalTime then
                nonLethalTime = aura.expirationTime - GetTime()
            else
                nonLethalTimeAssa = aura.expirationTime - GetTime()
            end
        end
    end

    return lethalTime, nonLethalTime, lethalTimeAssa, nonLethalTimeAssa
end

function RoguePoisons:PoisonCast(spellID)
    local lethalTime, nonLethalTime, lethalTimeAssa, nonLethalTimeAssa = self:CheckPoisons()
    if lethalIDs[spellID] then
        if lethalTimer then
            lethalTimer:Cancel()
        end
        lethalTimer = C_Timer.NewTimer(lethalTime - 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning,
            function() self:Update() end)
        if lethalTimeAssa then
            if lethalTimerAssa then
                lethalTimerAssa:Cancel()
            end
            lethalTimerAssa = C_Timer.NewTimer(
                lethalTimeAssa - 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning,
                function() self:Update() end)
        end
    elseif nonLethalIDs[spellID] then
        if nonLethalTimer then
            nonLethalTimer:Cancel()
        end
        nonLethalTimer = C_Timer.NewTimer(nonLethalTime - 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning,
            function() self:Update() end)
        if nonLethalTimeAssa then
            if nonLethalTimerAssa then
                nonLethalTimerAssa:Cancel()
            end
            nonLethalTimerAssa = C_Timer.NewTimer(
                nonLethalTimeAssa - 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning,
                function() self:Update() end)
        end
    else
        return
    end
    self:Update()
end

function RoguePoisons:ToggleFrameLock(value)
    if roguePoisonsFrame then
        roguePoisonsFrame:SetMovable(not value)
        roguePoisonsFrame:EnableMouse(not value)

        if not value then
            framesUnlocked = true
            roguePoisonsFrame:Show()
        else
            framesUnlocked = false
            self:Update()
        end
    end
end
