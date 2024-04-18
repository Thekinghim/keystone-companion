local _, Private = ...
local rf = Private.RoundedFrame

local options = {
    width = 352,
    height = 265,
}
local headerColor = CreateColorFromHexString("0DD0DCF5")
local barColor = CreateColorFromHexString("FF333333")

local timerFrame = rf.CreateFrame(UIParent, options)
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
