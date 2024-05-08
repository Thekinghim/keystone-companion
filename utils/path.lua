---@class KeystoneCompanionPrivate
local Private = select(2, ...)
---@class KeystoneCompanion
local addon = Private.Addon

Private.utils = Private.utils or {};

Private.utils.path = {
  getTexturePath = function(name) return Private.constants.ASSETS_PATH .. 'textures/' .. name end
}
