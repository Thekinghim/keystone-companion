local Private = select(2, ...)
local CreateRoundedFrame = Private.widgets.RoundedFrame.CreateFrame
local styles = Private.constants.styles
local customIconMixin = { customMixin = true }
local screenWidth = GetScreenWidth()
local addon = Private.Addon
local loc = addon.Loc

local shortDungeonNames = {
    -- Season 3 Dragonflight Dungeons
    [168] = "EB",   -- The Everbloom
    [198] = "DHT",  -- Darkheart Thicket
    [244] = "AD",   -- Atal'Dazar
    [464] = "RISE", -- Dawn of the Infinite: Murozond's Rise
    [199] = "BRH",  -- Black Rook Hold
    [456] = "TOTT", -- Throne of the Tides
    [463] = "FALL", -- Dawn of the Infinite: Galakrond's Fall
    [248] = "WM",   -- Waycrest Manor

    -- Season 4 Dragonflight Dungeons
    [399] = "RLP",  -- Ruby Life Pools
    [404] = "NELT", -- Neltharus
    [401] = "AV",   -- The Azure Vault
    [402] = "AA",   -- Algeth'ar Academy
    [400] = "NO",   -- The Nokhud Offensive
    [403] = "ULD",  -- Uldaman: Legacy of Tyr
    [406] = "HOI",  -- Halls of Infusion
    [405] = "BH",   -- Brackenhide Hollow
}

--[[
    This function is as backup
    This will auto generate short names
    It will return the last word if the short name is longer than 4 Letters
]]
local function shortenName(name)
    local short = ""
    for letter in name:gmatch("(%a)%a+") do
        short = short .. letter:upper()
    end
    if #short > 4 then
        return name:match("%a+$"):upper()
    end
    return short
end

local function getFont(parent, color, align)
    local font = parent:CreateFontString()
    font:SetFont(styles.FONTS.BOLD, screenWidth > 1920 and 12 or 11, "OUTLINE")
    font:SetJustifyV("MIDDLE")
    font:SetFontObject(styles.FONT_OBJECTS.BOLD)
    font:SetJustifyH(align)
    font:SetTextColor(color:GetRGBA())
    return font
end

function customIconMixin:InitializeCustomFrames()
    local dimm = self:CreateTexture()
    dimm:SetAllPoints()
    dimm:SetColorTexture(0, 0, 0, .6)

    local divider = self:CreateTexture()
    divider:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 6, 6)
    divider:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -6, 6)
    divider:SetHeight(2)
    divider:SetColorTexture(styles.COLORS.BORDER:GetRGBA())

    local tyra = getFont(self, styles.COLORS.TEXT_PRIMARY, "LEFT")
    tyra:SetPoint("LEFT", 5, -10)
    tyra:SetText("TYRA:")
    local forti = getFont(self, styles.COLORS.TEXT_PRIMARY, "LEFT")
    forti:SetPoint("LEFT", 5, 10)
    forti:SetText("FORTI:")

    local tLevel = getFont(self, styles.COLORS.TEXT_HIGHLIGHT, "RIGHT")
    tLevel:SetPoint("RIGHT", -5, -10)
    local fLevel = getFont(self, styles.COLORS.TEXT_HIGHLIGHT, "RIGHT")
    fLevel:SetPoint("RIGHT", -5, 10)

    local shortName = getFont(self, styles.COLORS.TEXT_PRIMARY, "LEFT")
    shortName:SetPoint("BOTTOMLEFT", divider, "TOPLEFT", -2, 4)
    local totalScore = getFont(self, styles.COLORS.TEXT_HIGHLIGHT, "RIGHT")
    totalScore:SetPoint("BOTTOMRIGHT", divider, "TOPRIGHT", 2, 4)

    self.TyranicalLevel = tLevel
    self.FortifiedLevel = fLevel
    self.ShortName = shortName
    self.TotalScore = totalScore
    self.initializedCustom = true
end

function customIconMixin:SetUp(mapInfo)
    if not self.initializedCustom then
        self:InitializeCustomFrames()
    end
    self.mapID = mapInfo.id
    local name, _, _, texture = C_ChallengeMode.GetMapUIInfo(mapInfo.id)
    local shortName = shortDungeonNames[self.mapID] or shortenName(name)
    if (texture == 0) then
        texture = "Interface\\Icons\\achievement_bg_wineos_underxminutes"
    end

    self.Icon:SetTexture(texture)
    self.Icon:SetDesaturated(mapInfo.level == 0)

    local bestRuns, overAllScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(mapInfo.id)
    local levels = {
        Tyrannical = 0,
        Fortified = 0
    }
    if not bestRuns then return end
    for _, info in ipairs(bestRuns) do
        levels[info.name] = info.level
    end
    self.TyranicalLevel:SetText(levels.Tyrannical)
    self.FortifiedLevel:SetText(levels.Fortified)
    self.ShortName:SetText(shortName)
    self.TotalScore:SetText(overAllScore)
    self.HighestLevel:Hide()
