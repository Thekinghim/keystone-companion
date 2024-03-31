local UI = CreateFrame('Frame', 'KeystoneCompanion', UIParent);
KeystoneCompanion.UI = { Frame = UI }

UI:Hide();
UI:SetMovable(true);
UI:EnableMouse(true);
UI:SetSize(438, 566);
UI:RegisterForDrag('LeftButton');
UI:SetScript('OnDragStart', UI.StartMoving)
UI:SetScript('OnDragStop', function(self) 
  self:StopMovingOrSizing();
  local point, relativeTo, relativePoint, offsetX, offsetY = self:GetPoint();
  KeystoneCompanionDB.UI = KeystoneCompanionDB.UI or {};
  KeystoneCompanionDB.UI = {point = point, relativeTo = relativeTo, relativePoint = relativePoint, offsetX = offsetX, offsetY = offsetY}
end)

UI.Bg = UI:CreateTexture('Background', 'BACKGROUND');
UI.Bg:SetAllPoints(UI);
UI.Bg:SetTexture('Interface/AddOns/Keystone-Companion/assets/textures/ui-backdrop')
UI.Bg.Mask = UI:CreateMaskTexture()
UI.Bg.Mask:SetAllPoints(UI.Bg)
UI.Bg.Mask:SetTexture('Interface/AddOns/Keystone-Companion/assets/textures/ui-backdrop', 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE');
UI.Bg:AddMaskTexture(UI.Bg.Mask)

UI.Top = CreateFrame('Frame', 'KeystoneCompanionTop', UI);
UI.Top:SetSize(384, 56)
UI.Top:SetPoint('TOPRIGHT', UI, 'TOPRIGHT', -20, -13)

UI.Title = CreateFrame('Frame', 'KeystoneCompanionTitle', UI);
UI.Title:SetSize(345, 56);
UI.Title:SetPoint('LEFT', UI.Top, 'LEFT');
UI.Title.Mask = UI.Title:CreateMaskTexture();
UI.Title.Mask:SetAllPoints(UI.Title);
UI.Title.Mask:SetTexture('Interface/AddOns/Keystone-Companion/assets/textures/ui-title-mask', 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE');
UI.Title.Texture = UI.Title:CreateTexture('KeystoneCompanionTitleBg', 'ARTWORK');
UI.Title.Texture:SetAllPoints(UI.Title);
UI.Title.Texture:SetColorTexture(28 / 255, 29 / 255, 32 / 255, 1);
UI.Title.Texture:AddMaskTexture(UI.Title.Mask);

UI.CloseButton = CreateFrame('Frame', 'KeystoneCompanionCloseButton', UI);
UI.CloseButton:SetSize(25, 25);
UI.CloseButton:SetPoint('TOPRIGHT', UI.Top, 'TOPRIGHT');
UI.CloseButton.Mask = UI.CloseButton:CreateMaskTexture();
UI.CloseButton.Mask:SetAllPoints(UI.CloseButton);
UI.CloseButton.Mask:SetTexture('Interface/AddOns/Keystone-Companion/assets/textures/ui-close-button', 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE');
UI.CloseButton.Texture = UI.CloseButton:CreateTexture('KeystoneCompanionCloseButtonTexture', 'ARTWORK');
UI.CloseButton.Texture:SetAllPoints(UI.CloseButton);
UI.CloseButton.Texture:SetTexture('Interface/AddOns/Keystone-Companion/assets/textures/ui-close-button');
UI.CloseButton.Texture:AddMaskTexture(UI.CloseButton.Mask);
UI.CloseButton:SetScript('OnEnter', function()
  UI.CloseButton.Texture:SetTexture('Interface/AddOns/Keystone-Companion/assets/textures/ui-close-button-highlight');
end)
UI.CloseButton:SetScript('OnLeave', function()
  UI.CloseButton.Texture:SetTexture('Interface/AddOns/Keystone-Companion/assets/textures/ui-close-button');
end)
UI.CloseButton:SetScript('OnMouseDown', function()
  UI:Hide();
end)

UI.Icon = CreateFrame('Frame', 'KeystoneCompanionIcon', UI);
UI.Icon:SetSize(36, 36);
UI.Icon:SetPoint('TOPLEFT', UI.Title, 'TOPLEFT', 8, -10);
UI.Icon.Mask = UI.Icon:CreateMaskTexture();
UI.Icon.Mask:SetAllPoints(UI.Icon);
UI.Icon.Mask:SetTexture('Interface/AddOns/Keystone-Companion/assets/textures/icon-mask', 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE');
UI.Icon.Texture = UI.Icon:CreateTexture('KeystoneCompanionIconTexture', 'OVERLAY');
UI.Icon.Texture:SetAllPoints(UI.Icon);
UI.Icon.Texture:SetTexture('Interface/AddOns/Keystone-Companion/assets/textures/addon-icon');
UI.Icon.Texture:AddMaskTexture(UI.Icon.Mask);

UI.Title.AddonName = UI.Title:CreateFontString('AddonName', 'OVERLAY')
UI.Title.AddonName:SetSize(220, 24);
UI.Title.AddonName:SetFontObject('GameFontHighlightCenter')
UI.Title.AddonName:SetFont('Interface/AddOns/Keystone-Companion/assets/fonts/RobotoSlab-Bold.ttf', 18, '');
UI.Title.AddonName:SetTextColor(255 / 255, 124 / 255, 10 / 255, 1);
UI.Title.AddonName:SetPoint('TOPLEFT', UI.Title, 'TOPLEFT', 50, -16);
UI.Title.AddonName:SetText('Keystone Companion')

UI.Party = CreateFrame('Frame', 'KeystoneCompanionParty', UI);
UI.Party:SetSize(411, 461);
UI.Party:SetPoint('TOPLEFT', UI, 'TOPLEFT', 13, -93);

UI.Party.Header = CreateFrame('Frame', 'KeystoneCompanionPartyHeader', UI.Party);
UI.Party.Header:SetSize(411, 17);
UI.Party.Header:SetPoint('TOPLEFT', UI.Party, 'TOPLEFT')

UI.Party.HeaderBar = CreateFrame('Frame', 'KeystoneCompanionHeaderBar', UI.Header);
UI.Party.HeaderBar:SetSize(411, 1);
UI.Party.HeaderBar:SetPoint('BOTTOMLEFT', UI.Party.Header, 'BOTTOMLEFT');
UI.Party.HeaderBar:SetPoint('BOTTOMRIGHT', UI.Party.Header, 'BOTTOMRIGHT');
UI.Party.HeaderBar.Texture = UI.Party.Header:CreateTexture('KeystoneCompanionHeaderBarTexture', 'OVERLAY')
UI.Party.HeaderBar.Texture:SetAllPoints(UI.Party.HeaderBar)
UI.Party.HeaderBar.Texture:SetColorTexture(89 / 255, 89 / 255, 91 / 255, 1);

UI.Party.Header.PlayerName = UI.Party.Header:CreateFontString('KeystoneCompanionHeaderPlayername', 'OVERLAY')
UI.Party.Header.PlayerName:SetSize(80, 12);
UI.Party.Header.PlayerName:SetJustifyH('LEFT');
UI.Party.Header.PlayerName:SetPoint('TOPLEFT', UI.Party.Header, 'TOPLEFT', 10, 0);
UI.Party.Header.PlayerName:SetFont('Interface/AddOns/Keystone-Companion/assets/fonts/SF-Pro.ttf', 12, '');
UI.Party.Header.PlayerName:SetText('Player Name')

UI.Party.Header.Food = UI.Party.Header:CreateFontString('KeystoneCompanionHeaderFood', 'OVERLAY')
UI.Party.Header.Food:SetSize(50, 12)
UI.Party.Header.Food:SetPoint('TOPLEFT', UI.Party.Header, 'TOPLEFT', 172 , 0);
UI.Party.Header.Food:SetFont('Interface/AddOns/Keystone-Companion/assets/fonts/SF-Pro.ttf', 12, '');
UI.Party.Header.Food:SetText('Food')

UI.Party.Header.Invis = UI.Party.Header:CreateFontString('KeystoneCompanionHeaderInvis', 'OVERLAY')
UI.Party.Header.Invis:SetSize(50, 12)
UI.Party.Header.Invis:SetPoint('TOPLEFT', UI.Party.Header, 'TOPLEFT', 232 , 0);
UI.Party.Header.Invis:SetFont('Interface/AddOns/Keystone-Companion/assets/fonts/SF-Pro.ttf', 12, '');
UI.Party.Header.Invis:SetText('Invis')

UI.Party.Header.Potions = UI.Party.Header:CreateFontString('KeystoneCompanionHeaderPotions', 'OVERLAY')
UI.Party.Header.Potions:SetSize(50, 12)
UI.Party.Header.Potions:SetPoint('TOPLEFT', UI.Party.Header, 'TOPLEFT', 292 , 0);
UI.Party.Header.Potions:SetFont('Interface/AddOns/Keystone-Companion/assets/fonts/SF-Pro.ttf', 12, '');
UI.Party.Header.Potions:SetText('Potions')

UI.Party.Header.Flasks = UI.Party.Header:CreateFontString('KeystoneCompanionHeaderFlasks', 'OVERLAY')
UI.Party.Header.Flasks:SetSize(50, 12)
UI.Party.Header.Flasks:SetPoint('TOPLEFT', UI.Party.Header, 'TOPLEFT', 352 , 0);
UI.Party.Header.Flasks:SetFont('Interface/AddOns/Keystone-Companion/assets/fonts/SF-Pro.ttf', 12, '');
UI.Party.Header.Flasks:SetText('Flasks')

UI.Footer = CreateFrame('Frame', 'KeystoneCompanionFooter', UI.Party);
UI.Footer:SetSize(411, 15);
UI.Footer:SetPoint('BOTTOMLEFT', UI.Party, 'BOTTOMLEFT');
UI.Footer:SetPoint('BOTTOMRIGHT', UI.Party, 'BOTTOMRIGHT');

UI.AddonVersion = UI.Footer:CreateFontString('KeystoneCompanionAddonVersion', 'OVERLAY');
UI.AddonVersion:SetSize(80, 10);
UI.AddonVersion:SetPoint('LEFT', UI.Footer, 'LEFT', 8, 0)
UI.AddonVersion:SetFont('Interface/AddOns/Keystone-Companion/assets/fonts/SF-Pro.ttf', 10, '');
UI.AddonVersion:SetTextColor(89 / 255, 89 / 255, 91 / 255, 1);
UI.AddonVersion:SetText('V' .. KeystoneCompanion.version)

UI.GitHub = CreateFrame('Frame', 'KeystoneCompanionFooterGitHub', UI.Footer);
UI.GitHub:SetSize(58, 15);
UI.GitHub:SetPoint('RIGHT', UI.Footer, 'RIGHT', -8, 0);
UI.GitHub.Label = UI.GitHub:CreateFontString('KeystoneCompanionFooterGitHubLabel', 'OVERLAY')
UI.GitHub.Label:SetSize(48, 13)
UI.GitHub.Label:SetPoint('LEFT', UI.GitHub, 'LEFT');
UI.GitHub.Label:SetFont('Interface/AddOns/Keystone-Companion/assets/fonts/SF-Pro.ttf', 10, '')
UI.GitHub.Label:SetTextColor(161 / 255, 161 / 255, 161 / 255, 1)
UI.GitHub.Label:SetText('GitHub');
UI.GitHub.Icon = CreateFrame('Frame', "KeystoneCompanionGitHubIcon", UI.GitHub);
UI.GitHub.Icon:SetSize(13, 13);
UI.GitHub.Icon:SetPoint("RIGHT", UI.GitHub, "RIGHT");
UI.GitHub.Icon.Mask = UI.GitHub.Icon:CreateMaskTexture();
UI.GitHub.Icon.Mask:SetAllPoints(UI.GitHub.Icon);
UI.GitHub.Icon.Mask:SetTexture('Interface/AddOns/Keystone-Companion/assets/textures/github-icon', 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE');
UI.GitHub.Icon.Texture = UI.GitHub.Icon:CreateTexture("KeystoneCompanionGitHubIconTexture", "OVERLAY");
UI.GitHub.Icon.Texture:SetAllPoints(UI.GitHub.Icon);
UI.GitHub.Icon.Texture:SetColorTexture(1, 1, 1, 1);
UI.GitHub.Icon.Texture:AddMaskTexture(UI.GitHub.Icon.Mask);
UI.GitHub:SetScript("OnEnter", function()
  UI.GitHub.Label:SetTextColor(204 / 255, 204 / 255, 204 / 255, 1);
  UI.GitHub.Icon.Texture:SetColorTexture(204 / 255, 204 / 255, 204 / 255, 1)
end)
UI.GitHub:SetScript("OnLeave", function()
  UI.GitHub.Label:SetTextColor(161 / 255, 161 / 255, 161 / 255, 1);
  UI.GitHub.Icon.Texture:SetColorTexture(1, 1, 1, 1);
end)

UI.Discord = CreateFrame('Frame', 'KeystoneCompanionFooterDiscord', UI.Footer);
UI.Discord:SetSize(112, 15);
UI.Discord:SetPoint('RIGHT', UI.Footer, 'RIGHT', -70, 0);
UI.Discord.Label = UI.Discord:CreateFontString('KeystoneCompanionFooterDiscordLabel', 'OVERLAY')
UI.Discord.Label:SetSize(100, 13)
UI.Discord.Label:SetPoint('LEFT', UI.Discord, 'LEFT');
UI.Discord.Label:SetFont('Interface/AddOns/Keystone-Companion/assets/fonts/SF-Pro.ttf', 10, '')
UI.Discord.Label:SetTextColor(161 / 255, 161 / 255, 161 / 255, 1)
UI.Discord.Label:SetText('Join us on Discord');
UI.Discord.Icon = CreateFrame('Frame', "KeystoneCompanionDiscordIcon", UI.Discord);
UI.Discord.Icon:SetSize(13, 13);
UI.Discord.Icon:SetPoint("RIGHT", UI.Discord, "RIGHT");
UI.Discord.Icon.Mask = UI.Discord.Icon:CreateMaskTexture();
UI.Discord.Icon.Mask:SetAllPoints(UI.Discord.Icon);
UI.Discord.Icon.Mask:SetTexture('Interface/AddOns/Keystone-Companion/assets/textures/discord-icon', 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE');
UI.Discord.Icon.Texture = UI.Discord.Icon:CreateTexture("KeystoneCompanionDiscordIconTexture", "OVERLAY");
UI.Discord.Icon.Texture:SetAllPoints(UI.Discord.Icon);
UI.Discord.Icon.Texture:SetTexture('Interface/AddOns/Keystone-Companion/assets/textures/discord-icon');
UI.Discord.Icon.Texture:AddMaskTexture(UI.Discord.Icon.Mask);
UI.Discord:SetScript("OnEnter", function()
  UI.Discord.Label:SetTextColor(204 / 255, 204 / 255, 204 / 255, 1);
  UI.Discord.Icon.Texture:SetTexture('Interface/AddOns/Keystone-Companion/assets/textures/discord-icon-highlight')
end)
UI.Discord:SetScript("OnLeave", function()
  UI.Discord.Label:SetTextColor(161 / 255, 161 / 255, 161 / 255, 1);
  UI.Discord.Icon.Texture:SetTexture('Interface/AddOns/Keystone-Companion/assets/textures/discord-icon')
end)

UI.Tooltip = CreateFrame('GameTooltip', 'KeystoneCompanionTooltip', UIParent, 'GameTooltipTemplate');
UI.CopyFrame = CreateFrame('Frame', 'KeystoneCompanionCopyFrame', UI);
UI.CopyFrame:SetHeight(64);
UI.CopyFrame:SetPoint("LEFT", UI, "LEFT", 20, 0)
UI.CopyFrame:SetPoint("RIGHT", UI, "RIGHT", -20, 0)
UI.CopyFrame:SetPoint("CENTER", 0, 10);
UI.CopyFrame:SetFrameStrata("DIALOG");
UI.CopyFrame.Bg = UI.CopyFrame:CreateTexture("KeystoneCompanionCopyFrameBg", "OVERLAY");
UI.CopyFrame.Bg:SetAllPoints(UI.CopyFrame);
UI.CopyFrame.Bg:SetTexture('Interface/AddOns/Keystone-Companion/assets/textures/copy-frame');
UI.CopyFrame.Mask = UI.CopyFrame:CreateMaskTexture();
UI.CopyFrame.Mask:SetAllPoints(UI.CopyFrame)
UI.CopyFrame.Mask:SetTexture('Interface/AddOns/Keystone-Companion/assets/textures/copy-frame')
UI.CopyFrame.Bg:AddMaskTexture(UI.CopyFrame.Mask)
UI.CopyFrame.Label = UI.CopyFrame:CreateFontString("KeystoneCompanionCopyFrameLabel", "OVERLAY");
UI.CopyFrame.Label:SetPoint("TOPLEFT", UI.CopyFrame, "TOPLEFT", 5, -5);
UI.CopyFrame.Label:SetPoint("BOTTOMRIGHT", UI.CopyFrame, "BOTTOMRIGHT", -5, 35);
UI.CopyFrame.Label:SetFont('Interface/AddOns/Keystone-Companion/assets/fonts/SF-Pro.ttf', 12);
UI.CopyFrame.Label:SetText('Copy below URL into your browser.')
UI.CopyFrame:Hide();

UI.EditBox = CreateFrame("EditBox", 'KeystoneCompanionCopyFrameEditBox', UI.CopyFrame, 'InputBoxTemplate');
UI.EditBox:SetFontObject("GameFontNormal")
UI.EditBox:SetFrameStrata("DIALOG")
UI.EditBox:SetHeight(24);
UI.EditBox:SetJustifyH("CENTER");
UI.EditBox:SetPoint("LEFT", UI.CopyFrame, "LEFT", 25, 0)
UI.EditBox:SetPoint("RIGHT", UI.CopyFrame, "RIGHT", -20, 0)
UI.EditBox:SetPoint("BOTTOM", UI.CopyFrame, "BOTTOM", 0, 10)
UI.EditBox:SetMultiLine(false);
UI.EditBox:SetScript("OnEscapePressed", function(self)
  self:ClearFocus()
  self:GetParent():Hide();
end)

UI.GitHub:SetScript("OnMouseDown", function()
  if(UI.CopyFrame:IsShown() and UI.EditBox:GetText() == 'https://github.com/kaelonR/keystone-companion') then
    UI.CopyFrame:Hide();
    return;
  end

  UI.EditBox:SetText('https://github.com/kaelonR/keystone-companion');
  UI.CopyFrame:Show();
end)

UI.Discord:SetScript("OnMouseDown", function()
  if(UI.CopyFrame:IsShown() and UI.EditBox:GetText() == 'https://discord.gg/KhFhC6kZ78') then
    UI.CopyFrame:Hide();
    return;
  end

  UI.EditBox:SetText('https://discord.gg/KhFhC6kZ78');
  UI.CopyFrame:Show();
end)


local createDungeonTooltip = function(self)
  local playerName = self:GetAttribute('player');
  if(playerName == nil) then return end
  
  local playerData = KeystoneCompanion.inventory[playerName];
  if(playerData.keystone.mapID == nil) then return end;

  local dungeonInfo = KeystoneCompanion.constants.dungeonTeleports[playerData.keystone.mapID];
  local spellId = dungeonInfo.spell.id;

  local spellKnown = IsSpellKnown(spellId, false);
  local spellUsable = IsUsableSpell(spellId);

  UI.Tooltip:ClearLines();

  UI.Tooltip:SetOwner(self, 'ANCHOR_NONE');
  UI.Tooltip:SetPoint('BOTTOMRIGHT', self, 'TOPLEFT');
  UI.Tooltip:SetText(dungeonInfo.name, 0.64, 0.21, 0.93, 1, true);
  UI.Tooltip:AddLine('Keystone level ' .. (playerData.keystone.level or 12))
  UI.Tooltip:AddLine(' ')
  if(not spellKnown) then
    UI.Tooltip:AddLine('You do not have this teleport', 1, 0, 0, true);
  elseif(not spellUsable) then
    UI.Tooltip:AddLine('Teleport not usable', 0.62, 0.62, 0.62, true);
  else
    UI.Tooltip:AddLine('Click to teleport');
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
    column.button:RegisterForClicks('AnyDown', 'AnyUp')
    column.button:SetAttribute('type', 'spell')
    column.button:SetScript('OnEnter', createDungeonTooltip)
    column.button:SetScript('OnLeave', function()
      if(UI.Tooltip:IsShown()) then UI.Tooltip:Hide() end
    end)
  end

  return column;
end

for i = 1, 5 do
  UI['player' .. i] = CreateFrame('Frame', 'Player' .. i .. 'Row', UI);
  local playerRow = UI['player' .. i];

  playerRow:SetSize(411, 83);
  playerRow:SetPoint('TOPLEFT', UI.Party.HeaderBar, 'TOPLEFT', 0, -1 - (83 * (i-1)))
  playerRow:SetPoint('TOPRIGHT', UI.Party.HeaderBar, 'TOPRIGHT', 0, -1 - (83 * (i-1)))
  playerRow.Content = CreateFrame('Frame', 'KeystoneCompanionPlayerRow' .. i .. 'Content', playerRow);
  playerRow.Content:SetSize(391, 63);
  playerRow.Content:SetPoint("TOPLEFT", playerRow, "TOPLEFT", 10, -10);
  playerRow.Content:SetPoint("BOTTOMRIGHT", playerRow, "BOTTOMRIGHT", -10, 10);

  playerRow.PlayerName = playerRow.Content:CreateFontString();
  playerRow.PlayerName:SetHeight(14)
  playerRow.PlayerName:SetPoint("TOPLEFT", playerRow.Content, "TOPLEFT", 0, 0);
  playerRow.PlayerName:SetPoint("TOPRIGHT", playerRow.Content, "TOPRIGHT");
  playerRow.PlayerName:SetFont('Interface/Addons/Keystone-Companion/assets/fonts/SF-Pro.ttf', 12)
  playerRow.PlayerName:SetTextColor(161 / 255, 161 / 255, 161 / 255, 1);
  playerRow.PlayerName:SetText("Player " .. i);
  playerRow.PlayerName:SetJustifyH('LEFT');

  playerRow.ClassIcon = CreateFrame('Frame', 'KeystoneCompanionPlayerRow' .. i .. 'ClassIcon', playerRow.Content);
  playerRow.ClassIcon:SetSize(35, 35);
  playerRow.ClassIcon:SetPoint("TOPLEFT", playerRow.Content, "TOPLEFT", 0, -25);
  playerRow.ClassIcon.Mask = playerRow.ClassIcon:CreateMaskTexture();
  playerRow.ClassIcon.Mask:SetAllPoints(playerRow.ClassIcon);
  playerRow.ClassIcon.Mask:SetTexture('Interface/Addons/Keystone-Companion/assets/textures/rounded-button');
  playerRow.ClassIcon.Texture = playerRow.ClassIcon:CreateTexture("KeystoneCompanionPlayerRow" .. i .. 'ClassIconTexture', 'ARTWORK');
  playerRow.ClassIcon.Texture:SetAllPoints(playerRow.ClassIcon);
  playerRow.ClassIcon.Texture:AddMaskTexture(playerRow.ClassIcon.Mask);
  playerRow.ClassIcon.Texture:SetTexture('Interface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES')
  playerRow.ClassIcon.Texture:SetTexCoord(unpack(CLASS_ICON_TCOORDS['MAGE']));

  playerRow.RoleIcon = CreateFrame('Frame', 'KeystoneCompanionPlayerRow' .. i .. 'RoleIcon', playerRow.Content);
  playerRow.RoleIcon:SetFrameStrata("HIGH");
  playerRow.RoleIcon:SetSize(20, 20);
  playerRow.RoleIcon:SetPoint('CENTER', playerRow.ClassIcon, 'BOTTOMRIGHT', 0, 0);
  playerRow.RoleIcon.Texture = playerRow.RoleIcon:CreateTexture('KeystoneCompanionPlayerRow' .. i .. 'RoleIconTexture', 'ARTWORK');
  playerRow.RoleIcon.Texture:SetAllPoints(playerRow.RoleIcon);
  playerRow.RoleIcon.Texture:SetTexture('Interface/LFGFRAME/UI-LFG-ICON-PORTRAITROLES');
  playerRow.RoleIcon.Texture:SetTexCoord(unpack(KeystoneCompanion.constants.roleIconCoords['DAMAGER']));

  playerRow.LeaderIcon = CreateFrame('Frame', 'KeystoneCompanionPlayerRow' .. i .. 'LeaderIcon', playerRow.Content);
  playerRow.LeaderIcon:SetFrameStrata("HIGH");
  playerRow.LeaderIcon:SetSize(20, 20);
  playerRow.LeaderIcon:SetPoint('CENTER', playerRow.ClassIcon, 'TOPRIGHT');
  playerRow.LeaderIcon.Texture = playerRow.LeaderIcon:CreateTexture('KeystoneCompanionPlayerRow' .. i .. 'LeaderIconTexture', 'ARTWORK');
  playerRow.LeaderIcon.Texture:SetAllPoints(playerRow.LeaderIcon);
  playerRow.LeaderIcon.Texture:SetTexture('Interface/GROUPFRAME/UI-Group-LeaderIcon');
  if( i ~= 3) then playerRow.LeaderIcon:Hide() end

  --playerRow.food = createColumn(playerRow, i, 'food', 'Food', 80, 100, 'itemButton')
  --playerRow.flask = createColumn(playerRow, i, 'flask', 'Flask', 80, 180, 'itemButton')
  --playerRow.potion = createColumn(playerRow, i, 'potion', 'Potion', 80, 260, 'itemButton')
  --playerRow.consumable = createColumn(playerRow, i, 'consumable', 'Consumable', 80, 340, 'itemButton')
  --playerRow.weaponEnchant = createColumn(playerRow, i, 'weaponEnchant', 'Enchant', 80, 420, 'itemButton')

end

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

  teleportButton:SetAttribute('spell', spellID)
  teleportButton:SetAttribute('player', playerName)
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