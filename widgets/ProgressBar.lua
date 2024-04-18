local _, Private = ...

local const = Private.constants.misc
local rf = Private.RoundedFrame

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
    fill_direction = "LEFT>RIGHT",
}

---@param parent Frame
---@param options ProgressBarOptions
---@return ProgressBar
local function createBar(parent, options)
    parent = parent or UIParent
    options = mixTables(defaultOptions, options)
    ---@class ProgressBar:Frame
    local frame = CreateFrame("Frame", nil, parent)
    for _, point in ipairs(options.points) do
        frame:SetPoint(unpack(point))
    end
    frame:SetSize(options.width, options.height)
    frame.Background = rf.CreateFrame(frame, options)
    frame.Background:ClearAllPoints()
    options.use_border = false
    frame.Foreground = rf.CreateFrame(frame, options)
    frame.Foreground:ClearAllPoints()

    -- Make the Grow stuff and shit

    return frame
end

--[[
    local function createBar()
    local r1, g1, b1 = Private.DEFAULTFOREGROUND:GetRGB()
    local r2, g2, b2 = Private.DEFAULTBACKGROUND:GetRGB()
    local frame = CreateFrame("Frame", nil, UIParent)
    local foreground = frame:CreateTexture(nil, "ARTWORK")
    local background = frame:CreateTexture(nil, "ARTWORK")
    foreground:SetVertexColor(r1, g1, b1, .8)
    background:SetVertexColor(r2, g2, b2, .8)
    foreground:SetDrawLayer("ARTWORK", 0)
    background:SetDrawLayer("ARTWORK", -1)
    background:SetAllPoints()

    return {
        frame = frame,
        foreground = foreground,
        background = background,
        value = 0,
        total = 0,
        SetProgress = function(self, value, total)
            if not self.grow then self:SetGrow("RIGHT") end
            self.value = value
            self.total = total
            local p = value / total
            if p > 1 then
                p = 1
            end
            if self.grow == "RIGHT" then
                self.foreground:SetPoint("RIGHT", self.background, "LEFT", p * self.background:GetWidth(), 0)
            elseif self.grow == "LEFT" then
                self.foreground:SetPoint("LEFT", self.background, "RIGHT", (p * self.background:GetWidth()) * -1, 0)
            elseif self.grow == "TOP" then
                self.foreground:SetPoint("TOP", self.background, "BOTTOM", 0, p * self.background:GetHeight())
            elseif self.grow == "BOTTOM" then
                self.foreground:SetPoint("BOTTOM", self.background, "TOP", 0, (p * self.background:GetHeight()) * -1)
            end
        end,
        SetColor = function(self, color)
            local r, g, b = color:GetRGB()
            self.foreground:SetVertexColor(r, g, b, .8)
        end,
        SetPoint = function(self, ...)
            self.frame:SetPoint(...)
        end,
        SetParent = function(self, parent)
            self.frame:SetParent(parent)
        end,
        SetAllPoints = function(self, ...)
            self.frame:SetAllPoints(...)
        end,
        SetSize = function(self, width, height)
            self.frame:SetSize(width, height)
            self:SetProgress(self.value, self.total)
        end,
        SetGrow = function(self, direction)
            foreground:ClearAllPoints()
            if not direction then direction = "RIGHT" end
            self.grow = direction
            if direction == "RIGHT" then
                -- Grow Left -> Right
                foreground:SetPoint("TOPLEFT")
                foreground:SetPoint("BOTTOMLEFT")
                foreground:SetPoint("RIGHT", background, "LEFT", 0, 0)
            elseif direction == "LEFT" then
                -- Grow Right -> Left
                foreground:SetPoint("TOPRIGHT")
                foreground:SetPoint("BOTTOMRIGHT")
                foreground:SetPoint("LEFT", background, "RIGHT", 0, 0)
            elseif direction == "TOP" then
                -- Grow Bottom -> Top
                foreground:SetPoint("BOTTOMLEFT")
                foreground:SetPoint("BOTTOMRIGHT")
                foreground:SetPoint("TOP", background, "BOTTOM", 0, 0)
            elseif direction == "BOTTOM" then
                -- Grow Top -> Bottom
                foreground:SetPoint("TOPLEFT")
                foreground:SetPoint("TOPRIGHT")
                foreground:SetPoint("BOTTOM", background, "TOP", 0, 0)
            else
                self.SetGrow("RIGHT")
            end
        end
    }
end
]]

---@class ProgressBarAPI
---@field CreateFrame fun(parent:Frame, options:ProgressBarOptions)
---@field GetBorderForSize fun(size:number)
Private.RoundedFrame = {
    CreateFrame = createBar,
}