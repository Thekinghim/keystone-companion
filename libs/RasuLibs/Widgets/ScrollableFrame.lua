local lib = LibStub("RasuGUI")
if lib.Widgets.ScrollableFrame then return end
local mixTables = lib.Widgets.Base.mixTables

---@class ScrollableFrameOptions
---@field frame_strata FrameStrata?
---@field width number?
---@field height number?
---@field anchors table?
---@field type "LIST"|"GRID"|?
---@field template string?
---@field initializer fun(frame:Frame, data:table)?
---@field extent_calculator fun(dataIndex:number, node:table)?
---@field elements_per_row number?
---@field element_padding number?
---@field element_height number?
---@field fill_width boolean?
local defaultOptions = {
    frame_strata = "HIGH",
    width = 250,
    height = 150,
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
    type = "LIST",
    template = "BackdropTemplate",
    initializer = nil,
    extent_calculator = nil,
    elements_per_row = 4,
    element_padding = 4,
    element_height = 40,
    fill_width = false,
}

local function createScrollable(parent, options)
    parent = parent or UIParent
    if not options.frame_strata then
        options.frame_strata = parent:GetFrameStrata()
    end
    options = mixTables(defaultOptions, options)

    ---@class ScrollBoxFrame : Frame,RasuGUIBaseMixin
    ---@field GetScrollPercentage fun(self:ScrollBoxFrame)
    ---@field SetScrollPercentage fun(self:ScrollBoxFrame, percentage:number)
    local scrollBox = CreateFrame("Frame", nil, parent, "WowScrollBoxList")
    scrollBox:SetFrameStrata(options.frame_strata)
    scrollBox:SetSize(options.width, options.height)
    Mixin(scrollBox, lib.Widgets.BaseMixin)

    ---@class ScrollBar : EventFrame
    ---@field SetHideIfUnscrollable fun(self:ScrollBar, hideScrollBar:boolean)
    local scrollBar = CreateFrame("EventFrame", nil, parent, "MinimalScrollBar")
    scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 5, 0)
    scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT")
    scrollBar:SetFrameStrata(options.frame_strata)
    scrollBar:SetHideIfUnscrollable(true)

    ---@class ScrollView : Frame
    ---@field SetElementExtentCalculator fun(self:ScrollView, extentCalculator:fun(dataIndex:number, node:table))
    ---@field SetElementExtent fun(self:ScrollView, extent:number)
    ---@field Flush fun(self:ScrollView)
    ---@field SetDataProvider fun(self:ScrollView, dataProvider:table)
    ---@field GetDataProvider fun(self:ScrollView)
    local scrollView = nil
    if options.type == "LIST" then
        scrollView = CreateScrollBoxListLinearView()
        scrollView:SetElementInitializer(options.template or "BackdropTemplate", options.initializer)
        ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, scrollView)
    elseif options.type == "GRID" then
        local fillWidth = (parent:GetWidth() - (options.elements_per_row - 1) * options.element_padding) /
            options.elements_per_row
        scrollView = CreateScrollBoxListGridView(options.elements_per_row, 0, 0, 0, 0, options.element_padding,
            options.element_padding);
        scrollView:SetElementInitializer(options.template or "BackdropTemplate", function(button, elementData)
            button:SetSize(options.fill_width and fillWidth or options.element_height, options.element_height)
            options.initializer(button, elementData)
        end)
        ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, scrollView);
    end
    if options.extent_calculator then
        scrollView:SetElementExtentCalculator(options.extent_calculator)
    else
        scrollView:SetElementExtent(options.element_height)
    end
    -- seems buggy so write my own func for this
    --ScrollUtil.AddManagedScrollBarVisibilityBehavior(scrollBox, scrollBar, options.anchors.with_scroll_bar,
    --options.anchors.without_scroll_bar)
    local function setAnchors(withScrollBar)
        scrollBox:ClearAllPoints()
        for _, anchor in ipairs(withScrollBar and options.anchors.with_scroll_bar or options.anchors.without_scroll_bar) do
            scrollBox:SetPoint(anchor:Get())
        end
    end
    scrollBar:HookScript("OnShow", function()
        setAnchors(true)
    end)
    scrollBar:HookScript("OnHide", function()
        setAnchors()
    end)
    setAnchors()

    function scrollView:UpdateContentData(data, keepOldData)
        if not data then return end
        local scrollPercent = scrollBox:GetScrollPercentage()
        local dataProvider = self:GetDataProvider()
        if not dataProvider then
            dataProvider = CreateDataProvider()
            self:SetDataProvider(dataProvider)
        end
        if not keepOldData then
            dataProvider:Flush()
        else
        end
        for _, part in ipairs(data) do
            dataProvider:Insert(part)
        end
        scrollBox:SetScrollPercentage(scrollPercent or 1)
    end

    return scrollBox, scrollView, scrollBar
end

---@class ScrollableFrameAPI
---@field CreateFrame fun(parent:Frame, options:ScrollableFrameOptions): ScrollBoxFrame, ScrollView, ScrollBar
lib.Widgets.ScrollableFrame = {
    CreateFrame = createScrollable
}
