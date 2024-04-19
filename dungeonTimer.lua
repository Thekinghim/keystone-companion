local _, Private = ...
local rf = Private.RoundedFrame
local pb = Private.ProgressBar
local const = Private.constants.misc

local timerFrame = rf.CreateFrame(UIParent, {
    width = 352,
    height = 265,
    border_texture = rf.GetBorderForSize(1),
    border_size = 1,
})
timerFrame:Hide()
local bossFrames = {}
local function formatTime(seconds)
    local sign = ""
    if seconds < 0 then
        sign = "-"
        seconds = -seconds
    end
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local remaining_seconds = seconds % 60

    if hours > 0 then
        return string.format("%s%02d:%02d:%02d", sign, hours, minutes, remaining_seconds)
    else
        return string.format("%s%02d:%02d", sign, minutes, remaining_seconds)
    end
end
local function createBossBar(anchor)
    ---@class Frame
    ---@field name FontString
    ---@field bestDiff FontString
    ---@field time FontString
    local boss
    for _, frame in ipairs(bossFrames) do
        if not frame.used then
            boss = frame
        end
    end
    if not boss then
        boss = CreateFrame("Frame", nil, timerFrame)
        boss:SetHeight(25)
        boss.name = boss:CreateFontString()
        boss.name:SetFontObject(const.FONT_OBJECTS.DEFAULT_SMALL)
        boss.name:SetJustifyH("LEFT")
        boss.name:SetPoint("LEFT", 8, 0)
        boss.bestDiff = boss:CreateFontString()
        boss.bestDiff:SetFontObject(const.FONT_OBJECTS.DEFAULT_SMALL)
        boss.bestDiff:SetJustifyH("RIGHT")
        boss.bestDiff:SetPoint("RIGHT", -75, 0)
        boss.time = boss:CreateFontString()
        boss.time:SetFontObject(const.FONT_OBJECTS.DEFAULT_SMALL)
        boss.time:SetJustifyH("RIGHT")
        boss.time:SetPoint("RIGHT", -8, 0)
        tinsert(bossFrames, boss)
    end
    boss:Show()
    boss.used = true
    boss.name:SetText("Hymdall")
    boss.bestDiff:SetText("+/- 0")
    boss.time:SetText("6:29")
    boss:ClearAllPoints()
    boss:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -4)
    boss:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -4)
    return boss
end
function timerFrame:ToggleMoveable()
    local makeMovable = false
    if not self:GetScript("OnMouseDown") then
        makeMovable = true
    end
    self:SetScript("OnMouseDown", makeMovable and function()
        self:StartMoving()
    end or nil)
    self:SetScript("OnMouseUp", makeMovable and function()
        self:StopMovingOrSizing()
    end or nil)
    self:SetMovable(makeMovable)
    self:EnableMouse(makeMovable)
end

function timerFrame:OnEvent(event, ...)
    if event == "CHALLENGE_MODE_START" then
        self:FillFrame()
        self:SetScript("OnUpdate", timerFrame.UpdateFrame)
    elseif event == "CHALLENGE_MODE_COMPLETED" then
        self:ReleaseFrame()
    elseif event == "PLAYER_ENTERING_WORLD" then
        if C_ChallengeMode.IsChallengeModeActive() then
            self:OnEvent("CHALLENGE_MODE_START")
        end
    end
end

function timerFrame:SetAffixes(...)
    local affixes = ...
    if type(affixes) ~= "table" then
        affixes = { ... }
    end
    local affixString = ""
    for _, affixID in ipairs(affixes) do
        local affixFile = select(3, C_ChallengeMode.GetAffixInfo(affixID))
        if affixFile then
            affixString = string.format("%s|T%s:14|t", affixString, affixFile)
        end
    end
    self.affixes:SetText(affixString)
end

local fakeDB = {
    [198] = {         -- mapID for DHT
        [10] = {      -- affixID for Fortified
            [6] = {   -- key Level
                389,  -- [1] 06:29
                689,  -- [2] 11:29
                1093, -- [3] 18:13
                1458, -- [4] 24:18
                1758, -- [5] 29:18
            }
        }
    }
}
local function getBestTimes(mapID, affixID, keyLevel)
    if fakeDB[mapID] and fakeDB[mapID][affixID] and fakeDB[mapID][affixID][keyLevel] and type(fakeDB[mapID][affixID][keyLevel]) == "table" then
        return fakeDB[mapID][affixID][keyLevel]
    end
end

