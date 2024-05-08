---@class KeystoneCompanionPrivate
local Private = select(2, ...)

---@class KCConstants
---@field affixTalents KCAffixTalents
Private.constants = Private.constants or {};

---@class KCAffixInfoInfo
---@field specs [number]
---@field definitionID number
---@field reason string

---@class KCAffixes
---@field [9]  {[number] : KCAffixInfoInfo} Tyrannical
---@field [10]  {[number] : KCAffixInfoInfo} Fortified
---@field [135]  {[number] : KCAffixInfoInfo} Afflicted
---@field [136] {[number] : KCAffixInfoInfo} Incorporeal
---@field [3] {[number] : KCAffixInfoInfo} Volcanic
---@field [134] {[number] : KCAffixInfoInfo} Entangling
---@field [124] {[number] : KCAffixInfoInfo} Storming
---@field [123] {[number] : KCAffixInfoInfo} Spiteful
---@field [6] {[number] : KCAffixInfoInfo} Raging
---@field [7] {[number] : KCAffixInfoInfo} Bolstering
---@field [11] {[number] : KCAffixInfoInfo} Bursting
---@field [8] {[number] : KCAffixInfoInfo} Sanguine

---@class KCClasses
---@field [1] KCAffixes Warrior
---@field [2] KCAffixes Paladin
---@field [3] KCAffixes Hunter
---@field [4] KCAffixes Rogue
---@field [5] KCAffixes Priest
---@field [6] KCAffixes Death Knight
---@field [7] KCAffixes Shaman
---@field [8] KCAffixes Mage
---@field [9] KCAffixes Warlock
---@field [10] KCAffixes Monk
---@field [11] KCAffixes Druid
---@field [12] KCAffixes Demon Hunter
---@field [13] KCAffixes Evoker

---@class KCAffixTalents : KCClasses
local aTalents = {}
Private.constants.affixTalents = aTalents
--[[
    Table Structure is as follows: [ClassID] -> [AffixID] -> Info Table
    Info Table:
        - specs (table)
            - A list of specs that the talent is valid for.
        - definitionID (number)
            - The unique Talent ID.
        - reason (string)
            - A short Reason for why this talent is valid.
]]
--{specs = {}, definitionID = 0, reason = ""}, -- Spell
--

-- Warrior [71] = Arms, [72] = Fury, [73] = Protection
aTalents[1] = {
    -- Level 2 Affixes:
    -- Tyrannical
    [9] = {},
    -- Fortified
    [10] = {},

    -- Level 5 Affixes:
    -- Afflicted
    [135] = {},
    -- Incorporeal
    [136] = {
        { specs = { 71, 72, 73 }, definitionID = 117255, reason = "Menace is a bit of a mixed bag, since it knocks all nearby enemies back 15 yards. It's useful for shutting down the Incorporeal adds, but only if you specifically target the Incorporeal, but knocking packs of enemies around can be pretty dangerous at times. Intimidating Shout is still somewhat useful without Menace, but it only lasts 8 seconds, rather than 15, so it's not nearly as effective for completely locking down an Incorporeal add." }, -- Menace
    },
    -- Volcanic
    [3] = {},
    -- Entangling
    [134] = {
        { specs = { 71, 72 }, definitionID = 117213, reason = "Entangling can be easily handled by saving Heroic Leap to immediately break the effect." }, -- Heroic Leap
        { specs = { 73 },     definitionID = 117237, reason = "Avatar will break you free from the Entangling vine without having to leave the circle." }, -- Avatar
    },
    -- Storming
    [124] = {},

    -- Level 10 Affixes:
    -- Spiteful
    [123] = {
        { specs = { 71, 72, 73 }, definitionID = 117203, reason = "Help keep Spiteful Shades off of you and your party members." }, -- Storm Bolt
    },
    -- Raging
    [6] = {},
    -- Bolstering
    [7] = {},
    -- Bursting
    [11] = {},
    -- Sanguine
    [8] = {},
}

