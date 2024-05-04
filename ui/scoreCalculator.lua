local _, KeystoneCompanion = ...
local styles = KeystoneCompanion.constants.styles;
local getTexturePath = KeystoneCompanion.utils.path.getTexturePath
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

local calculatorFrame = KeystoneCompanion.widgets.RoundedFrame.CreateFrame(UIParent, {
    height = 400,
    width = 600,
    border_size = 2,
})
calculatorFrame:SetFrameStrata("FULLSCREEN")
calculatorFrame:Hide()
calculatorFrame:EnableMouse(true)
calculatorFrame:SetMovable(true)
calculatorFrame:SetScript("OnMouseDown", function(self)
    self:StartMoving()
end)
calculatorFrame:SetScript("OnMouseUp", function(self)
    self:StopMovingOrSizing()
end)
local function createTooltip(frame, tooltipText)
    frame:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(tooltipText, styles.COLORS.TEXT_PRIMARY:GetRGBA())
        GameTooltip:Show()
    end)
    frame:HookScript("OnLeave", function()
        GameTooltip:Hide()
    end)
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
local function createCheckBox(parent, point, size, state, isDisabled, text, tooltip)
    local checkBox = CreateFrame("CheckButton", nil, parent)
    local check = checkBox:CreateTexture()
    local checkDisable = checkBox:CreateTexture()
    check:SetAtlas("checkmark-minimal")
    checkDisable:SetAtlas("checkmark-minimal-disabled")
    checkBox:SetDisabledCheckedTexture(checkDisable)
    checkBox:SetCheckedTexture(check)
    checkBox:SetSize(size, size)
    checkBox:SetPoint(unpack(point))
    checkBox:SetNormalAtlas("checkbox-minimal")
    checkBox:SetPushedAtlas("checkbox-minimal")
    checkBox:SetChecked(state)
    checkBox:SetEnabled(not isDisabled)
    local label = checkBox:CreateFontString()
    label:SetFontObject(styles.FONT_OBJECTS.BOLD)
    label:SetJustifyH("LEFT")
    label:SetPoint("LEFT", checkBox, "RIGHT", 8, 0)
    label:SetText(text)
    if tooltip then
        createTooltip(checkBox, tooltip)
        createTooltip(label, tooltip)
    end
    return checkBox
end

-- Add these to styles Constants
local buttonDefault = CreateColorFromHexString("FF17191C")
local buttonHover = CreateColorFromHexString("FF36373B")

local function createRoundedButton(parent, point, width, height, isDisabled, text, tooltip)
    ---@class roundedButton : Frame
    local button = CreateFrame("Frame", nil, parent)
    button:SetPoint(unpack(point))
    button:SetSize(width, height)
    local mask = button:CreateMaskTexture()
    mask:SetAllPoints(button)
    mask:SetTexture(getTexturePath('masks/rounded-button-big'))
    local texture = button:CreateTexture()
    texture:SetAllPoints(button)
    texture:SetColorTexture(buttonDefault:GetRGBA())
    texture:AddMaskTexture(mask)
    local label = button:CreateFontString()
    label:SetFontObject(styles.FONT_OBJECTS.BOLD)
    label:SetPoint("CENTER")
    label:SetText(text)
    button.disabled = isDisabled
    button.texture = texture
    button.label = label
    button:SetScript("OnEnter", function(self)
        if not self.disabled then
            self.texture:SetColorTexture(buttonHover:GetRGBA())
        end
    end)
    button:SetScript("OnLeave", function(self)
        self.texture:SetColorTexture(buttonDefault:GetRGBA())
    end)
    if tooltip then
        createTooltip(button, tooltip)
    end

    return button
end

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

--[[
        local options = {
            parent = UIParent, -- Parent Frame
            anchors = { -- Anchors for the frame
                {"TOPLEFT"},
                {"BOTTOMRIGHT"}
            },
            type = "LIST", -- Type is either List or Grid
            initializer = function () end, -- Initializer function to create the elements
            extentCalculator = function () end, -- needed for elements without fixed height
            elementExtent= 25, -- Height of the elements if fixed
            elementsPerRow = 1, -- Number of elements per row (GRID)
            elementPadding = 0, -- Padding between elements (GRID)
            template = 0, -- Template that is used for the elements
        }
    ]]

local function createScrollable(options)
    local scrollBox = CreateFrame("Frame", nil, options.parent, "WowScrollBoxList")
    scrollBox:SetPoint(unpack(options.anchors[2]))
    scrollBox:SetPoint(unpack(options.anchors[1]))

    local scrollBar = CreateFrame("EventFrame", nil, options.parent, "MinimalScrollBar")
    scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 5, 0)
    scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT")
    scrollBar:SetHideIfUnscrollable(true)

    local scrollView = nil
    if options.type == "LIST" then
        scrollView = CreateScrollBoxListLinearView()
        scrollView:SetElementInitializer(options.template or "BackdropTemplate", options.initializer)
        ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, scrollView)
    elseif options.type == "GRID" then
        local fillWidth = (options.parent:GetWidth() - (options.elementsPerRow - 1) * options.elementPadding) /
            options.elementsPerRow
        scrollView = CreateScrollBoxListGridView(options.elementsPerRow, 0, 0, 0, 0, options.elementPadding,
            options.elementPadding);
        scrollView:SetElementInitializer(options.template or "BackdropTemplate", function(button, elementData)
            button:SetSize(fillWidth, options.elementHeight)
            options.initializer(button, elementData)
        end)
        ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, scrollView);
    end
    if options.extentCalculator then
        scrollView:SetElementExtentCalculator(options.extentCalculator)
    else
        scrollView:SetElementExtent(options.elementHeight)
    end

    function scrollView:UpdateContentData(data)
        local scrollPercent = scrollBox:GetScrollPercentage()
        self:Flush()
        local dataProvider = CreateDataProvider()
        self:SetDataProvider(dataProvider)
        if not data then return end
        for _, part in ipairs(data) do
            dataProvider:Insert(part)
        end
        scrollBox:SetScrollPercentage(scrollPercent or 1)
    end

    return scrollView, scrollBox, scrollBar
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
closeButton:SetScript("OnEnter", function(self)
    self.tex:SetVertexColor(1, 1, 1)
end)
closeButton:SetScript("OnLeave", function(self)
    self.tex:SetVertexColor(.75, .75, .75)
end)
closeButton:SetScript("OnMouseDown", function()
    calculatorFrame:Hide()
end)

