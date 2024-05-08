---@class KeystoneCompanionPrivate
local Private = select(2, ...)

---@class KCConstants
---@field roleIconCoords KCRoleIcons
Private.constants = Private.constants or {}

---@class KCRoleIcons
---@field TANK table
---@field HEALER table
---@field DAMAGER table
Private.constants.roleIconCoords = {
  TANK = { 0, 19 / 64, 22 / 64, 41 / 64 },
  HEALER = { 20 / 64, 39 / 64, 1 / 64, 20 / 64 },
  DAMAGER = { 20 / 64, 39 / 64, 22 / 64, 41 / 64 },
}
