local UI = CreateFrame('Frame', 'KeystoneCompanion', UIParent);
KeystoneCompanion.UI = { Frame = UI }

UI:Hide();
UI:SetMovable(true);
UI:EnableMouse(true);
UI:RegisterForDrag('LeftButton');
UI:SetScript('OnDragStart', UI.StartMoving)
UI:SetScript('OnDragStop', UI.StopMovingOrSizing)
UI:SetPoint('CENTER', UIParent, 'CENTER')
UI:SetSize(438, 485)

UI.Bg = UI:CreateTexture("Background", 'BACKGROUND');
UI.Bg:SetAllPoints(UI);
UI.Bg:SetTexture("Interface/AddOns/Keystone-Companion/textures/ui-backdrop")

UI.BgMask = UI:CreateMaskTexture()
UI.BgMask:SetAllPoints(UI.Bg)
UI.BgMask:SetTexture('Interface\\AddOns\\Keystone-Companion\\textures\\ui-backdrop', 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE');
UI.Bg:AddMaskTexture(UI.BgMask)

UI.Top = CreateFrame('Frame', 'KeystoneCompanionTop', UI);
UI.Top:SetSize(384, 56)

UI.Title = CreateFrame('Frame', 'KeystoneCompanionTitle', UI);
UI.Title:SetSize(345, 56)

--UI.TopBorder:SetHeight(28.5);
--UI.TitleBg = UI:CreateTexture('titleBg', 'BACKGROUND', '_UI-Frame-TitleTileBg', 1);
--UI.TitleBg:SetPoint('TOPLEFT', 2, -2);
--UI.TitleBg:SetPoint('TOPRIGHT', -25, -2);
--UI.TitleBg:Show();
--UI.TitleBg:SetPoint('BOTTOMLEFT', UI.TopBorder, 'BOTTOMLEFT', 0, 7)

--UI.TitleText:SetHeight(15);
--UI.TitleText:SetText('Keystone Companion');

--UI.Tooltip = CreateFrame('GameTooltip', 'KeystoneCompanionTooltip', UIParent, 'GameTooltipTemplate'); 

local createDungeonTooltip = function(self)
  local playerName = self:GetAttribute("player");
  if(playerName == nil) then return end
  
  local playerData = KeystoneCompanion.inventory[playerName];
  if(playerData.keystone.mapID == nil) then return end;

  local dungeonInfo = KeystoneCompanion.constants.dungeonTeleports[playerData.keystone.mapID];
  local spellId = dungeonInfo.spell.id;

  local spellKnown = IsSpellKnown(spellId, false);
  local spellUsable = IsUsableSpell(spellId);

  UI.Tooltip:ClearLines();

  UI.Tooltip:SetOwner(self, "ANCHOR_NONE");
  UI.Tooltip:SetPoint("BOTTOMRIGHT", self, "TOPLEFT");
  UI.Tooltip:SetText(dungeonInfo.name, 0.64, 0.21, 0.93, 1, true);
  UI.Tooltip:AddLine('Keystone level ' .. (playerData.keystone.level or 12))
  UI.Tooltip:AddLine(' ')
  if(not spellKnown) then
    UI.Tooltip:AddLine("You do not have this teleport", 1, 0, 0, true);
  elseif(not spellUsable) then
    UI.Tooltip:AddLine("Teleport not usable", 0.62, 0.62, 0.62, true);
  else
    UI.Tooltip:AddLine("Click to teleport");
  end
  UI.Tooltip:Show();
end

local createColumn = function(playerRow, playerIndex, columnName, label, width, leftX, type)
  local column = CreateFrame('Frame', columnName .. 'Column' .. playerIndex, playerRow);
  column:SetSize(width, 80);
  column:SetPoint('TOPLEFT', playerRow, 'TOPLEFT', leftX, 0)
  column:SetPoint('TOPRIGHT', playerRow, 'TOPLEFT', leftX + width, 0)

  column.label = column:CreateFontString(columnName .. 'ColumnLabel' .. playerIndex, 'OVERLAY');
  column.label:SetFontObject('GameFontHighlight')
  column.label:SetPoint('TOP', column, 'TOP', 0, -10);
  column.label:SetText(label)

  if(type == 'itemButton') then
    column.itemButton = CreateFrame('ItemButton', columnName .. 'ColumnItemButton' .. playerIndex, column);
    column.itemButton:SetSize(40, 40)
    column.itemButton.NormalTexture:SetSize(40, 40)
    column.itemButton.PushedTexture:SetSize(30, 30)
    column.itemButton:SetPoint('CENTER', column, 'CENTER', 0, -10);
    column.itemButton:SetNormalTexture('Interface/PaperDoll/UI-Backpack-EmptySlot')
    column.itemButton:SetButtonState('NORMAL', true);
    -- column.itemButton:SetScript('OnEnter', function(self)
    --   local itemId = self:GetItem();
    --   if(itemId ~= nil) then
    --     UI.Tooltip:SetOwner(self, 'ANCHOR_NONE');
    --     UI.Tooltip:SetPoint('BOTTOMRIGHT', self, 'TOPLEFT');
    --     UI.Tooltip:SetItemByID(itemId);
    --     UI.Tooltip:Show();
    --   end
    -- end)
    -- column.itemButton:SetScript('OnLeave', function()
    --   if(UI.Tooltip:IsShown()) then UI.Tooltip:Hide() end
    -- end)
  elseif(type == 'teleportButton') then
    column.button = CreateFrame('Button', 'TeleportButton' .. playerIndex, column, 'SecureActionButtonTemplate')
    column.button:SetSize(40, 40);
    column.button:SetPoint('CENTER', column, 'CENTER', 0, -10);
    column.button:RegisterForClicks("AnyDown", "AnyUp")
    column.button:SetAttribute("type", "spell")
    column.button:SetScript('OnEnter', createDungeonTooltip)
    column.button:SetScript('OnLeave', function()
      if(UI.Tooltip:IsShown()) then UI.Tooltip:Hide() end
    end)
  end

  return column;
end

-- for i = 1, 5 do
--   UI['player' .. i] = CreateFrame('Frame', 'Player' .. i .. 'Row', UI);
--   local playerRow = UI['player' .. i];

--   playerRow:SetHeight(80);
--   playerRow:SetPoint('TOPLEFT', UI, 'TOPLEFT', 0, -25 - (80 * (i-1)))
--   playerRow:SetPoint('TOPRIGHT', UI, 'TOPRIGHT', 0, -25 - (80 * (i-1)))

--   playerRow.character = createColumn(playerRow,  i, 'character', 'Player ' .. i, 100, 0)
--   playerRow.food = createColumn(playerRow, i, 'food', 'Food', 80, 100, 'itemButton')
--   playerRow.flask = createColumn(playerRow, i, 'flask', 'Flask', 80, 180, 'itemButton')
--   playerRow.potion = createColumn(playerRow, i, 'potion', 'Potion', 80, 260, 'itemButton')
--   playerRow.consumable = createColumn(playerRow, i, 'consumable', 'Consumable', 80, 340, 'itemButton')
--   playerRow.weaponEnchant = createColumn(playerRow, i, 'weaponEnchant', 'Enchant', 80, 420, 'itemButton')
--   playerRow.dungeon = createColumn(playerRow, i, 'dungeon', 'Dungeon', 100, 500, 'teleportButton')

-- end

local updateItemButton = function(itemButton, itemData)
  if(#itemData == 0) then
    itemButton:Reset();
    itemButton.NormalTexture:Show();
  end
  for itemId, count in pairs(itemData) do
    itemButton:Reset();
    itemButton:SetItem(itemId);
    itemButton:SetItemButtonCount(count)
    itemButton.NormalTexture:Hide();
  end
end

local updatePortalButton = function(teleportButton, playerName, mapID)
  if(mapID == nil) then
    teleportButton:SetNormalTexture('Interface/PaperDoll/UI-Backpack-EmptySlot');
    return;
  end

  local spellID = KeystoneCompanion.constants.dungeonTeleports[mapID].spell.id

  teleportButton:SetAttribute("spell", spellID)
  teleportButton:SetAttribute("player", playerName)
  teleportButton:SetNormalTexture(GetSpellTexture(spellID))

  local known = IsSpellKnown(spellID, false)
  local usable = IsUsableSpell(spellID)

  if(not known or not usable) then
    teleportButton:SetAlpha(0.4)
  else
    teleportButton:SetAlpha(1)
  end
end

function KeystoneCompanion.UI.Rerender()
  -- for i = 1, 5 do --reset player rows
  --   UI['player' .. i]:Hide()
  -- end

  -- local players = {}; --normalize player entries
  -- for k, v in pairs(KeystoneCompanion.inventory) do
  --   if(type(v) == 'table') then
  --     if(k == 'self') then
  --       table.insert(players, 1, {name = UnitName('player'), info = v})
  --     else
  --       if(k ~= UnitName('player')) then
  --         table.insert(players, {name = k, info = v})
  --       end
  --     end
  --   end
  -- end

  -- local rowIndex = 0;
  -- for _, v in pairs(players) do
  --   rowIndex = rowIndex + 1;
  --   local playerRow = UI['player' .. rowIndex];

  --   playerRow.character.label:SetText(v.name, 1, 1, 1, 1, true)

  --   updateItemButton(playerRow.food.itemButton, v.info.items.Food)
  --   updateItemButton(playerRow.flask.itemButton, v.info.items.Flask);
  --   updateItemButton(playerRow.potion.itemButton, v.info.items.Potion);
  --   updateItemButton(playerRow.consumable.itemButton, v.info.items.Consumable);
  --   updateItemButton(playerRow.weaponEnchant.itemButton, v.info.items.WeaponEnchantment);
  --   updatePortalButton(playerRow.dungeon.button, v.name, v.info.keystone.mapID)

  --   playerRow:Show();
  -- end
end