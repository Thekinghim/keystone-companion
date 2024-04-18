local _, KeystoneCompanion = ...

KeystoneCompanion.constants = KeystoneCompanion.constants or {};
KeystoneCompanion.constants.items = {
  Food = {
    [197778] = { name = 'Timely Demise' },
    [197779] = { name = 'Filet of Fangs' },
    [197780] = { name = 'Seamoth Surprise' },
    [197781] = { name = 'Salt-Baked Fishcake' },
    [197782] = { name = 'Feisty Fish Sticks' },
    [197783] = { name = 'Aromatic Seafood Platter' },
    [197784] = { name = 'Sizzling Seafood Medley' },
    [197785] = { name = 'Revenge, Served Cold' },
    [197786] = { name = 'Thousandbone Tongueslicer' },
    [197787] = { name = 'Great Cerulean Sea' },
    [197794] = { name = 'Grand Banquet of the Kalu\'ak' },
    [204072] = { name = 'Deviously Deviled Eggs' },
  },
  Rune = {
    [201325] = { name = 'Draconic Augment Rune' },
    [211495] = { name = 'Dreambound Augment Rune' },
  },
  Potion = {
    [191365] = { name = 'Potion of Frozen Focus' },
    [191368] = { name = 'Potion of Chilled Clarity' },
    [191371] = { name = 'Potion of Withering Vitality' },
    [191374] = { name = 'Residual Neural Channeling Agent' },
    [191380] = { name = 'Refreshing Healing Potion' },
    [191383] = { name = 'Elemental Potion of Ultimate Power' },
    [191386] = { name = 'Aerated Mana Potion' },
    [191389] = { name = 'Elemental Potion of Power' },
    [191395] = { name = 'Potion of the Hushed Zephyr' },
    [191398] = { name = 'Potion of Gusts' },
    [191401] = { name = 'Potion of Shocking Disclosure' },
    [207023] = { name = 'Dreamwalker\'s Healing Potion' },
    [207041] = { name = 'Potion of Withering Dreams' },
  },
  Flask = {
    [191320] = { name = 'Phial of the Eye in the Storm' },
    [191323] = { name = 'Phial of Still Air' },
    [191326] = { name = 'Phial of Icy Preservation' },
    [191329] = { name = 'Iced Phial of Corrupting Rage' },
    [191332] = { name = 'Phial of Charged Isolation' },
    [191335] = { name = 'Phial of Glacial Fury' },
    [191338] = { name = 'Phial of Static Empowerment' },
    [191341] = { name = 'Phial of Tepid Versatility' },
    [191350] = { name = 'Charged Phial of Alacrity' },
    [191359] = { name = 'Phial of Elemental Chaos' },
  },
  WeaponEnchantment = {
    [191940] = { name = 'Primal Whetstone' },
    [191944] = { name = 'Primal Weightstone' },
    [191950] = { name = 'Primal Razorstone' },
    [194820] = { name = 'Howling Rune' },
    [194823] = { name = 'Buzzing Rune' },
    [194826] = { name = 'Chirping Rune' },
    [204973] = { name = 'Hissing Rune' },
    [198318] = { name = 'High Intensity Thermal Scanner' },
  }
}

KeystoneCompanion.constants.itemLookup = {};
for category, entries in pairs(KeystoneCompanion.constants.items) do
  for itemId in pairs(entries) do
    KeystoneCompanion.constants.itemLookup[itemId] = category
  end
end