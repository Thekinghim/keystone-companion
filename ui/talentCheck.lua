---@class KeystoneCompanionPrivate
local Private = select(2, ...)
---@class KeystoneCompanion
local addon = Private.Addon
local loc = addon.Loc
local styles = Private.constants.styles

local getTexturePath = Private.utils.path.getTexturePath
local aTalents = Private.constants.affixTalents

local widgets = Private.widgets
local createRoundedFrame = widgets.RoundedFrame.CreateFrame
local createRoundedButton = widgets.RoundedButton.CreateFrame
local createScrollable = widgets.ScrollableFrame.CreateFrame

local addonTitle = styles.COLORS.TEXT_HIGHLIGHT:WrapTextInColorCode("Keystone Companion")
local infoIcon = {
    file = getTexturePath("icons/info"),
    fileStr = string.format("|T%s:16|t", getTexturePath("icons/info")),
}

local talentCheckFrame = createRoundedFrame(UIParent,
    { border_size = 2, width = 300, height = 200, frame_strata = "FULLSCREEN" })
talentCheckFrame:MakeMovable()
local title = talentCheckFrame:CreateFontString()
title:SetFont(styles.FONTS.BOLD, 16, "")
title:SetPoint("TOP", 0, -12)
title:SetText(addonTitle .. ": " .. loc["Talent Check"])
local moreInfo = talentCheckFrame:CreateFontString()
moreInfo:SetFontObject(styles.FONT_OBJECTS.NORMAL)
moreInfo:SetPoint("TOP", 0, -30)
moreInfo:SetText(infoIcon.fileStr .. loc["Hover over Icons for more Info."])

local iconBox, iconView = createScrollable(talentCheckFrame, {
    anchors = {
        with_scroll_bar = {
            CreateAnchor("TOPLEFT", 12, -54),
            CreateAnchor("BOTTOMRIGHT", -37, 49)
        },
        without_scroll_bar = {
            CreateAnchor("TOPLEFT", 25, -54),
            CreateAnchor("BOTTOMRIGHT", -25, 49)
        },
    },
    type = "GRID",
    element_height = 45,
    elements_per_row = 5,
    element_padding = 5,
    initializer = function(frame, elementData)
        ---@cast frame table : Frame
        if not frame.initialized then
            local icon = frame:CreateTexture()
            icon:SetPoint("TOPLEFT", 1, -1)
            icon:SetPoint("BOTTOMRIGHT", -1, 1)
            local mask = frame:CreateMaskTexture();
            mask:SetAllPoints(icon)
            mask:SetAtlas("UI-Frame-IconMask")
            icon:AddMaskTexture(mask)
            frame.icon = icon
            frame.initialized = true
        end
        frame.icon:SetDesaturated(not elementData.talented)
        frame.icon:SetTexture(elementData.texture)
        widgets.BaseMixin.AddTooltip(frame, elementData.tooltipText)
    end,
})

local okayButton = createRoundedButton(talentCheckFrame, {
    points = {
        { "TOPLEFT",  iconBox, "BOTTOMLEFT",  0, -12 },
        { "TOPRIGHT", iconBox, "BOTTOMRIGHT", 0, -12 }
    },
    height = 25,
    font_text = OKAY,
    frame_strata = "FULLSCREEN_DIALOG",
    tooltip_text = CLOSE
})
okayButton:SetScript("OnMouseDown", function()
    talentCheckFrame:Hide()
end)
local function isDefinitionIDTalented(definitionID)
    local configID = C_ClassTalents.GetActiveConfigID()
    if configID == nil then return end

    local configInfo = C_Traits.GetConfigInfo(configID)
    if configInfo == nil then return end

    for _, treeID in ipairs(configInfo.treeIDs) do
        local nodes = C_Traits.GetTreeNodes(treeID)
        for i, nodeID in ipairs(nodes) do
            local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
            for _, entryID in ipairs(nodeInfo.entryIDsWithCommittedRanks) do
                local entryInfo = C_Traits.GetEntryInfo(configID, entryID)
                if entryInfo and entryInfo.definitionID then
                    if definitionID == entryInfo.definitionID then return true end
                end
            end
        end
    end
    return false
end

