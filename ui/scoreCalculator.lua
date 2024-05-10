---@class KeystoneCompanionPrivate
local Private = select(2, ...)
---@class KeystoneCompanion
local addon = Private.Addon
local loc = addon.Loc
local styles = Private.constants.styles
local getTexturePath = Private.utils.path.getTexturePath

local widgets = Private.widgets
local createRoundedFrame = widgets.RoundedFrame.CreateFrame
local createRoundedButton = widgets.RoundedButton.CreateFrame
local createScrollable = widgets.ScrollableFrame.CreateFrame
local createCheckBox = widgets.CheckBox.CreateFrame

function addon:ScoreCalculatorInit()
    local mythicPlusMaps = C_ChallengeMode.GetMapTable()
    local const = {
        THRESHOLD = 0.4,
        MAX_ADDITION = 5,
        MAX_REMOVAL = 10,
        BASE_SCORE = { 0, 94, 101, 108, 125, 132, 139, 146, 153, 170 },
        AFFIX = { [9] = "Tyrannical", [10] = "Fortified", ["Tyrannical"] = 9, ["Fortified"] = 10 }
    }
    local function calcTimeBonus(timePercent)
        local percentageOffset = (1 - timePercent)
        if percentageOffset > const.THRESHOLD then
            return const.MAX_ADDITION
        elseif percentageOffset > 0 then
            return percentageOffset * const.MAX_ADDITION / const.THRESHOLD
        elseif percentageOffset == 0 then
            return 0
        elseif percentageOffset > -const.THRESHOLD then
            return percentageOffset * const.MAX_ADDITION / const.THRESHOLD - const.MAX_REMOVAL
        else
            return nil
        end
    end
    local function calcScore(mapID, level, timeInSeconds)
        local dungeonTime = select(3, C_ChallengeMode.GetMapUIInfo(mapID))
        local baseScore = const.BASE_SCORE[math.min(level, 10)] + max(0, level - 10) * 7
        local timePercent = timeInSeconds / dungeonTime
        local timeScore = calcTimeBonus(timePercent)
        return baseScore + timeScore
    end

    local function calcScoreSum(score1, score2)
        return max(score1, score2) * 1.5 + min(score1, score2) * 0.5
    end

    local savedIterations = {}
    local iterationData = {}
    local function convertBlizzardData(mapID)
        local converted = {
            Tyrannical = 0,
            Fortified = 0,
            Complete = 0
        }
        local blizzardData, blizzardTotal = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(mapID)
        if blizzardData then
            converted.Complete = blizzardTotal or 0
            for _, info in ipairs(blizzardData) do
                converted[info.name] = info.score
            end
        end
        return converted
    end
    local function newIterationData(resetSaved)
        tinsert(savedIterations, iterationData)
        if resetSaved then
            savedIterations = {}
        end
        iterationData = {}
        for _, mapID in ipairs(mythicPlusMaps) do
            iterationData[mapID] = convertBlizzardData(mapID)
        end
    end
    local function changeIterationData(mapID, affix, level, durationSec)
        iterationData[mapID][affix] = calcScore(mapID, level, durationSec)
        iterationData[mapID].Complete = calcScoreSum(iterationData[mapID].Tyrannical, iterationData[mapID].Fortified)
    end
    local function getCurrentIteration(mapID)
        return iterationData[mapID]
    end

    local function calcScores(dungeonId, customRuns)
        local scoreData = {
            Tyrannical = 0,
            Fortified = 0,
        }
        local blizzardScores = {
            Complete = 0
        }
        local blizzardAffixScoreData, blizzardTotalScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(dungeonId)
        if blizzardAffixScoreData then
            blizzardScores.Complete = blizzardTotalScore or 0
            for _, info in pairs(blizzardAffixScoreData) do
                scoreData[info.name] = info.score
            end
        end
        if customRuns then
            for affix, info in pairs(customRuns) do
                scoreData[affix] = calcScore(dungeonId, info.level, info.durationSec)
            end
        end
        local cKeyScore = calcScoreSum(scoreData.Tyrannical, scoreData.Fortified)
        local bKeyScore = blizzardScores.Complete
        return cKeyScore - bKeyScore, cKeyScore
    end

    local function getWeeks()
        local affix = C_MythicPlus.GetCurrentAffixes()[1].id
        return const.AFFIX[affix], affix == 10 and const.AFFIX[9] or const.AFFIX[10]
    end

    local calculatorFrame = createRoundedFrame(UIParent, {
        height = 400,
        width = 600,
        border_size = 2,
        frame_strata = "FULLSCREEN"
    })
    calculatorFrame:Hide()
    calculatorFrame:MakeMovable()
    local function createTooltip(frame, tooltipText)
        widgets.BaseMixin.AddTooltip(frame, tooltipText)
    end
    local function createEditBox(parent, point, width, height, isNumeric, maxLetters, placeholder, tooltip)
        local editBox = CreateFrame("EditBox", nil, parent, "InputBoxInstructionsTemplate")
        editBox.Instructions:SetFontObject(styles.FONT_OBJECTS.BOLD)
        editBox.Instructions:SetText(placeholder)
        editBox:SetPoint(unpack(point))
        editBox:SetSize(width, height)
        editBox:SetFontObject(styles.FONT_OBJECTS.BOLD)
        editBox:SetJustifyH("LEFT")
        editBox:SetNumeric(isNumeric)
        editBox:SetMaxLetters(maxLetters)
        editBox:ClearFocus()
        editBox:SetAutoFocus(false)
        if tooltip then
            createTooltip(editBox, tooltip)
        end
        return editBox
    end

    ---- Add these to styles Constants
    local buttonDefault = CreateColorFromHexString("FF17191C")

    local function createToggleTexture(parent, point, size, state, texture, useAtlas, tooltip)
        local toggleTexture = parent:CreateTexture()
        function toggleTexture:GetEnabled()
            return not self:IsDesaturated()
        end

        function toggleTexture:SetEnabled(isEnabled)
            self:SetDesaturated(not isEnabled)
        end

        function toggleTexture:Toggle()
            self:SetEnabled(not self:GetEnabled())
        end

        toggleTexture:EnableMouse(true)
        toggleTexture:SetScript("OnMouseDown", function(self)
            self:Toggle()
        end)
        toggleTexture:SetPoint(unpack(point))
        toggleTexture:SetSize(size, size)
        toggleTexture:SetEnabled(state)
        if useAtlas then
            toggleTexture:SetAtlas(texture)
        else
            toggleTexture:SetTexture(texture)
        end
        if tooltip then
            createTooltip(toggleTexture, tooltip)
        end
        return toggleTexture
    end

    local topBar = CreateFrame("Frame", nil, calculatorFrame)
    topBar:SetPoint("TOPLEFT")
    topBar:SetPoint("TOPRIGHT")
    topBar:SetHeight(35)
    topBar.mask = topBar:CreateMaskTexture()
    topBar.mask:SetAllPoints()
    topBar.mask:SetTexture(getTexturePath('masks/rounded-button-big'), 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
    topBar.tex = topBar:CreateTexture()
    topBar.tex:SetAllPoints()
    topBar.tex:SetColorTexture(28 / 255, 29 / 255, 32 / 255, 1)
    topBar.tex:AddMaskTexture(topBar.mask)

    local topText = topBar:CreateFontString()
    topText:SetFont(styles.FONTS.BOLD, 16, "")
    topText:SetJustifyH("CENTER")
    topText:SetJustifyV("MIDDLE")
    topText:SetTextColor(styles.COLORS.TEXT_PRIMARY:GetRGBA())
    topText:SetAllPoints()
    topText:SetText(styles.COLORS.TEXT_HIGHLIGHT:WrapTextInColorCode("Keystone Companion") .. ": M+ Score Calculator")

    local closeButton = CreateFrame("Frame", nil, topBar)
    closeButton:SetPoint("RIGHT", -5, 0)
    closeButton:SetSize(20, 20)
    closeButton.tex = closeButton:CreateTexture(nil, "ARTWORK")
    closeButton.tex:SetAllPoints(closeButton)
    closeButton.tex:SetTexture(getTexturePath("widgets/ui-close-button"))
    closeButton.tex:SetVertexColor(.75, .75, .75)
    closeButton.mask = closeButton:CreateMaskTexture()
    closeButton.mask:SetAllPoints(closeButton.tex)
    closeButton.mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE",
        "CLAMPTOBLACKADDITIVE")
    closeButton.tex:AddMaskTexture(closeButton.mask)
    closeButton:EnableMouse(true)
    closeButton:SetScript("OnEnter", function(frame)
        frame.tex:SetVertexColor(1, 1, 1)
    end)
    closeButton:SetScript("OnLeave", function(frame)
        frame.tex:SetVertexColor(.75, .75, .75)
    end)
    closeButton:SetScript("OnMouseDown", function()
        calculatorFrame:Hide()
    end)

    local targetScore = createEditBox(calculatorFrame, { "TOPLEFT", topBar, "BOTTOMLEFT", 15, -15 }, 100, 20, true, 4,
        loc["Target Score"])
    local maxKeyLevel = createEditBox(calculatorFrame, { "TOPLEFT", targetScore, "BOTTOMLEFT", 0, -5 }, 100, 20, true, 2,
        loc["Max. Key Level"])
    local onlyCurrentWeekCB = createCheckBox(calculatorFrame, {
        points = { { "TOPLEFT", maxKeyLevel, "BOTTOMLEFT", -7, -5 } },
        default_state = true,
        font_object = styles.FONT_OBJECTS.BOLD,
        font_text = loc["Only this Week"],
    })
    local dungeonToggles = {}
    for dungeonIndex, mapID in ipairs(mythicPlusMaps) do
        local dungeonName, _, _, dungeonTexture = C_ChallengeMode.GetMapUIInfo(mapID)
        local toggleTexture = createToggleTexture(calculatorFrame,
            { "TOPRIGHT", topBar, "BOTTOMRIGHT", -15 + ((dungeonIndex - 1) * -55), -15 }, 50,
            true, dungeonTexture, false, dungeonName)
        toggleTexture.mapID = mapID
        tinsert(dungeonToggles, toggleTexture)
    end

    local calculateButton = createRoundedButton(calculatorFrame, {
        height = 30,
        points = { { "TOPRIGHT", dungeonToggles[1], "BOTTOMRIGHT", 0, -5 }, { "TOPLEFT", dungeonToggles[#dungeonToggles], "BOTTOMLEFT", 0, -5 } },
        border_size = 0,
        font_object = styles.FONT_OBJECTS.BOLD,
        font_text = loc["Calculate"]
    })
    calculateButton:SetScript("OnMouseDown", function(frame)
        local disabledDungeons = {}
        for _, toggle in ipairs(dungeonToggles) do
            if not toggle:GetEnabled() then
                disabledDungeons[toggle.mapID] = true
            end
        end
        local maxKeyNumber = tonumber(maxKeyLevel:GetText()) or 0
        local targetScoreNumber = tonumber(targetScore:GetText()) or 0
        local onlyCurrentWeekState = onlyCurrentWeekCB:GetChecked()
        frame.ShowResults(maxKeyNumber, targetScoreNumber, onlyCurrentWeekState, disabledDungeons)
    end)

    local _, scrollView = createScrollable(calculatorFrame, {
        frame_strata = "TOOLTIP",
        anchors = {
            with_scroll_bar = {
                CreateAnchor("TOPRIGHT", calculateButton, "BOTTOMRIGHT", -20, -5),
                CreateAnchor("BOTTOMLEFT", 15, 15)
            },
            without_scroll_bar = {
                CreateAnchor("TOPRIGHT", calculateButton, "BOTTOMRIGHT", 0, -5),
                CreateAnchor("BOTTOMLEFT", 15, 15)
            },
        },
        element_height = 65,
        element_padding = 5,
        elements_per_row = 1,
        extent_calculator = function(_, elementData)
            local rows = #elementData.rows
            return (rows * 35) + 50
        end,
        initializer = function(frame, elementData)
            frame.rows = frame.rows or {}
            for _, row in ipairs(frame.rows) do
                row:Hide()
            end
            if not frame.initialized then
                local background = CreateFrame("Frame", nil, frame, "BackdropTemplate")
                background:SetPoint("TOPLEFT")
                background:SetPoint("BOTTOMRIGHT", 0, 5)
                background:SetBackdrop({
                    bgFile = "Interface/buttons/white8x8.blp",
                    edgeFile = "interface/lfgframe/lfgborder.blp",
                    edgeSize = 2,
                })
                background:SetBackdropColor(buttonDefault:GetRGBA())
                background:SetBackdropBorderColor(0, 0, 0)

                local header = CreateFrame("Frame", nil, frame)
                header:SetPoint("TOPLEFT", 12, 0)
                header:SetPoint("TOPRIGHT", -12, 0)
                header:SetHeight(35)

                local name = header:CreateFontString()
                name:SetFontObject(styles.FONT_OBJECTS.BOLD)
                name:SetPoint("LEFT")
                name:SetText(loc["NAME"])

                local level = header:CreateFontString()
                level:SetFontObject(styles.FONT_OBJECTS.BOLD)
                level:SetPoint("LEFT", 175, 0)
                level:SetText(loc["LEVEL"])

                local affix = header:CreateFontString()
                affix:SetFontObject(styles.FONT_OBJECTS.BOLD)
                affix:SetPoint("LEFT", 250, 0)
                affix:SetText(loc["AFFIX"])

                local completion = header:CreateFontString()
                completion:SetFontObject(styles.FONT_OBJECTS.BOLD)
                completion:SetPoint("RIGHT", -125, 0)
                completion:SetText(loc["NEEDED"])

                local timeLimit = header:CreateFontString()
                timeLimit:SetFontObject(styles.FONT_OBJECTS.BOLD)
                timeLimit:SetPoint("RIGHT", -75, 0)
                timeLimit:SetText(loc["LIMIT"])

                local gain = header:CreateFontString()
                gain:SetFontObject(styles.FONT_OBJECTS.BOLD)
                gain:SetPoint("RIGHT")
                gain:SetText(loc["GAIN"])

                local divider = header:CreateTexture()
                divider:SetPoint("TOPLEFT", header, "BOTTOMLEFT")
                divider:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT")
                divider:SetHeight(2)
                divider:SetColorTexture(styles.COLORS.TEXT_SECONDARY:GetRGBA())
                frame.headDivider = divider

                frame.initialized = true
            end
            local rowAnchor = frame.headDivider
            for index, rowData in ipairs(elementData.rows) do
                local row = frame.rows[index]
                if not row then
                    row = CreateFrame("Frame", nil, frame)
                    row:SetPoint("TOPLEFT", rowAnchor, "BOTTOMLEFT", 0, -5)
                    row:SetPoint("TOPRIGHT", rowAnchor, "BOTTOMRIGHT", 0, -5)
                    row:SetHeight(30)

                    local name = row:CreateFontString()
                    name:SetFontObject(styles.FONT_OBJECTS.BOLD)
                    name:SetPoint("LEFT")
                    row.name = name

                    local level = row:CreateFontString()
                    level:SetFontObject(styles.FONT_OBJECTS.BOLD)
                    level:SetPoint("LEFT", 175, 0)
                    row.level = level

                    local affix = row:CreateFontString()
                    affix:SetFontObject(styles.FONT_OBJECTS.BOLD)
                    affix:SetPoint("LEFT", 250, 0)
                    row.affix = affix

                    local completion = row:CreateFontString()
                    completion:SetFontObject(styles.FONT_OBJECTS.BOLD)
                    completion:SetPoint("RIGHT", -125, 0)
                    row.completion = completion

                    local timeLimit = row:CreateFontString()
                    timeLimit:SetFontObject(styles.FONT_OBJECTS.BOLD)
                    timeLimit:SetPoint("RIGHT", -75, 0)
                    row.timeLimit = timeLimit

                    local gain = row:CreateFontString()
                    gain:SetFontObject(styles.FONT_OBJECTS.BOLD)
                    gain:SetPoint("RIGHT")
                    row.gain = gain

                    local divider = row:CreateTexture()
                    divider:SetPoint("TOPLEFT", row, "BOTTOMLEFT")
                    divider:SetPoint("TOPRIGHT", row, "BOTTOMRIGHT")
                    divider:SetHeight(2)
                    divider:SetColorTexture(styles.COLORS.TEXT_SECONDARY:GetRGBA())
                    row.divider = divider
                end
                row:Show()
                frame.rows[index] = row
                rowAnchor = row

                if rowData.impossible then
                    row.name:SetText("|cFFe74c3c" .. loc["Not Possible!"])
                    row.level:SetText("")
                    row.affix:SetText("")
                    row.timeLimit:SetText("")
                    row.completion:SetText("")
                    row.gain:SetText("")
                    return
                end

                local dungeonName, _, dungeonTime, dungeonTexture = C_ChallengeMode.GetMapUIInfo(rowData.dungeon)
                local affixName, _, affixTexture = C_ChallengeMode.GetAffixInfo(rowData.affix)
                local levelColor = C_ChallengeMode.GetKeystoneLevelRarityColor(rowData.level or 0)

                row.name:SetText(string.format("|T%s:16|t %s", dungeonTexture, dungeonName))
                row.level:SetText(levelColor:WrapTextInColorCode((rowData.level or 0) .. "+++"))
                row.affix:SetText(string.format("|T%s:16|t %s", affixTexture, affixName))
                row.timeLimit:SetText(SecondsToClock(dungeonTime))
                row.completion:SetText(SecondsToClock(dungeonTime * 0.6))
                row.gain:SetText(string.format("%.2f", rowData.gain))
            end
        end
    })

    local impossibleRun = {
        {
            rows = {
                {
                    impossible = true
                }
            }
        }
    }
    local function printScoreTable(maxKey, targetRating, onlyCurrentWeek, bannedDungeons)
        if maxKey == 0 then
            scrollView:UpdateContentData(impossibleRun)
            return
        end
        targetRating = targetRating or 0
        newIterationData()
        local dungeonsRun = {}
        local week, otherWeek = getWeeks()
        local currentScore = C_ChallengeMode.GetOverallDungeonScore()
        local neededScore = targetRating - currentScore
        local maxRun = {
            [week] = { level = maxKey, durationSec = 1 }
        }
        if not onlyCurrentWeek then
            maxRun[otherWeek] = { level = maxKey, durationSec = 1 }
        end
        for _, dungeonId in ipairs(mythicPlusMaps) do
            for runWeek, runTable in pairs(maxRun) do
                if not bannedDungeons[dungeonId] then
                    local gain = calcScores(dungeonId, { [runWeek] = runTable })
                    tinsert(dungeonsRun, { dungeon = dungeonId, gain = gain, week = runWeek, level = runTable.level })
                end
            end
        end
        sort(dungeonsRun, function(a, b)
            return a.gain > b.gain
        end)
        local runs = {}
        for _, v in ipairs(dungeonsRun) do
            neededScore = neededScore - v.gain
            tinsert(runs, {
                dungeon = v.dungeon,
                affix = const.AFFIX[v.week],
                level = v.level,
                gain = v.gain,
            })
            if neededScore <= 0 then
                break
            end
        end
        if neededScore > 0 then
            scrollView:UpdateContentData(impossibleRun)
        else
            scrollView:UpdateContentData({
                {
                    rows = runs
                },
            })
        end
    end

    calculateButton.ShowResults = printScoreTable

    local UI = Private.UI
    local function createCalcButton(parent, offsetX, offsetY)
        local calcButton = CreateFrame('Frame', nil, parent)
        calcButton:SetSize(25, 25)
        calcButton:SetPoint('TOPRIGHT', parent, 'TOPRIGHT', offsetX, offsetY)
        local mask = calcButton:CreateMaskTexture()
        mask:SetAllPoints()
        mask:SetTexture(getTexturePath('widgets/settings-button'), 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
        local background = calcButton:CreateTexture(nil, "BACKGROUND")
        background:SetAllPoints()
        background:SetColorTexture(28 / 255, 29 / 255, 32 / 255)
        background:AddMaskTexture(mask)
        local icon = calcButton:CreateTexture()
        icon:SetPoint("TOPLEFT", 2, -2)
        icon:SetPoint("BOTTOMRIGHT", -2, 2)
        icon:SetTexture(getTexturePath("widgets/calculator"))
        icon:SetVertexColor(.9, .9, .9)
        calcButton.bg = background

        calcButton:EnableMouse(true)
        calcButton:SetScript("OnMouseDown", function()
            calculatorFrame:Show()
        end)
        calcButton:SetScript("OnEnter", function(frame)
            frame.bg:SetColorTexture(50 / 255, 51 / 255, 54 / 255)
        end)
        calcButton:SetScript("OnLeave", function(frame)
            frame.bg:SetColorTexture(28 / 255, 29 / 255, 32 / 255)
        end)
        return calcButton
    end

    UI.CalculatorButton = createCalcButton(UI.Frame.Top, -30, 0)
    createCalcButton(ChallengesFrame, -15, -30)
end
