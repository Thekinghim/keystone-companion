---@class KeystoneCompanionPrivate
local Private = select(2, ...)

---@class KCConstants
---@field items KCItemList
---@field itemLookup KCItemLookup
Private.constants = Private.constants or {}

---@class KCItemList
Private.constants.items = {
  Food = {
    [197778] = true, -- Timely Demise
    [197779] = true, -- Filet of Fangs
    [197780] = true, -- Seamoth Surprise
    [197781] = true, -- Salt-Baked Fishcake
    [197782] = true, -- Feisty Fish Sticks
    [197783] = true, -- Aromatic Seafood Platter
    [197784] = true, -- Sizzling Seafood Medley
    [197785] = true, -- Revenge, Served Cold
    [197786] = true, -- Thousandbone Tongueslicer
    [197787] = true, -- Great Cerulean Sea
    [197794] = true, -- Grand Banquet of the Kalu'ak
    [204072] = true, -- Deviously Deviled Eggs
  },
  Rune = {
    [201325] = true, -- Draconic Augment Rune
    [211495] = true, -- Dreambound Augment Rune
  },
  Potion = {
    [191365] = true, -- Potion of Frozen Focus
    [191368] = true, -- Potion of Chilled Clarity
    [191371] = true, -- Potion of Withering Vitality
    [191374] = true, -- Residual Neural Channeling Agent
    [191380] = true, -- Refreshing Healing Potion
    [191383] = true, -- Elemental Potion of Ultimate Power
    [191386] = true, -- Aerated Mana Potion
    [191389] = true, -- Elemental Potion of Power
    [191395] = true, -- Potion of the Hushed Zephyr
    [191398] = true, -- Potion of Gusts
    [191401] = true, -- Potion of Shocking Disclosure
    [207023] = true, -- Dreamwalker's Healing Potion
    [207041] = true, -- Potion of Withering Dreams
  },
  Flask = {
    [191320] = true, -- Phial of the Eye in the Storm
    [191323] = true, -- Phial of Still Air
    [191326] = true, -- Phial of Icy Preservation
    [191329] = true, -- Iced Phial of Corrupting Rage
    [191332] = true, -- Phial of Charged Isolation
    [191335] = true, -- Phial of Glacial Fury
    [191338] = true, -- Phial of Static Empowerment
    [191341] = true, -- Phial of Tepid Versatility
    [191350] = true, -- Charged Phial of Alacrity
    [191359] = true, -- Phial of Elemental Chaos
  },
  WeaponEnchantment = {
    [191940] = true, -- Primal Whetstone
    [191944] = true, -- Primal Weightstone
    [191950] = true, -- Primal Razorstone
    [194820] = true, -- Howling Rune
    [194823] = true, -- Buzzing Rune
    [194826] = true, -- Chirping Rune
    [204973] = true, -- Hissing Rune
    [198318] = true, -- High Intensity Thermal Scanner
  }
}

---@class KCItemLookup
---@field [number] "Food"|"Rune"|"Potion"|"Flask"|"WeaponEnchantment"|nil
Private.constants.itemLookup = {};
for category, entries in pairs(Private.constants.items) do
  for itemId in pairs(entries) do
    Private.constants.itemLookup[itemId] = category
  end
end
