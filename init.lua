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

Private.version = C_AddOns.GetAddOnMetadata(addonName, "Version");
Private.buildType = 'alpha';
Private.isDev = function() return KeystoneCompanionDB.settings.DevMode end;
Private.print = function(msg) print("|cffddca2eKeystoneCompanion|r: " .. msg) end;
Private.colorise = function(color, msg) return "|cff" .. color .. msg .. "|r" end;

function GetLocale() return "itIT" end
---@class KeystoneCompanion : RasuAddonBase
KeystoneCompanion = LibStub("RasuAddon"):CreateAddon(
  "Keystone Companion",
  "KeystoneCompanionDB",
  defaultDB,
  locale,
  "enUS"
)

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
