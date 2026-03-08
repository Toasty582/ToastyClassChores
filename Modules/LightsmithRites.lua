local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.LightsmithRites = ToastyClassChores.LightsmithRites or {}
local LightsmithRites = ToastyClassChores.LightsmithRites

local lightsmithRitesFrame
local frameTexture
local framesUnlocked = false

local riteDuration
local riteTimer

local riteSpellIDs = {
    [433583] = 433583, -- Adjuration
    [433568] = 433568, -- Sanctification
}

local riteAuraIDs = {
    [433584] = 433584, -- Adjuration
    [433550] = 433550, -- Sanctification
}

function ToastyClassChores:SetLightsmithRitesTracking(info, value)
    self.db.profile.lightsmithRitesTracking = value
    if value then
        self:Print("Enabling Lightsmith Rite Tracking")
        LightsmithRites:Initialize()
    else
        self:Print("Disabling Lightsmith Rite Tracking")
        if lightsmithRitesFrame then
            lightsmithRitesFrame:Hide()
        end
    end
end

function ToastyClassChores:SetLightsmithRitesIconSize(info, value)
    self.db.profile.lightsmithRitesIconSize = value
    if lightsmithRitesFrame then
        lightsmithRitesFrame:SetSize(value, value)
    end
end

function ToastyClassChores:SetLightsmithRitesOpacity(info, value)
    self.db.profile.lightsmithRitesOpacity = value
    if lightsmithRitesFrame then
        lightsmithRitesFrame:SetAlpha(value)
    end
end

function ToastyClassChores:SetLightsmithRitesEarlyWarning(info, value)
    self.db.profile.lightsmithRitesEarlyWarning = value
    LightsmithRites:Update()
end

function ToastyClassChores:SetLightsmithRitesEarlyWarningNoCombat(info, value)
    self.db.profile.lightsmithRitesEarlyWarningNoCombat = value
    LightsmithRites:Update()
end

function LightsmithRites:Initialize()
    if not (ToastyClassChores.db.profile.lightsmithRitesTracking and C_ClassTalents.GetActiveHeroTalentSpec() == 49) then
        return
    end
    if not lightsmithRitesFrame then
        lightsmithRitesFrame = CreateFrame("Frame", "Lightsmith Rites Reminder", UIParent)
        lightsmithRitesFrame:SetPoint(ToastyClassChores.db.profile.lightsmithRitesLocation.frameAnchorPoint, UIParent,
            ToastyClassChores.db.profile.lightsmithRitesLocation.parentAnchorPoint,
            ToastyClassChores.db.profile.lightsmithRitesLocation.xPos,
            ToastyClassChores.db.profile.lightsmithRitesLocation.yPos)
        lightsmithRitesFrame:SetSize(ToastyClassChores.db.profile.lightsmithRitesIconSize,
            ToastyClassChores.db.profile.lightsmithRitesIconSize)
        frameTexture = lightsmithRitesFrame:CreateTexture(nil, "BACKGROUND")
        frameTexture:SetTexture(237172) -- Defaults to Sanctification icon
        frameTexture:SetAllPoints()
    end

    lightsmithRitesFrame:RegisterForDrag("LeftButton")
    lightsmithRitesFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    lightsmithRitesFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        ToastyClassChores.db.profile.lightsmithRitesLocation.frameAnchorPoint, _, ToastyClassChores.db.profile.lightsmithRitesLocation.parentAnchorPoint, ToastyClassChores.db.profile.lightsmithRitesLocation.xPos, ToastyClassChores.db.profile.lightsmithRitesLocation.yPos =
            lightsmithRitesFrame:GetPoint()
    end)
    lightsmithRitesFrame:SetAlpha(ToastyClassChores.db.profile.lightsmithRitesOpacity)
    if not framesUnlocked then
        lightsmithRitesFrame:Hide()
    end
    self:CreateDurations()
    self:Update()
end

