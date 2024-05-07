local _, Private = ...
local CreateRoundedFrame = Private.widgets.RoundedFrame.CreateFrame
local styles = Private.constants.styles

local settingsFrame = CreateRoundedFrame(UIParent, {
    height = 200,
    width = 200,
    border_size = 0,
    background_color = CreateColor(1, 1, 1, 0.5),
})
settingsFrame:Hide()
local settingsTitle = settingsFrame:CreateFontString()
settingsTitle:SetFontObject(styles.FONT_OBJECTS.BOLD)
settingsTitle:SetText("Settings")
settingsTitle:SetPoint("TOP", 0, -5)
