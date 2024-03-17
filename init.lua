KeystoneCompanionDB = {
  settings = {
    DevMode = false
  }
}

KeystoneCompanion = {
  version = '0.0.1',
  isDev = function () return KeystoneCompanionDB.settings.DevMode end,
  print = function(msg) print("|cffddca2eKeystoneCompanion|r: " .. msg) end,
  colorise = function(color, msg) return "|cff" .. color .. msg .. "|r" end
}