function timerFrame:FillFrame()
    self:Show()
    self.runData = {}
    local mapID = C_ChallengeMode.GetActiveChallengeMapID() or 0
    local dungeonName, _, timeLimit = C_ChallengeMode.GetMapUIInfo(mapID)
    local level, affixes = C_ChallengeMode.GetActiveKeystoneInfo()
    self.runData.week = affixes[1] -- Fort or Tyra
    self.runData.mapID = mapID
    self.runData.level = level
    self.runData.timeLimit = timeLimit
    self.runData.plus3 = timeLimit * 0.6
    self.runData.plus2 = timeLimit * 0.8
    self.runData.maxCriteria = select(3, C_Scenario.GetStepInfo())
    self.runData.maxCount = select(5, C_Scenario.GetCriteriaInfo(self.runData.maxCriteria))
    self:SetAffixes(affixes)
    self.title:SetText(string.format("+%d %s", level, dungeonName))
    self.bosses = {}
    self.runData.bestTimes = getBestTimes(mapID, self.runData.week, level)
    self.runData.currentBoss = 1

    local bossAnchor = self.timeBar
    for bossIndex = 1, self.runData.maxCriteria - 1 do
        local bossBar = createBossBar(bossAnchor)
        self.bosses[bossIndex] = bossBar
        bossBar.dead = false
        bossBar.name:SetText(C_Scenario.GetCriteriaInfo(bossIndex))
        bossBar.bestDiff:SetText("")
        bossBar.time:SetText("")
        bossAnchor = bossBar
    end

    self.countBar:ClearAllPoints()
    self.countBar:SetPoint("TOPLEFT", bossAnchor, "BOTTOMLEFT", 0, -4)
    self.countBar:SetPoint("TOPRIGHT", bossAnchor, "BOTTOMRIGHT", 0, -4)

    -- 132 Base + 25 per Boss + 4 per Boss + 1 (Gaps)
    self:SetHeight((132) + (self.runData.maxCriteria - 1) * 25 + self.runData.maxCriteria * 4)
end

function timerFrame:ReleaseFrame()
    self:Hide()
    self:SetScript("OnUpdate", nil)
    for _, frame in ipairs(bossFrames) do
        frame.used = false
        frame:Hide()
    end
end

function timerFrame:UpdateFrame()
    -- For Performance this should later be split into UpdateTime, UpdateBossAndCount, UpdateDeaths
    if not C_ChallengeMode.IsChallengeModeActive() then
        self:ReleaseFrame()
        return
    end
    local currentTime = select(2, GetWorldElapsedTime(1))
    if self.last and currentTime <= self.last then return end
    self.last = currentTime

    self.time:SetText(string.format("%s / %s", formatTime(currentTime), formatTime(self.runData.timeLimit)))
    self.timeBar:SetProgress(currentTime, self.runData.timeLimit)
    local plus3Remain = self.runData.plus3 - currentTime
    local plus2Remain = self.runData.plus2 - currentTime
    local plus1Remain = self.runData.timeLimit - currentTime
    self.plus3.text:SetText(formatTime(plus3Remain))
    self.plus2.text:SetText(formatTime(plus2Remain))
    self.plus1.text:SetText(formatTime(plus1Remain))

    local deaths = C_ChallengeMode.GetDeathCount()
    self.deaths:SetText(string.format("%d %s14|t", deaths, ICON_LIST[8]))

    local count = select(4, C_Scenario.GetCriteriaInfo(self.runData.maxCriteria))
    local countPercent = select(8, C_Scenario.GetCriteriaInfo(self.runData.maxCriteria))
    self.countPercent:SetText(countPercent)
    self.countNumber:SetText(string.format("%d/%d", count, self.runData.maxCount))
    self.countBar:SetProgress(count, self.runData.maxCount)

    local liveIndex = 0
    for bossIndex = 1, self.runData.maxCriteria - 1 do
        local bossBar = self.bosses[bossIndex]
        local dead = select(11, C_Scenario.GetCriteriaInfo(bossIndex))
        if dead and dead>0 and not bossBar.dead then
            bossBar.dead = dead
            local deathTime = dead - currentTime
            bossBar.name:SetTextColor(const.COLORS.POSITIVE:GetRGBA())
            bossBar.time:SetTextColor(const.COLORS.POSITIVE:GetRGBA())
            bossBar.time:SetText(formatTime(deathTime))
            if self.runData.bestTimes and self.runData.bestTimes[self.runData.currentBoss] then
                local best = self.runData.bestTimes[self.runData.currentBoss]
                self.runData.currentBoss = self.runData.currentBoss + 1
                bossBar.bestDiff:SetText(formatTime((best - deathTime) * -1))
                if best < deathTime then
                    bossBar.time:SetTextColor(const.COLORS.NEGATIVE:GetRGBA())
                    bossBar.bestDiff:SetTextColor(const.COLORS.NEGATIVE:GetRGBA())
                elseif best == deathTime then
                    bossBar.time:SetTextColor(const.COLORS.NEUTRAL:GetRGBA())
                    bossBar.bestDiff:SetTextColor(const.COLORS.NEUTRAL:GetRGBA())
                elseif best > deathTime then
                    bossBar.time:SetTextColor(const.COLORS.POSITIVE:GetRGBA())
                    bossBar.bestDiff:SetTextColor(const.COLORS.POSITIVE:GetRGBA())
                end
            end
        end

        if not bossBar.dead then
            local time = ""
            if self.runData.bestTimes and self.runData.bestTimes[self.runData.currentBoss + liveIndex] then
                local best = self.runData.bestTimes[self.runData.currentBoss + liveIndex]
                time = formatTime(best)
            end
            bossBar.name:SetTextColor(const.COLORS.TEXT_PRIMARY:GetRGBA())
            bossBar.time:SetTextColor(const.COLORS.TEXT_PRIMARY:GetRGBA())
            bossBar.time:SetText(time)
            bossBar.bestDiff:SetText("")
            liveIndex = liveIndex + 1
        end
    end
