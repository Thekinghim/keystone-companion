---@class KeystoneCompanionPrivate
local Private = select(2, ...)

---@class KCDatabase
Private.DefaultDatabase = {
    libDBIcon = { hide = false },
    settings = {
        DevMode = false,
        DevChatPrint = true,
        MinimapButton = true,
        timerSettings = {
            active = true,
            scale = 80,
            anchor = { point = "RIGHT", relativePoint = "RIGHT", offsetX = -25, offsetY = 0 },
            alpha = 100
        }
    },
    bestTimes = {},
}

-- Stuff like DB Toggles should go here and do callbacks
-- On Init it should also automatically do migration to support older versions

function Private.InitDatabaseCallbacks()
    local addon = Private.Addon
    addon:CreateDatabaseCallback("settings.MinimapButton", function(_, value)
        if value then
            Private.LibDBIcon:Show("Keystone Companion")
        else
            Private.LibDBIcon:Hide("Keystone Companion")
        end
        Private.UI.Settings.Minimap.Activate:SetChecked(value)
    end)

    addon:CreateDatabaseCallback("settings.DevMode", function(_, value)
        if value then
            addon.dev.DebugFrame:Show()
        else
            addon.dev.DebugFrame:Hide()
        end
    end)
end
