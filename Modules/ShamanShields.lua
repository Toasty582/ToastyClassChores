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

function ToastyClassChores:SetShamanShieldsTracking(info, value)
    self.db.profile.shamanShieldsTracking = value
    if value then
        self:Print("Enabling Shaman Shield Tracking")
        ShamanShields:Initialize()
    else
        self:Print("Disabling Shaman Shield Tracking")
        if shamanShieldsFrame then
            shamanShieldsFrame:Hide()
        end
    end
end

function ToastyClassChores:SetShamanShieldsIconSize(info, value)
    self.db.profile.shamanShieldsIconSize = value
    if shamanShieldsFrame then
        shamanShieldsFrame:SetSize(value, value)
    end
end

function ToastyClassChores:SetShamanShieldsOpacity(info, value)
    self.db.profile.shamanShieldsOpacity = value
    if shamanShieldsFrame then
        shamanShieldsFrame:SetAlpha(value)
    end
end

function ToastyClassChores:SetShamanShieldsEarlyWarning(info, value)
    self.db.profile.shamanShieldsEarlyWarning = value
    ShamanShields:Update()
end

function ShamanShields:Initialize()
    playerClass = ToastyClassChores.cdb.profile.class
    if not (ToastyClassChores.db.profile.shamanShieldsTracking and playerClass == "SHAMAN") then
        return
    end
    if not shamanShieldsFrame then
        shamanShieldsFrame = CreateFrame("Frame", "Shaman Shield Reminder", UIParent)
        shamanShieldsFrame:SetPoint(ToastyClassChores.db.profile.shamanShieldsLocation.frameAnchorPoint, UIParent,
            ToastyClassChores.db.profile.shamanShieldsLocation.parentAnchorPoint,
            ToastyClassChores.db.profile.shamanShieldsLocation.xPos,
            ToastyClassChores.db.profile.shamanShieldsLocation.yPos)
        shamanShieldsFrame:SetSize(ToastyClassChores.db.profile.shamanShieldsIconSize,
            ToastyClassChores.db.profile.shamanShieldsIconSize)
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
        ToastyClassChores.db.profile.shamanShieldsLocation.frameAnchorPoint, _, ToastyClassChores.db.profile.shamanShieldsLocation.parentAnchorPoint, ToastyClassChores.db.profile.shamanShieldsLocation.xPos, ToastyClassChores.db.profile.shamanShieldsLocation.yPos =
            shamanShieldsFrame:GetPoint()
    end)
    shamanShieldsFrame:SetAlpha(ToastyClassChores.db.profile.shamanShieldsOpacity)
    if not framesUnlocked then
        shamanShieldsFrame:Hide()
    end
    self:CreateDurations()
    self:Update()
end

function ShamanShields:Update()
    if not (ToastyClassChores.db.profile.shamanShieldsTracking and playerClass == "SHAMAN") then
        return
    end
    if not shamanShieldsFrame then
        self:Initialize()
    end
    self:CheckDurations()
    if shieldDuration:GetRemainingDuration() <= 60 * ToastyClassChores.db.profile.shamanShieldsEarlyWarning or shieldDuration:GetRemainingDuration() == nil then
        shamanShieldsFrame:Show()
        return
    else
        if not framesUnlocked then
            shamanShieldsFrame:Hide()
        end
        return
    end
end

function ShamanShields:CreateDurations()
    if not (ToastyClassChores.db.profile.shamanShieldsTracking and playerClass == "SHAMAN") then
        return
    end
    shieldDuration = C_DurationUtil.CreateDuration()
end

function ShamanShields:CheckDurations()
    if not (ToastyClassChores.db.profile.shamanShieldsTracking and playerClass == "SHAMAN") then
        return
    end
    if C_SpecializationInfo.GetSpecialization() == 3 then
        preferredShield = 52127
        frameTexture:SetTexture(132315)
        frameTexture:SetAllPoints()
    else
        preferredShield = 192106
        frameTexture:SetTexture(136051)
        frameTexture:SetAllPoints()
    end
    if C_Secrets.ShouldAurasBeSecret() then
        if not shieldDuration:GetStartTime() then
            shieldDuration:SetTimeFromEnd(GetTime() + ToastyClassChores.cdb.profile.remainingshamanShieldTime)
            if shieldTimer then
                shieldTimer:Cancel()
            end
            if shieldDuration:GetRemainingDuration() - 60 * ToastyClassChores.db.profile.shamanShieldsEarlyWarning > 0 then
                shieldTimer = C_Timer.NewTimer(
                    shieldDuration:GetRemainingDuration() - 60 * ToastyClassChores.db.profile.shamanShieldsEarlyWarning,
                    function() ShamanShields:Update() end)
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
            if shieldDuration:GetRemainingDuration() - 60 * ToastyClassChores.db.profile.shamanShieldsEarlyWarning > 0 then
                shieldTimer = C_Timer.NewTimer(
                    shieldDuration:GetRemainingDuration() - 60 * ToastyClassChores.db.profile.shamanShieldsEarlyWarning,
                    function() ShamanShields:Update() end)
            end
            buffFound = true
        end
        if not buffFound then
            shieldDuration:Reset()
        end
    end
    self:StoreDurations()
end

function ShamanShields:StoreDurations()
    if not (ToastyClassChores.db.profile.shamanShieldsTracking and playerClass == "SHAMAN") then
        return
    end
    if shieldDuration then
        ToastyClassChores.cdb.profile.remainingshamanShieldTime = shieldDuration:GetRemainingDuration()
    else
        ToastyClassChores.cdb.profile.remainingshamanShieldTime = nil
    end
end

function ShamanShields:ShieldCast(spellID)
    if not (ToastyClassChores.db.profile.shamanShieldsTracking and playerClass == "SHAMAN") then
        return
    end
    if spellID == 192106 or spellID == 52127 then
        shieldDuration:SetTimeFromEnd(GetTime() + 3600, 3600)
        if shieldTimer then
            shieldTimer:Cancel()
        end
        shieldTimer = C_Timer.NewTimer(3600 - 60 * ToastyClassChores.db.profile.shamanShieldsEarlyWarning,
            function() ShamanShields:Update() end)
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
