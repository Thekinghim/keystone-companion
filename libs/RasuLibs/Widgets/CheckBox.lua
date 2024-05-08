local lib = LibStub("RasuGUI")
if lib.Widgets.CheckBox then return end

local mixTables = lib.Widgets.Base.mixTables

---@class CheckBoxOptions
---@field size number?
---@field points table?
---@field frame_strata FrameStrata?
---@field default_state boolean?
---@field is_disabled boolean?
---@field font_text string?
---@field font_object FontObject?
---@field callback fun(self:CheckBox, isChecked:boolean)?
local defaultOptions = {
    size = 20,
    points = { { "CENTER" } },
    frame_strata = "HIGH",
    default_state = false,
    is_disabled = false,
    font_text = "",
    font_object = GameFontHighlightCenter,
    callback = nil
}

---@param parent Frame
---@param options CheckBoxOptions
---@return CheckBox
local function createCheckBox(parent, options)
    parent = parent or UIParent
    if not options.frame_strata then
        options.frame_strata = parent:GetFrameStrata()
    end
    options = mixTables(defaultOptions, options)
    ---@class CheckBox:CheckButton,RasuGUIBaseMixin
    local checkBox = CreateFrame("CheckButton", nil, parent)
    checkBox:SetFrameStrata(options.frame_strata)
    Mixin(checkBox, lib.Widgets.BaseMixin)
    local check = checkBox:CreateTexture()
    local checkDisable = checkBox:CreateTexture()
    check:SetAtlas("checkmark-minimal")
    checkDisable:SetAtlas("checkmark-minimal-disabled")
    checkBox:SetDisabledCheckedTexture(checkDisable)
    checkBox:SetCheckedTexture(check)
    checkBox:SetNormalAtlas("checkbox-minimal")
    checkBox:SetPushedAtlas("checkbox-minimal")

    for _, point in ipairs(options.points) do
        checkBox:SetPoint(unpack(point))
    end
    checkBox:SetSize(options.size, options.size)
    checkBox:SetChecked(options.default_state)
    checkBox:SetEnabled(not options.is_disabled)

    local label = checkBox:CreateFontString()
    label:SetFontObject(options.font_object)
    label:SetJustifyH("LEFT")
    label:SetPoint("LEFT", checkBox, "RIGHT", 8, 0)
    label:SetText(options.font_text)

    checkBox.callback = options.callback
    checkBox.label = label

    checkBox:SetScript("OnClick", function(self)
        if self.callback then
            self:callback(self:GetChecked())
        end
    end)

    return checkBox
end

---@class CheckBoxAPI
---@field CreateFrame fun(parent:Frame, options:CheckBoxOptions): CheckBox
lib.Widgets.CheckBox = {
    CreateFrame = createCheckBox
}