function LightsmithRites:Update()
    if not (ToastyClassChores.db.profile.lightsmithRitesTracking and C_ClassTalents.GetActiveHeroTalentSpec() == 49) then
        if lightsmithRitesFrame and not framesUnlocked then
            lightsmithRitesFrame:Hide()
        end
        return
    end
    if not lightsmithRitesFrame then
        self:Initialize()
    end
    self:CheckDurations()

    local earlyWarningThreshold = 60 * ToastyClassChores.db.profile.lightsmithRitesEarlyWarning
    if PlayerIsInCombat() and ToastyClassChores.db.profile.lightsmithRitesEarlyWarningNoCombat then
        earlyWarningThreshold = 0
    end
    if riteDuration:GetRemainingDuration() <= earlyWarningThreshold or riteDuration:GetRemainingDuration() == nil then
        lightsmithRitesFrame:Show()
        return
    else
        if not framesUnlocked then
            lightsmithRitesFrame:Hide()
        end
        return
    end

    -- Blizz desecreted the wrong spellID lmao
    --[[
    local riteTime = self:CheckRites()

    local earlyWarningThreshold = 60 * ToastyClassChores.db.profile.lightsmithRitesEarlyWarning
    if PlayerIsInCombat() and ToastyClassChores.db.profile.lightsmithRitesEarlyWarningNoCombat then
        earlyWarningThreshold = 0
    end

    if riteTime == nil then
        lightsmithRitesFrame:Show()
        return
    end
    if riteTime <= earlyWarningThreshold then
        lightsmithRitesFrame:Show()
        return
    else
        if not framesUnlocked then
            lightsmithRitesFrame:Hide()
            return
        end
    end
    ]]
end

function LightsmithRites:CreateDurations()
    if not (ToastyClassChores.db.profile.lightsmithRitesTracking and C_ClassTalents.GetActiveHeroTalentSpec() == 49) then
        return
    end
    riteDuration = C_DurationUtil.CreateDuration()
end

function LightsmithRites:CheckDurations()
    if not (ToastyClassChores.db.profile.lightsmithRitesTracking and C_ClassTalents.GetActiveHeroTalentSpec() == 49) then
        return
    end
    if C_Secrets.ShouldAurasBeSecret() then
        if not riteDuration:GetStartTime() then
            riteDuration:SetTimeFromEnd(GetTime() + ToastyClassChores.cdb.profile.remainingLightsmithRiteTime)
            if riteTimer then
                riteTimer:Cancel()
            end
            if riteDuration:GetRemainingDuration() - 60 * ToastyClassChores.db.profile.lightsmithRitesEarlyWarning > 0 then
                riteTimer = C_Timer.NewTimer(
                    riteDuration:GetRemainingDuration() - 60 * ToastyClassChores.db.profile.lightsmithRitesEarlyWarning,
                    function() self:Update() end)
            end
        end
    else
        local buffFound = false
        for _, spellID in pairs(riteAuraIDs) do
            local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
            if aura then
                riteDuration:SetTimeFromEnd(aura.expirationTime, 3600)
                if riteTimer then
                    riteTimer:Cancel()
                end
                if riteDuration:GetRemainingDuration() - 60 * ToastyClassChores.db.profile.lightsmithRitesEarlyWarning > 0 then
                    riteTimer = C_Timer.NewTimer(
                        riteDuration:GetRemainingDuration() -
                        60 * ToastyClassChores.db.profile.lightsmithRitesEarlyWarning,
                        function() self:Update() end)
                end
                buffFound = true
            end
            if not buffFound then
                riteDuration:Reset()
            end
        end
    end
    self:StoreDurations()
end

function LightsmithRites:StoreDurations()
    if not (ToastyClassChores.db.profile.lightsmithRitesTracking and C_ClassTalents.GetActiveHeroTalentSpec() == 49) then
        return
    end
    if riteDuration then
        ToastyClassChores.cdb.profile.remainingLightsmithRiteTime = riteDuration:GetRemainingDuration()
    else
        ToastyClassChores.cdb.profile.remainingLightsmithRiteTime = nil
    end
end

-- Blizzard desecreted the wrong fucking spellID lmfao
--[[
function LightsmithRites:CheckRites()
    if not (ToastyClassChores.db.profile.lightsmithRitesTracking and C_ClassTalents.GetActiveHeroTalentSpec() == 49) then
        return nil
    end
    local riteTime

    for _, spellID in pairs(riteAuraIDs) do
        local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
        if aura then
            riteTime = aura.expirationTime - GetTime()
        end
    end

    return riteTime
end]]

function LightsmithRites:RiteCast(spellID)
    --local riteTime = self:CheckRites()
    if riteSpellIDs[spellID] then
        riteDuration:SetTimeFromEnd(GetTime() + 3600, 3600)
        if riteTimer then
            riteTimer:Cancel()
        end
        riteTimer = C_Timer.NewTimer(3600 - 60 * ToastyClassChores.db.profile.lightsmithRitesEarlyWarning,
            function() self:Update() end)
    else
        return
    end
    self:Update()
end

function LightsmithRites:ToggleFrameLock(value)
    if lightsmithRitesFrame then
        lightsmithRitesFrame:SetMovable(not value)
        lightsmithRitesFrame:EnableMouse(not value)

        if not value then
            framesUnlocked = true
            lightsmithRitesFrame:Show()
        else
            framesUnlocked = false
            self:Update()
        end
    end
end