end

local function applyMixin(self)
    if self.customMixin then return end
    self.customMixin = true
    for _, frame in ipairs(self.DungeonIcons) do
        frame = Mixin(frame, customIconMixin)
    end
    self.WeeklyInfo.Child.SeasonBest:Hide()
end

local weeklyBest
local function createWeeklyBest()
    local wc = ChallengesFrame.WeeklyInfo.Child.WeeklyChest
    local wcText = wc.RunStatus
    wcText:ClearAllPoints()
    wcText:SetPoint("TOPLEFT", -50, 150)
    wcText:SetPoint("BOTTOMRIGHT", 50, 0)
    weeklyBest = CreateRoundedFrame(ChallengesFrame, {
        height = 225,
        width = 130,
        points = { { "TOPLEFT", 20, -75 } },
        border_size = 2,
    })
    local title = weeklyBest:CreateFontString()
    title:SetPoint("TOP", 0, -10)
    title:SetFontObject(styles.FONT_OBJECTS.BOLD)
    title:SetTextColor(styles.COLORS.TEXT_HIGHLIGHT:GetRGBA())
    title:SetText(loc["WEEKLY BEST"])

    local divider = weeklyBest:CreateTexture()
    divider:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -11, -4)
    divider:SetPoint("TOPRIGHT", title, "BOTTOMRIGHT", 11, -4)
    divider:SetHeight(2)
    divider:SetColorTexture(styles.COLORS.BORDER:GetRGBA())

    local rowContainer = CreateFrame("Frame", nil, weeklyBest)
    rowContainer:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 0, -10)
    rowContainer:SetPoint("BOTTOMRIGHT", -12, 12)
    local heightPerRow = (rowContainer:GetHeight() - 8 * 2) / 8
    weeklyBest.heightPerRow = heightPerRow

    local anchorFrame = rowContainer
    local unevenBG = CreateColorFromHexString("0DD0DCF5")
    local keyColor = CreateColorFromHexString("FFE0C73A")
    local rows = {}
    weeklyBest.rows = rows
    for i = 1, 8 do
        local row = CreateRoundedFrame(rowContainer, {
            height = heightPerRow,
            points = {
                { "TOPLEFT",  anchorFrame, i == 1 and "TOPLEFT" or "BOTTOMLEFT",   0, -2 },
                { "TOPRIGHT", anchorFrame, i == 1 and "TOPRIGHT" or "BOTTOMRIGHT", 0, -2 }
            },
            background_color = i % 2 ~= 0 and unevenBG or nil
        })
        anchorFrame = row
        tinsert(rows, row)
        local key = row:CreateFontString()
        key:SetPoint("LEFT", 4, 0)
        key:SetFontObject(styles.FONT_OBJECTS.BOLD)
        key:SetTextColor(keyColor:GetRGBA())
        key:SetText("")

        local score = row:CreateFontString()
        score:SetPoint("RIGHT", -4, 0)
        score:SetFontObject(styles.FONT_OBJECTS.BOLD)
        score:SetText(styles.COLORS.TEXT_HIGHLIGHT:WrapTextInColorCode(""))

        function row:UpdateKey(dungeon, level, scoreNum)
            if not scoreNum then return end
            local shortName = shortDungeonNames[dungeon]
            key:SetText(string.format("%s +%d", shortName, level))
            local scoreColor = C_ChallengeMode.GetKeystoneLevelRarityColor(level)
            score:SetText(scoreColor:WrapTextInColorCode(scoreNum))
            self:Show()
        end
    end
end

local function updateWeeklyBest()
    if not weeklyBest then return end
    for _, row in ipairs(weeklyBest.rows) do
        row:Hide()
    end
    local weeklyRuns = C_MythicPlus.GetRunHistory()
    local runs = {}
    for _, runInfo in ipairs(weeklyRuns) do
        tinsert(runs, { dungeon = runInfo.mapChallengeModeID, level = runInfo.level, score = runInfo.runScore })
    end
    sort(runs, function(a, b)
        return a.score > b.score
    end)
    for i, runInfo in ipairs(runs) do
        if weeklyBest.rows[i] then
            weeklyBest.rows[i]:UpdateKey(runInfo.dungeon, runInfo.level, runInfo.score)
        end
    end
    weeklyBest:SetHeight(min(8, #runs) * (weeklyBest.heightPerRow + 2) + 48)
end


local function onEvent(_, event, loadedAddon)
    if event == "ADDON_LOADED" and loadedAddon == "Blizzard_ChallengesUI" then
        ChallengesFrame:HookScript("OnShow", function(self)
            applyMixin(self)
        end)
        createWeeklyBest()
        updateWeeklyBest()
    elseif event == "CHALLENGE_MODE_MAPS_UPDATE" then
        updateWeeklyBest()
    end
end

addon:RegisterEvent("ADDON_LOADED", "ui/bestDungeons.lua", onEvent)
addon:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE", "ui/bestDungeons.lua", onEvent)
