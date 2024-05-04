local lib = LibStub("RasuGUI")
if lib.Widgets.RoundedFrame then return end

local styles = lib.styles
local mixTables = lib.Widgets.Base.mixTables
local getPath = lib.Widgets.Base.getAddonPath

local borderTextures = {
  [1] = getPath('assets/textures/rounded-frame/border-1px.tga');
  [2] = getPath('assets/textures/rounded-frame/border-2px.tga');
  [4] = getPath('assets/textures/rounded-frame/border-4px.tga');
  [6] = getPath('assets/textures/rounded-frame/border-6px.tga');
  [8] = getPath('assets/textures/rounded-frame/border-8px.tga');
  [10] = getPath('assets/textures/rounded-frame/border-10px.tga');
}

---@param frame Texture
---@param texture string
local function applySlice(frame, texture)
    frame:SetTexture(texture)
    frame:SetTextureSliceMargins(12, 12, 12, 12)
    frame:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
end

---@class RoundedFrameOptions
---@field height number?
---@field width number?
---@field points table?
---@field border_size number?
---@field border_color colorRGB?
---@field background_color colorRGB?
---@field frame_strata FrameStrata?
local defaultOptions = {
    height = 200,
    width = 200,
    points = { { "CENTER" } },
    border_size = 0,
    border_color = styles.COLORS.BORDER,
    background_color = styles.COLORS.BACKGROUND,
    frame_strata = "HIGH"
}

---@param parent Frame
---@param options RoundedFrameOptions
---@return RoundedFrame
local function createRoundedFrame(parent, options)
    parent = parent or UIParent
    options = mixTables(defaultOptions, options)

    ---@class RoundedFrame:Frame
    local frame = CreateFrame("Frame", nil, parent)
    for _, point in ipairs(options.points) do
        frame:SetPoint(unpack(point))
    end

    frame:SetSize(options.width, options.height)

    frame.Background = frame:CreateTexture(nil, "BACKGROUND")
    applySlice(frame.Background, getPath('assets/textures/rounded-frame/base.tga'))
    frame.Background:SetVertexColor(options.background_color:GetRGBA())
    frame.Background:SetAllPoints()

    if options.border_size > 0 then
        frame.Border = frame:CreateTexture(nil, "BORDER")
        applySlice(frame.Border, borderTextures[options.border_size])
        frame.Border:SetVertexColor(options.border_color:GetRGBA())
        frame.Border:SetPoint("TOPLEFT", -options.border_size, options.border_size)
        frame.Border:SetPoint("BOTTOMRIGHT", options.border_size, -options.border_size)
    end

    if options.frame_strata then
        frame:SetFrameStrata(options.frame_strata)
    end

    return frame
end

---@class RoundedFrameAPI
---@field CreateFrame fun(parent:Frame, options:RoundedFrameOptions): Frame
lib.Widgets.RoundedFrame = {
    CreateFrame = createRoundedFrame
}