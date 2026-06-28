local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.ShamanShields = ToastyClassChores.ShamanShields or {}
local ShamanShields = ToastyClassChores.ShamanShields

local shamanShieldsFrame
local frameTexture
local framesUnlocked = false

local preferredShield

local shieldDuration
local shieldTimer

local playerClass
local shamanShieldsDB

function ToastyClassChores:SetShamanShieldsTracking(info, value)
    shamanShieldsDB.tracking = value
    if value then
        self:Print("Enabling Shaman Shield Tracking")
        ShamanShields:Initialize()
    else
        self:Print("Disabling Shaman Shield Tracking")
        if shamanShieldsFrame then
            shamanShieldsFrame:Hide()
        end
        if shieldDuration then
            shieldDuration:Reset()
        end
        if shieldTimer then
            shieldTimer:Cancel()
        end
    end
end

function ToastyClassChores:SetShamanShieldsIconSize(info, value)
    shamanShieldsDB.iconSize = value
    if shamanShieldsFrame then
        shamanShieldsFrame:SetSize(value, value)
    end
end

function ToastyClassChores:SetShamanShieldsOpacity(info, value)
    shamanShieldsDB.opacity = value
    if shamanShieldsFrame then
        shamanShieldsFrame:SetAlpha(value)
    end
end

function ToastyClassChores:SetShamanShieldsEarlyWarning(info, value)
    shamanShieldsDB.earlyWarning = value
    ShamanShields:Update()
end

function ToastyClassChores:SetShamanShieldsEarlyWarningNoCombat(info, value)
    shamanShieldsDB.earlyWarningNoCombat = value
    ShamanShields:Update()
end

function ShamanShields:Initialize()
    shamanShieldsDB = ToastyClassChores.db.profile.shamanShields
    playerClass = ToastyClassChores.cdb.profile.class
    if not (shamanShieldsDB.tracking and playerClass == "SHAMAN") then
        return
    end
    if not shamanShieldsFrame then
        shamanShieldsFrame = CreateFrame("Frame", "Shaman Shield Reminder", UIParent)
        shamanShieldsFrame:SetPoint(shamanShieldsDB.location.frameAnchorPoint, UIParent,
            shamanShieldsDB.location.parentAnchorPoint, shamanShieldsDB.location.xPos, shamanShieldsDB.location.yPos)
        shamanShieldsFrame:SetSize(shamanShieldsDB.iconSize, shamanShieldsDB.iconSize)
        frameTexture = shamanShieldsFrame:CreateTexture(nil, "BACKGROUND")
        frameTexture:SetTexture(136051)
        frameTexture:SetAllPoints()
    end

    shamanShieldsFrame:RegisterForDrag("LeftButton")
    shamanShieldsFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    shamanShieldsFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        shamanShieldsDB.location.frameAnchorPoint, _, shamanShieldsDB.location.parentAnchorPoint, shamanShieldsDB.location.xPos, shamanShieldsDB.location.yPos =
            shamanShieldsFrame:GetPoint()
    end)
    shamanShieldsFrame:SetAlpha(shamanShieldsDB.opacity)
    if not framesUnlocked then
        shamanShieldsFrame:Hide()
    end
    shieldDuration = C_DurationUtil.CreateDuration()
    self:Update()
end

function ShamanShields:Update()
    if not (shamanShieldsDB.tracking and playerClass == "SHAMAN") then
        if shamanShieldsFrame and not framesUnlocked then
            shamanShieldsFrame:Hide()
        end
        return
    end
    if not shamanShieldsFrame then
        self:Initialize()
    end
    if C_SpecializationInfo.GetSpecialization() == 3 then
        preferredShield = 52127 -- Water Shield
        frameTexture:SetTexture(132315)
        frameTexture:SetAllPoints()
    else
        preferredShield = 192106 -- Lightning Shield
        frameTexture:SetTexture(136051)
        frameTexture:SetAllPoints()
    end
    self:CheckDurations() -- Checks the buff to see if the duration has desynced for whatever reason

    local earlyWarningThreshold = 60 * shamanShieldsDB.earlyWarning
    if PlayerIsInCombat() and shamanShieldsDB.earlyWarningNoCombat then
        earlyWarningThreshold = 0
    end
    if shieldDuration:GetRemainingDuration() <= earlyWarningThreshold or shieldDuration:GetRemainingDuration() == nil then
        shamanShieldsFrame:Show()
        return
    else
        if not framesUnlocked then
            shamanShieldsFrame:Hide()
        end
        return
    end
end

function ShamanShields:CheckDurations()
    if not (shamanShieldsDB.tracking and playerClass == "SHAMAN") then
        return
    end
    if C_Secrets.ShouldAurasBeSecret() then
        if not shieldDuration:GetStartTime() then
            shieldDuration:SetTimeFromEnd(GetTime() + ToastyClassChores.cdb.profile.remainingshamanShieldTime)
            if shieldTimer then
                shieldTimer:Cancel()
            end
            if shieldDuration:GetRemainingDuration() - 60 * shamanShieldsDB.earlyWarning > 0 then
                shieldTimer = C_Timer.NewTimer(
                    shieldDuration:GetRemainingDuration() - 60 * shamanShieldsDB.earlyWarning,
                    function() self:Update() end)
            end
        end
    else
        local buffFound = false
        local aura = C_UnitAuras.GetPlayerAuraBySpellID(preferredShield)
        if aura then
            shieldDuration:SetTimeFromEnd(aura.expirationTime, 3600)
            if shieldTimer then
                shieldTimer:Cancel()
            end
            if shieldDuration:GetRemainingDuration() - 60 * shamanShieldsDB.earlyWarning > 0 then
                shieldTimer = C_Timer.NewTimer(
                    shieldDuration:GetRemainingDuration() - 60 * shamanShieldsDB.earlyWarning,
                    function() self:Update() end)
            end
            buffFound = true
        end
        if not buffFound then
            shieldDuration:Reset()
            if shieldTimer then
                shieldTimer:Cancel()
            end
        end
    end
    self:StoreDurations()
end

function ShamanShields:StoreDurations()
    if not (shamanShieldsDB.tracking and playerClass == "SHAMAN") then
        return
    end
    if shieldDuration then
        ToastyClassChores.cdb.profile.remainingShamanShieldTime = shieldDuration:GetRemainingDuration()
    else
        ToastyClassChores.cdb.profile.remainingShamanShieldTime = nil
    end
end

function ShamanShields:ShieldCast(spellID)
    if not (shamanShieldsDB.tracking and playerClass == "SHAMAN") then
        return
    end
    if spellID == preferredShield then
        shieldDuration:SetTimeFromEnd(GetTime() + 3600, 3600)
        if shieldTimer then
            shieldTimer:Cancel()
        end
        shieldTimer = C_Timer.NewTimer(3600 - 60 * shamanShieldsDB.earlyWarning,
            function() self:Update() end)
    end
    self:Update()
end

function ShamanShields:ToggleFrameLock(value)
    if shamanShieldsFrame then
        shamanShieldsFrame:SetMovable(not value)
        shamanShieldsFrame:EnableMouse(not value)

        if not value then
            framesUnlocked = true
            shamanShieldsFrame:Show()
        else
            framesUnlocked = false
            self:Update()
        end
    end
end
