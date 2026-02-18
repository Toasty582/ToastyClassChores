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
        if lethalDuration:GetRemainingDuration() == 0 or nonLethalDuration:GetRemainingDuration() == 0 or lethalDurationAssa:GetRemainingDuration() == 0 or nonLethalDurationAssa:GetRemainingDuration() == 0 or lethalDuration:GetRemainingDuration() == nil or nonLethalDuration:GetRemainingDuration() == nil or lethalDurationAssa:GetRemainingDuration() == nil or nonLethalDurationAssa:GetRemainingDuration() == nil then
            roguePoisonsFrame:Show()
            return
        else
            roguePoisonsFrame:Hide()
            return
        end
    else
        if lethalDuration:GetRemainingDuration() == 0 or nonLethalDuration:GetRemainingDuration() == 0 or lethalDuration:GetRemainingDuration() == nil or nonLethalDuration:GetRemainingDuration() == nil then
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
        elseif nonLethalIDs[spellID] then
            nonLethalDuration:SetTimeFromEnd(GetTime() + 3600, 3600)
        end
    else
        if lethalIDs[spellID] then
            if lethalDuration:GetEndTime() < lethalDurationAssa:GetEndTime() then
                lethalDuration:SetTimeFromEnd(GetTime() + 3600, 3600)
            else
                lethalDurationAssa:SetTimeFromEnd(GetTime() + 3600, 3600)
            end
        elseif nonLethalIDs[spellID] then
            if nonLethalDuration:GetEndTime() < nonLethalDurationAssa:GetEndTime() then
                nonLethalDuration:SetTimeFromEnd(GetTime() + 3600, 3600)
            else
                nonLethalDurationAssa:SetTimeFromEnd(GetTime() + 3600, 3600)
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
        end
        if not nonLethalDuration:GetStartTime() then
            nonLethalDuration:SetTimeFromEnd(GetTime() + ToastyClassChores.cdb.profile.remainingNonLethalPoisonTime, 3600)
        end
        if lethalDurationAssa then
            if not lethalDurationAssa:GetStartTime() then
                lethalDurationAssa:SetTimeFromEnd(GetTime() + ToastyClassChores.cdb.profile.remainingLethalPoisonTimeAssa, 3600)
            end
        end
        if nonLethalDurationAssa then
            if not nonLethalDurationAssa:GetStartTime() then
                nonLethalDurationAssa:SetTimeFromEnd(GetTime() + ToastyClassChores.cdb.profile.remainingNOnLethalPoisonTimeAssa, 3600)
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
                    secondPoisonFound = true
                else
                    nonLethalDuration:SetTimeFromEnd(aura.expirationTime, 3600)
                    firstPoisonFound = true
                end
            end
        end
        if not firstPoisonFound then
            nonLethalDuration:Reset()
        end
        if not secondPoisonFound and nonLethalDurationAssa then
            nonLethalDurationAssa:Reset()
        end
        firstPoisonFound = false
        secondPoisonFound = false
        for _, spellID in pairs(lethalIDs) do
            local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
            if aura then
                if firstPoisonFound then
                    lethalDurationAssa:SetTimeFromEnd(aura.expirationTime, 3600)
                    secondPoisonFound = true
                else
                    lethalDuration:SetTimeFromEnd(aura.expirationTime, 3600)
                    firstPoisonFound = true
                end
            end
        end
        if not firstPoisonFound then
            lethalDuration:Reset()
        end
        if not secondPoisonFound and lethalDurationAssa then
            lethalDurationAssa:Reset()
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
