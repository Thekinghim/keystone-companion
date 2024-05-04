local _, KeystoneCompanion = ...;

local LibSerialize = LibStub:GetLibrary("LibSerialize");
local LibDeflate = LibStub:GetLibrary("LibDeflate");
local print, devPrint = KeystoneCompanion.print, KeystoneCompanion.dev.print

KeystoneCompanion.inventory = {};

function KeystoneCompanion.inventory:NewEmptyInventory()
  return { items = {}, keystone = { mapID = nil, level = nil }, itemLevel = { overall = nil, equipped = nil }, mythicPlusScore = nil, knownTeleports = {} };
end

KeystoneCompanion.inventory.self = KeystoneCompanion.inventory:NewEmptyInventory();

function KeystoneCompanion.inventory:GetInventoryString()
  if (#self.self.items == 0) then
    self:ScanInventory();
  end

  local serialisedInventory = LibSerialize:Serialize(self.self);
  local compressedInventory = LibDeflate:CompressDeflate(serialisedInventory);
  local inventoryString = LibDeflate:EncodeForWoWAddonChannel(compressedInventory);
  return inventoryString;
end

local ToArray = function(itemData)
  local array = {};
  for k, v in pairs(itemData) do table.insert(array, { itemID = k, count = v }) end
  return array;
end

local ScanItem = function(itemCache, bagIndex, bagSlot)
  local itemInfo = C_Container.GetContainerItemInfo(bagIndex, bagSlot);
  if (itemInfo == nil) then return end

  local itemCategory = KeystoneCompanion.constants.itemLookup[itemInfo.itemID];
  if (itemCategory == nil) then return end

  if (itemCache[itemCategory][itemInfo.itemID] == nil) then
    itemCache[itemCategory][itemInfo.itemID] = itemInfo.stackCount;
  else
    itemCache[itemCategory][itemInfo.itemID] = itemCache[itemCategory][itemInfo.itemID] + itemInfo.stackCount
  end
end

local ScanBag = function(itemCache, bagIndex)
  local bagSize = C_Container.GetContainerNumSlots(bagIndex);
  for bagSlot = 1, bagSize do ScanItem(itemCache, bagIndex, bagSlot) end
end

function KeystoneCompanion.inventory:ScanInventory()
  local itemCache = {
    Food = {},
    Rune = {},
    Potion = {},
    Flask = {},
    WeaponEnchantment = {}
  }

  for bagIndex = 0, NUM_BAG_SLOTS do ScanBag(itemCache, bagIndex) end

  self.self.items = {
    Food = ToArray(itemCache.Food),
    Rune = ToArray(itemCache.Rune),
    Potion = ToArray(itemCache.Potion),
    Flask = ToArray(itemCache.Flask),
    WeaponEnchantment = ToArray(itemCache.WeaponEnchantment)
  }

  local keystoneMapId = C_MythicPlus.GetOwnedKeystoneMapID();
  if (keystoneMapId == nil) then
    self.self.keystone = { mapId = nil, level = nil };
  else
    local keystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel();
    self.self.keystone = { mapID = keystoneMapId, level = keystoneLevel };
  end

  self.self.knownTeleports = {};
  for instanceId, dungeonTeleportInfo in pairs(KeystoneCompanion.constants.dungeonTeleports) do
    if (IsSpellKnown(dungeonTeleportInfo.spell.id, false)) then
      table.insert(self.self.knownTeleports, instanceId)
    end
  end

  self.self.mythicPlusScore = C_ChallengeMode.GetOverallDungeonScore();
  local overall, equipped = GetAverageItemLevel();
  self.self.itemLevel = { overall = overall, equipped = equipped };
end

function KeystoneCompanion.inventory:LoadString(sender, inventoryString)
  local decodedString = LibDeflate:DecodeForWoWAddonChannel(inventoryString);
  local uncompressedString = LibDeflate:DecompressDeflate(decodedString);
  local success, inventory = LibSerialize:Deserialize(uncompressedString);
  if (not success) then return end;

  self[sender] = inventory;
  if (self[sender]['keystone'] == nil) then
    self[sender]['keystone'] = { mapID = nil, level = nil }
  end
  if (self[sender]['itemLevel'] == nil) then
    self[sender]['itemLevel'] = { overall = nil, equipped = nil }
  end
end

function KeystoneCompanion.inventory:LoadFromDetailsInfo(sender, level, mapID)
  if (self[sender] == nil) then self[sender] = self:NewEmptyInventory() end
  self[sender].keystone = { mapID = mapID > 0 and mapID or nil, level = level > 0 and level or nil };
  if (KeystoneCompanion.UI.Frame:IsShown()) then
    KeystoneCompanion.UI.Rerender();
  end
end
