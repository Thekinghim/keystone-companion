---@class KeystoneCompanionPrivate
local Private = select(2, ...)

---@class KCConstants
---@field dungeonTeleports KCDungeonPorts
Private.constants = Private.constants or {}

---@class KCDungeonPorts
Private.constants.dungeonTeleports = {
  [1754] = 410071, -- Freehold : Path of the Freebooter (Battle for Azeroth)
  [1841] = 410074, -- The Underrot : Path of Festering Rot (Battle for Azeroth)
  [2097] = 373274, -- Operation: Mechagon : Path of the Scrappy Prince (Battle for Azeroth)
  [1862] = 424167, -- Waycrest Manor : Path of Heart's Bane (Battle for Azeroth)
  [1763] = 424187, -- Atal'Dazar : Path of the Golden Tomb (Battle for Azeroth)
  [657] = 410080,  -- The Vortex Pinnacle : Path of Wind's Domain (Cataclysm)
  [643] = 424142,  -- Throne of the Tides : Path of the Tidehunter (Cataclysm)
  [2521] = 393256, -- Ruby Life Pools : Path of the Clutch Defender (Dragonflight)
  [2516] = 393262, -- The Nokhud Offensive : Path of the Windswept Plains (Dragonflight)
  [2520] = 393267, -- Brackenhide Hollow : Path of the Rotting Woods (Dragonflight)
  [2526] = 393273, -- Algeth'ar Academy : Path of the Draconic Diploma (Dragonflight)
  [2519] = 393276, -- Neltharus : Path of the Obsidian Hoard (Dragonflight)
  [2515] = 393279, -- The Azure Vault : Path of Arcane Secrets (Dragonflight)
  [2527] = 393283, -- Halls of Infusion : Path of the Titanic Reservoir (Dragonflight)
  [2451] = 393222, -- Uldaman : Path of the Watcher's Legacy (Dragonflight)
  [2579] = 424197, -- Dawn of the Infinite : Path of Twisted Time (Dragonflight)
  [1477] = 393764, -- Halls of Valor : Path of Proven Worth (Legion)
  [1458] = 410078, -- Neltharion's Lair : Path of the Earth-Warder (Legion)
  [1571] = 393766, -- Court of Stars : Path of the Grand Magistrix (Legion)
  [1651] = 373262, -- Karazhan : Path of the Fallen Guardian (Legion)
  [1501] = 424153, -- Black Rook Hold : Path of Ancient Horrors (Legion)
  [1466] = 424163, -- Darkheart Thicket : Path of the Nightmare Lord (Legion)
  [960] = 131204,  -- Temple of the Jade Serpent : Path of the Jade Serpent (Mists of Pandaria)
  [961] = 131205,  -- Stormstout Brewery : Path of the Stout Brew (Mists of Pandaria)
  [959] = 131206,  -- Shado-Pan Monastery : Path of the Shado-Pan (Mists of Pandaria)
  [994] = 131222,  -- Mogu'shan Palace : Path of the Mogu King (Mists of Pandaria)
  [962] = 131225,  -- Gate of the Setting Sun : Path of the Setting Sun (Mists of Pandaria)
  [1001] = 131231, -- Scarlet Halls : Path of the Scarlet Blade (Mists of Pandaria)
  [1004] = 131229, -- Scarlet Monastery : Path of the Scarlet Mitre (Mists of Pandaria)
  [1007] = 131232, -- Scholomance : Path of the Necromancer (Mists of Pandaria)
  [1011] = 131228, -- Siege of Niuzao Temple : Path of the Black Ox (Mists of Pandaria)
  [2296] = 373190, -- Castle Nathria : Path of the Sire (Shadowlands Raids)
  [2450] = 373191, -- Sanctum of Domination : Path of the Tormented Soul (Shadowlands Raids)
  [2481] = 373192, -- Sepulcher of the First Ones : Path of the First Ones (Shadowlands Raids)
  [1175] = 159895, -- Bloodmaul Slag Mines : Path of the Bloodmaul (Warlords of Draenor)
  [1182] = 159897, -- Auchindoun : Path of the Vigilant (Warlords of Draenor)
  [1209] = 159898, -- Skyreach : Path of the Skies (Warlords of Draenor)
  [1279] = 159901, -- The Everbloom : Path of the Verdant (Warlords of Draenor)
  [1176] = 159899, -- Shadowmoon Burial Grounds : Path of the Crescent Moon (Warlords of Draenor)
  [1358] = 159902, -- Upper Blackrock Spire : Path of the Burning Mountain (Warlords of Draenor)
  [1208] = 159900, -- Grimrail Depot : Path of the Dark Rail (Warlords of Draenor)
  [1195] = 159896, -- Iron Docks : Path of the Iron Prow (Warlords of Draenor)
  [375] = 354464, -- Mists
  [376] = 354462, -- Necrotic Wake
  [399] = 393256, -- Ruby Life Pools
  [400] = 393262, -- Nokhud Offensive
  [401] = 393279, -- Azure Vault
  [402] = 393273, -- Algethar Academy
  [403] = 393222, -- Uldaman
  [404] = 393276, -- Neltharus
  [405] = 393267, -- Brackenhide Hollow
  [406] = 393283, -- Halls of Infusion
  [438] = 410080, -- Vortex Pinnacle
  [456] = 424142, -- THOT
  [463] = 424197, -- DOTI LOWER
  [464] = 424197, -- DOTI UPPER
  [499] = 445444, -- Priory
  [500] = 445443, -- The Rookery
  [501] = 445269, -- Stonevault
  [502] = 445416, -- City of Threads
  [503] = 445417, -- Ara Ara
  [504] = 445441, -- Darkflame Cleft
  [505] = 445414, -- The Dawnbreaker
  [506] = 445440, -- Cinderbrew Meadery
  [507] = 445424, -- Grim Batol
}
