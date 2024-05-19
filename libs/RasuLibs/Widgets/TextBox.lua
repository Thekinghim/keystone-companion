local lib = LibStub("RasuGUI")
if lib.Widgets.TextBox then return end

local mixTables = lib.Widgets.Base.mixTables

---@class TextBoxOptions
---@field width number?
---@field height number?
---@field points table?
---@field isDisabled boolean?
---@field instructions string?
---@field text string?
---@field frame_strata strata?
---@field callback fun(self:TextBox, text:string)?
local defaultOptions = {
    width = 100,
    height = 20,
    points = { { "CENTER" } },
    isDisabled = false,
    instructions = "",
    text = "",
}

---@param parent Frame
---@param options TextBoxOptions
---@return TextBox
local function createTextBox(parent, options)
    parent = parent or UIParent
    if not options.frame_strata then
        options.frame_strata = parent:GetFrameStrata()
    end
    options = mixTables(defaultOptions, options)
    ---@class TextBox:EditBox,RasuGUIBaseMixin
    ---@field Instructions FontString
    local textBox = CreateFrame("EditBox", nil, parent, "InputBoxInstructionsTemplate")
    textBox:ClearFocus()
    textBox:SetAutoFocus(false)
    textBox:SetFrameStrata(options.frame_strata)
    Mixin(textBox, lib.Widgets.BaseMixin)
    for _, point in ipairs(options.points) do
        textBox:SetPoint(unpack(point))
    end

    textBox:SetSize(options.width, options.height)
    textBox:SetEnabled(not options.isDisabled)
    textBox.Instructions:SetText(options.instructions)
    textBox:SetText(options.text)

    textBox.callback = options.callback

    textBox:HookScript("OnTextChanged", function(self)
        self:callback(self:GetText())
    end)

    return textBox
end

---@class TextBoxAPI
---@field CreateFrame fun(parent:Frame, options:TextBoxOptions): TextBox
lib.Widgets.TextBox = {
    CreateFrame = createTextBox
}
