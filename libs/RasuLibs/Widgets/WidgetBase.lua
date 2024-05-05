local addonName = ...
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

---@param frame Frame|table
---@param tooltipText string
function lib.Widgets.Base.AddTooltip(frame, tooltipText)
    frame.tooltipText = tooltipText
    if frame.hasTooltip then return end
    frame:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(self.tooltipText, lib.styles.COLORS.TEXT_HOVER:GetRGBA())
        GameTooltip:Show()
    end)
    frame:HookScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    frame.hasTooltip = true
end

---This gotta be redesigned if the lib gets used by multiple addons
---@param path string
---@return string
lib.Widgets.Base.getAddonPath = function(path)
    return string.format("Interface\\Addons\\%s\\%s", addonName, path)
end
