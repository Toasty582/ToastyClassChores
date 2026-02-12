local ADDON_NAME, ns = ...
local ToastyClassChores = ns.Addon

ToastyClassChores.RaidBuffs = ToastyClassChores.RaidBuffs or {}
local RaidBuffs = ToastyClassChores.RaidBuffs

local raidBuffsFrame

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
        RaidBuffs:Initialize()
    else
        self:Print("Disabling Raid Buff Tracking")
        if raidBuffsFrame then
            raidBuffsFrame:SetAlpha(0)
        end
    end
end

function RaidBuffs:Initialize()
    if not (ToastyClassChores.db.profile.raidBuffTracking and raidBuffIconList[ToastyClassChores.cdb.profile.class]) then
        return
    end
    raidBuffsFrame = CreateFrame("Frame", "Raid Buffs Reminder", ToastyClassChores.choreFrame)
    raidBuffsFrame:SetPoint("CENTER")
    raidBuffsFrame:SetSize(100, 100)
    ToastyClassChores.raidBuffsFrame = raidBuffsFrame
    local frameTexture = raidBuffsFrame:CreateTexture(nil, "BACKGROUND")
    frameTexture:SetTexture(raidBuffIconList[ToastyClassChores.cdb.profile.class])
    frameTexture:SetAllPoints()
    raidBuffsFrame:SetAlpha(0)
end

function RaidBuffs:GlowShow(spellID)
    if not (ToastyClassChores.db.profile.raidBuffTracking and raidBuffIconList[ToastyClassChores.cdb.profile.class]) then
        return
    end
    if not raidBuffsFrame then
        self:Initialize()
    end
    if raidBuffClassList[spellID] == ToastyClassChores.cdb.profile.class then
        raidBuffsFrame:SetAlpha(0.5)
    end
end

function RaidBuffs:GlowHide(spellID)
    if not (ToastyClassChores.db.profile.raidBuffTracking and raidBuffIconList[ToastyClassChores.cdb.profile.class]) then
        return
    end
    if not raidBuffsFrame then
        self:Initialize()
    end
    if raidBuffClassList[spellID] == ToastyClassChores.cdb.profile.class then
        raidBuffsFrame:SetAlpha(0)
    end
end
