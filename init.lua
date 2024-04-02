KeystoneCompanionDB = {
  settings = {
    DevMode = false
  }
}

KeystoneCompanion = {
  version = '1.0.0-beta.1',
  buildType = 'beta',
  isDev = function () return KeystoneCompanionDB.settings.DevMode end,
  print = function(msg) print("|cffddca2eKeystoneCompanion|r: " .. msg) end,
  colorise = function(color, msg) return "|cff" .. color .. msg .. "|r" end
}

