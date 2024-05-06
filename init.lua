local addonName, Private = ...

local rasuGUI = LibStub("RasuGUI")

Private.RasuGUI = rasuGUI
Private.widgets = rasuGUI.Widgets
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

---@class KeystoneCompanion : RasuAddonBase
KeystoneCompanion = LibStub("RasuAddon"):CreateAddon(
  addonName,
  "Keystone Companion",
  "KeystoneCompanionDB",
  defaultDB,
  locale
)

KeystoneCompanion.buildType = "alpha"

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
  KeystoneCompanionDebug = KeystoneCompanionDebug or {}
end

function Private.AddDebugEntry(entry)
  local time = time()
  tinsert(KeystoneCompanionDebug, { time = time, entry = entry })
  print(string.format("New Debug Print: %s", entry))
end

KeystoneCompanion.Private = Private
Private.Addon = KeystoneCompanion
