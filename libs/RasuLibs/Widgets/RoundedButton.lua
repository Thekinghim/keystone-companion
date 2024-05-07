local lib = LibStub("RasuGUI")
if lib.Widgets.RoundedButton then return end

local styles = lib.styles
local CreateRoundedFrame = lib.Widgets.RoundedFrame.CreateFrame
local mixTables = lib.Widgets.Base.mixTables

---@class RoundedButtonOptions : RoundedFrameOptions
---@field font_object string|FontObject|?
---@field font_points table|?
---@field font_text string|?
---@field is_Disabled boolean|?
---@field default_button ColorMixin|?
---@field hover_button ColorMixin|?
---@field disabled_button ColorMixin|?
---@field default_text ColorMixin|?
---@field hover_text ColorMixin|?
---@field disabled_text ColorMixin|?
---@field tooltip_text string|?
local defaultOptions = {
    height = 200,
    width = 200,
    points = { { "CENTER" } },
    border_size = 2,
    border_color = styles.COLORS.BORDER,
    background_color = styles.COLORS.BACKGROUND,
    frame_strata = 'HIGH',
    font_object = GameFontHighlightCenter,
    font_points = { { "CENTER" } },
    font_text = "Press me!",
    is_disabled = false,
    default_button = styles.COLORS.BUTTON_DEFAULT,
    hover_button = styles.COLORS.BUTTON_HOVER,
    disabled_button = styles.COLORS.BUTTON_DISABLED,
    default_text = styles.COLORS.TEXT_DEFAULT,
    hover_text = styles.COLORS.TEXT_HOVER,
    disabled_text = styles.COLORS.TEXT_DISABLED,
    tooltip_text = nil
}

---@param parent Frame
---@param options RoundedButtonOptions
---@return RoundedButton
local function createButton(parent, options)
    parent = parent or UIParent
    if not options.frame_strata then
        options.frame_strata = parent:GetFrameStrata()
    end
    options = mixTables(defaultOptions, options)
    ---@class RoundedButton : Frame,RasuGUIBaseMixin
    ---@field disabled boolean
    ---@field label FontString
    ---@field Background Texture
    ---@field colors table
    ---@field SetDisabled fun(self:RoundedButton, is_disabled:boolean)
    ---@field UpdateColor fun(self:RoundedButton, isMouseOver:boolean|?)
    local frame = CreateRoundedFrame(parent, options)
    Mixin(frame, lib.Widgets.BaseMixin)
    for _, point in ipairs(options.points) do
        frame:SetPoint(unpack(point))
    end
    frame:SetSize(options.width, options.height)

    local label = frame:CreateFontString()
    label:SetFontObject(options.font_object)
    label:SetPoint("CENTER")
    label:SetText(options.font_text)
    frame:EnableMouse(true)
    frame.disabled = options.is_disabled
    frame.label = label
    frame.Background:SetVertexColor(options.default_button:GetRGBA())
    frame.colors = {
        btnDefault = options.default_button,
        btnHover = options.hover_button,
        btnDisabled = options.disabled_button,

        txtDefault = options.default_text,
        txtHover = options.hover_text,
        txtDisabled = options.disabled_text,
    }
    function frame:SetDisabled(isDisabled)
        self.disabled = isDisabled
        self:UpdateColor()
    end

    function frame:UpdateColor(isMouseOver)
        local btnColor = self.colors.btnDefault
        local txtColor = self.colors.txtDefault
        if self.disabled then
            btnColor = self.colors.btnDisabled
            txtColor = self.colors.txtDisabled
        elseif isMouseOver then
            btnColor = self.colors.btnHover
            txtColor = self.colors.txtHover
        end
        self.Background:SetVertexColor(btnColor:GetRGBA())
        self.label:SetTextColor(txtColor:GetRGBA())
    end

    frame:UpdateColor(false)

    frame:SetScript("OnEnter", function(self)
        self:UpdateColor(true)
    end)
    frame:SetScript("OnLeave", function(self)
        self:UpdateColor(false)
    end)

    function frame:UpdateTooltipText(text)
        self:AddTooltip(text)
    end

    if options.tooltip_text then
        frame:UpdateTooltipText(options.tooltip_text)
    end

    return frame
end

---@class RoundedButtonAPI
---@field CreateFrame fun(parent:Frame, options:RoundedButtonOptions) : RoundedButton
lib.Widgets.RoundedButton = {
    CreateFrame = createButton,
}
