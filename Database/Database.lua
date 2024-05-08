---@class KeystoneCompanionPrivate
local Private = select(2, ...)

---@class KCDatabase
Private.DefaultDatabase = {
    libDBIcon = { hide = false },
    settings = {
        DevMode = false,
        DevChatPrint = true,
        MinimapButton = true,
        bestTimes = {},
    }
}

-- Stuff like DB Toggles should go here and do callbacks
-- On Init it should also automatically do migration to support older versions