-- Paladin [65] = Holy, [66] = Protection, [70] = Retribution
aTalents[2] = {
    -- Level 2 Affixes:
    -- Tyrannical
    [9] = {},
    -- Fortified
    [10] = {},

    -- Level 5 Affixes:
    -- Afflicted
    [135] = {
        { specs = { 65 },     definitionID = 107482, reason = "You need this for this affix as Afflicted Afflicted cannot be dispelled with a magic dispel." }, -- Improved Cleanse
        { specs = { 66, 70 }, definitionID = 107481, reason = "With this, you can help on every single spawn." },                                               -- Cleanse Toxins
    },
    -- Incorporeal
    [136] = {
        { specs = { 65, 66, 70 }, definitionID = 107628, reason = "You can use this to control Incorporeal." },                                                      -- Turn Evil
        { specs = { 65, 66, 70 }, definitionID = 107590, reason = "You can also use this for Incorporeal but giving up Blinding Light might be too steep a cost." }, -- Repentance
    },
    -- Volcanic
    [3] = {},
    -- Entangling
    [134] = {
        { specs = { 65, 66, 70 }, definitionID = 107592, reason = "You can use this for every single one." },              -- Blessing of Freedom
        { specs = { 66 },         definitionID = 120491, reason = "You can free yourself and a party member with this." }, -- Unbound Freedom
        { specs = { 70 },         definitionID = 120466, reason = "You can free yourself and a party member with this." }, -- Unbound Freedom
    },
    -- Storming
    [124] = {},

    -- Level 10 Affixes:
    -- Spiteful
    [123] = {
        { specs = { 65 }, definitionID = 107609, reason = "This lets you ignore Spiteful adds for a while." },         -- Blessing of Protection
        { specs = { 66 }, definitionID = 107464, reason = "Get this to help slow them and keep them under control." }, -- Consecrated Ground
    },
    -- Raging
    [6] = {
        { specs = { 65 }, definitionID = 107607, reason = "You can use it on the tank if they need it during Raging." }, -- Blessing of Sacrifice
    },
    -- Bolstering
    [7] = {},
    -- Bursting
    [11] = {
        { specs = { 66 }, definitionID = 116891, reason = "You can cast this on the healer to lower incoming damage drastically" },                                           -- Blessing of Spellwarding
        { specs = { 65 }, definitionID = 107537, reason = "This helps a lot! Using it as late as possible as stacks ramp is imperative in dealing with large packs dying." }, -- Beacon of Virtue
        { specs = { 65 }, definitionID = 107470, reason = "This is also incredibly good at healing through Bursting." },                                                      -- Divine Toll
        { specs = { 65 }, definitionID = 107568, reason = "This is also incredibly good at healing through Bursting." },                                                      -- Daybreak
        { specs = { 65 }, definitionID = 107607, reason = "Use this liberally on classes that cannot not remove stacks on their own." },                                      -- Blessing of Sacrifice
    },
    -- Sanguine
    [8] = {},
}

-- Hunter [253] = Beast Mastery, [254] = Marksmanship, [255] = Survival
aTalents[3] = {
    -- Level 2 Affixes:
    -- Tyrannical
    [9] = {},
    -- Fortified
    [10] = {},

    -- Level 5 Affixes:
    -- Afflicted
    [135] = {},
    -- Incorporeal
    [136] = {
        { specs = { 253, 254, 255 }, definitionID = 105642, reason = "Can be used in addition to Freezing Trap" }, -- Scare Beast
    },
    -- Volcanic
    [3] = {},
    -- Entangling
    [134] = {
        { specs = { 253, 254, 255 }, definitionID = 105636, reason = "This is mandatory to clear root with disengage" }, -- Posthaste
    },
    -- Storming
    [124] = {},

    -- Level 10 Affixes:
    -- Spiteful
    [123] = {
        { specs = { 253, 254, 255 }, definitionID = 105652, reason = "This is great against Shades" },                -- Binding Shot
        { specs = { 253, 254, 255 }, definitionID = 105694, reason = "Use this as an extra way to stop Spitefuls." }, -- Entrapment
    },
    -- Raging
    [6] = {
        { specs = { 253, 254, 255 }, definitionID = 105619, reason = "You always want this in combination with Improved Tranquilizing Shot' to clear raging." }, -- Tranquilizing Shot
        { specs = { 253, 254, 255 }, definitionID = 105634, reason = "You want this for higher Focus gain during Raging weeks." },                               -- Improved Tranquilizing Shot
    },
    -- Bolstering
    [7] = {},
    -- Bursting
    [11] = {},
    -- Sanguine
    [8] = {
        { specs = { 253, 254, 255 }, definitionID = 105622, reason = "Use  this to remove mobs from Sanguine pools." }, -- High Explosive Trap
    },
}

