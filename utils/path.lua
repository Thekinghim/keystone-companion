local _, KeystoneCompanion = ...;
KeystoneCompanion.utils = KeystoneCompanion.utils or {};

KeystoneCompanion.utils.path = {
  getTexturePath = function (name) return KeystoneCompanion.constants.ASSETS_PATH .. 'textures/' .. name end
}