local KeystoneCompanion = select(2, ...)
local styles = KeystoneCompanion.constants.styles
local aTalents = KeystoneCompanion.constants.affixTalents
local CreateRoundedFrame = KeystoneCompanion.widgets.RoundedFrame.CreateFrame
local getTexturePath = KeystoneCompanion.utils.path.getTexturePath

local addonTitle = styles.COLORS.TEXT_HIGHLIGHT:WrapTextInColorCode("Keystone Companion")
local infoIcon = {
    file = getTexturePath("icons/info"),
    fileStr = string.format("|T%s:16|t", getTexturePath("icons/info")),
}
local buttonDefault = CreateColorFromHexString("FF17191C")
local buttonHover = CreateColorFromHexString("FF36373B")
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
local function createRoundedButton(parent, points, width, height, isDisabled, text, tooltip)
    ---@class roundedButton : RoundedFrame
    local button = CreateRoundedFrame(parent, {
        width = width,
        height = height,
        points = points,
    })
    local label = button:CreateFontString()
    label:SetFontObject(styles.FONT_OBJECTS.BOLD)
    label:SetPoint("CENTER")
    label:SetText(text)
    button:EnableMouse(true)
    button.disabled = isDisabled
    button.label = label
    button.Background:SetVertexColor(buttonDefault:GetRGBA())
    button:SetScript("OnEnter", function(self)
        if not self.disabled then
            self.Background:SetVertexColor(buttonHover:GetRGBA())
        end
    end)
    button:SetScript("OnLeave", function(self)
        self.Background:SetVertexColor(buttonDefault:GetRGBA())
    end)
    if tooltip then
        createTooltip(button, tooltip)
    end
    return button
end
local function createScrollable(options)
    local scrollBox = CreateFrame("Frame", nil, options.parent, "WowScrollBoxList")
    local scrollBar = CreateFrame("EventFrame", nil, options.parent, "MinimalScrollBar")
    scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 5, 0)
    scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT")
    scrollBar:SetHideIfUnscrollable(true)

    local scrollView = nil
    if options.type == "LIST" then
        scrollView = CreateScrollBoxListLinearView()
        scrollView:SetElementInitializer(options.template or "BackdropTemplate", options.initializer)
        ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, scrollView)
    elseif options.type == "GRID" then
        local fillWidth = (options.parent:GetWidth() - (options.elementsPerRow - 1) * options.elementPadding) /
            options.elementsPerRow
        scrollView = CreateScrollBoxListGridView(options.elementsPerRow, 0, 0, 0, 0, options.elementPadding,
            options.elementPadding);
        scrollView:SetElementInitializer(options.template or "BackdropTemplate", function(button, elementData)
            button:SetSize(options.fillWidth and fillWidth or options.elementHeight, options.elementHeight)
            options.initializer(button, elementData)
        end)
        ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, scrollView);
    end
    if options.extentCalculator then
        scrollView:SetElementExtentCalculator(options.extentCalculator)
    else
        scrollView:SetElementExtent(options.elementHeight)
    end
    -- Sadly this seems to be broken for Grids rn from blizzards side
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(scrollBox, scrollBar, options.anchors.withScrollBar,
        options.anchors.withoutScrollBar);

    function scrollView:UpdateContentData(data)
        local scrollPercent = scrollBox:GetScrollPercentage()
        self:Flush()
        local dataProvider = CreateDataProvider()
        self:SetDataProvider(dataProvider)
        if not data then return end
        for _, part in ipairs(data) do
            dataProvider:Insert(part)
        end
        scrollBox:SetScrollPercentage(scrollPercent or 1)
    end

    return scrollView, scrollBox, scrollBar
end

local talentCheckFrame = CreateRoundedFrame(UIParent, { border_size = 2, width = 300, height = 250 })
talentCheckFrame:EnableMouse(true)
talentCheckFrame:SetMovable(true)
talentCheckFrame:SetScript("OnMouseDown", function(self)
    self:StartMoving()
end)
talentCheckFrame:SetScript("OnMouseUp", function(self)
    self:StopMovingOrSizing()
end)
local title = talentCheckFrame:CreateFontString()
title:SetFont(styles.FONTS.BOLD, 16, "")
title:SetPoint("TOP", 0, -12)
title:SetText(addonTitle .. ": Talent Check")
local moreInfo = talentCheckFrame:CreateFontString()
moreInfo:SetFontObject(styles.FONT_OBJECTS.NORMAL)
moreInfo:SetPoint("TOP", 0, -30)
moreInfo:SetText(infoIcon.fileStr .. "Hover over Icons for more Info.")

local iconView, iconBox = createScrollable({
    parent = talentCheckFrame,
    anchors = {
        withScrollBar = {
            CreateAnchor("TOPLEFT", 12, -54),
            CreateAnchor("BOTTOMRIGHT", -37, 49)
        },
        withoutScrollBar = {
            CreateAnchor("TOPLEFT", 25, -54),
            CreateAnchor("BOTTOMRIGHT", -25, 49)
        },
    },
    type = "GRID",
    elementHeight = 45,
    elementsPerRow = 5,
    elementPadding = 5,
    initializer = function(frame, elementData)
        if not frame.initialized then
            local icon = frame:CreateTexture()
            icon:SetPoint("TOPLEFT", 1, -1)
            icon:SetPoint("BOTTOMRIGHT", -1, 1)
            frame.icon = icon
            frame.initialized = true
        end
        frame.icon:SetDesaturated(not elementData.talented)
        frame.icon:SetTexture(elementData.texture)
        createTooltip(frame, elementData.tooltipText)
    end,
})

local okayButton = createRoundedButton(talentCheckFrame,
    { { "TOPLEFT", iconBox, "BOTTOMLEFT", 0, -12 }, { "TOPRIGHT", iconBox, "BOTTOMRIGHT", 0, -12 } }, 0, 25,
    false, OKAY)
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
            "%s%s%s|r\n%s\n\n%sReason for Recommendation:|r\n%s\n\n%sAffix for Recommendation:|r\n|T%s:12|t %s\n\n%sRecommendation Specs:|r",
            secondaryMarkup, highlightMarkup, name,
            description, highlightMarkup, reason, highlightMarkup, affixIcon, affixName, highlightMarkup)
        for _, specID in ipairs(specs) do
            local specName, _, specIcon = select(2, GetSpecializationInfoByID(specID))
            tooltipText = string.format("%s\n|T%s:12|t %s", tooltipText, specIcon, specName)
        end
        local tMarkup = isTalented and positiveMarkup or negativeMarkup
        local tText = isTalented and YES or NO
        tooltipText = string.format("%s\n\n%sIs talented: %s%s", tooltipText, highlightMarkup, tMarkup, tText)

        return icon, tooltipText
    end
end

local function isRecommendedForSpec(specs, specID)
    for _, recommendedSpec in ipairs(specs) do
        if recommendedSpec == specID then return true end
    end
    return false
end

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
    iconView:UpdateContentData(info)
    if showFrame then
        talentCheckFrame:Show()
    end
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

local eventFrame = CreateFrame("Frame", nil, UIParent)
eventFrame:RegisterEvent("READY_CHECK")
eventFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
eventFrame:SetScript("OnEvent", onEvent)
