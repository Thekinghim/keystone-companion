local _, Private = ...
local rf = Private.RoundedFrame
local const = Private.constants.misc

local headerColor = CreateColorFromHexString("0DD0DCF5")
local barColor = CreateColorFromHexString("FF333333")

local timerFrame = rf.CreateFrame(UIParent, {
    width = 352,
    height = 265,
    border_texture = rf.GetBorderForSize(1),
    border_size = 1,
})
local headerBar = rf.CreateFrame(timerFrame, {
    height = 38,
    use_border = false,
    background_color = headerColor,
    points = {
        { "TOPLEFT",  12,  -12 },
        { "TOPRIGHT", -12, -12 }
    }
})
local timeBar = rf.CreateFrame(headerBar, {
    height = 25,
    use_border = false,
    background_color = barColor,
    points = {
        { "TOPLEFT",  headerBar, "BOTTOMLEFT",  0, -12 },
        { "TOPRIGHT", headerBar, "BOTTOMRIGHT", 0, -12 }
    }
})
local countBar = rf.CreateFrame(timerFrame, {
    height = 33,
    background_color = barColor,
    border_size = 1,
    points = {
        { "BOTTOMLEFT",  12,  12 },
        { "BOTTOMRIGHT", -12, 12 }
    }
})

local deathText = headerBar:CreateFontString()
deathText:SetFontObject(const.FONT_OBJECTS.SEMIBOLD)
deathText:SetJustifyH("RIGHT")
deathText:SetTextColor(const.COLORS.TEXT_SECONDARY:GetRGBA())
deathText:SetPoint("RIGHT", -12, 0)
deathText:SetText("20 " .. ICON_LIST[8] .. "14|t")

local dungeonTitle = headerBar:CreateFontString()
dungeonTitle:SetFontObject(const.FONT_OBJECTS.SEMIBOLD)
dungeonTitle:SetJustifyH("LEFT")
dungeonTitle:SetTextColor(const.COLORS.TEXT_PRIMARY:GetRGBA())
dungeonTitle:SetPoint("LEFT", 12, 0)
dungeonTitle:SetText("+30 Halls of Valor")

local affixes = headerBar:CreateFontString()
affixes:SetFontObject(const.FONT_OBJECTS.SEMIBOLD)
affixes:SetJustifyH("LEFT")
affixes:SetPoint("LEFT", dungeonTitle, "RIGHT", 12, 0)
function affixes:SetAffixes(...)
    local affixString = ""
    for _, affixID in ipairs({ ... }) do
        local affixFile = select(3, C_ChallengeMode.GetAffixInfo(affixID))
        if affixFile then
            affixString = string.format("%s|T%s:14|t", affixString, affixFile)
        end
    end
    self:SetText(affixString)
end

affixes:SetAffixes(9, 11, 3, 132)