-- Rogue [259] = Assasination, [260] = Outlaw, [261] = Subtlety
aTalents[4] = {
    -- Level 2 Affixes:
    -- Tyrannical
    [9] = {},
    -- Fortified
    [10] = {},

    -- Level 5 Affixes:
    -- Afflicted
    [135] = {},
    -- Incorporeal
    [136] = {
        { specs = { 259, 260, 261 }, definitionID = 117636, reason = "Use this or other CC to deal with Incorporeal" }, -- Gouge
        { specs = { 259, 261 },      definitionID = 117577, reason = "Use this or other CC to deal with Incorporeal" }, -- Blind
    },
    -- Volcanic
    [3] = {},
    -- Entangling
    [134] = {},
    -- Storming
    [124] = {
        { specs = { 259, 260, 261 }, definitionID = 117649, reason = "This makes it significantly easier to manage storming." }, -- Acrobatic Strikes
    },

    -- Level 10 Affixes:
    -- Spiteful
    [123] = {
        { specs = { 259, 260, 261 }, definitionID = 117662, reason = "You always wanna use this for Spitefuls" }, -- Evasion
    },
    -- Raging
    [6] = {
        { specs = { 260, 261 }, definitionID = 117635, reason = "Can be used to clear enrage from big mobs." }, -- Shiv
    },
    -- Bolstering
    [7] = {},
    -- Bursting
    [11] = {
        { specs = { 259, 260 }, definitionID = 117590, reason = "This is great for high stacks." }, -- Cloak of Shadows
    },
    -- Sanguine
    [8] = {},
}

-- Priest [256] = Discipline, [257] = Holy, [258] = Shadow
aTalents[5] = {
    -- Level 2 Affixes:
    -- Tyrannical
    [9] = {},
    -- Fortified
    [10] = {},

    -- Level 5 Affixes:
    -- Afflicted
    [135] = {
        { specs = { 256, 257 }, definitionID = 108860, reason = "Be sure to spec into this to deal with afflicted." }, -- Improved Purify
        { specs = { 256, 257 }, definitionID = 108827, reason = "This is also very good for afflicted." },             -- Power Word: Life
    },
    -- Incorporeal
    [136] = {
        { specs = { 256, 257, 258 }, definitionID = 108683, reason = "This will control the minion and cause it to cast damage reduction debuffs onto enemies." }, -- Dominate Mind
        { specs = { 256, 257, 258 }, definitionID = 108848, reason = "This can be used on the second Incorporeal." },                                              -- Shackle Undead
    },
    -- Volcanic
    [3] = {},
    -- Entangling
    [134] = {
        { specs = { 256, 257, 258 }, definitionID = 108839, reason = "With this you can use Fade to remove entangling." },                           -- Phantasm
        { specs = { 256, 257, 258 }, definitionID = 108841, reason = "You can spec into this to ensure that you always have fade for entangling." }, -- Improved Fade
    },
    -- Storming
    [124] = {},

    -- Level 10 Affixes:
    -- Spiteful
    [123] = {
        { specs = { 256, 257, 258 }, definitionID = 108683, reason = "You can use this on Shades that target you to dispose them." }, -- Dominate Mind
    },
    -- Raging
    [6] = {},
    -- Bolstering
    [7] = {},
    -- Bursting
    [11] = {
        { specs = { 256, 257, 258 }, definitionID = 108854, reason = "This will remove all Busting stacks." },         -- Mass Dispel
        { specs = { 256, 257, 258 }, definitionID = 108853, reason = "This is a solid option if mana is a concern." }, -- Mental Agility
    },
    -- Sanguine
    [8] = {},
}

