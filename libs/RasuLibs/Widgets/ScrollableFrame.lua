local lib = LibStub("RasuGUI")
if lib.Widgets.ScrollableFrame then return end
local mixTables = lib.Widgets.Base.mixTables

---@class ScrollableFrameOptions
---@field width number?
---@field height number?
---@field anchors table?
---@field type "LIST"|"GRID"|?
---@field template string?
---@field initializer fun(frame:Frame, data:table)?
---@field extentCalculator fun(dataIndex:number, node:table)?
---@field elementsPerRow number?
---@field elementPadding number?
---@field elementHeight number?
---@field fillWidth boolean?
local defaultOptions = {
    width = 250,
    height = 150,
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
    type = "LIST",
    template = "BackdropTemplate",
    initializer = nil,
    extentCalculator = nil,
    elementsPerRow = 4,
    elementPadding = 4,
    elementHeight = 40,
    fillWidth = false,
}

local function createScrollable(parent, options)
    parent = parent or UIParent
    options = mixTables(defaultOptions, options)

    ---@class ScrollBoxFrame : Frame
    ---@field GetScrollPercentage fun(self:ScrollBoxFrame)
    ---@field SetScrollPercentage fun(self:ScrollBoxFrame, percentage:number)
    local scrollBox = CreateFrame("Frame", nil, parent, "WowScrollBoxList")
    scrollBox:SetSize(options.width, options.height)

    ---@class ScrollBar : EventFrame
    ---@field SetHideIfUnscrollable fun(self:ScrollBar, hideScrollBar:boolean)
    local scrollBar = CreateFrame("EventFrame", nil, parent, "MinimalScrollBar")
    scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 5, 0)
    scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT")
    scrollBar:SetHideIfUnscrollable(true)

    ---@class ScrollView : Frame
    ---@field SetElementExtentCalculator fun(self:ScrollView, extentCalculator:fun(dataIndex:number, node:table))
    ---@field SetElementExtent fun(self:ScrollView, extent:number)
    ---@field Flush fun(self:ScrollView)
    ---@field SetDataProvider fun(self:ScrollView, dataProvider:table)
    local scrollView = nil
    if options.type == "LIST" then
        scrollView = CreateScrollBoxListLinearView()
        scrollView:SetElementInitializer(options.template or "BackdropTemplate", options.initializer)
        ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, scrollView)
    elseif options.type == "GRID" then
        local fillWidth = (parent:GetWidth() - (options.elementsPerRow - 1) * options.elementPadding) /
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

    return scrollBox, scrollView, scrollBar
end

---@class ScrollableFrameAPI
---@field CreateFrame fun(parent:Frame, options:ScrollableFrameOptions): ScrollBoxFrame, ScrollView, ScrollBar
lib.Widgets.ScrollableFrame = {
    CreateFrame = createScrollable
}
