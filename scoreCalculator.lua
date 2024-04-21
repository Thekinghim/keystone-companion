local KeystoneCompanion = select(2, ...)
local getTexturePath = KeystoneCompanion.utils.path.getTexturePath
local mythicPlusMaps = C_ChallengeMode.GetMapTable()

local const = {
    THRESHOLD = 0.4,
    MAX_ADDITION = 5,
    MAX_REMOVAL = 10,
    BASE_SCORE = { 0, 40, 45, 55, 60, 65, 75, 80, 85, 100 },
    AFFIX = { [9] = "Tyrannical", [10] = "Fortified" }
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
local function newIterationData()
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
local function printScoreTable(maxKey, targetRating, onlyCurrentWeek, bannedDungeons)
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
                tinsert(dungeonsRun, { dungeon = dungeonId, gain = gain, week = runWeek })
            end
        end
    end
    sort(dungeonsRun, function(a, b)
        return a.gain > b.gain
    end)
    for _, v in ipairs(dungeonsRun) do
        neededScore = neededScore - v.gain
        local dungeonName = C_ChallengeMode.GetMapUIInfo(v.dungeon)
        print(string.format("Dungeon: %s (%s), gives %d", dungeonName, v.week, v.gain))
        if neededScore <= 0 then
            break
        end
    end
    if neededScore > 0 then
        print("not reachable")
    else
        print(currentScore .. " to " .. targetRating)
    end
end

local calculatorFrame = KeystoneCompanion.widgets.RoundedFrame.CreateFrame(UIParent, {
    height = 400,
    width = 600,
    border_size = 2,
})

local styles = KeystoneCompanion.constants.styles
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

local targetScore = createEditBox(calculatorFrame, { "TOPLEFT", 15, -15 }, 100, 20, true, 4, "Target Score")
local maxKeyLevel = createEditBox(calculatorFrame, { "TOPLEFT", 15, -45 }, 100, 20, true, 2, "Max. Key Level")
local onlyCurrentWeek = createCheckBox(calculatorFrame, { "TOPLEFT", 8, -75 }, 20, true, false, "Only this Week")
local dungeonToggles = {}
for dungeonIndex, mapID in ipairs(mythicPlusMaps) do
    local dungeonName, _, _, dungeonTexture = C_ChallengeMode.GetMapUIInfo(mapID)
    local toggleTexture = createToggleTexture(calculatorFrame, { "TOPLEFT", 140 + ((dungeonIndex - 1) * 55), -15 }, 50,
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
    local onlyCurrentWeekState = onlyCurrentWeek:GetChecked()
    printScoreTable(maxKeyNumber, targetScoreNumber, onlyCurrentWeekState, disabledDungeons)
end)
