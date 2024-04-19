local addonName, Private = ...
local addon = Private.Addon

addon.constants = addon.constants or { misc = {} }
addon.constants.misc = addon.constants.misc or {}
local const = addon.constants.misc

const.ASSETS_PATH = "interface/addons/" .. addonName .. "/assets"
const.COLORS = {
    BACKGROUND = CreateColorFromHexString("99131315"),
    FOREGROUND = CreateColorFromHexString("FF009901"),
    BORDER = CreateColorFromHexString("FFFF8000"),

    TEXT_PRIMARY = CreateColorFromHexString("FFFFFFFF"),
    TEXT_SECONDARY = CreateColorFromHexString("FFFF8000"),

    POSITIVE = CreateColorFromHexString("FF02FF03"),
    NEGATIVE = CreateColorFromHexString("FFFF0000"),
    NEUTRAL = CreateColorFromHexString("FFF4ED03"),
}
const.TEXTURES = {
    ROUNDED_BORDER = const.ASSETS_PATH .. "/textures/rounded-square-border-2px.tga", -- added files for different border sizes use rounded-square-border-[size]px.tga (available 2, 4, 6, 8, 10)
    ROUNDED_SQUARE = const.ASSETS_PATH .. "/textures/rounded-square.tga",
}
const.VALID_BORDER_SIZES = {
    [1] = true, [2] = true, [4] = true, [6] = true, [8] = true, [10] = true
}
const.FONTS = {
    DEFAULT = const.ASSETS_PATH .. "/fonts/SF-Pro.ttf",
    SEMIBOLD = const.ASSETS_PATH .. "/fonts/SF-Pro-Display-Semibold.otf",
    BOLD = const.ASSETS_PATH .. "/fonts/RobotoSlab-Bold.ttf",
}
const.FONT_OBJECTS = {
    DEFAULT_SMALL = addonName .. "DefaultSmall",
    SEMIBOLD_SMALL = addonName .. "SemiboldSmall",
    BOLD_SMALL = addonName .. "BoldSmall",

    DEFAULT = addonName .. "Default",
    SEMIBOLD = addonName .. "Semibold",
    BOLD = addonName .. "Bold",
}
-- [[ Create Font Objects ]] --
do
    local font = CreateFont(addonName .. "Default")
    font:SetFont(const.FONTS.DEFAULT, 16, "")
    font:SetJustifyH("LEFT")
    font:SetJustifyV("MIDDLE")
    font:SetTextColor(const.COLORS.TEXT_PRIMARY:GetRGBA())
end
do
    local font = CreateFont(addonName .. "Semibold")
    font:CopyFontObject(const.FONT_OBJECTS.DEFAULT)
    font:SetFont(const.FONTS.SEMIBOLD, 16, "")
end
do
    local font = CreateFont(addonName .. "Bold")
    font:CopyFontObject(const.FONT_OBJECTS.DEFAULT)
    font:SetFont(const.FONTS.BOLD, 16, "")
end
do
    local font = CreateFont(addonName .. "DefaultSmall")
    font:CopyFontObject(const.FONT_OBJECTS.DEFAULT)
    font:SetFont(const.FONTS.DEFAULT, 14, "")
end
do
    local font = CreateFont(addonName .. "SemiboldSmall")
    font:CopyFontObject(const.FONT_OBJECTS.SEMIBOLD)
    font:SetFont(const.FONTS.SEMIBOLD, 14, "")
end
do
    local font = CreateFont(addonName .. "BoldSmall")
    font:CopyFontObject(const.FONT_OBJECTS.BOLD)
    font:SetFont(const.FONTS.BOLD, 14, "")
end
