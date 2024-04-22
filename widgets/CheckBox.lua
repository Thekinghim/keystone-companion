local _, KeystoneCompanion = ...
local styles = KeystoneCompanion.constants.styles;
local mixTables = KeystoneCompanion.widgets.Base.mixTables

---@class CheckBoxOptions
---@field size number?
---@field points table?
---@field defaultState boolean?
---@field isDisabled boolean?
---@field text string?
---@field fontObject FontObject?
---@field callback fun(self:CheckBox, isChecked:boolean)?
local defaultOptions = {
    size = 20,
    points = { { "CENTER" } },
    defaultState = false,
    isDisabled = false,
    text = "",
    fontObject = styles.FONT_OBJECTS.BOLD,
}

---@param parent Frame
---@param options CheckBoxOptions
---@return CheckBox
local function createCheckBox(parent, options)
    parent = parent or UIParent
    options = mixTables(defaultOptions, options)
    ---@class CheckBox:CheckButton
    local checkBox = CreateFrame("CheckButton", nil, parent)
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
    checkBox:SetChecked(options.defaultState)
    checkBox:SetEnabled(not options.isDisabled)

    local label = checkBox:CreateFontString()
    label:SetFontObject(options.fontObject)
    label:SetJustifyH("LEFT")
    label:SetPoint("LEFT", checkBox, "RIGHT", 8, 0)
    label:SetText(options.text)

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
KeystoneCompanion.widgets.CheckBox = {
    CreateFrame = createCheckBox
}
