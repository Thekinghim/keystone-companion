local addonName, Private = ...

local rasuGUI = LibStub("RasuGUI")
Private.RasuGUI = rasuGUI
Private.widgets = rasuGUI.Widgets

local defaultDB = {
  settings = {
    DevMode = false,
    MinimapButton = true
  }
}

local locale = Private.Locales

KeystoneCompanionDB = {
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
--Private.isDev = function() return KeystoneCompanion.DB.settings.DevMode end;
KeystoneCompanion.colorise = function(color, msg) return string.format("|cff%s%s|r", color, msg) end;
function KeystoneCompanion:isDev()
  return self.DB.settings.DevMode
end

function KeystoneCompanion:OnInitialize()
  KeystoneCompanionDebug = KeystoneCompanionDebug or {}
end
function Private.AddDebugEntry(entry)
  local time = time()
  tinsert(KeystoneCompanionDebug, {time = time, entry = entry})
  print(string.format("New Debug Print: %s", entry))
end
KeystoneCompanion.Private = Private
Private.Addon = KeystoneCompanion