-- Death Knight [250] = Blood, [251] = Frost, [252] = Unholy
aTalents[6] = {
    -- Level 2 Affixes:
    -- Tyrannical
    [9] = {},
    -- Fortified
    [10] = {},

    -- Level 5 Affixes:
    -- Afflicted
    [135] = {},
    -- Incorporeal
    [136] = {
        { specs = { 250, 251, 252 }, definitionID = 101190, reason = "You can use this to deal with this Affix" }, -- Control Undead
    },
    -- Volcanic
    [3] = {},
    -- Entangling
    [134] = {
        { specs = { 250, 251, 252 }, definitionID = 101209, reason = "This can directly remove entangling but it's recommended to just use Death's Advance to get out instead." }, -- Wraith Walk
    },
    -- Storming
    [124] = {},

    -- Level 10 Affixes:
    -- Spiteful
    [123] = {},
    -- Raging
    [6] = {},
    -- Bolstering
    [7] = {},
    -- Bursting
    [11] = {
        { specs = { 250, 251, 252 }, definitionID = 101201, reason = "You can pre cast this to not get any Bursting stacks." }, -- Anti-Magic Shell
    },
    -- Sanguine
    [8] = {},
}

-- Shaman [262] = Elemental, [263] = Enhancement, [264] = Restoration
aTalents[7] = {
    -- Level 2 Affixes:
    -- Tyrannical
    [9] = {},
    -- Fortified
    [10] = {},

    -- Level 5 Affixes:
    -- Afflicted
    [135] = {
        { specs = { 262, 263 },      definitionID = 106966, reason = "You can easily deal with Afflicted adds with this." },                         -- Cleanse Spirit
        { specs = { 262, 263, 264 }, definitionID = 106984, reason = "This basically removes the affix but you might not have it for each spawn." }, -- Poison Cleansing Totem
        { specs = { 264 },           definitionID = 106962, reason = "You need this to dispel afflicted." },                                         -- Improved Purify Spirit
    },
    -- Incorporeal
    [136] = {
        { specs = { 262, 263, 264 }, definitionID = 106981, reason = "You can completely handle one Incorporeal with this." }, -- Hex
    },
    -- Volcanic
    [3] = {},
    -- Entangling
    [134] = {
        { specs = { 262, 263, 264 }, definitionID = 106958, reason = "You can use this to immediately break the root." }, -- Thunderous Paws
    },
    -- Storming
    [124] = {},

    -- Level 10 Affixes:
    -- Spiteful
    [123] = {
        { specs = { 262, 263, 264 }, definitionID = 106971, reason = "Great for keeping Shades away" }, -- Earthgrab Totem
    },
    -- Raging
    [6] = {},
    -- Bolstering
    [7] = {},
    -- Bursting
    [11] = {
        { specs = { 264 }, definitionID = 106933, reason = "This can sometimes come in handy during Bursting." }, -- Spirit Link Totem
    },
    -- Sanguine
    [8] = {
        { specs = { 262, 263, 264 }, definitionID = 106989, reason = "You can use this to knock adds out of the sanguine puddles." }, -- Thundershock
    },
}

