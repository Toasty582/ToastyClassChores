local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.RoguePoisons = ToastyClassChores.RoguePoisons or {}
local RoguePoisons = ToastyClassChores.RoguePoisons

local roguePoisonsFrame
local frameTexture
local framesUnlocked = false

local playerClass
local doublePoison

local roguePoisonsDB

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
    roguePoisonsDB.tracking = value
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
    roguePoisonsDB.iconSize = value
    if roguePoisonsFrame then
        roguePoisonsFrame:SetSize(value, value)
    end
end

function ToastyClassChores:SetRoguePoisonsOpacity(info, value)
    roguePoisonsDB.opacity = value
    if roguePoisonsFrame then
        roguePoisonsFrame:SetAlpha(value)
    end
end

function ToastyClassChores:SetRoguePoisonsEarlyWarning(info, value)
    roguePoisonsDB.earlyWarning = value
    RoguePoisons:Update()
end

function ToastyClassChores:SetRoguePoisonsEarlyWarningNoCombat(info, value)
    roguePoisonsDB.earlyWarningNoCombat = value
    RoguePoisons:Update()
end

function RoguePoisons:Initialize()
    roguePoisonsDB = ToastyClassChores.db.profile.roguePoisons
    playerClass = ToastyClassChores.cdb.profile.class
    if not (roguePoisonsDB.tracking and playerClass == "ROGUE") then
        return
    end
    if not roguePoisonsFrame then
        roguePoisonsFrame = CreateFrame("Frame", "Rogue Poisons Reminder", UIParent)
        roguePoisonsFrame:SetPoint(roguePoisonsDB.location.frameAnchorPoint, UIParent,
            roguePoisonsDB.location.parentAnchorPoint, roguePoisonsDB.location.xPos, roguePoisonsDB.location.yPos)
        roguePoisonsFrame:SetSize(roguePoisonsDB.iconSize, roguePoisonsDB.iconSize)
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
        roguePoisonsDB.location.frameAnchorPoint, _, roguePoisonsDB.location.parentAnchorPoint, roguePoisonsDB.location.xPos, roguePoisonsDB.location.yPos =
            roguePoisonsFrame:GetPoint()
    end)
    roguePoisonsFrame:SetAlpha(roguePoisonsDB.opacity)
    if not framesUnlocked then
        roguePoisonsFrame:Hide()
    end
    self:CheckDoublePoison()
    self:Update()
end

function RoguePoisons:Update()
    if not (roguePoisonsDB.tracking and playerClass == "ROGUE") then
        if roguePoisonsFrame and not framesUnlocked then
            roguePoisonsFrame:Hide()
        end
        return
    end
    if not roguePoisonsFrame then
        self:Initialize()
    end

    local lethalTime, nonLethalTime, lethalTimeAssa, nonLethalTimeAssa = self:CheckPoisons()

    local earlyWarningThreshold = 60 * roguePoisonsDB.earlyWarning
    if PlayerIsInCombat() and roguePoisonsDB.earlyWarningNoCombat then
        earlyWarningThreshold = 0
    end

    if (C_SpecializationInfo.GetSpecialization() == 1) and doublePoison then
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
    if not (roguePoisonsDB.tracking and playerClass == "ROGUE") then
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

function RoguePoisons:CheckDoublePoison()
    if C_SpecializationInfo.GetSpecialization() == 1 then
        doublePoison = C_SpellBook.IsSpellKnown(381801)
    else
        doublePoison = false
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
