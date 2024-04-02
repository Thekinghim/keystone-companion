local LibSerialize = LibStub:GetLibrary("LibSerialize");
local LibDeflate = LibStub:GetLibrary("LibDeflate");
local print, devPrint = KeystoneCompanion.print, KeystoneCompanion.dev.print

KeystoneCompanion.inventory = {
  self = { class = '', items = {}, keystone = { mapID = nil, level = nil }, knownTeleports = { } };
}

function KeystoneCompanion.inventory:GetInventoryString()
  if(#self.self.items == 0) then
    self:ScanInventory();
  end

  local serialisedInventory = LibSerialize:Serialize(self.self);
  local compressedInventory = LibDeflate:CompressDeflate(serialisedInventory);
  local inventoryString = LibDeflate:EncodeForWoWAddonChannel(compressedInventory);
  return inventoryString;
end

local ScanItem = function (itemCache, bagIndex, bagSlot)
  local itemInfo = C_Container.GetContainerItemInfo(bagIndex, bagSlot);
  if(itemInfo == nil) then return end

  local itemCategory = KeystoneCompanion.constants.itemLookup[itemInfo.itemID];
  if(itemCategory == nil) then return end

  if(itemCache[itemCategory][itemInfo.itemID] == nil) then 
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
  self.self.items = {
    Consumable = {},
    Flask = {},
    Food = {},
    Potion = {},
    WeaponEnchantment = {}
  }

  for bagIndex = 0, NUM_BAG_SLOTS do ScanBag(self.self.items, bagIndex) end

  local keystoneMapId = C_MythicPlus.GetOwnedKeystoneMapID();
  if(keystoneMapId == nil) then
    self.self.keystone = { mapId = nil, level = nil };
  else
    local keystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel();
    self.self.keystone = { mapID = keystoneMapId, level = keystoneLevel };
  end

  self.self.knownTeleports = {};
  for instanceId, dungeonTeleportInfo in pairs(KeystoneCompanion.constants.dungeonTeleports) do 
    if(IsSpellKnown(dungeonTeleportInfo.spell.id, false)) then
      table.insert(self.self.knownTeleports, instanceId)
    end
  end
end

function KeystoneCompanion.inventory:LoadString(sender, inventoryString)
  local decodedString = LibDeflate:DecodeForWoWAddonChannel(inventoryString);
  local uncompressedString = LibDeflate:DecompressDeflate(decodedString);
  local success, inventory = LibSerialize:Deserialize(uncompressedString);
  if (not success) then return end;

  self[sender] = inventory;
  if(#self[sender]['keystone'] == 0) then
    self[sender]['keystone'] = { mapID = nil, level = nil }
  end
end