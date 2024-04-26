local _, KeystoneCompanion = ...
KeystoneCompanion.constants = KeystoneCompanion.constants or {};
KeystoneCompanion.constants.affixTalents = {}
local aTalents = KeystoneCompanion.constants.affixTalents

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
        { specs = { 73 }, definitionID = 117237, reason = "Avatar will break you free from the Entangling vine without having to leave the circle." }, -- Avatar
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
        {specs = {65}, definitionID = 107482, reason = "You need this for this affix as Afflicted Afflicted cannot be dispelled with a magic dispel."}, -- Improved Cleanse
        {specs = {66, 70}, definitionID = 107481, reason = "With this, you can help on every single spawn."}, -- Cleanse Toxins
    },
    -- Incorporeal
    [136] = {
        {specs = {65, 66, 70}, definitionID = 107628, reason = "You can use this to control Incorporeal."}, -- Turn Evil
        {specs = {65, 66, 70}, definitionID = 107590, reason = "You can also use this for Incorporeal but giving up Blinding Light might be too steep a cost."}, -- Repentance
    },
    -- Volcanic
    [3] = {},
    -- Entangling
    [134] = {
        {specs = {65, 66, 70}, definitionID = 107592, reason = "You can use this for every single one."}, -- Blessing of Freedom
        {specs = {66}, definitionID = 120491, reason = "You can free yourself and a party member with this."}, -- Unbound Freedom
        {specs = {70}, definitionID = 120466, reason = "You can free yourself and a party member with this."}, -- Unbound Freedom
    },
    -- Storming
    [124] = {},

    -- Level 10 Affixes:
    -- Spiteful
    [123] = {
        {specs = {65}, definitionID = 107609, reason = "This lets you ignore Spiteful adds for a while."}, -- Blessing of Protection
        {specs = {66}, definitionID = 107464, reason = "Get this to help slow them and keep them under control."}, -- Consecrated Ground
    },
    -- Raging
    [6] = {
        {specs = {65}, definitionID = 107607, reason = "You can use it on the tank if they need it during Raging."}, -- Blessing of Sacrifice
    },
    -- Bolstering
    [7] = {},
    -- Bursting
    [11] = {
        {specs = {66}, definitionID = 116891, reason = "You can cast this on the healer to lower incoming damage drastically"}, -- Blessing of Spellwarding
        {specs = {65}, definitionID = 107537, reason = "This helps a lot! Using it as late as possible as stacks ramp is imperative in dealing with large packs dying."}, -- Beacon of Virtue
        {specs = {65}, definitionID = 107470, reason = "This is also incredibly good at healing through Bursting."}, -- Divine Toll
        {specs = {65}, definitionID = 107568, reason = "This is also incredibly good at healing through Bursting."}, -- Daybreak
        {specs = {65}, definitionID = 107607, reason = "Use this liberally on classes that cannot not remove stacks on their own."}, -- Blessing of Sacrifice
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
    [136] = {},
    -- Volcanic
    [3] = {},
    -- Entangling
    [134] = {},
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
    [11] = {},
    -- Sanguine
    [8] = {},
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
    [136] = {},
    -- Volcanic
    [3] = {},
    -- Entangling
    [134] = {},
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
    [11] = {},
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
    [135] = {},
    -- Incorporeal
    [136] = {},
    -- Volcanic
    [3] = {},
    -- Entangling
    [134] = {},
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
    [11] = {},
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
    [136] = {},
    -- Volcanic
    [3] = {},
    -- Entangling
    [134] = {},
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
    [11] = {},
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
    [135] = {},
    -- Incorporeal
    [136] = {},
    -- Volcanic
    [3] = {},
    -- Entangling
    [134] = {},
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
    [11] = {},
    -- Sanguine
    [8] = {},
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
    [135] = {},
    -- Incorporeal
    [136] = {},
    -- Volcanic
    [3] = {},
    -- Entangling
    [134] = {},
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
    [11] = {},
    -- Sanguine
    [8] = {},
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
    [136] = {},
    -- Volcanic
    [3] = {},
    -- Entangling
    [134] = {},
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
    [135] = {},
    -- Incorporeal
    [136] = {},
    -- Volcanic
    [3] = {},
    -- Entangling
    [134] = {},
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
    [11] = {},
    -- Sanguine
    [8] = {},
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
    [136] = {},
    -- Volcanic
    [3] = {},
    -- Entangling
    [134] = {},
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
    [11] = {},
    -- Sanguine
    [8] = {},
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
    [135] = {},
    -- Incorporeal
    [136] = {},
    -- Volcanic
    [3] = {},
    -- Entangling
    [134] = {},
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
    [11] = {},
    -- Sanguine
    [8] = {},
}
