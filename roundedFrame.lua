local _, Private = ...

local constants = {}
constants.ASSETS_PATH = "interface/addons/keystone-companion/assets"

constants.COLORS = {
    BACKGROUND = CreateColorFromHexString("99131315"),
    BORDER = CreateColorFromHexString("FFFF8000"),
}
constants.TEXTURES = {
    ROUNDED_BORDER = constants.ASSETS_PATH .. "/textures/rounded-square-border-2px.tga", -- added files for different border sizes use rounded-square-border-[size]px.tga (available 2, 4, 6, 8, 10)
    ROUNDED_SQUARE = constants.ASSETS_PATH .. "/textures/rounded-square.tga",
}
constants.VALID_BORDER_SIZES = {
    [2] = true, [4] = true, [6] = true, [8] = true, [10] = true
}

---@param size number
local function getBorderForSize(size)
    if not constants.VALID_BORDER_SIZES[size] then size = 2 end
    return constants.ASSETS_PATH .. "/textures/rounded-square-border-" .. size .. "px.tga"
end

---@param frame Texture
---@param texture string
local function applySlice(frame, texture)
    frame:SetTexture(texture)
    frame:SetTextureSliceMargins(24, 24, 24, 24)
    frame:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
end

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

---@class RoundedFrameOptions
---@field height number?
---@field width number?
---@field parent Frame?
---@field points table?
---@field background_color colorRGB?
---@field background_texture string?
---@field use_border boolean?
---@field border_color colorRGB?
---@field border_texture string?
---@field border_size number?
local defaultOptions = {
    height = 200,
    width = 200,
    parent = UIParent,
    points = { { "CENTER" } },
    background_color = constants.COLORS.BACKGROUND,
    background_texture = constants.TEXTURES.ROUNDED_SQUARE,
    use_border = true,
    border_color = constants.COLORS.BORDER,
    border_texture = constants.TEXTURES.ROUNDED_BORDER,
    border_size = 2, -- Default Texture has a 2px border
}

---@param parent Frame
---@param options RoundedFrameOptions
---@return RoundedFrame
local function createRoundedFrame(parent, options)
    options = mixTables(defaultOptions, options)
    ---@class RoundedFrame:Frame
    local frame = CreateFrame("Frame", nil, parent)
    for _, point in ipairs(options.points) do
        frame:SetPoint(unpack(point))
    end
    frame:SetSize(options.width, options.height)

    frame.Background = frame:CreateTexture(nil, "BACKGROUND")
    applySlice(frame.Background, options.background_texture)
    frame.Background:SetVertexColor(options.background_color:GetRGBA())
    frame.Background:SetAllPoints()

    if options.use_border then
        frame.Border = frame:CreateTexture(nil, "BORDER")
        applySlice(frame.Border, options.border_texture)
        frame.Border:SetVertexColor(options.border_color:GetRGBA())
        frame.Border:SetPoint("TOPLEFT", -options.border_size, options.border_size)
        frame.Border:SetPoint("BOTTOMRIGHT", options.border_size, -options.border_size)
    end

    return frame
end

---@class RoundedFrameAPI
---@field CreateFrame fun(parent:Frame, options:RoundedFrameOptions)
---@field GetBorderForSize fun(size:number)
Private.RoundedFrame = {
    CreateFrame = createRoundedFrame,
    GetBorderForSize = getBorderForSize,
}

--[[
    Example Usage:
    local rf = Private.RoundedFrame
    local borderSize = 4
    local options = {
        width = 352,
        height = 265,
        border_size = borderSize,
        border_texture = rf.GetBorderForSize(borderSize)
    }
    local frame = rf.CreateFrame(UIParent, options)
]]
