local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.RoguePoisons = ToastyClassChores.RoguePoisons or {}
local RoguePoisons = ToastyClassChores.RoguePoisons

local roguePoisonsFrame
local frameTexture
local framesUnlocked = false

local lethalAuraInstanceID
local nonLethalAuraInstanceID
local lethalAuraInstanceIDAssa
local nonLethalAuraInstanceIDAssa

local lethalDuration
local nonLethalDuration
local lethalDurationAssa
local nonLethalDurationAssa

local lethalTimer
local nonLethalTimer
local lethalTimerAssa
local nonLethalTimerAssa

local playerClass

local lethalIDs = {
    [8679] = 8679,
    [315584] = 315584,
    [381664] = 381664,
    [2823] = 2823,
}

local nonLethalIDs = {
    [5761] = 5761,
    [3408] = 3408,
    [381637] = 381637,
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
    self:CreateDurations()
    self:Update()
end

function RoguePoisons:Update()
    if not (ToastyClassChores.db.profile.roguePoisonsTracking and playerClass == "ROGUE") then
        return
    end
    if not roguePoisonsFrame then
        self:Initialize()
    end

    self:CheckDurations()

    ToastyClassChores:Debug(lethalDuration:GetRemainingDuration())
    ToastyClassChores:Debug(nonLethalDuration:GetRemainingDuration())
    if lethalDurationAssa then
        ToastyClassChores:Debug(lethalDurationAssa:GetRemainingDuration())
    end
    if nonLethalDurationAssa then
        ToastyClassChores:Debug(nonLethalDurationAssa:GetRemainingDuration())
    end

    if C_SpecializationInfo.GetSpecialization() == 1 then
        if lethalDuration:GetRemainingDuration() <= 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning or nonLethalDuration:GetRemainingDuration() <= 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning or lethalDurationAssa:GetRemainingDuration() <= 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning or nonLethalDurationAssa:GetRemainingDuration() <= 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning or lethalDuration:GetRemainingDuration() == nil or nonLethalDuration:GetRemainingDuration() == nil or lethalDurationAssa:GetRemainingDuration() == nil or nonLethalDurationAssa:GetRemainingDuration() == nil then
            roguePoisonsFrame:Show()
            return
        else
            roguePoisonsFrame:Hide()
            return
        end
    else
        if lethalDuration:GetRemainingDuration() <= 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning or nonLethalDuration:GetRemainingDuration() <= 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning or lethalDuration:GetRemainingDuration() == nil or nonLethalDuration:GetRemainingDuration() == nil then
            roguePoisonsFrame:Show()
            return
        else
            roguePoisonsFrame:Hide()
            return
        end
    end
end

function RoguePoisons:PoisonCast(spellID)
    if not (ToastyClassChores.db.profile.roguePoisonsTracking and playerClass == "ROGUE") then
        return
    end
    if not lethalIDs[spellID] and not nonLethalIDs[spellID] then
        return
    end
    if GetSpecialization ~= 1 then
        if lethalIDs[spellID] then
            lethalDuration:SetTimeFromEnd(GetTime() + 3600, 3600)
            if lethalTimer then
                lethalTimer:Cancel()
            end
            lethalTimer = C_Timer.NewTimer(3600 - 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning,
                function() RoguePoisons:Update() end)
        elseif nonLethalIDs[spellID] then
            nonLethalDuration:SetTimeFromEnd(GetTime() + 3600, 3600)
            if nonLethalTimer then
                nonLethalTimer:Cancel()
            end
            nonLethalTimer = C_Timer.NewTimer(3600 - 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning,
                function() RoguePoisons:Update() end)
        end
    else
        if lethalIDs[spellID] then
            if lethalDuration:GetEndTime() < lethalDurationAssa:GetEndTime() then
                lethalDuration:SetTimeFromEnd(GetTime() + 3600, 3600)
                if lethalTimer then
                    lethalTimer:Cancel()
                end
                lethalTimer = C_Timer.NewTimer(3600 - 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning,
                    function() RoguePoisons:Update() end)
            else
                lethalDurationAssa:SetTimeFromEnd(GetTime() + 3600, 3600)
                if lethalTimerAssa then
                    lethalTimerAssa:Cancel()
                end
                lethalTimerAssa = C_Timer.NewTimer(3600 - 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning,
                    function() RoguePoisons:Update() end)
            end
        elseif nonLethalIDs[spellID] then
            if nonLethalDuration:GetEndTime() < nonLethalDurationAssa:GetEndTime() then
                nonLethalDuration:SetTimeFromEnd(GetTime() + 3600, 3600)
                if nonLethalTimer then
                    nonLethalTimer:Cancel()
                end
                nonLethalTimer = C_Timer.NewTimer(3600 - 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning,
                    function() RoguePoisons:Update() end)
            else
                nonLethalDurationAssa:SetTimeFromEnd(GetTime() + 3600, 3600)
                if nonLethalTimerAssa then
                    nonLethalTimerAssa:Cancel()
                end
                nonLethalTimerAssa = C_Timer.NewTimer(3600 - 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning,
                    function() RoguePoisons:Update() end)
            end
        end
    end
    self:Update()
end

function RoguePoisons:CreateDurations()
    if not (ToastyClassChores.db.profile.roguePoisonsTracking and playerClass == "ROGUE") then
        return
    end
    if GetSpecialization() ~= 1 then
        lethalDuration = C_DurationUtil.CreateDuration()
        nonLethalDuration = C_DurationUtil.CreateDuration()
        lethalDurationAssa = nil
        nonLethalDurationAssa = nil
    else
        lethalDuration = C_DurationUtil.CreateDuration()
        nonLethalDuration = C_DurationUtil.CreateDuration()
        lethalDurationAssa = C_DurationUtil.CreateDuration()
        nonLethalDurationAssa = C_DurationUtil.CreateDuration()
    end
    self:CheckDurations()
end

function RoguePoisons:CheckDurations()
    if not (ToastyClassChores.db.profile.roguePoisonsTracking and playerClass == "ROGUE") then
        return
    end
    if C_Secrets.ShouldAurasBeSecret() then
        ToastyClassChores:Debug("Secrets active")
        if not lethalDuration:GetStartTime() then
            lethalDuration:SetTimeFromEnd(GetTime() + ToastyClassChores.cdb.profile.remainingLethalPoisonTime, 3600)
            if lethalTimer then
                lethalTimer:Cancel()
            end
            if lethalDuration:GetRemainingDuration() - 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning > 0 then
                lethalTimer = C_Timer.NewTimer(
                    lethalDuration:GetRemainingDuration() - 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning,
                    function() RoguePoisons:Update() end)
            end
        end
        if not nonLethalDuration:GetStartTime() then
            nonLethalDuration:SetTimeFromEnd(GetTime() + ToastyClassChores.cdb.profile.remainingNonLethalPoisonTime, 3600)
            if nonLethalTimer then
                nonLethalTimer:Cancel()
            end
            if nonLethalDuration:GetRemainingDuration() - 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning > 0 then
                nonLethalTimer = C_Timer.NewTimer(
                    nonLethalDuration:GetRemainingDuration() - 60 * ToastyClassChores.db.profile
                    .roguePoisonsEarlyWarning,
                    function() RoguePoisons:Update() end)
            end
        end
        if lethalDurationAssa then
            if not lethalDurationAssa:GetStartTime() then
                lethalDurationAssa:SetTimeFromEnd(
                    GetTime() + ToastyClassChores.cdb.profile.remainingLethalPoisonTimeAssa, 3600)
                if lethalTimerAssa then
                    lethalTimerAssa:Cancel()
                end
                if lethalDurationAssa:GetRemainingDuration() - 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning > 0 then
                    lethalTimerAssa = C_Timer.NewTimer(
                        lethalDurationAssa:GetRemainingDuration() -
                        60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning,
                        function() RoguePoisons:Update() end)
                end
            end
        end
        if nonLethalDurationAssa then
            if not nonLethalDurationAssa:GetStartTime() then
                nonLethalDurationAssa:SetTimeFromEnd(
                    GetTime() + ToastyClassChores.cdb.profile.remainingNonLethalPoisonTimeAssa, 3600)
                if nonLethalTimerAssa then
                    nonLethalTimerAssa:Cancel()
                end
                if nonLethalDurationAssa:GetRemainingDuration() - 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning > 0 then
                    nonLethalTimerAssa = C_Timer.NewTimer(
                        nonLethalDurationAssa:GetRemainingDuration() -
                        60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning,
                        function() RoguePoisons:Update() end)
                end
            end
        end
    else
        local firstPoisonFound = false
        local secondPoisonFound = false
        for _, spellID in pairs(nonLethalIDs) do
            local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
            if aura then
                if firstPoisonFound then
                    nonLethalDurationAssa:SetTimeFromEnd(aura.expirationTime, 3600)
                    if nonLethalTimerAssa then
                        nonLethalTimerAssa:Cancel()
                    end
                    if nonLethalDurationAssa:GetRemainingDuration() - 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning > 0 then
                        nonLethalTimerAssa = C_Timer.NewTimer(
                            nonLethalDurationAssa:GetRemainingDuration() -
                            60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning,
                            function() RoguePoisons:Update() end)
                    end
                    secondPoisonFound = true
                else
                    nonLethalDuration:SetTimeFromEnd(aura.expirationTime, 3600)
                    if nonLethalTimer then
                        nonLethalTimer:Cancel()
                    end
                    if nonLethalDuration:GetRemainingDuration() - 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning > 0 then
                        nonLethalTimer = C_Timer.NewTimer(
                            nonLethalDuration:GetRemainingDuration() - 60 * ToastyClassChores.db.profile
                            .roguePoisonsEarlyWarning,
                            function() RoguePoisons:Update() end)
                    end
                    firstPoisonFound = true
                end
            end
        end
        if not firstPoisonFound then
            nonLethalDuration:Reset()
            if nonLethalTimer then
                nonLethalTimer:Cancel()
            end
        end
        if not secondPoisonFound and nonLethalDurationAssa then
            nonLethalDurationAssa:Reset()
            if nonLethalTimerAssa then
                nonLethalTimerAssa:Cancel()
            end
        end
        firstPoisonFound = false
        secondPoisonFound = false
        for _, spellID in pairs(lethalIDs) do
            local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
            if aura then
                if firstPoisonFound then
                    lethalDurationAssa:SetTimeFromEnd(aura.expirationTime, 3600)
                    if lethalTimerAssa then
                        lethalTimerAssa:Cancel()
                    end
                    if lethalDurationAssa:GetRemainingDuration() - 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning > 0 then
                        lethalTimerAssa = C_Timer.NewTimer(
                            lethalDurationAssa:GetRemainingDuration() -
                            60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning,
                            function() RoguePoisons:Update() end)
                    end
                    secondPoisonFound = true
                else
                    lethalDuration:SetTimeFromEnd(aura.expirationTime, 3600)
                    if lethalTimer then
                        lethalTimer:Cancel()
                    end
                    if lethalDuration:GetRemainingDuration() - 60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning > 0 then
                        lethalTimer = C_Timer.NewTimer(
                            lethalDuration:GetRemainingDuration() -
                            60 * ToastyClassChores.db.profile.roguePoisonsEarlyWarning,
                            function() RoguePoisons:Update() end)
                    end
                    firstPoisonFound = true
                end
            end
        end
        if not firstPoisonFound then
            lethalDuration:Reset()
            if lethalTimer then
                lethalTimer:Cancel()
            end
        end
        if not secondPoisonFound and lethalDurationAssa then
            lethalDurationAssa:Reset()
            if lethalTimerAssa then
                lethalTimerAssa:Cancel()
            end
        end
        self:StoreDurations()
    end
end

function RoguePoisons:StoreDurations()
    if not (ToastyClassChores.db.profile.roguePoisonsTracking and playerClass == "ROGUE") then
        return
    end
    if lethalDuration then
        ToastyClassChores.cdb.profile.remainingLethalPoisonTime = lethalDuration:GetRemainingDuration()
    else
        ToastyClassChores.cdb.profile.remainingLethalPoisonTime = nil
    end
    if nonLethalDuration then
        ToastyClassChores.cdb.profile.remainingNonLethalPoisonTime = nonLethalDuration:GetRemainingDuration()
    else
        ToastyClassChores.cdb.profile.remainingNonLethalPoisonTime = nil
    end
    if lethalDurationAssa then
        ToastyClassChores.cdb.profile.remainingLethalPoisonTimeAssa = lethalDurationAssa:GetRemainingDuration()
    else
        ToastyClassChores.cdb.profile.remainingLethalPoisonTimeAssa = nil
    end
    if nonLethalDurationAssa then
        ToastyClassChores.cdb.profile.remainingNonLethalPoisonTimeAssa = nonLethalDurationAssa:GetRemainingDuration()
    else
        ToastyClassChores.cdb.profile.remainingNonLethalPoisonTimeAssa = nil
    end
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
