---@class KeystoneCompanionPrivate
local Private = select(2, ...)
---@class KeystoneCompanion
local addon = Private.Addon
local styles = Private.constants.styles
local widgets = Private.widgets

local dungeonShorts = {
    [410071] = "FH",
    [410074] = "UNDR",
    [373274] = "MECH",
    [424167] = "WM",
    [424187] = "AD",
    [410080] = "VP",
    [424142] = "TOTT",
    [393256] = "RLP",
    [393262] = "NO",
    [393267] = "BH",
    [393273] = "AA",
    [393276] = "NELT",
    [393279] = "AV",
    [393283] = "HOI",
    [393222] = "ULD",
    [424197] = "DOTI",
    [393764] = "HOV",
    [410078] = "NL",
    [393766] = "COS",
    [373262] = "KARA",
    [424153] = "BRH",
    [424163] = "DHT",
    [131204] = "TJS",
    [131205] = "SSB",
    [131206] = "SPM",
    [131222] = "MSP",
    [131225] = "GSS",
    [131231] = "SH",
    [131229] = "SM",
    [131232] = "SCHO",
    [131228] = "SON",
    [373190] = "CN",
    [373191] = "SOD",
    [373192] = "SOTFO",
    [159895] = "BSM",
    [159897] = "AU",
    [159898] = "SR",
    [159901] = "EB",
    [159899] = "SBG",
    [159902] = "UBS",
    [159900] = "GD",
    [159896] = "ID",
}
local spellCache = {}

local function teleportButtonInit(button, data)
    ---@cast button Button
    if not button.initialized then
        local icon = button:CreateTexture(nil, "BACKGROUND")
        local mask = button:CreateMaskTexture(nil, "BACKGROUND")
        local text = button:CreateFontString()
        text:SetFont(styles.FONTS.HEADING, 12, "OUTLINE")
        text:SetAllPoints()
        mask:SetAllPoints(icon)
        mask:SetAtlas("UI-Frame-IconMask")
        icon:AddMaskTexture(mask)
        button.icon = icon
        button.text = text
        button.initialized = true
        button:SetAttribute("type", "spell")
        button:RegisterForClicks("AnyUp", "AnyDown")
    end
    button:SetAttribute("spell", data.spellID)
    button.icon:SetTexture(GetSpellTexture(data.spellID))
    button.icon:SetDesaturated(not IsSpellKnown(data.spellID))
    button:SetNormalTexture(button.icon)
    button.text:SetText(dungeonShorts[data.spellID])
    local spell = Spell:CreateFromSpellID(data.spellID)
    spell:ContinueOnSpellLoad(function()
        local name = spell:GetSpellName()
        local desc = spell:GetSpellDescription()
        spellCache[data.spellID] = {
            name = name,
            desc = desc,
            search = name .. desc
        }
        widgets.BaseMixin.AddTooltip(button,
            string.format("%s\n%s%s", name, styles.COLORS.TEXT_SECONDARY:GenerateHexColorMarkup(), desc))
    end)
end

local function createTeleportFrame()
    local mPlusFrame = ChallengesFrame
    if C_AddOns.IsAddOnLoaded("RaiderIO") and _G["RaiderIO_ProfileTooltip"] then
        mPlusFrame = _G["RaiderIO_ProfileTooltip"]
    end
    local baseFrame = widgets.RoundedFrame.CreateFrame(mPlusFrame, {
        points = {
            { "TOPLEFT",    mPlusFrame, "TOPRIGHT",    5, -5 },
            { "BOTTOMLEFT", mPlusFrame, "BOTTOMRIGHT", 5, 5 },
        },
        width = 250,
        border_size = 2,
    })
    local scrollBox, scrollView = widgets.ScrollableFrame.CreateFrame(baseFrame, {
        initializer = teleportButtonInit,
        template = "InsecureActionButtonTemplate",
        type = "GRID",
        element_height = 50,
        element_padding = 5,
        elements_per_row = 4,
        anchors = {
            with_scroll_bar = {
                CreateAnchor("TOPLEFT", 10, -40),
                CreateAnchor("BOTTOMRIGHT", -25, 10)
            },
            without_scroll_bar = {
                CreateAnchor("TOPLEFT", 10, -40),
                CreateAnchor("BOTTOMRIGHT", -10, 10)
            },
        },
    })
    local searchBox = widgets.TextBox.CreateFrame(baseFrame, {
        instructions = "Search",
        points = {
            { "TOPLEFT",  10,        -10 },
            { "TOPRIGHT", -10,       -10 },
            { "BOTTOM",   scrollBox, "TOP", 0, 10 }
        }
    })

    local function isMatchingFilter(spellID, filter)
        if (not filter) or type(filter) ~= "string" then return true end
        filter = filter:gsub("%%", "%%%%"):gsub("%+", "%%+")
        local spellInfo = spellCache[spellID]
        if not spellInfo then return true end
        local spellSearch = spellInfo.search:lower()
        if not (filter and not spellSearch:match(filter)) then
            return true
        end
        return false
    end

    local function updateTeleports(filterString)
        scrollView:UpdateContentData({})
        for _, spellID in pairs(Private.constants.dungeonTeleports) do
            if (filterString and isMatchingFilter(spellID, filterString)) or not filterString then
                scrollView:UpdateContentData({ { spellID = spellID } }, true)
            end
        end
    end

    searchBox.callback = function(_, text)
        updateTeleports(text)
    end
    baseFrame:SetScript("OnShow", updateTeleports)
end

local function onEvent(_, event, loadedAddon)
    if event == "ADDON_LOADED" and loadedAddon == "Blizzard_ChallengesUI" then
        createTeleportFrame()
    end
end

addon:RegisterEvent("ADDON_LOADED", "ui/dungeonTeleports.lua", onEvent)
