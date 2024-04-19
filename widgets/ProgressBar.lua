local Private = select(2, ...)
local addon = Private.Addon

if not addon.Widgets then
    addon.print("Widgets Missing")
    return
end

local const = addon.constants.misc
local roundedframe = addon.Widgets.RoundedFrame

---@param ... table
---@return table
local function mixTables(...)
    local mixed = {}
    for _, tbl in pairs({ ... }) do
        if type(tbl) == "table" then
            Mixin(mixed, tbl)
        end
    end
    return mixed
end

---@class ProgressBarOptions
---@field foreground_color colorRGB?
---@field fill_direction FillDirections?
---@field progress_value number?
---@field progress_total number?
local defaultOptions = {
    height = 200,
    width = 200,
    points = { { "CENTER" } },
    background_color = const.COLORS.BACKGROUND,
    background_texture = const.TEXTURES.ROUNDED_SQUARE,
    use_border = true,
    border_color = const.COLORS.BORDER,
    border_texture = const.TEXTURES.ROUNDED_BORDER,
    border_size = 2, -- Default Texture has a 2px border
    foreground_color = const.COLORS.FOREGROUND,
    fill_direction = "RIGHT",
    progress_value = 50,
    progress_total = 100
}
---@alias FillDirections
---| '"RIGHT"' # From Left to Right
---| '"LEFT"' # From Right to Left
---| '"TOP"' # From Bottom to Top
---| '"BOTTOM"' # From Top to Bottom

---@param parent Frame
---@param options ProgressBarOptions
---@return ProgressBar
local function createBar(parent, options)
    parent = parent or UIParent
    options = mixTables(defaultOptions, options)
    ---@class ProgressBar:Frame
    ---@field value number?
    ---@field total number?
    ---@field fillDirection FillDirections?
    ---@field SetProgress fun(self:ProgressBar, value:number, total:number))
    ---@field SetFill fun(self:ProgressBar, direction:FillDirections)
    local frame = CreateFrame("Frame", nil, parent)
    for _, point in ipairs(options.points) do
        frame:SetPoint(unpack(point))
    end
    frame:SetSize(options.width, options.height)
    frame.Background = roundedframe.CreateFrame(frame, options)
    frame.Background:ClearAllPoints()
    frame.Background:SetAllPoints()
    frame.Background.Background:SetDrawLayer("BACKGROUND", -1)
    options.use_border = false
    options.background_color = options.foreground_color
    frame.Foreground = roundedframe.CreateFrame(frame, options)
    frame.Foreground.Background:SetDrawLayer("BACKGROUND", 0)
    frame.Foreground:ClearAllPoints()
    frame.Foreground:SetPoint("TOPLEFT")
    frame.Foreground:SetPoint("BOTTOMLEFT")
    frame.Foreground:SetPoint("RIGHT", frame.Background, "LEFT", 0, 0)
    function frame:SetProgress(value, total)
        if not self.fillDirection then self:SetFill("RIGHT") end
        self.value = tonumber(value)
        self.total = tonumber(total)
        local p = self.value / self.total
        if p > 1 then
            p = 1
        end
        if self.fillDirection == "RIGHT" then
            self.Foreground:SetPoint("RIGHT", self.Background, "LEFT", p * self.Background:GetWidth(), 0)
        elseif self.fillDirection == "LEFT" then
            self.Foreground:SetPoint("LEFT", self.Background, "RIGHT", (p * self.Background:GetWidth()) * -1, 0)
        elseif self.fillDirection == "TOP" then
            self.Foreground:SetPoint("TOP", self.Background, "BOTTOM", 0, p * self.Background:GetHeight())
        elseif self.fillDirection == "BOTTOM" then
            self.Foreground:SetPoint("BOTTOM", self.Background, "TOP", 0, (p * self.Background:GetHeight()) * -1)
        end
    end

    function frame:SetFill(direction)
        self.Foreground:ClearAllPoints()
        if not direction then direction = "RIGHT" end
        self.fillDirection = direction
        if direction == "RIGHT" then
            -- Fill from Left -> Right
            self.Foreground:SetPoint("TOPLEFT")
            self.Foreground:SetPoint("BOTTOMLEFT")
            self.Foreground:SetPoint("RIGHT", self.Background, "LEFT", 0, 0)
        elseif direction == "LEFT" then
            -- Fill from Right -> Left
            self.Foreground:SetPoint("TOPRIGHT")
            self.Foreground:SetPoint("BOTTOMRIGHT")
            self.Foreground:SetPoint("LEFT", self.Background, "RIGHT", 0, 0)
        elseif direction == "TOP" then
            -- Fill from Bottom -> Top
            self.Foreground:SetPoint("BOTTOMLEFT")
            self.Foreground:SetPoint("BOTTOMRIGHT")
            self.Foreground:SetPoint("TOP", self.Background, "BOTTOM", 0, 0)
        elseif direction == "BOTTOM" then
            -- Fill from Top -> Bottom
            self.Foreground:SetPoint("TOPLEFT")
            self.Foreground:SetPoint("TOPRIGHT")
            self.Foreground:SetPoint("BOTTOM", self.Background, "TOP", 0, 0)
        else
            self:SetFill("RIGHT")
        end
    end

    frame:SetFill(options.fill_direction)
    frame:SetProgress(options.progress_value, options.progress_total)

    return frame
end
--[[
    Example Usage:
    local pb = KeystoneCompanion.Widgets.ProgressBar
    local options = {
        width = 220,
        height = 22,
        points = { { "TOP", 0, -100 } },
        use_border = false
    }
    local frame = pb.CreateFrame(UIParent, options)
]]

---@class ProgressBarAPI
---@field CreateFrame fun(parent:Frame, options:ProgressBarOptions) : ProgressBar
addon.Widgets.ProgressBar = {
    CreateFrame = createBar,
}
