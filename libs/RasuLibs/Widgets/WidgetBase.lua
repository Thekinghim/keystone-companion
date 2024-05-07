---@class RasuGUI
---@field Widgets table
local lib = LibStub:NewLibrary("RasuGUI", 1)

if not lib then
    return
end

lib.Widgets = {
    Base = {}
}
lib.styles = {
    COLORS = {
        BACKGROUND = CreateColorFromHexString("FF131315"),
        BORDER = CreateColorFromHexString("FFFF8000"),
        BUTTON_DEFAULT = CreateColorFromHexString("FF17191C"),
        BUTTON_HOVER = CreateColorFromHexString("FF36373B"),
        BUTTON_DISABLED = CreateColorFromHexString("FF46484C"),
        TEXT_DEFAULT = CreateColorFromHexString("FFA1A1A1"),
        TEXT_HOVER = CreateColorFromHexString("FFFFFFFF"),
        TEXT_DISABLED = CreateColorFromHexString("FF6E6E6E"),
    }
}

---@param ... table
---@return table
lib.Widgets.Base.mixTables = function(...)
    local mixed = {}
    for _, tbl in pairs({ ... }) do
        if type(tbl) == "table" then
            Mixin(mixed, tbl)
        end
    end
    return mixed
end


---This gotta be redesigned if the lib gets used by multiple addons
local addonName = ...
---@param path string
---@return string
lib.Widgets.Base.getAddonPath = function(path)
    return string.format("Interface\\Addons\\%s\\%s", addonName, path)
end

-- Mixins
---@class RasuGUIBaseMixin
lib.Widgets.BaseMixin = {}

---@param self Frame
---@param tooltipText string
function lib.Widgets.BaseMixin:AddTooltip(tooltipText)
    self.tooltipText = tooltipText
    if self.hasTooltip then return end
    self:HookScript("OnEnter", function(frame)
        GameTooltip:SetOwner(frame, "ANCHOR_CURSOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(frame.tooltipText, lib.styles.COLORS.TEXT_HOVER:GetRGBA())
        GameTooltip:Show()
    end)
    self:HookScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    self.hasTooltip = true
end

---@param self Frame
function lib.Widgets.BaseMixin:MakeMovable(deactivate, onStop, onStart)
    local isActive = not deactivate
    self:SetMovable(isActive)
    self:EnableMouse(isActive)
    self:RegisterForDrag('LeftButton')
    self:SetScript('OnDragStart', isActive and function (frame, ...)
        frame:StartMoving()
        if onStart then
            onStart(frame, ...)
        end
    end or nil)
    self:SetScript('OnDragStop', isActive and function (frame, ...)
        frame:StopMovingOrSizing()
        if onStop then
            onStop(frame, ...)
        end
    end or nil)
end