local targetScore = createEditBox(calculatorFrame, { "TOPLEFT", topBar, "BOTTOMLEFT", 15, -15 }, 100, 20, true, 4,
    "Target Score")
local maxKeyLevel = createEditBox(calculatorFrame, { "TOPLEFT", targetScore, "BOTTOMLEFT", 0, -5 }, 100, 20, true, 2,
    "Max. Key Level")
local onlyCurrentWeekCB = createCheckBox(calculatorFrame, { "TOPLEFT", maxKeyLevel, "BOTTOMLEFT", -7, -5 }, 20, true,
    false, "Only this Week")
local dungeonToggles = {}
for dungeonIndex, mapID in ipairs(mythicPlusMaps) do
    local dungeonName, _, _, dungeonTexture = C_ChallengeMode.GetMapUIInfo(mapID)
    local toggleTexture = createToggleTexture(calculatorFrame,
        { "TOPLEFT", topBar, "BOTTOMLEFT", 140 + ((dungeonIndex - 1) * 55), -15 }, 50,
        true, dungeonTexture, false, dungeonName)
    toggleTexture.mapID = mapID
    tinsert(dungeonToggles, toggleTexture)
end

local calculateButton = createRoundedButton(calculatorFrame, { "TOPLEFT", dungeonToggles[1], "BOTTOMLEFT", 0, -5 }, 200,
    30, false, "Calculate")
calculateButton:SetPoint("TOPRIGHT", dungeonToggles[#dungeonToggles], "BOTTOMRIGHT", 0, -5)
calculateButton:SetScript("OnMouseDown", function(self)
    local disabledDungeons = {}
    for _, toggle in ipairs(dungeonToggles) do
        if not toggle:GetEnabled() then
            disabledDungeons[toggle.mapID] = true
        end
    end
    local maxKeyNumber = tonumber(maxKeyLevel:GetText()) or 0
    local targetScoreNumber = tonumber(targetScore:GetText()) or 0
    local onlyCurrentWeekState = onlyCurrentWeekCB:GetChecked()
    self.ShowResults(maxKeyNumber, targetScoreNumber, onlyCurrentWeekState, disabledDungeons)
end)

local scrollView = createScrollable({
    parent = calculatorFrame,
    anchors = {
        { "TOPRIGHT",   calculateButton, "BOTTOMRIGHT", 0, -5 },
        { "BOTTOMLEFT", 15,              15 }
    },
    type = "LIST",
    elementHeight = 65,
    elementPadding = 5,
    elementsPerRow = 1,
    extentCalculator = function(_, elementData)
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
            name:SetText("NAME")

            local level = header:CreateFontString()
            level:SetFontObject(styles.FONT_OBJECTS.BOLD)
            level:SetPoint("LEFT", 175, 0)
            level:SetText("LEVEL")

            local affix = header:CreateFontString()
            affix:SetFontObject(styles.FONT_OBJECTS.BOLD)
            affix:SetPoint("LEFT", 250, 0)
            affix:SetText("AFFIX")

            local completion = header:CreateFontString()
            completion:SetFontObject(styles.FONT_OBJECTS.BOLD)
            completion:SetPoint("RIGHT", -125, 0)
            completion:SetText("NEEDED")

            local timeLimit = header:CreateFontString()
            timeLimit:SetFontObject(styles.FONT_OBJECTS.BOLD)
            timeLimit:SetPoint("RIGHT", -75, 0)
            timeLimit:SetText("LIMIT")

            local gain = header:CreateFontString()
            gain:SetFontObject(styles.FONT_OBJECTS.BOLD)
            gain:SetPoint("RIGHT")
            gain:SetText("GAIN")

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
                row.name:SetText("|cFFe74c3cNot Possible!|r")
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

local UI = KeystoneCompanion.UI
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
    calcButton:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(50 / 255, 51 / 255, 54 / 255)
    end)
    calcButton:SetScript("OnLeave", function(self)
        self.bg:SetColorTexture(28 / 255, 29 / 255, 32 / 255)
    end)
    return calcButton
end

UI.CalculatorButton = createCalcButton(UI.Frame.Top, -30, 0)

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, event, addon)
    if event == "ADDON_LOADED" and addon == "Blizzard_ChallengesUI" then
        createCalcButton(ChallengesFrame, -15, -30)
        eventFrame:UnregisterAllEvents()
    end
end)
