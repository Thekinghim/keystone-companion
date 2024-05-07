local addonName, Private = ...

local rasuGUI = LibStub("RasuGUI")

Private.RasuGUI = rasuGUI
Private.widgets = rasuGUI.Widgets
Private.LibDeflate = LibStub:GetLibrary("LibDeflate");
Private.LibSerialize = LibStub:GetLibrary("LibSerialize")
Private.LibDataBroker = LibStub:GetLibrary("LibDataBroker-1.1")
Private.LibDBIcon = LibStub:GetLibrary("LibDBIcon-1.0")

local locale = Private.Locales
local defaultDB = {
  settings = {
    DevMode = false,
    MinimapButton = true
  }
}

for lang, langInfo in pairs(Private.Locales) do
  if langInfo.isEditing then
    function GetLocale() return lang end
  end
end
---@class KeystoneCompanion : RasuAddonBase
KeystoneCompanion = LibStub("RasuAddon"):CreateAddon(
  addonName,
  "KeystoneCompanionDB",
  defaultDB,
  locale
)

KeystoneCompanion.buildType = C_AddOns.GetAddOnMetadata(addonName, "X-Build-Type"):lower()

function KeystoneCompanion:isDev()
  return self.DB.settings.DevMode
end

KeystoneCompanion.colorise = function(color, msg)
  if type(color) == "table" then
    color = color:GenerateHexColorNoAlpha()
  end
  return string.format("|cff%s%s|r", color, msg)
end
function KeystoneCompanion:OnInitialize()
  KeystoneCompanionDebug = KeystoneCompanionDebug or { messages = {} }

  -- This is needed for some M+ Related Functions
  -- As the UI can not be loaded before entering the World we just run this in the first possible frame
  RunNextFrame(function()
    if not C_AddOns.IsAddOnLoaded("Blizzard_ChallengesUI") then
      local hideAfter = not PVEFrame:IsVisible()
      PVEFrame_ShowFrame("ChallengesFrame")
      if hideAfter then HideUIPanel(PVEFrame) end
    end
    self:ScoreCalculatorInit()
  end)

  self:TimerInit() -- ui/dungeonTimer.lua
end

KeystoneCompanion.Private = Private
Private.Addon = KeystoneCompanion