end

local headerColor = CreateColorFromHexString("0DD0DCF5")
local barColor = CreateColorFromHexString("FF333333")

local headerBar = rf.CreateFrame(timerFrame, {
    height = 38,
    use_border = false,
    background_color = headerColor,
    points = {
        { "TOPLEFT",  12,  -12 },
        { "TOPRIGHT", -12, -12 }
    }
})

local deathText = headerBar:CreateFontString()
deathText:SetFontObject(const.FONT_OBJECTS.SEMIBOLD)
deathText:SetJustifyH("RIGHT")
deathText:SetTextColor(const.COLORS.TEXT_SECONDARY:GetRGBA())
deathText:SetPoint("RIGHT", -12, 0)
timerFrame.deaths = deathText

local dungeonTitle = headerBar:CreateFontString()
dungeonTitle:SetFontObject(const.FONT_OBJECTS.SEMIBOLD)
dungeonTitle:SetJustifyH("LEFT")
dungeonTitle:SetTextColor(const.COLORS.TEXT_PRIMARY:GetRGBA())
dungeonTitle:SetPoint("LEFT", 12, 0)
timerFrame.title = dungeonTitle

local affixes = headerBar:CreateFontString()
affixes:SetFontObject(const.FONT_OBJECTS.SEMIBOLD)
affixes:SetJustifyH("LEFT")
affixes:SetPoint("LEFT", dungeonTitle, "RIGHT", 12, 0)
timerFrame.affixes = affixes

local timeBar = pb.CreateFrame(timerFrame, {
    height = 25,
    use_border = false,
    background_color = barColor,
    points = {
        { "TOPLEFT",  headerBar, "BOTTOMLEFT",  0, -12 },
        { "TOPRIGHT", headerBar, "BOTTOMRIGHT", 0, -12 }
    }
})
timerFrame.timeBar = timeBar

local timeText = timeBar.Foreground:CreateFontString()
timeText:SetFontObject(const.FONT_OBJECTS.DEFAULT_SMALL)
timeText:SetJustifyH("LEFT")
timeText:SetPoint("LEFT", 8, 0)
timerFrame.time = timeText

local plus3 = timeBar.Foreground:CreateTexture()
plus3:SetTexture(const.TEXTURES.ROUNDED_SQUARE)
plus3:SetPoint("LEFT", timeBar.Background:GetWidth() * 0.6, 0) -- 40% Time left
plus3:SetSize(2, 14)
plus3.text = timeBar.Foreground:CreateFontString()
plus3.text:SetFontObject(const.FONT_OBJECTS.DEFAULT_SMALL)
plus3.text:SetJustifyH("RIGHT")
plus3.text:SetPoint("RIGHT", plus3, "LEFT", -8, 0)
timerFrame.plus3 = plus3

local plus2 = timeBar.Foreground:CreateTexture()
plus2:SetTexture(const.TEXTURES.ROUNDED_SQUARE)
plus2:SetPoint("LEFT", timeBar.Background:GetWidth() * 0.8, 0) -- 20% Time left
plus2:SetSize(2, 14)
plus2.text = timeBar.Foreground:CreateFontString()
plus2.text:SetFontObject(const.FONT_OBJECTS.DEFAULT_SMALL)
plus2.text:SetJustifyH("RIGHT")
plus2.text:SetPoint("RIGHT", plus2, "LEFT", -8, 0)
timerFrame.plus2 = plus2

local plus1 = {}
plus1.text = timeBar.Foreground:CreateFontString()
plus1.text:SetFontObject(const.FONT_OBJECTS.DEFAULT_SMALL)
plus1.text:SetJustifyH("RIGHT")
plus1.text:SetPoint("RIGHT", timeBar, "RIGHT", -8, 0)
timerFrame.plus1 = plus1

local countBar = pb.CreateFrame(timerFrame, {
    height = 33,
    background_color = barColor,
    border_size = 1,
})
timerFrame.countBar = countBar

local countPercent = countBar.Foreground:CreateFontString()
countPercent:SetFontObject(const.FONT_OBJECTS.DEFAULT_SMALL)
countPercent:SetJustifyH("LEFT")
countPercent:SetPoint("LEFT", countBar, "LEFT", 8, 0)
timerFrame.countPercent = countPercent

local countNumber = countBar.Foreground:CreateFontString()
countNumber:SetFontObject(const.FONT_OBJECTS.DEFAULT_SMALL)
countNumber:SetJustifyH("RIGHT")
countNumber:SetPoint("RIGHT", countBar, "RIGHT", -8, 0)
timerFrame.countNumber = countNumber

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("CHALLENGE_MODE_START")
eventFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(_, ...)
    timerFrame:OnEvent(...)
end)
