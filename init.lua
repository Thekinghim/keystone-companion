local addonName, KeystoneCompanion = ...

local rasuGUI = LibStub("RasuGUI")
KeystoneCompanion.RasuGUI = rasuGUI
KeystoneCompanion.widgets = rasuGUI.Widgets

KeystoneCompanionDB = {
  settings = {
    DevMode = false,
    MinimapButton = true
  }
}

KeystoneCompanion.version = C_AddOns.GetAddOnMetadata(addonName, "Version");
KeystoneCompanion.buildType = 'release';
KeystoneCompanion.isDev = function() return KeystoneCompanionDB.settings.DevMode end;
KeystoneCompanion.print = function(msg) print("|cffddca2eKeystoneCompanion|r: " .. msg) end;
KeystoneCompanion.colorise = function(color, msg) return "|cff" .. color .. msg .. "|r" end;

_G.KeystoneCompanion = KeystoneCompanion;
