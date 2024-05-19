---@class KeystoneCompanionPrivate
local Private = select(2, ...)
---@class KeystoneCompanion
local addon = Private.Addon
local loc = addon.Loc
local styles = Private.constants.styles
local widgets = Private.widgets

local function teleportButtonInit(button, data)
    ---@cast button Button
    if not button.initialized then
        local icon = button:CreateTexture()
        icon:SetPoint("TOPLEFT", 1, -1)
        icon:SetPoint("BOTTOMRIGHT", -1, 1)
        local mask = button:CreateMaskTexture();
        mask:SetAllPoints(icon)
        mask:SetAtlas("UI-Frame-IconMask")
        icon:AddMaskTexture(mask)
        button.icon = icon
        button.initialized = true
        button:SetAttribute("type", "spell")
        button:RegisterForClicks("AnyUp", "AnyDown")
    end
    button:SetAttribute("spell", data.spellID)
    button.icon:SetTexture(GetSpellTexture(data.spellID))
    button.icon:SetDesaturated(not IsSpellKnown(data.spellID))
    button:SetNormalTexture(button.icon)
    local spell = Spell:CreateFromSpellID(data.spellID)
    spell:ContinueOnSpellLoad(function()
        local name = spell:GetSpellName()
        local desc = spell:GetSpellDescription()
        widgets.BaseMixin.AddTooltip(button, string.format("%s\n%s%s", name, styles.COLORS.TEXT_SECONDARY:GenerateHexColorMarkup(), desc))
    end)
end

local function createTeleportFrame()
    local baseFrame = widgets.RoundedFrame.CreateFrame(ChallengesFrame, {
        points = {
            { "TOPLEFT",    ChallengesFrame, "TOPRIGHT",    5, -5 },
            { "BOTTOMLEFT", ChallengesFrame, "BOTTOMRIGHT", 5, 5 },
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
                CreateAnchor("TOPLEFT", 10, -35),
                CreateAnchor("BOTTOMRIGHT", -25, 10)
            },
            without_scroll_bar = {
                CreateAnchor("TOPLEFT", 10, -35),
                CreateAnchor("BOTTOMRIGHT", -10, 10)
            },
        },
    })

    local function updateTeleports()
        scrollView:UpdateContentData({})
        for _, spellID in pairs(Private.constants.dungeonTeleports) do
            scrollView:UpdateContentData({{spellID = spellID}}, true)
        end
    end

    baseFrame:SetScript("OnShow", updateTeleports)
end

local function onEvent(_, event, loadedAddon)
    if event == "ADDON_LOADED" and loadedAddon == "Blizzard_ChallengesUI" then
        createTeleportFrame()
    end
end

addon:RegisterEvent("ADDON_LOADED", "ui/dungeonTeleports.lua", onEvent)