-- Mage [62] = Arcane, [63] = Fire, [64] = Frost
aTalents[8] = {
    -- Level 2 Affixes:
    -- Tyrannical
    [9] = {},
    -- Fortified
    [10] = {},

    -- Level 5 Affixes:
    -- Afflicted
    [135] = {
        { specs = { 62, 63, 64 }, definitionID = 85178, reason = "Use this to deal with Afflicted." }, -- Remove Curse
    },
    -- Incorporeal
    [136] = {},
    -- Volcanic
    [3] = {
        { specs = { 62, 63, 64 }, definitionID = 85165, reason = "This or Shimmer are both great here." },  -- Ice Floes
        { specs = { 62, 63, 64 }, definitionID = 85166, reason = "This or Ice Floes are both great here" }, -- Shimmer
    },
    -- Entangling
    [134] = {
        { specs = { 62, 63, 64 }, definitionID = 85160, reason = "If you don't want to move you can use this to clear entangling." }, -- Energized Barriers
    },
    -- Storming
    [124] = {
        { specs = { 62, 63, 64 }, definitionID = 85165, reason = "This or Shimmer are both great here." },  -- Ice Floes
        { specs = { 62, 63, 64 }, definitionID = 85166, reason = "This or Ice Floes are both great here" }, -- Shimmer
    },

    -- Level 10 Affixes:
    -- Spiteful
    [123] = {
        { specs = { 62, 63, 64 }, definitionID = 85147, reason = "Use this to keep Shades away." }, -- Ring of Frost
    },
    -- Raging
    [6] = {},
    -- Bolstering
    [7] = {},
    -- Bursting
    [11] = {
        { specs = { 62, 63, 64 }, definitionID = 85177, reason = "Use this before you get high stacks." }, -- Alter Time
    },
    -- Sanguine
    [8] = {
        { specs = { 62, 63, 64 }, definitionID = 85163, reason = "Use this to knock mobs away from pools." }, -- Blast Wave
    },
}

-- Warlock [265] = Affliction, [266] = Demonology, [267] = Destruction
aTalents[9] = {
    -- Level 2 Affixes:
    -- Tyrannical
    [9] = {},
    -- Fortified
    [10] = {},

    -- Level 5 Affixes:
    -- Afflicted
    [135] = {},
    -- Incorporeal
    [136] = {
        { specs = { 265, 266, 267 }, definitionID = 96456, reason = "You can Banish the mobs that spawn, effectively negating the affix." }, -- Banish
    },
    -- Volcanic
    [3] = {},
    -- Entangling
    [134] = {},
    -- Storming
    [124] = {},

    -- Level 10 Affixes:
    -- Spiteful
    [123] = {
        { specs = { 265, 266, 267 }, definitionID = 96454, reason = "This or Mortal Coil are great ways to deal with Shades." }, -- Shadowfury
        { specs = { 265, 266, 267 }, definitionID = 96459, reason = "This or Shadowfury are great ways to deal with Shades." },  -- Mortal Coil
    },
    -- Raging
    [6] = {
        { specs = { 265, 266, 267 }, definitionID = 96444, reason = "You can use this to greatly increase the cast time with Curse of Tongues" }, -- Amplify Curse
    },
    -- Bolstering
    [7] = {},
    -- Bursting
    [11] = {},
    -- Sanguine
    [8] = {},
}

