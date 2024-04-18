local _, KeystoneCompanion = ...

KeystoneCompanionDB = {
  settings = {
    DevMode = false
  }
}

KeystoneCompanion.version = '1.0.0'
KeystoneCompanion.buildType = 'release'
KeystoneCompanion.isDev = function () return KeystoneCompanionDB.settings.DevMode end
KeystoneCompanion.print = function(msg) print("|cffddca2eKeystoneCompanion|r: " .. msg) end
KeystoneCompanion.colorise = function(color, msg) return "|cff" .. color .. msg .. "|r" end

_G.KeystoneCompanion = KeystoneCompanion;