local highlightMarkup = styles.COLORS.TEXT_HIGHLIGHT:GenerateHexColorMarkup()
local secondaryMarkup = styles.COLORS.TEXT_SECONDARY:GenerateHexColorMarkup()
local positiveMarkup = styles.COLORS.GREEN_LIGHT:GenerateHexColorMarkup()
local negativeMarkup = styles.COLORS.RED_LIGHT:GenerateHexColorMarkup()
local function getIconAndTooltip(specs, reason, spellID, affixID, isTalented)
    if spellID then
        local name, _, icon = GetSpellInfo(spellID)
        local affixName, _, affixIcon = C_ChallengeMode.GetAffixInfo(affixID)
        local description = GetSpellDescription(spellID)
        local tooltipText = string.format(
            "%s%s%s|r\n%s\n\n%s" ..
            loc["Reason for Recommendation:"] ..
            "|r\n%s\n\n%s" ..
            loc["Affix for Recommendation:"] ..
            "|r\n|T%s:12|t %s\n\n%s" ..
            loc["Recommendation Specs:"] ..
            "|r",
            secondaryMarkup, highlightMarkup, name,
            description, highlightMarkup, reason, highlightMarkup, affixIcon, affixName, highlightMarkup)
        for _, specID in ipairs(specs) do
            local specName, _, specIcon = select(2, GetSpecializationInfoByID(specID))
            tooltipText = string.format("%s\n|T%s:12|t %s", tooltipText, specIcon, specName)
        end
        local tMarkup = isTalented and positiveMarkup or negativeMarkup
        local tText = isTalented and YES or NO
        tooltipText = string.format("%s\n\n%s" .. loc["Is talented:"] .. " %s%s", tooltipText, highlightMarkup, tMarkup,
            tText)

        return icon, tooltipText
    end
end

local function isRecommendedForSpec(specs, specID)
    for _, recommendedSpec in ipairs(specs) do
        if recommendedSpec == specID then return true end
    end
    return false
end

local noRecommendation = string.format(
    "%s%sKeystone Companion|r\n\n" ..
    loc
    ["It appears that there are no talent recommendations for this affix yet. You might want to submit something through the Discord."] ..
    "\n\n%s%s|r",
    secondaryMarkup, highlightMarkup, highlightMarkup, "https://discord.gg/KhFhC6kZ78")

local function updateTalentCheck(showFrame)
    local info = {}
    local classID = select(2, UnitClassBase("player"))
    local specID = PlayerUtil.GetCurrentSpecID()
    local recommended = aTalents[classID]
    for _, affix in ipairs(C_MythicPlus.GetCurrentAffixes()) do
        for _, recInfo in ipairs(recommended[affix.id]) do
            if isRecommendedForSpec(recInfo.specs, specID) then
                local definitionInfo = C_Traits.GetDefinitionInfo(recInfo.definitionID)
                local spellID = definitionInfo.spellID
                local isTalented = isDefinitionIDTalented(recInfo.definitionID)
                local texture, tooltipText = getIconAndTooltip(recInfo.specs, recInfo.reason, spellID, affix.id,
                    isTalented)
                tinsert(info, { texture = texture, tooltipText = tooltipText, talented = isTalented })
            end
        end
    end
    if #info < 1 then
        tinsert(info, { texture = 3610509, tooltipText = noRecommendation, talented = true })
    end
    iconView:UpdateContentData(info)
    if showFrame then
        talentCheckFrame:Show()
    end
end
talentCheckFrame:Hide()

Private.TestTalentsCheck = function()
    local originalFunc = C_MythicPlus.GetCurrentAffixes
    ---@diagnostic disable-next-line: duplicate-set-field
    function C_MythicPlus.GetCurrentAffixes()
        local affixes = {
            {        -- Level 2 Affixes
                9,   -- Tyrannical
                10   -- Fortified
            },
            {        -- Level 5 Affixes
                135, -- Afflicted
                136, -- Incorporeal
                3,   -- Volcanic
                134, -- Entangling
                124, -- Storming
            },
            {        -- Level 10 Affixes
                123, -- Spiteful
                6,   -- Raging
                7,   -- Bolstering
                11,  -- Bursting
                8    -- Sanguine
            }
        }
        local affixesNow = {}
        print("============================")
        print("Affixes: |cFF808080(These Affixes are randomly generated!)")
        for _, levelAffixes in ipairs(affixes) do
            if #levelAffixes > 1 then
                local affixID = levelAffixes[math.random(1, #levelAffixes)]
                local name, _, icon = C_ChallengeMode.GetAffixInfo(affixID)
                print(string.format("|T%s:16|t %s", icon, name))
                tinsert(affixesNow, { id = affixID })
            end
        end
        print("============================")
        return affixesNow
    end

    updateTalentCheck(true)
    C_MythicPlus.GetCurrentAffixes = originalFunc
end

local function onEvent(_, event)
    local diff = select(3, GetInstanceInfo())
    if diff ~= 23 then return end
    if event == "READY_CHECK" then
        updateTalentCheck(true)
    elseif event == "TRAIT_CONFIG_UPDATED" then
        updateTalentCheck()
    end
end

addon:RegisterEvent("READY_CHECK", "ui/talentCheck.lua", onEvent)
addon:RegisterEvent("TRAIT_CONFIG_UPDATED", "ui/talentCheck.lua", onEvent)