-- Monk [268] = Brewmaster, [269] = Windwalker, [270] = Mistweaver
aTalents[10] = {
    -- Level 2 Affixes:
    -- Tyrannical
    [9] = {},
    -- Fortified
    [10] = {},

    -- Level 5 Affixes:
    -- Afflicted
    [135] = {
        { specs = { 268, 269 }, definitionID = 107631, reason = "Get this to deal with afflicted." },   -- Detox
        { specs = { 270 },      definitionID = 107632, reason = "You need this to handle afflicted." }, -- Improved Detox
    },
    -- Incorporeal
    [136] = {
        { specs = { 268, 269, 270 }, definitionID = 106508, reason = "Use this to handle incoporeal." }, -- Paralysis
    },
    -- Volcanic
    [3] = {},
    -- Entangling
    [134] = {
        { specs = { 269, 270 }, definitionID = 106509, reason = "This immediately removes the entangling debuff." }, -- Tiger's Lust
    },
    -- Storming
    [124] = {},

    -- Level 10 Affixes:
    -- Spiteful
    [123] = {
        { specs = { 268, 269, 270 }, definitionID = 106518, reason = "You can use this to create a safe area from shades." }, -- Ring of Peace
    },
    -- Raging
    [6] = {},
    -- Bolstering
    [7] = {
        { specs = { 268 }, definitionID = 106518, reason = "You can make use of this to keep mobs with high stacks aways from you." }, -- Ring of Peace
    },
    -- Bursting
    [11] = {
        { specs = { 270 },           definitionID = 106380, reason = "You can clear the entire group with this." },          -- Revival
        { specs = { 268, 269, 270 }, definitionID = 106517, reason = "You can remove your own Bursting stacks with this." }, -- Diffuse Magic
    },
    -- Sanguine
    [8] = {
        { specs = { 268, 269, 270 }, definitionID = 106518, reason = "This is great to get mobs out of sanguine pools." }, -- Ring of Peace
    },
}

-- Druid [102] = Balance, [103] = Feral, [104] = Guardian, [105] = Restoration
aTalents[11] = {
    -- Level 2 Affixes:
    -- Tyrannical
    [9] = {},
    -- Fortified
    [10] = {},

    -- Level 5 Affixes:
    -- Afflicted
    [135] = {
        { specs = { 102, 103, 104 }, definitionID = 108288, reason = "It's the best way of dealing with afflicted as Balance and Feral but costly on Guardian." }, -- Remove Corruption
        { specs = { 104 },           definitionID = 108211, reason = "Can be used to heal afflicted to full HP." },                                                -- After the Wildfire
    },
    -- Incorporeal
    [136] = {
        { specs = { 102, 103, 104, 105 }, definitionID = 108294, reason = "Either take this or Cyclone. These are some of the best spells in the game for dealing with Incoporeal due to their lack of a cooldown." },   -- Hibernate
        { specs = { 102, 103, 104, 105 }, definitionID = 108296, reason = "Either take this or Hibernate. These are some of the best spells in the game for dealing with Incoporeal due to their lack of a cooldown." }, -- Cyclone
    },
    -- Volcanic
    [3] = {},
    -- Entangling
    [134] = {},
    -- Storming
    [124] = {},

    -- Level 10 Affixes:
    -- Spiteful
    [123] = {
        { specs = { 102, 103, 104, 105 }, definitionID = 108326, reason = "Keeping Spiteful Adds slowed + having a grip on them back into melee is always great for you and others who are targeted by them." }, -- Ursol's Vortex
        { specs = { 104 },                definitionID = 108237, reason = "Can be talented if your group has absolutely no slows." },                                                                            -- Infected Wounds
    },
    -- Raging
    [6] = {
        { specs = { 102, 103, 104, 105 }, definitionID = 108312, reason = "This is situationally very strong depending on which mobs need to be soothed" }, -- Soothe
    },
    -- Bolstering
    [7] = {},
    -- Bursting
    [11] = {
        { specs = { 102, 103, 104 }, definitionID = 108328, reason = "Your healer will love this." },                                                           -- Innervate
        { specs = { 104 },           definitionID = 108211, reason = "A really helpful tool to keep your group alive." },                                       -- After the Wildfire
        { specs = { 105 },           definitionID = 108116, reason = "Great for groups that can't count." },                                                    -- Efflorescence
        { specs = { 105 },           definitionID = 108134, reason = "You'll want Lifebloom on yourself with this Talent as mobs start to die." },              -- Photosynthesis
        { specs = { 105 },           definitionID = 108141, reason = "This is also extremely good here but you might not have it for every pack." },            -- Flourish
        { specs = { 105 },           definitionID = 108113, reason = "For when you weren't expecting the stacks and didn't have time to prepare in advance." }, -- Flourish
    },
    -- Sanguine
    [8] = {
        { specs = { 102, 103, 104, 105 }, definitionID = 108292, reason = "You can reposition mobs with this to reduce the healing they receive from Sanguine puddles." }, -- Typhoon
        { specs = { 102, 103, 104, 105 }, definitionID = 108326, reason = "You can reposition mobs with this to reduce the healing they receive from Sanguine puddles." }, -- Ursol's Vortex
    },
}

