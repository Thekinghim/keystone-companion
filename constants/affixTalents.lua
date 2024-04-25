local _, KeystoneCompanion = ...

local function copyTable(tbl)
    local newTbl = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            newTbl[k] = copyTable(v)
        else
            newTbl[k] = v
        end
    end
    return newTbl
end

local affixes = {
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
--

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
