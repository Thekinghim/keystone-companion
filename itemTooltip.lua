local trackRanges = {
    ["Adventurer"] = { min = 10305, max = 10312, levels = " [467 - 483]" },
    ["Champion"] = { min = 10313, max = 10320, levels = " [493 - 515]" },
    ["Explorer"] = { min = 10321, max = 10328, levels = " [454 - 476]" },
    ["Hero"] = { min = 10329, max = 10334, levels = " [506 - 522]" },
    ["Myth"] = { min = 10335, max = 10338, levels = " [519 - 528]" },
    ["Veteran"] = { min = 10341, max = 10348, levels = " [480 - 502]" },
}
local currencies = {
    [2806] = " [467 - 489]", -- Whelpling's Awakened Crest
    [2807] = " [493 - 502]", -- Drake's Awakened Crest
    [2809] = " [506 - 515]", -- Wyrm's Awakened Crest
    [2812] = " [519 - 528]", -- Aspect's Awakened Crest
}
local tracks = {}

for _, trackInfo in pairs(trackRanges) do
    for i = trackInfo.min, trackInfo.max do
        tracks[i] = trackInfo.levels
    end
end

local function getTrack(link)
    local _, linkOptions = LinkUtil.ExtractLink(link)
    local item = { strsplit(":", linkOptions) }

    local numBonusIDs = tonumber(item[13])
    if numBonusIDs then
        for i = 1, numBonusIDs do
            if tracks[tonumber(item[13 + i])] then
                return tracks[tonumber(item[13 + i])]
            end
        end
    end
    return false
end

local function updateTooltip(tooltip, addition)
    tooltip.TextLeft1:SetText((tooltip.TextLeft1:GetText() or "") .. addition)
end
local function updateItemTooltip(tooltip)
    if not tooltip or not tooltip.GetItem then return end
    local link = select(2, tooltip:GetItem())
    if not link then return end
    local trackStr = getTrack(link)
    if trackStr then
        updateTooltip(tooltip, trackStr)
    end
end
local function updateCurrencyTooltip(tooltip, data)
    if data.id and currencies[data.id] then
        updateTooltip(tooltip, currencies[data.id])
    end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Currency, updateCurrencyTooltip)
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, updateItemTooltip)
