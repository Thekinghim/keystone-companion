---@class KeystoneCompanionPrivate
local Private = select(2, ...)
---@class KeystoneCompanion
local addon = Private.Addon
local loc = addon.Loc
local widgets = Private.widgets
local getTexturePath = Private.utils.path.getTexturePath
local styles = Private.constants.styles
local dungeonNameFixes = {
    [464] = "DotI: Upper", -- Dawn of the Infinite: Murozond's Rise
    [463] = "DotI: Lower", -- Dawn of the Infinite: Galakrond's Fall
    [403] = "Uldaman",     -- Uldaman: Legacy of Tyr
}

function addon:TimerInit()
    local db = self.DB
    local uiSettings = Private.UI.Settings.Timer
    if not db.bestTimes then
        db.bestTimes = {}
    end
    local mdt = MDT

    -- Creates a Tooltip hook to show MDT count on Unit Tooltips
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip, data)
        if not mdt then return end
        local guid = data.guid
        if not guid then return end
        local npcID = select(6, strsplit("-", guid))
        if not npcID then return end
        local count = mdt:GetEnemyForces(tonumber(npcID))
        if count and count > 0 then
            tooltip:AddDoubleLine(loc["M+ Count"], count)
        end
    end)

    ---@class DungeronTimerFrame : RoundedFrame
    local timerFrame = widgets.RoundedFrame.CreateFrame(UIParent, {
        width = 352,
        height = 265,
        border_size = 1,
        background_color = styles.COLORS.BACKGROUND_TRANSPARENT
    })
    Private.DungeonTimerFrame = timerFrame
    timerFrame:SetClampedToScreen(true)
    timerFrame:Hide()
    timerFrame.currentPull = {}
    local bossFrames = {}
    local function getBestTimes(mapID, affixID, keyLevel)
        if not db.bestTimes then return end
        if db.bestTimes[mapID] and db.bestTimes[mapID][affixID] and db.bestTimes[mapID][affixID][keyLevel] and type(db.bestTimes[mapID][affixID][keyLevel]) == "table" then
            return db.bestTimes[mapID][affixID][keyLevel]
        end
    end

    local function saveBestTimes(mapID, affixID, keyLevel, times)
        local dbTimes = getBestTimes(mapID, affixID, keyLevel) or {}
        for index, newTime in pairs(times) do
            if not dbTimes[index] or dbTimes[index] > newTime then
                dbTimes[index] = newTime
            end
        end
        if not db.bestTimes[mapID] then db.bestTimes[mapID] = {} end
        if not db.bestTimes[mapID][affixID] then db.bestTimes[mapID][affixID] = {} end
        db.bestTimes[mapID][affixID][keyLevel] = dbTimes
    end

    local function getEnemyForces()
        local enemyForces = select(3, C_Scenario.GetStepInfo())
        local totalCount, _, _, mobPointsStr = select(5, C_Scenario.GetCriteriaInfo(enemyForces))
        if not totalCount or not mobPointsStr then return 0, 100 end

        local currentCountStr = gsub(mobPointsStr, "%%", "")
        local currentCount = tonumber(currentCountStr)
        return currentCount, totalCount
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
            boss.name:SetFont(styles.FONTS.BOLD, 14, "OUTLINE");
            boss.name:SetJustifyH("LEFT")
            boss.name:SetPoint("LEFT", 8, 0)
            boss.bestDiff = boss:CreateFontString()
            boss.bestDiff:SetFont(styles.FONTS.BOLD, 14, "OUTLINE");
            boss.bestDiff:SetJustifyH("RIGHT")
            boss.bestDiff:SetPoint("RIGHT", -75, 0)
            boss.time = boss:CreateFontString()
            boss.time:SetFont(styles.FONTS.BOLD, 14, "OUTLINE")
            boss.time:SetJustifyH("RIGHT")
            boss.time:SetPoint("RIGHT", -8, 0)
            tinsert(bossFrames, boss)
        end
        boss:Show()
        boss.used = true
        boss.name:SetText("")
        boss.bestDiff:SetText("")
        boss.time:SetText("")
        boss:ClearAllPoints()
        boss:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -4)
        boss:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -4)
        return boss
    end

    function timerFrame:ToggleMoveable(forceState)
        local makeMovable = false
        if not self:GetScript("OnDragStart") then
            makeMovable = true
        end
        if forceState ~= nil then
            makeMovable = forceState
        end
        self:MakeMovable(not makeMovable, self.SaveAnchors)

        self:Show()
        if not makeMovable and (not C_ChallengeMode.IsChallengeModeActive() or not db.settings.timerSettings.active) then
            self:Hide()
        end
    end

    function timerFrame:SaveAnchors()
        local point, _, relativePoint, offsetX, offsetY = self:GetPoint();
        db.settings.timerSettings.anchor = {
            point = point,
            relativePoint = relativePoint,
            offsetX = offsetX,
            offsetY = offsetY
        }
    end

    function timerFrame:SetActivated(state)
        if state == nil then return end
        db.settings.timerSettings.active = state
        self:ToggleMoveable(self:IsMovable())
        if C_ChallengeMode.IsChallengeModeActive() then
            self:OnEvent("CHALLENGE_MODE_START")
        end
    end

    function timerFrame:ScaleFrame(percent)
        if not percent then return end
        local scale = percent / 100
        self:SetScale(scale)
        db.settings.timerSettings.scale = percent
        self:SaveAnchors()
    end

    function timerFrame:SetAnchors(anchor)
        if not anchor then return end
        self:ClearAllPoints()
        self:SetPoint(anchor.point, UIParent, anchor.relativePoint, anchor.offsetX, anchor.offsetY)
    end

    function timerFrame:ChangeAlpha(percent)
        if not percent then return end
        local alpha = percent / 100
        self:SetAlpha(alpha)
        db.settings.timerSettings.alpha = percent
    end

    function timerFrame:LoadSettings()
        if not db.settings then db.settings = {} end
        if not db.settings.timerSettings or db.settings.timerSettings.anchor[1] ~= nil then
            db.settings.timerSettings = {
                active = true,
                scale = 80,
                anchor = { point = "RIGHT", relativePoint = "RIGHT", offsetX = -25, offsetY = 0 },
                alpha = 100
            }
        end
        local settings = db.settings.timerSettings
        self:SetAnchors(settings.anchor)
        self:ScaleFrame(settings.scale)
        self:ChangeAlpha(settings.alpha)

        -- UI Settings stuff
        uiSettings.Activate:SetChecked(settings.active)
        uiSettings.Activate.callback = function(_, checked)
            self:SetActivated(checked)
        end
        uiSettings.Unlock:SetChecked(false)
        uiSettings.Unlock.callback = function(_, checked)
            self:ToggleMoveable(checked)
        end
        uiSettings.Scale:SetValue(settings.scale)
        uiSettings.Scale.callback = function(_, value)
            self:ScaleFrame(value)
        end
        uiSettings.Alpha:SetValue(settings.alpha)
        uiSettings.Alpha.callback = function(_, value)
            self:ChangeAlpha(value)
        end
    end

    function timerFrame:OnEvent(event, ...)
        if not db.settings.timerSettings then
            self:LoadSettings()
        end
        if not db.settings.timerSettings.active and event ~= "PLAYER_ENTERING_WORLD" then
            self:ReleaseFrame()
            return
        end
        if event == "CHALLENGE_MODE_START" then
            self:FillFrame()
        elseif event == "CHALLENGE_MODE_COMPLETED" then
            saveBestTimes(self.runData.mapID, self.runData.week, self.runData.level, self:GetBossTimes())
            addon:devPrint("MAP ID", self.runData.mapID)
            addon:devPrint("RUN WEEK", self.runData.week)
            addon:devPrint("RUN LEVEL", self.runData.level)
            addon:devPrint("BOSS TIMES")
            DevTools_Dump(self:GetBossTimes())
            self.last = 0
            self:SetScript("OnUpdate", nil)
        elseif event == "PLAYER_ENTERING_WORLD" then
            local isLogin, isReload = ...
            if isLogin or isReload then
                self:LoadSettings()
            else
                self:ReleaseFrame()
            end
            if C_ChallengeMode.IsChallengeModeActive() then
                self:OnEvent("CHALLENGE_MODE_START")
            end
        elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
            local _, se, _, _, _, _, _, destGUID = ...
            if se == "UNIT_DIED" then
                self:RemoveFromCurrentPull(destGUID)
            end
        elseif event == "UNIT_THREAT_LIST_UPDATE" then
            local unit = ...
            if unit and UnitExists(unit) then
                local guid = UnitGUID(unit)
                self:AddToCurrentPull(guid)
            end
        elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_DEAD" then
            self:ResetCurrentPull()
        end
    end

    function timerFrame:ResetCurrentPull()
        self.currentPull = {}
    end

    function timerFrame:AddToCurrentPull(guid)
        self.currentPull[guid] = true
    end

    function timerFrame:RemoveFromCurrentPull(guid)
        self.currentPull[guid] = false
    end

    function timerFrame:GetCurrentPull()
        local count = 0
        for guid, active in pairs(self.currentPull) do
            if active and mdt then
                local npc_id = select(6, strsplit("-", guid))
                local added = mdt:GetEnemyForces(tonumber(npc_id))
                if added and added > 0 then
                    count = count + added
                end
            end
        end
        return count
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

    function timerFrame:GetBossTimes()
        local times = {}
        for index, boss in pairs(self.bosses) do
            addon:devPrint(string.format("Boss %d died %s", index, boss.dead))
            times[index] = boss.dead
        end
        return times
    end

    function timerFrame:FillFrame()
        self:ReleaseFrame()
        self:SetScript("OnUpdate", self.UpdateFrame)
        self:ResetCurrentPull()
        if ObjectiveTrackerFrame and ObjectiveTrackerFrame:IsVisible() then
            ObjectiveTrackerFrame:Hide()
        end
        self:Show()
        self.runData = {}
        local mapID = C_ChallengeMode.GetActiveChallengeMapID() or 0
        local dungeonName, _, timeLimit = C_ChallengeMode.GetMapUIInfo(mapID)
        if dungeonNameFixes[mapID] then
            dungeonName = dungeonNameFixes[mapID]
        end
        local level, affixes = C_ChallengeMode.GetActiveKeystoneInfo()
        self.runData.week = affixes[1] -- Fort or Tyra
        self.runData.mapID = mapID
        self.runData.level = level
        self.runData.timeLimit = timeLimit
        self.runData.plus3 = timeLimit * 0.6
        self.runData.plus2 = timeLimit * 0.8
        self.runData.maxCriteria = select(3, C_Scenario.GetStepInfo())
        self:SetAffixes(affixes)
        self.title:SetText(string.format("+%d %s", level, dungeonName))
        self.bosses = {}
        self.runData.bestTimes = getBestTimes(mapID, self.runData.week, level)
        self.runData.currentBoss = 1

        local bossAnchor = self.timeBar
        for bossIndex = 1, self.runData.maxCriteria - 1 do
            addon:devPrint(self.runData.maxCriteria, C_Scenario.GetCriteriaInfo(bossIndex))
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
        self.last = 0
        self:SetScript("OnUpdate", nil)
        self:Hide()
        for _, frame in ipairs(bossFrames) do
            frame.name:SetText("")
            frame.name:SetTextColor(styles.COLORS.TEXT_PRIMARY:GetRGBA())
            frame.bestDiff:SetText("")
            frame.bestDiff:SetTextColor(styles.COLORS.TEXT_PRIMARY:GetRGBA())
            frame.time:SetText("")
            frame.time:SetTextColor(styles.COLORS.TEXT_PRIMARY:GetRGBA())
            frame.dead = false
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
        if self.runData.maxCriteria ~= select(3, C_Scenario.GetStepInfo()) then
            self:FillFrame()
            return
        end
        local currentTime = select(2, GetWorldElapsedTime(1))
        if self.last and currentTime <= self.last then return end
        self.last = currentTime

        self.time:SetText(string.format("%s / %s", SecondsToClock(currentTime), SecondsToClock(self.runData.timeLimit)))
        self.timeBar:SetProgress(currentTime, self.runData.timeLimit)
        local plus3Remain = self.runData.plus3 - currentTime
        local plus2Remain = self.runData.plus2 - currentTime
        local plus1Remain = self.runData.timeLimit - currentTime
        self.plus3.text:SetText(SecondsToClock(plus3Remain))
        self.plus2.text:SetText(SecondsToClock(plus2Remain))
        self.plus1.text:SetText(SecondsToClock(plus1Remain))

        local deaths = C_ChallengeMode.GetDeathCount()
        self.deaths:SetText(string.format("%d %s14|t", deaths, ICON_LIST[8]))

        local count, total = getEnemyForces()
        self.countPercent:SetText(string.format("%.2f%%", count / total * 100))
        self.countNumber:SetText(string.format("%d/%d", count, total))
        if count < total and mdt then
            local pullCount = self:GetCurrentPull()
            if pullCount > 0 then
                local pullPercent = pullCount / total * 100
                self.countPercent:SetText(string.format("%s (+%.2f%%)", self.countPercent:GetText(), pullPercent))
                self.countNumber:SetText(string.format("%s (+%d)", self.countNumber:GetText(), pullCount))
            end
        end
        self.countBar:SetProgress(count, total)

        local liveIndex = 0
        for bossIndex = 1, self.runData.maxCriteria - 1 do
            local bossBar = self.bosses[bossIndex]
            local dead = select(11, C_Scenario.GetCriteriaInfo(bossIndex))
            if dead and dead > 0 and not bossBar.dead then
                bossBar.dead = dead
                local deathTime = dead - currentTime
                bossBar.name:SetTextColor(styles.COLORS.GREEN_LIGHT:GetRGBA())
                bossBar.time:SetTextColor(styles.COLORS.GREEN_LIGHT:GetRGBA())
                bossBar.time:SetText(SecondsToClock(deathTime))
                if self.runData.bestTimes and self.runData.bestTimes[self.runData.currentBoss] then
                    local best = self.runData.bestTimes[self.runData.currentBoss]
                    self.runData.currentBoss = self.runData.currentBoss + 1
                    bossBar.bestDiff:SetText(SecondsToClock((best - deathTime) * -1))
                    if best < deathTime then
                        bossBar.time:SetTextColor(styles.COLORS.RED_LIGHT:GetRGBA())
                        bossBar.bestDiff:SetTextColor(styles.COLORS.RED_LIGHT:GetRGBA())
                    elseif best == deathTime then
                        bossBar.time:SetTextColor(styles.COLORS.YELLOW_LIGHT:GetRGBA())
                        bossBar.bestDiff:SetTextColor(styles.COLORS.YELLOW_LIGHT:GetRGBA())
                    elseif best > deathTime then
                        bossBar.time:SetTextColor(styles.COLORS.GREEN_LIGHT:GetRGBA())
                        bossBar.bestDiff:SetTextColor(styles.COLORS.GREEN_LIGHT:GetRGBA())
                    end
                end
            end

            if not bossBar.dead then
                local time = ""
                if self.runData.bestTimes and self.runData.bestTimes[self.runData.currentBoss + liveIndex] then
                    local best = self.runData.bestTimes[self.runData.currentBoss + liveIndex]
                    time = SecondsToClock(best)
                end
                bossBar.name:SetTextColor(styles.COLORS.TEXT_PRIMARY:GetRGBA())
                bossBar.time:SetTextColor(styles.COLORS.TEXT_PRIMARY:GetRGBA())
                bossBar.time:SetText(time)
                bossBar.bestDiff:SetText("")
                liveIndex = liveIndex + 1
            end
        end
    end

    local headerColor = CreateColorFromHexString("0DD0DCF5")
    local barColor = CreateColorFromHexString("FF333333")

    local headerBar = widgets.RoundedFrame.CreateFrame(timerFrame, {
        height = 38,
        background_color = headerColor,
        points = {
            { "TOPLEFT",  12,  -12 },
            { "TOPRIGHT", -12, -12 }
        }
    })

    local deathText = headerBar:CreateFontString()
    deathText:SetFont(styles.FONTS.BOLD, 16, "OUTLINE")
    deathText:SetJustifyH("RIGHT")
    deathText:SetTextColor(styles.COLORS.TEXT_HIGHLIGHT:GetRGBA())
    deathText:SetPoint("RIGHT", -12, 0)
    timerFrame.deaths = deathText

    local dungeonTitle = headerBar:CreateFontString()
    dungeonTitle:SetFont(styles.FONTS.BOLD, 16, "OUTLINE")
    dungeonTitle:SetJustifyH("LEFT")
    dungeonTitle:SetTextColor(styles.COLORS.TEXT_PRIMARY:GetRGBA())
    dungeonTitle:SetPoint("LEFT", 12, 0)
    timerFrame.title = dungeonTitle

    local affixes = headerBar:CreateFontString()
    affixes:SetFont(styles.FONTS.BOLD, 16, "OUTLINE")
    affixes:SetJustifyH("LEFT")
    affixes:SetPoint("LEFT", dungeonTitle, "RIGHT", 12, 0)
    timerFrame.affixes = affixes

    local timeBar = widgets.ProgressBar.CreateFrame(timerFrame, {
        height = 25,
        background_color = barColor,
        foreground_color = styles.COLORS.GREEN_DARK,
        border_size = 0,
        points = {
            { "TOPLEFT",  headerBar, "BOTTOMLEFT",  0, -12 },
            { "TOPRIGHT", headerBar, "BOTTOMRIGHT", 0, -12 }
        }
    })
    timerFrame.timeBar = timeBar

    local timeText = timeBar.Foreground:CreateFontString()
    timeText:SetFont(styles.FONTS.BOLD, 14, "")
    timeText:SetJustifyH("LEFT")
    timeText:SetPoint("LEFT", 8, 0)
    timerFrame.time = timeText

    local plus3 = timeBar.Foreground:CreateTexture()
    plus3:SetTexture(getTexturePath('rounded-frame/base'))
    plus3:SetPoint("LEFT", timeBar.Background:GetWidth() * 0.6, 0) -- 40% Time left
    plus3:SetSize(2, 14)
    plus3.text = timeBar.Foreground:CreateFontString()
    plus3.text:SetFont(styles.FONTS.BOLD, 14, "")
    plus3.text:SetJustifyH("RIGHT")
    plus3.text:SetPoint("RIGHT", plus3, "LEFT", -8, 0)
    timerFrame.plus3 = plus3

    local plus2 = timeBar.Foreground:CreateTexture()
    plus2:SetTexture(getTexturePath('rounded-frame/base'))
    plus2:SetPoint("LEFT", timeBar.Background:GetWidth() * 0.8, 0) -- 20% Time left
    plus2:SetSize(2, 14)
    plus2.text = timeBar.Foreground:CreateFontString()
    plus2.text:SetFont(styles.FONTS.BOLD, 14, "")
    plus2.text:SetJustifyH("RIGHT")
    plus2.text:SetPoint("RIGHT", plus2, "LEFT", -8, 0)
    timerFrame.plus2 = plus2

    local plus1 = {}
    plus1.text = timeBar.Foreground:CreateFontString()
    plus1.text:SetFont(styles.FONTS.BOLD, 14, "")
    plus1.text:SetJustifyH("RIGHT")
    plus1.text:SetPoint("RIGHT", timeBar, "RIGHT", -8, 0)
    timerFrame.plus1 = plus1

    local countBar = widgets.ProgressBar.CreateFrame(timerFrame, {
        height = 33,
        background_color = barColor,
        foreground_color = styles.COLORS.GREEN_DARK,
        border_size = 2,
    })
    countBar.Background.Border:ClearAllPoints()
    countBar.Background.Border:SetPoint("TOPLEFT", -1, 1)
    countBar.Background.Border:SetPoint("BOTTOMRIGHT", 1, -1)
    timerFrame.countBar = countBar

    local countPercent = countBar.Foreground:CreateFontString()
    countPercent:SetFont(styles.FONTS.BOLD, 14, "")
    countPercent:SetJustifyH("LEFT")
    countPercent:SetPoint("LEFT", countBar, "LEFT", 8, 0)
    timerFrame.countPercent = countPercent

    local countNumber = countBar.Foreground:CreateFontString()
    countNumber:SetFont(styles.FONTS.BOLD, 14, "")
    countNumber:SetJustifyH("RIGHT")
    countNumber:SetPoint("RIGHT", countBar, "RIGHT", -8, 0)
    timerFrame.countNumber = countNumber

    local function onEvent(_, ...)
        if timerFrame then
            timerFrame:OnEvent(...)
        end
    end

    self:RegisterEvent("PLAYER_ENTERING_WORLD", "ui/dungeronTimer.lua", onEvent)
    self:RegisterEvent("CHALLENGE_MODE_START", "ui/dungeronTimer.lua", onEvent)
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED", "ui/dungeronTimer.lua", onEvent)
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "ui/dungeronTimer.lua", onEvent, nil, { "UNIT_DIED" })
    self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", "ui/dungeronTimer.lua", onEvent)
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "ui/dungeronTimer.lua", onEvent)
    self:RegisterEvent("PLAYER_DEAD", "ui/dungeronTimer.lua", onEvent)
end
