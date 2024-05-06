local lib = LibStub("RasuGUI")
if lib.Widgets.Slider then return end

local mixTables = lib.Widgets.Base.mixTables

---@class SliderOptions
---@field width number?
---@field height number?
---@field points table?
---@field defaultValue number?
---@field stepValue number?
---@field minValue number?
---@field maxValue number?
---@field isDisabled boolean?
---@field text string?
---@field fontObject FontObject?
---@field callback fun(self:CheckBox, isChecked:boolean)?
local defaultOptions = {
    width = 100,
    height = 20,
    points = { { "CENTER" } },
    defaultValue = 50,
    stepValue = 1,
    minValue = 0,
    maxValue = 100,
    isDisabled = false,
    text = "",
    fontObject = GameFontHighlightCenter,
}

---@param parent Frame
---@param options SliderOptions
---@return ModernSlider
local function createSlider(parent, options)
    parent = parent or UIParent
    if not options.frame_strata then
        options.frame_strata = parent:GetFrameStrata()
    end
    options = mixTables(defaultOptions, options)
    ---@class ModernSlider:Slider
    local slider = CreateFrame("Slider", nil, parent, "MinimalSliderTemplate")
    slider:SetFrameStrata(options.frame_strata)
    Mixin(slider, lib.Widgets.BaseMixin)

    for _, point in ipairs(options.points) do
        slider:SetPoint(unpack(point))
    end
    slider:SetSize(options.width, options.height)
    slider:SetEnabled(not options.isDisabled)
    slider:SetMinMaxValues(options.minValue, options.maxValue)
    slider:SetValue(options.defaultValue)
    slider:SetValueStep(options.stepValue)
    slider:SetObeyStepOnDrag(true)

    local label = slider:CreateFontString()
    label:SetFontObject(options.fontObject)
    label:SetPoint("BOTTOM", slider, "TOP", 0, 2)
    label:SetText(options.text)

    local value = slider:CreateFontString()
    value:SetFontObject(options.fontObject)
    value:SetPoint("TOP", slider, "BOTTOM", 0, -2)
    value:SetText(tostring(slider:GetValue()))

    slider.callback = options.callback
    slider.label = label

    slider:SetScript("OnValueChanged", function(self)
        value:SetText(tostring(self:GetValue()))
    end)

    slider:SetScript("OnMouseUp", function(self)
        if self.callback then
            self:callback(self:GetValue())
        end
    end)

    return slider
end

---@class SliderAPI
---@field CreateFrame fun(parent:Frame, options:SliderOptions): ModernSlider
lib.Widgets.Slider = {
    CreateFrame = createSlider
}