-- Demon Hunter [577] = Havoc, [581] = Vengeance
aTalents[12] = {
    -- Level 2 Affixes:
    -- Tyrannical
    [9] = {},
    -- Fortified
    [10] = {},

    -- Level 5 Affixes:
    -- Afflicted
    [135] = {},
    -- Incorporeal
    [136] = {
        { specs = { 577, 581 }, definitionID = 117932, reason = "You should be able to cage 1 add per spawn with this." }, -- Imprison
    },
    -- Volcanic
    [3] = {},
    -- Entangling
    [134] = {
        { specs = { 581 }, definitionID = 117858, reason = "You can get this to immediately remove entangling." }, -- Vengeful Retreat
    },
    -- Storming
    [124] = {},

    -- Level 10 Affixes:
    -- Spiteful
    [123] = {
        { specs = { 577 }, definitionID = 117916, reason = "This is great for dealing with Shades." },    -- Chaos Nova
        { specs = { 581 }, definitionID = 117872, reason = "This is great for keeping Shades together" }, -- Sigil of Chains
    },
    -- Raging
    [6] = {},
    -- Bolstering
    [7] = {},
    -- Bursting
    [11] = {
        { specs = { 577 }, definitionID = 117926, reason = "You should use this for high Bursting stacks." }, -- Darkness
    },
    -- Sanguine
    [8] = {
        { specs = { 577 }, definitionID = 122755, reason = "You can reduce sanguine healing with this." },   -- Mortal Dance
        { specs = { 581 }, definitionID = 117872, reason = "You can grip mobs out of sanguine with this." }, -- Sigil of Chains
    },
}

-- Evoker [1467] = Devastation, [1468] = Preservation, [1473] = Augmentation
aTalents[13] = {
    -- Level 2 Affixes:
    -- Tyrannical
    [9] = {},
    -- Fortified
    [10] = {},

    -- Level 5 Affixes:
    -- Afflicted
    [135] = {
        { specs = { 1467, 1473 },       definitionID = 120627, reason = "Get this to deal with afflicted." },     -- Expunge
        { specs = { 1467, 1468, 1473 }, definitionID = 120614, reason = "This can also be used for afflicted." }, -- Cauterizing Flame
    },
    -- Incorporeal
    [136] = {
        { specs = { 1467, 1468, 1473 }, definitionID = 120613, reason = "You can get this to deal with incoporeal." }, -- Sleep Walk
    },
    -- Volcanic
    [3] = {},
    -- Entangling
    [134] = {},
    -- Storming
    [124] = {},

    -- Level 10 Affixes:
    -- Spiteful
    [123] = {
        { specs = { 1468 }, definitionID = 120626, reason = "You can get this to keep Shades away." }, -- Landslide
    },
    -- Raging
    [6] = {
        { specs = { 1467, 1468, 1473 }, definitionID = 120618, reason = "You can AoE remove Raging with this." }, -- Overawe
    },
    -- Bolstering
    [7] = {},
    -- Bursting
    [11] = {
        { specs = { 1467, 1468, 1473 }, definitionID = 120670, reason = "This is great for Bursting as it heals you back." }, -- Renewing Blaze
        { specs = { 1468 },             definitionID = 120567, reason = "This is good to heal against Bursting." },           -- Ouroboros
        { specs = { 1468 },             definitionID = 120663, reason = "This is great if you get really high stacks." },     -- Rewind
    },
    -- Sanguine
    [8] = {
        { specs = { 1467, 1468, 1473 }, definitionID = 120617, reason = "You should get this to knock mobs out of sanguine." }, -- Heavy Wingbeats
    },
}
