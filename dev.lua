---@class KeystoneCompanionPrivate
local Private = select(2, ...)
---@class KeystoneCompanion
local addon = Private.Addon
local styles = Private.constants.styles
local widgets = Private.widgets
addon.dev = {};

function addon.dev.CloneInventory(from, to)
  Private.inventory[to] = Private.inventory[from];
  Private.UI.Rerender();
end

local function argsToString(...)
  local output = ""
  for _, arg in ipairs({ ... }) do
    output = string.format("%s%s,", output, tostring(arg))
  end
  return output
end

function addon:ToggleDevMode(forceState)
  self.DB.settings.DevMode = forceState ~= nil and forceState or not self.DB.settings.DevMode
  if self:isDev() then
    self.dev.DebugFrame:Show()
  else
    self.dev.DebugFrame:Hide()
  end
end

function addon:devPrint(...)
  if (self:isDev()) then
    local argStr = argsToString(...)
    local currentTime = date("%m/%d/%y %H:%M:%S")
    self:Print("|cffff0000(Dev) |r", argStr)

    if EventTrace then
      EventTrace:LogEvent(self.Name, ...)
    end

    if KeystoneCompanionDebug then
      if not KeystoneCompanionDebug.messages then KeystoneCompanionDebug.messages = {} end
      tinsert(KeystoneCompanionDebug.messages, { time = currentTime, entry = { ... } })
    end

    self:AddDevLine(argStr, currentTime)
  end
end

function addon:DevInit()
  local devFrame = widgets.RoundedFrame.CreateFrame(UIParent, {
    height = 350,
    width = 500,
    points = { { "TOPLEFT" } },
    frame_strata = "TOOLTIP",
    background_color = Private.constants.styles.COLORS.BACKGROUND_TRANSPARENT
  })
  self.dev.DebugFrame = devFrame
  devFrame:MakeMovable()
  devFrame:SetResizable(true)
  local screenWidth, screenheight = UIParent:GetSize()
  devFrame:SetResizeBounds(325, 175, screenWidth * 0.8, screenheight * 0.8)
  devFrame:SetClampedToScreen(true)
  if not self:isDev() then
    devFrame:Hide()
  end

  local devTitle = devFrame:CreateFontString()
  devTitle:SetFontObject(styles.FONT_OBJECTS.HEADING)
  devTitle:SetPoint("TOP", 0, -10)
  devTitle:SetText("Keystone Companion: Dev Debug")

  local devScrollBox, devScrollView = widgets.ScrollableFrame.CreateFrame(devFrame, {
    width = 500,
    height = 350,
    initializer = function(frame, elementData)
      if not frame.initialized then
        frame.initialized = true
        local log = frame:CreateFontString()
        log:SetAllPoints()
        log:SetFontObject(styles.FONT_OBJECTS.NORMAL)
        log:SetJustifyH("LEFT")
        frame.log = log
      end
      frame.log:SetText(elementData.text)
    end,
    element_height = 20
  })
  local sizer = CreateFrame("Frame", nil, devFrame)
  sizer:SetPoint("BOTTOMRIGHT", 2.5, -2.5)
  sizer:SetSize(16, 16)
  local sizerTex = sizer:CreateTexture()
  sizerTex:SetAllPoints()
  sizerTex:SetTexture(386864)
  sizer:EnableMouse(true)
  sizer:RegisterForDrag('LeftButton')
  sizer:SetScript("OnDragStart", function(frame)
    frame:GetParent():StartSizing("BOTTOMRIGHT", true)
  end)
  sizer:SetScript("OnDragStop", function(frame)
    frame:GetParent():StopMovingOrSizing()
  end)

  local copy = widgets.RoundedButton.CreateFrame(devFrame, {
    points = {
      { "TOPLEFT",  devScrollBox, "BOTTOMLEFT",  0, -10 },
      { "TOPRIGHT", devScrollBox, "BOTTOMRIGHT", 0, -10 },
      { "BOTTOM",   0,            10 },
    },
    font_text = "COPY DEV OUTPUT"
  })

  local copyFrame = widgets.RoundedFrame.CreateFrame(UIParent, {
    height = 350,
    width = 500,
    frame_strata = "TOOLTIP",
    background_color = Private.constants.styles.COLORS.BACKGROUND_TRANSPARENT
  })
  copyFrame:Hide()
  local copyScroll = CreateFrame("Frame", nil, copyFrame, "ScrollingEditBoxTemplate")
  copyScroll:SetPoint("TOPLEFT", 10, -10)
  copyScroll:SetPoint("BOTTOMRIGHT", -25, 40)
  copyScroll:GetEditBox():SetFontObject(styles.FONT_OBJECTS.NORMAL)
  copyScroll:GetEditBox():SetJustifyH("LEFT")
  local copyScrollBar = CreateFrame("EventFrame", nil, copyFrame, "MinimalScrollBar")
  copyScrollBar:SetPoint("TOPRIGHT", -15, -10)
  copyScrollBar:SetPoint("BOTTOMRIGHT", -15, 40)
  copyScrollBar:SetHideIfUnscrollable(true)
  ScrollUtil.RegisterScrollBoxWithScrollBar(copyScroll.ScrollBox, copyScrollBar)
  local closeCopyFrame = widgets.RoundedButton.CreateFrame(copyFrame, {
    points = {
      { "TOPLEFT",  copyScroll.ScrollBox, "BOTTOMLEFT",  0, -10 },
      { "TOPRIGHT", copyScroll.ScrollBox, "BOTTOMRIGHT", 0, -10 },
      { "BOTTOM",   0,                    10 },
    },
    font_text = CLOSE
  })
  closeCopyFrame:SetScript("OnMouseDown", function()
    copyFrame:Hide()
  end)

  local function getData(inputTbl)
    inputTbl = inputTbl or {}
    local oldSize = devScrollView:GetDataProviderSize()
    if oldSize > 0 then
      devScrollView:ForEachElementData(function(oldData)
        tinsert(inputTbl, oldData)
      end)
    end
    return inputTbl
  end

  local function isCharacterReadable(char)
    return char:byte() >= 32 and char:byte() <= 126
  end
  local function hasUnreadableCharacters(str)
    for i = 1, #str do
      if not isCharacterReadable(str:sub(i, i)) then
        return true
      end
    end
    return false
  end

  local function updateCopyText()
    local eb = copyScroll:GetEditBox()
    for _, entry in ipairs(getData()) do
      local txt = entry.text
      if hasUnreadableCharacters(txt) then
        txt = strlenutf8(txt)
      end
      eb:SetText(string.format("%s%s\n", eb:GetText(), txt))
    end
    copyFrame:Show()
  end

  copy:SetScript("OnMouseDown", function()
    updateCopyText()
  end)

  function addon:AddDevLine(text, currentTime)
    local debugText = string.format("[%s] %s", currentTime, text)
    local newData = getData()
    tinsert(newData, { text = debugText })
    devScrollView:UpdateContentData(newData)
  end
end
