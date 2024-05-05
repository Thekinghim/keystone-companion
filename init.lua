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

local locale = {
  enUS = { ["TestLocale"] = "TestLocale" }
}

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

---@class KeystoneCompanion : RasuAddonBase
KeystoneCompanion = LibStub("RasuAddon"):CreateAddon(
  "Keystone Companion",
  "KeystoneCompanionDB",
  defaultDB,
  locale,
  "enUS"
)

function KeystoneCompanion:OnInitialize()
end
KeystoneCompanion.Private = Private
Private.Addon = KeystoneCompanion
