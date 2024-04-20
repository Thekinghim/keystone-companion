local KeystoneCompanion = select(2, ...)

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
    for _, dungeonId in ipairs(C_ChallengeMode.GetMapTable()) do
        if not bannedDungeons[dungeonId] then
            local gain = calcScores(dungeonId, maxRun)
            tinsert(dungeonsRun, { dungeon = dungeonId, gain = gain })
        end
    end
    sort(dungeonsRun, function(a, b)
        return a.gain > b.gain
    end)
    for k, v in ipairs(dungeonsRun) do
        neededScore = neededScore - v.gain
        print(k, v.dungeon, v.gain)
        if neededScore <= 0 then
            break
        end
    end
    print(currentScore .. " to " .. targetRating)
end
printScoreTable(20, 2730, true, {[244] = true})

local calculatorFrame = KeystoneCompanion.widgets.RoundedFrame.CreateFrame(UIParent, {
    height = 400,
    width = 600,
    border_size = 2,
})
