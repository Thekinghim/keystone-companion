local _, KeystoneCompanion = ...
local CreateRoundedFrame = KeystoneCompanion.widgets.RoundedFrame.CreateFrame;
local getTexturePath = KeystoneCompanion.utils.path.getTexturePath;
local styles = KeystoneCompanion.constants.styles;

local UI = CreateRoundedFrame(UIParent, {
  width = 438, height = 566, border_size = 1, frame_strata = "DIALOG"
});
KeystoneCompanion.UI = { Frame = UI };

UI:Hide();
UI:SetMovable(true);
UI:EnableMouse(true);
UI:SetSize(470, 566);
UI:RegisterForDrag('LeftButton');
UI:SetScript('OnDragStart', UI.StartMoving)
UI:SetScript('OnDragStop', function(self)
  self:StopMovingOrSizing();
  local point, relativeTo, relativePoint, offsetX, offsetY = self:GetPoint();
  KeystoneCompanionDB.UI = KeystoneCompanionDB.UI or {};
  KeystoneCompanionDB.UI = { point = point, relativeTo = relativeTo, relativePoint = relativePoint, offsetX = offsetX, offsetY =
  offsetY }
end)

UI.Top = CreateFrame('Frame', 'KeystoneCompanionTop', UI);
UI.Top:SetSize(431, 56)
UI.Top:SetPoint('TOPRIGHT', UI, 'TOPRIGHT', -20, -13)

UI.Title = CreateFrame('Frame', 'KeystoneCompanionTitle', UI);
UI.Title:SetSize(325, 56);
UI.Title:SetPoint('LEFT', UI.Top, 'LEFT');
UI.Title.Mask = UI.Title:CreateMaskTexture();
UI.Title.Mask:SetAllPoints(UI.Title);
UI.Title.Mask:SetTexture(getTexturePath('masks/ui-title-frame'), 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE');
UI.Title.Texture = UI.Title:CreateTexture('KeystoneCompanionTitleBg', 'ARTWORK');
UI.Title.Texture:SetAllPoints(UI.Title);
UI.Title.Texture:SetColorTexture(28 / 255, 29 / 255, 32 / 255, 1);
UI.Title.Texture:AddMaskTexture(UI.Title.Mask);

UI.CloseButton = CreateFrame('Frame', 'KeystoneCompanionCloseButton', UI);
UI.CloseButton:SetSize(25, 25);
UI.CloseButton:SetPoint('TOPRIGHT', UI.Top, 'TOPRIGHT');
UI.CloseButton.Mask = UI.CloseButton:CreateMaskTexture();
UI.CloseButton.Mask:SetAllPoints(UI.CloseButton);
UI.CloseButton.Mask:SetTexture(getTexturePath('widgets/ui-close-button'), 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE');
UI.CloseButton.Texture = UI.CloseButton:CreateTexture('KeystoneCompanionCloseButtonTexture', 'ARTWORK');
UI.CloseButton.Texture:SetAllPoints(UI.CloseButton);
UI.CloseButton.Texture:SetTexture(getTexturePath('widgets/ui-close-button'));
UI.CloseButton.Texture:AddMaskTexture(UI.CloseButton.Mask);
UI.CloseButton:SetScript('OnEnter', function()
  UI.CloseButton.Texture:SetTexture(getTexturePath('widgets/ui-close-button-highlight'));
end)
UI.CloseButton:SetScript('OnLeave', function()
  UI.CloseButton.Texture:SetTexture(getTexturePath('widgets/ui-close-button'));
end)
UI.CloseButton:SetScript('OnMouseDown', function()
  UI:Hide();
end)

UI.Icon = CreateFrame('Frame', 'KeystoneCompanionIcon', UI);
UI.Icon:SetSize(36, 36);
UI.Icon:SetPoint('TOPLEFT', UI.Title, 'TOPLEFT', 8, -10);
UI.Icon.Mask = UI.Icon:CreateMaskTexture();
UI.Icon.Mask:SetAllPoints(UI.Icon);
UI.Icon.Mask:SetTexture(getTexturePath('masks/addon-icon'), 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE');
UI.Icon.Texture = UI.Icon:CreateTexture('KeystoneCompanionIconTexture', 'OVERLAY');
UI.Icon.Texture:SetAllPoints(UI.Icon);
UI.Icon.Texture:SetTexture(getTexturePath('icons/addon'));
UI.Icon.Texture:AddMaskTexture(UI.Icon.Mask);

UI.Title.AddonName = UI.Title:CreateFontString('AddonName', 'OVERLAY')
UI.Title.AddonName:SetSize(220, 24);
UI.Title.AddonName:SetFontObject(styles.FONT_OBJECTS.HEADING)
UI.Title.AddonName:SetPoint('TOPLEFT', UI.Title, 'TOPLEFT', 50, -16);
UI.Title.AddonName:SetText('Keystone Companion')

UI.Party = CreateFrame('Frame', 'KeystoneCompanionParty', UI);
UI.Party:SetSize(438, 461);
UI.Party:SetPoint('TOPLEFT', UI, 'TOPLEFT', 13, -93);

UI.Party.Header = CreateFrame('Frame', 'KeystoneCompanionPartyHeader', UI.Party);
UI.Party.Header:SetSize(442, 17);
UI.Party.Header:SetPoint('TOPLEFT', UI.Party, 'TOPLEFT')

UI.Party.HeaderBar = CreateFrame('Frame', 'KeystoneCompanionHeaderBar', UI.Header);
UI.Party.HeaderBar:SetHeight(1);
UI.Party.HeaderBar:SetPoint('BOTTOMLEFT', UI.Party.Header, 'BOTTOMLEFT');
UI.Party.HeaderBar:SetPoint('BOTTOMRIGHT', UI.Party.Header, 'BOTTOMRIGHT');
UI.Party.HeaderBar.Texture = UI.Party.Header:CreateTexture('KeystoneCompanionHeaderBarTexture', 'OVERLAY')
UI.Party.HeaderBar.Texture:SetAllPoints(UI.Party.HeaderBar)
UI.Party.HeaderBar.Texture:SetColorTexture(89 / 255, 89 / 255, 91 / 255, 1);

UI.Party.Header.PlayerName = UI.Party.Header:CreateFontString('KeystoneCompanionHeaderPlayername', 'OVERLAY')
UI.Party.Header.PlayerName:SetSize(80, 12);
UI.Party.Header.PlayerName:SetFontObject(styles.FONT_OBJECTS.BOLD);
UI.Party.Header.PlayerName:SetJustifyH('LEFT');
UI.Party.Header.PlayerName:SetPoint('TOPLEFT', UI.Party.Header, 'TOPLEFT', 10, 0);
UI.Party.Header.PlayerName:SetText('Player name');

UI.Party.Header.Food = UI.Party.Header:CreateFontString('KeystoneCompanionHeaderFood', 'OVERLAY')
UI.Party.Header.Food:SetSize(67, 12);
UI.Party.Header.Food:SetFontObject(styles.FONT_OBJECTS.BOLD);
UI.Party.Header.Food:SetJustifyH('LEFT');
UI.Party.Header.Food:SetPoint('TOPLEFT', UI.Party.Header, 'TOPLEFT', 128, 0);
UI.Party.Header.Food:SetText('Food');

UI.Party.Header.Rune = UI.Party.Header:CreateFontString('KeystoneCompanionHeaderRune', 'OVERLAY')
UI.Party.Header.Rune:SetSize(67, 12);
UI.Party.Header.Rune:SetFontObject(styles.FONT_OBJECTS.BOLD);
UI.Party.Header.Rune:SetJustifyH('LEFT');
UI.Party.Header.Rune:SetPoint('TOPLEFT', UI.Party.Header, 'TOPLEFT', 195, 0);
UI.Party.Header.Rune:SetText('Runes');

UI.Party.Header.Potions = UI.Party.Header:CreateFontString('KeystoneCompanionHeaderPotions', 'OVERLAY')
UI.Party.Header.Potions:SetSize(67, 12);
UI.Party.Header.Potions:SetFontObject(styles.FONT_OBJECTS.BOLD);
UI.Party.Header.Potions:SetJustifyH('LEFT');
UI.Party.Header.Potions:SetPoint('TOPLEFT', UI.Party.Header, 'TOPLEFT', 262, 0);
UI.Party.Header.Potions:SetText('Potions');

UI.Party.Header.Flasks = UI.Party.Header:CreateFontString('KeystoneCompanionHeaderFlasks', 'OVERLAY')
UI.Party.Header.Flasks:SetSize(67, 12)
UI.Party.Header.Flasks:SetFontObject(styles.FONT_OBJECTS.BOLD);
UI.Party.Header.Flasks:SetJustifyH('LEFT');
UI.Party.Header.Flasks:SetPoint('TOPLEFT', UI.Party.Header, 'TOPLEFT', 329, 0);
UI.Party.Header.Flasks:SetText('Flasks')

UI.Party.Header.Weapon = UI.Party.Header:CreateFontString('KeystoneCompanionHeaderWeapon', 'OVERLAY')
UI.Party.Header.Weapon:SetSize(67, 12)
UI.Party.Header.Weapon:SetFontObject(styles.FONT_OBJECTS.BOLD);
UI.Party.Header.Weapon:SetJustifyH('LEFT');
UI.Party.Header.Weapon:SetPoint('TOPLEFT', UI.Party.Header, 'TOPLEFT', 392, 0);
UI.Party.Header.Weapon:SetText('Weapon')

UI.Footer = CreateFrame('Frame', 'KeystoneCompanionFooter', UI);
UI.Footer:SetSize(411, 15);
UI.Footer:SetPoint('BOTTOMLEFT', UI.Party, 'BOTTOMLEFT');
UI.Footer:SetPoint('BOTTOMRIGHT', UI.Party, 'BOTTOMRIGHT');

UI.AddonVersion = UI.Footer:CreateFontString('KeystoneCompanionAddonVersion', 'OVERLAY');
UI.AddonVersion:SetSize(80, 10);
UI.AddonVersion:SetFontObject(styles.FONT_OBJECTS.NORMAL)
UI.AddonVersion:SetPoint('LEFT', UI.Footer, 'LEFT', 8, 0)
UI.AddonVersion:SetTextColor(89 / 255, 89 / 255, 91 / 255, 1);
UI.AddonVersion:SetJustifyH('LEFT');
UI.AddonVersion:SetText('V' .. KeystoneCompanion.version)

UI.GitHub = CreateFrame('Frame', 'KeystoneCompanionFooterGitHub', UI.Footer);
UI.GitHub:SetSize(58, 15);
UI.GitHub:SetPoint('RIGHT', UI.Footer, 'RIGHT', -8, 0);
UI.GitHub.Label = UI.GitHub:CreateFontString('KeystoneCompanionFooterGitHubLabel', 'OVERLAY')
UI.GitHub.Label:SetSize(48, 13)
UI.GitHub.Label:SetPoint('LEFT', UI.GitHub, 'LEFT');
UI.GitHub.Label:SetFontObject(styles.FONT_OBJECTS.NORMAL)
UI.GitHub.Label:SetTextColor(161 / 255, 161 / 255, 161 / 255, 1)
UI.GitHub.Label:SetText('GitHub');
UI.GitHub.Icon = CreateFrame('Frame', "KeystoneCompanionGitHubIcon", UI.GitHub);
UI.GitHub.Icon:SetSize(13, 13);
UI.GitHub.Icon:SetPoint("RIGHT", UI.GitHub, "RIGHT");
UI.GitHub.Icon.Mask = UI.GitHub.Icon:CreateMaskTexture();
UI.GitHub.Icon.Mask:SetAllPoints(UI.GitHub.Icon);
UI.GitHub.Icon.Mask:SetTexture(getTexturePath('icons/github'), 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE');
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
UI.Discord.Label:SetFontObject(styles.FONT_OBJECTS.NORMAL)
UI.Discord.Label:SetTextColor(161 / 255, 161 / 255, 161 / 255, 1)
UI.Discord.Label:SetText('Join us on Discord');
UI.Discord.Icon = CreateFrame('Frame', "KeystoneCompanionDiscordIcon", UI.Discord);
UI.Discord.Icon:SetSize(13, 13);
UI.Discord.Icon:SetPoint("RIGHT", UI.Discord, "RIGHT");
UI.Discord.Icon.Mask = UI.Discord.Icon:CreateMaskTexture();
UI.Discord.Icon.Mask:SetAllPoints(UI.Discord.Icon);
UI.Discord.Icon.Mask:SetTexture(getTexturePath('icons/discord'), 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE');
UI.Discord.Icon.Texture = UI.Discord.Icon:CreateTexture("KeystoneCompanionDiscordIconTexture", "OVERLAY");
UI.Discord.Icon.Texture:SetAllPoints(UI.Discord.Icon);
UI.Discord.Icon.Texture:SetTexture(getTexturePath('icons/discord'));
UI.Discord.Icon.Texture:AddMaskTexture(UI.Discord.Icon.Mask);
UI.Discord:SetScript("OnEnter", function()
  UI.Discord.Label:SetTextColor(204 / 255, 204 / 255, 204 / 255, 1);
  UI.Discord.Icon.Texture:SetTexture(getTexturePath('icons/discord-highlight'))
end)
UI.Discord:SetScript("OnLeave", function()
  UI.Discord.Label:SetTextColor(161 / 255, 161 / 255, 161 / 255, 1);
  UI.Discord.Icon.Texture:SetTexture(getTexturePath('icons/discord'))
end)

UI.Tooltip = CreateFrame('GameTooltip', 'KeystoneCompanionTooltip', UIParent, 'GameTooltipTemplate');
UI.Tooltip:RegisterEvent("MODIFIER_STATE_CHANGED");
UI.Tooltip:SetScript("OnHide", function (self)
  self:SetScript("OnEvent", nil);
end);

UI.CopyFrame = CreateRoundedFrame(UI,
  { width = UI:GetWidth(), height = 64, points = { { "LEFT", UI, "LEFT", 20, 0 }, { "RIGHT", UI, "RIGHT", -20, 0 }, { "CENTER", 0, 10 } }, border_size = 1 })
UI.CopyFrame:SetFrameStrata("DIALOG");
UI.CopyFrame.Label = UI.CopyFrame:CreateFontString("KeystoneCompanionCopyFrameLabel", "OVERLAY");
UI.CopyFrame.Label:SetPoint("TOPLEFT", UI.CopyFrame, "TOPLEFT", 5, -5);
UI.CopyFrame.Label:SetPoint("BOTTOMRIGHT", UI.CopyFrame, "BOTTOMRIGHT", -5, 35);
UI.CopyFrame.Label:SetFont(styles.FONTS.NORMAL, 12);
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
  if (UI.CopyFrame:IsShown() and UI.EditBox:GetText() == 'https://github.com/kaelonR/keystone-companion') then
    UI.CopyFrame:Hide();
    return;
  end

  UI.EditBox:SetText('https://github.com/kaelonR/keystone-companion');
  UI.CopyFrame:Show();
end)

UI.Discord:SetScript("OnMouseDown", function()
  if (UI.CopyFrame:IsShown() and UI.EditBox:GetText() == 'https://discord.gg/KhFhC6kZ78') then
    UI.CopyFrame:Hide();
    return;
  end

  UI.EditBox:SetText('https://discord.gg/KhFhC6kZ78');
  UI.CopyFrame:Show();
end)

local function createPlayerTooltip(self) -- changed it so that the function can call itself
  local playerName = self:GetAttribute('player')
  if (playerName == nil) then return end
  if (playerName == UnitName('player')) then playerName = 'self' end

  local playerData = KeystoneCompanion.inventory[playerName];
  if (playerData == nil) then return end;

  UI.Tooltip:ClearLines();
  UI.Tooltip:SetOwner(self, 'ANCHOR_NONE');
  UI.Tooltip:SetPoint('BOTTOMRIGHT', self, 'TOPLEFT');
  UI.Tooltip:SetText(self:GetAttribute('player'));
  UI.Tooltip:AddLine('');

  if (playerData.mythicPlusScore ~= nil and playerData.mythicPlusScore > 0) then
    local scoreColor = C_ChallengeMode.GetDungeonScoreRarityColor(playerData.mythicPlusScore)
    UI.Tooltip:AddDoubleLine('Mythic+ score', playerData.mythicPlusScore, nil, nil, nil, scoreColor:GetRGB())
  end

  if (playerData.itemLevel ~= nil and playerData.itemLevel.equipped ~= nil) then
    UI.Tooltip:AddDoubleLine('Item level', math.floor(playerData.itemLevel.equipped), nil, nil, nil, 1, 1, 1)
    if (playerData.itemLevel.equipped ~= playerData.itemLevel.overall) then
      UI.Tooltip:AddDoubleLine('Item level in bags', math.floor(playerData.itemLevel.overall), nil, nil, nil, 1, 1, 1)
    end
  end

  UI.Tooltip:Show();

  local mythicPlusScore = playerData.mythicPlusScore ~= nil and playerData.mythicPlusScore > 0 and
  C_ChallengeMode.GetDungeonScoreRarityColor(playerData.mythicPlusScore) or '';
  local scoreColor = mythicPlusScore;
  local itemLevel = playerData.itemLevel;

  UI.Tooltip:SetScript("OnEvent", function (tooltip)
    if IsAltKeyDown() then
      tooltip:ClearLines();
      tooltip:SetText(self:GetAttribute('player'));
      local maps = C_ChallengeMode.GetMapTable();
      for _, mapID in ipairs(maps) do
        local level = select(2, C_MythicPlus.GetWeeklyBestForMap(mapID)) or 0;
        local name = C_ChallengeMode.GetMapUIInfo(mapID);
        tooltip:AddDoubleLine(name, level, nil, nil, nil, C_ChallengeMode.GetKeystoneLevelRarityColor(level):GetRGBA());
        UI.Tooltip:Show();
      end
    else
      createPlayerTooltip(self);
    end
  end);
end

local createDungeonTooltip = function(self)
  local playerName = self:GetAttribute('player');
  if (playerName == nil) then return end
  if (playerName == UnitName('player')) then playerName = 'self' end

  local playerData = KeystoneCompanion.inventory[playerName];
  if (playerData.keystone.mapID == nil) then return end;

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
  if (not spellKnown) then
    UI.Tooltip:AddLine('You do not have this teleport', 1, 0, 0, true);
  elseif (not spellUsable) then
    UI.Tooltip:AddLine('Teleport not usable', 0.62, 0.62, 0.62, true);
  else
    UI.Tooltip:AddLine('Click to teleport');
  end
  UI.Tooltip:Show();
end

local nextPage = function(self)
  local cell = self:GetParent():GetParent();
  local currentPage = cell.ItemButton:GetAttribute('page') or 1;
  local player = cell.ItemButton:GetAttribute('player');
  local itemCategory = cell.ItemButton:GetAttribute('category');

  cell.ItemButton:SetAttribute('page', currentPage + 1);

  local playerData = player == UnitName('player') and KeystoneCompanion.inventory.self or
  KeystoneCompanion.inventory[player];
  KeystoneCompanion.UI.RerenderItemCell(cell, player, playerData.items[itemCategory]);
end

local previousPage = function(self)
  local cell = self:GetParent():GetParent();
  local currentPage = cell.ItemButton:GetAttribute('page') or 1;
  if (currentPage == 1) then return end;

  local player = cell.ItemButton:GetAttribute('player');
  local itemCategory = cell.ItemButton:GetAttribute('category');

  cell.ItemButton:SetAttribute('page', currentPage - 1);

  local playerData = player == UnitName('player') and KeystoneCompanion.inventory.self or
  KeystoneCompanion.inventory[player];
  KeystoneCompanion.UI.RerenderItemCell(cell, player, playerData.items[itemCategory]);
end

local createItemCell = function(parent, row, column, cellName)
  local cell = CreateFrame('Frame', 'KeystoneCompanionPlayerRow' .. row .. cellName, parent);
  cell:SetSize(42, 42);
  cell:SetPoint("TOPLEFT", parent, "TOPLEFT", (67 * (column - 1)), 0);
  cell.ItemButton = CreateFrame('ItemButton', "KeystoneCompanionPlayerRow" .. row .. cellName .. "ItemButton", cell,
    "InsecureActionButtonTemplate");
  cell.ItemButton:SetSize(27, 27);
  cell.ItemButton.NormalTexture:SetSize(27, 27);
  cell.ItemButton.PushedTexture:SetSize(20, 20);
  cell.ItemButton.IconBorder:SetAllPoints(cell.ItemButton);
  cell.ItemButton:SetPoint('TOP', cell, 'TOP');
  cell.ItemButton:SetNormalTexture('Interface/PaperDoll/UI-Backpack-EmptySlot')
  cell.ItemButton:SetButtonState('NORMAL', true);
  cell.ItemButton:SetAttribute('category', cellName);
  cell.ItemButton:RegisterForClicks('AnyDown', 'AnyUp');
  cell.ItemButton:SetAttribute('type', 'item');

  cell.ItemButton:SetScript('OnEnter', function(self)
    local itemId = self:GetItem();
    if (itemId ~= nil) then
      UI.Tooltip:SetOwner(self, 'ANCHOR_NONE');
      UI.Tooltip:SetPoint('BOTTOMRIGHT', self, 'TOPLEFT');
      UI.Tooltip:SetItemByID(itemId);
      UI.Tooltip:Show();
    end
  end)
  cell.ItemButton:SetScript('OnLeave', function()
    if (UI.Tooltip:IsShown()) then UI.Tooltip:Hide() end
  end)


  cell.Pagination = CreateFrame('Frame', 'KeystoneCompanionPlayerRow' .. row .. cellName .. 'Pagination', cell);
  cell.Pagination:SetHeight(12)
  cell.Pagination:SetPoint("BOTTOMLEFT", cell, "BOTTOMLEFT");
  cell.Pagination:SetPoint("BOTTOMRIGHT", cell, "BOTTOMRIGHT");

  cell.Pagination.PreviousButton = CreateFrame('Frame', 'KeystoneCompanionPlayerRow' .. row .. cellName .. 'PrevButton',
    cell.Pagination);
  cell.Pagination.PreviousButton:SetSize(12, 12);
  cell.Pagination.PreviousButton:SetPoint("LEFT", cell.Pagination, "LEFT")
  cell.Pagination.PreviousButton.Texture = cell.Pagination.PreviousButton:CreateTexture('KeystoneCompanionPlayerRow' ..
  row .. cellName .. 'PrevButtonTexture');
  cell.Pagination.PreviousButton.Texture:SetSize(8, 8);
  cell.Pagination.PreviousButton.Texture:SetPoint("TOPLEFT", cell.Pagination.PreviousButton, "TOPLEFT", 3, -3);
  cell.Pagination.PreviousButton.Texture:SetTexture(getTexturePath('widgets/previous-button'));
  cell.Pagination.PreviousButton:SetScript("OnEnter", function()
    cell.Pagination.PreviousButton.Texture:SetTexture(getTexturePath('widgets/previous-button-highlight'));
  end)
  cell.Pagination.PreviousButton:SetScript("OnLeave", function()
    cell.Pagination.PreviousButton.Texture:SetTexture(getTexturePath('widgets/previous-button'));
  end)
  cell.Pagination.PreviousButton:SetScript("OnMouseDown", previousPage)

  cell.Pagination.NextButton = CreateFrame('Frame', 'KeystoneCompanionPlayerRow' .. row .. cellName .. 'NextButton',
    cell.Pagination);
  cell.Pagination.NextButton:SetSize(12, 12);
  cell.Pagination.NextButton:SetPoint("RIGHT", cell.Pagination, "RIGHT", -2, 0)
  cell.Pagination.NextButton.Texture = cell.Pagination.NextButton:CreateTexture('KeystoneCompanionPlayerRow' ..
  row .. cellName .. 'NextButtonTexture');
  cell.Pagination.NextButton.Texture:SetSize(8, 8);
  cell.Pagination.NextButton.Texture:SetPoint("TOPLEFT", cell.Pagination.NextButton, "TOPLEFT", 3, -3);
  cell.Pagination.NextButton.Texture:SetTexture(getTexturePath('widgets/next-button'));
  cell.Pagination.NextButton:SetScript("OnEnter", function()
    cell.Pagination.NextButton.Texture:SetTexture(getTexturePath('widgets/next-button-highlight'));
  end)
  cell.Pagination.NextButton:SetScript("OnLeave", function()
    cell.Pagination.NextButton.Texture:SetTexture(getTexturePath('widgets/next-button'));
  end)
  cell.Pagination.NextButton:SetScript("OnMouseDown", nextPage)

  cell.Pagination.Label = cell.Pagination:CreateFontString(
  "KeystoneCompanionPlayerRow" .. row .. cellName .. "PaginationLabel", "OVERLAY");
  cell.Pagination.Label:SetAllPoints(cell.Pagination, "CENTER", 1);
  cell.Pagination.Label:SetFontObject(styles.FONT_OBJECTS.NORMAL)
  cell.Pagination.Label:SetText("3/5");

  cell.Pagination:Hide();

  return cell;
end

for i = 1, 5 do
  UI['player' .. i] = CreateFrame('Frame', 'Player' .. i .. 'Row', UI.Party);
  local playerRow = UI['player' .. i];

  playerRow:SetSize(438, 83);
  playerRow:SetPoint('TOPLEFT', UI.Party.HeaderBar, 'TOPLEFT', 0, -1 - (83 * (i - 1)))
  playerRow:SetPoint('TOPRIGHT', UI.Party.HeaderBar, 'TOPRIGHT', 0, -1 - (83 * (i - 1)))
  if (i % 2 == 0) then
    playerRow.Mask = playerRow:CreateMaskTexture();
    playerRow.Mask:SetAllPoints(playerRow);
    playerRow.Mask:SetTexture(getTexturePath('frames/player-row-light'));
    playerRow.Texture = playerRow:CreateTexture('Player' .. i .. 'RowBackground');
    playerRow.Texture:SetAllPoints(playerRow);
    playerRow.Texture:SetTexture(getTexturePath('frames/player-row-light'));
    playerRow.Texture:AddMaskTexture(playerRow.Mask);
  end

  playerRow.Content = CreateFrame('Frame', 'KeystoneCompanionPlayerRow' .. i .. 'Content', playerRow);
  playerRow.Content:SetSize(458, 63);
  playerRow.Content:SetPoint("TOPLEFT", playerRow, "TOPLEFT", 10, -10);
  playerRow.Content:SetPoint("BOTTOMRIGHT", playerRow, "BOTTOMRIGHT", -10, 10);

  playerRow.PlayerName = playerRow.Content:CreateFontString();
  playerRow.PlayerName:SetHeight(14)
  playerRow.PlayerName:SetPoint("TOPLEFT", playerRow.Content, "TOPLEFT", 0, 0);
  playerRow.PlayerName:SetPoint("TOPRIGHT", playerRow.Content, "TOPRIGHT");
  playerRow.PlayerName:SetFont(styles.FONTS.BOLD, 12)
  playerRow.PlayerName:SetJustifyH('LEFT');
  playerRow.PlayerName:SetTextColor(161 / 255, 161 / 255, 161 / 255, 1);
  playerRow.PlayerName:SetText("Player " .. i);

  playerRow.ClassIcon = CreateFrame('Frame', 'KeystoneCompanionPlayerRow' .. i .. 'ClassIcon', playerRow.Content);
  playerRow.ClassIcon:SetSize(35, 35);
  playerRow.ClassIcon:SetPoint("TOPLEFT", playerRow.Content, "TOPLEFT", 0, -25);
  playerRow.ClassIcon.Mask = playerRow.ClassIcon:CreateMaskTexture();
  playerRow.ClassIcon.Mask:SetAllPoints(playerRow.ClassIcon);
  playerRow.ClassIcon.Mask:SetTexture(getTexturePath('masks/rounded-button'));
  playerRow.ClassIcon.Texture = playerRow.ClassIcon:CreateTexture(
  "KeystoneCompanionPlayerRow" .. i .. 'ClassIconTexture', 'ARTWORK');
  playerRow.ClassIcon.Texture:SetAllPoints(playerRow.ClassIcon);
  playerRow.ClassIcon.Texture:AddMaskTexture(playerRow.ClassIcon.Mask);
  playerRow.ClassIcon.Texture:SetTexture('Interface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES');
  playerRow.ClassIcon:SetScript('OnEnter', function(self)
    createPlayerTooltip(self);
  end)
  playerRow.ClassIcon:SetScript('OnLeave', function(self)
    if (UI.Tooltip:IsShown()) then UI.Tooltip:Hide() end
  end)
  playerRow.ClassIcon:Hide();

  playerRow.RoleIcon = CreateFrame('Frame', 'KeystoneCompanionPlayerRow' .. i .. 'RoleIcon', playerRow.ClassIcon);
  playerRow.RoleIcon:SetSize(20, 20);
  playerRow.RoleIcon:SetPoint('CENTER', playerRow.ClassIcon, 'BOTTOMRIGHT', 0, 0);
  playerRow.RoleIcon.Texture = playerRow.RoleIcon:CreateTexture('KeystoneCompanionPlayerRow' .. i .. 'RoleIconTexture',
    'ARTWORK');
  playerRow.RoleIcon.Texture:SetAllPoints(playerRow.RoleIcon);
  playerRow.RoleIcon.Texture:SetTexture('Interface/LFGFRAME/UI-LFG-ICON-PORTRAITROLES');
  playerRow.RoleIcon:Hide();

  playerRow.LeaderIcon = CreateFrame('Frame', 'KeystoneCompanionPlayerRow' .. i .. 'LeaderIcon', playerRow.ClassIcon);
  playerRow.LeaderIcon:SetSize(20, 20);
  playerRow.LeaderIcon:SetPoint('CENTER', playerRow.ClassIcon, 'TOPRIGHT');
  playerRow.LeaderIcon.Texture = playerRow.LeaderIcon:CreateTexture(
  'KeystoneCompanionPlayerRow' .. i .. 'LeaderIconTexture', 'ARTWORK');
  playerRow.LeaderIcon.Texture:SetAllPoints(playerRow.LeaderIcon);
  playerRow.LeaderIcon.Texture:SetTexture('Interface/GROUPFRAME/UI-Group-LeaderIcon');
  playerRow.LeaderIcon:Hide();

  playerRow.DungeonIcon = CreateFrame('Button', 'KeystoneCompanionPlayerRow' .. i .. 'DungeonButton', playerRow.Content,
    'InsecureActionButtonTemplate');
  playerRow.DungeonIcon:SetSize(35, 35);
  playerRow.DungeonIcon:SetPoint("TOPLEFT", playerRow.Content, "TOPLEFT", 55, -25);
  playerRow.DungeonIcon:RegisterForClicks("AnyDown", "AnyUp");
  playerRow.DungeonIcon:SetAttribute('type', 'spell');
  playerRow.DungeonIcon:SetAlpha(0.4);
  playerRow.DungeonIcon:SetScript('OnEnter', function(self)
    createDungeonTooltip(self);
  end)
  playerRow.DungeonIcon:SetScript('OnLeave', function(self)
    if (UI.Tooltip:IsShown()) then UI.Tooltip:Hide() end
  end)

  playerRow.DungeonIcon:Hide();

  playerRow.KeystoneLevel = CreateFrame('Frame', 'KeystoneCompanionPlayerRow' .. i .. 'KeystoneLevel', playerRow.Content);
  playerRow.KeystoneLevel:SetSize(22, 22);
  playerRow.KeystoneLevel:SetPoint('CENTER', playerRow.DungeonIcon, 'BOTTOMRIGHT');
  playerRow.KeystoneLevel.Mask = playerRow.KeystoneLevel:CreateMaskTexture();
  playerRow.KeystoneLevel.Mask:SetAllPoints(playerRow.KeystoneLevel);
  playerRow.KeystoneLevel.Mask:SetTexture(getTexturePath('frames/portrait-black'));
  playerRow.KeystoneLevel.Texture = playerRow.KeystoneLevel:CreateTexture('KeystoneCompanionPlayerRow' ..
  i .. 'KeystoneLevelTexture');
  playerRow.KeystoneLevel.Texture:SetAllPoints(playerRow.KeystoneLevel)
  playerRow.KeystoneLevel.Texture:SetTexture(getTexturePath('frames/portrait-black'));
  playerRow.KeystoneLevel.Texture:AddMaskTexture(playerRow.KeystoneLevel.Mask);
  playerRow.KeystoneLevel.Label = playerRow.KeystoneLevel:CreateFontString('KeystoneCompanionPlayerRow' ..
  i .. 'KeystoneLevelLabel');
  playerRow.KeystoneLevel.Label:SetFontObject(styles.FONT_OBJECTS.NORMAL)
  playerRow.KeystoneLevel.Label:SetTextColor(styles.COLORS.TEXT_SECONDARY:GetRGBA());
  playerRow.KeystoneLevel.Label:SetJustifyH('CENTER');
  playerRow.KeystoneLevel.Label:SetJustifyV('CENTER');

  playerRow.KeystoneLevel:Hide();

  playerRow.Inventory = CreateFrame('Frame', 'KeystoneCompanionPlayerRow' .. i .. 'Inventory', playerRow.Content);
  playerRow.Inventory:SetSize(310, 42);
  playerRow.Inventory:SetPoint("BOTTOMRIGHT", playerRow.Content, "BOTTOMRIGHT");

  playerRow.Food = createItemCell(playerRow.Inventory, i, 1, 'Food');
  playerRow.Rune = createItemCell(playerRow.Inventory, i, 2, 'Rune');
  playerRow.Potions = createItemCell(playerRow.Inventory, i, 3, 'Potion');
  playerRow.Flasks = createItemCell(playerRow.Inventory, i, 4, 'Flask');
  playerRow.Weapon = createItemCell(playerRow.Inventory, i, 5, 'WeaponEnchantment');
  playerRow.Inventory:Hide();
end


function KeystoneCompanion.UI.RerenderItemCell(cell, playerName, itemData)
  local itemCount = itemData == nil and 0 or #itemData;
  cell.ItemButton:SetAttribute('player', playerName);

  if (itemCount == 0) then
    cell.Pagination:Hide();
    cell.ItemButton:Reset();
    cell.ItemButton.NormalTexture:Show();
    return;
  end

  local currentPage = cell.ItemButton:GetAttribute('page') or 1;
  if (currentPage > itemCount) then
    cell.ItemButton:SetAttribute('page', itemCount);
    currentPage = itemCount;
  end

  if (currentPage == 1) then
    cell.Pagination.PreviousButton:Hide();
  else
    cell.Pagination.PreviousButton:Show();
  end
  if (currentPage == itemCount) then
    cell.Pagination.NextButton:Hide();
  else
    cell.Pagination.NextButton:Show();
  end

  cell.Pagination.Label:SetText(currentPage .. '/' .. itemCount);
  cell.Pagination:Show();

  local currentItem = itemData[currentPage];
  cell.ItemButton:SetItem(currentItem.itemID);
  cell.ItemButton:SetItemButtonCount(currentItem.count);
  cell.ItemButton.NormalTexture:Hide();

  if (playerName == UnitName('player')) then
    cell.ItemButton:SetAttribute('item', select(1, C_Item.GetItemInfo(currentItem.itemID)));
  end
end

function KeystoneCompanion.UI.RerenderPlayerRow(row, playerName, playerData)
  row.PlayerName:SetText(playerName);

  local unitClass = select(2, UnitClass(playerName));
  if (unitClass ~= nil) then
    row.ClassIcon.Texture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[unitClass]));
    row.ClassIcon:SetAttribute('player', playerName);
    row.ClassIcon:Show();
  else
    row.ClassIcon:Hide();
  end

  local role = UnitGroupRolesAssigned(playerName);
  if (role == 'NONE') then
    row.RoleIcon:Hide();
  else
    row.RoleIcon.Texture:SetTexCoord(unpack(KeystoneCompanion.constants.roleIconCoords[role]))
    row.RoleIcon:Show();
  end

  if (UnitIsGroupLeader(playerName, LE_PARTY_CATEGORY_HOME)) then
    row.LeaderIcon:Show();
  else
    row.LeaderIcon:Hide();
  end

  if (playerData.keystone == nil or playerData.keystone.mapID == nil) then
    row.DungeonIcon:Hide();
    row.KeystoneLevel:Hide();
  else
    local dungeonInfo = KeystoneCompanion.constants.dungeonTeleports[playerData.keystone.mapID];
    row.DungeonIcon:SetAttribute('player', playerName);
    row.DungeonIcon:SetAttribute('spell', dungeonInfo.spell.id);
    row.DungeonIcon:SetNormalTexture(GetSpellTexture(dungeonInfo.spell.id));
    row.DungeonIcon:Show();

    local spellKnown = IsSpellKnown(dungeonInfo.spell.id, false);
    local spellUsable = IsUsableSpell(dungeonInfo.spell.id);

    if (spellKnown and spellUsable) then
      row.DungeonIcon:SetAlpha(1);
    else
      row.DungeonIcon:SetAlpha(0.6);
    end

    row.KeystoneLevel.Label:SetText(playerData.keystone.level);
    if (playerData.keystone.level >= 10) then
      row.KeystoneLevel.Label:SetPoint('LEFT', row.KeystoneLevel, 'LEFT', 5, 0);
    else
      row.KeystoneLevel.Label:SetPoint('LEFT', row.KeystoneLevel, 'LEFT', 8, 0);
    end
    row.KeystoneLevel:Show();
  end

  if (playerData.items == nil) then
    row.Inventory:Hide();
  else
    row.Inventory:Show();
    KeystoneCompanion.UI.RerenderItemCell(row.Food, playerName, playerData.items.Food);
    KeystoneCompanion.UI.RerenderItemCell(row.Rune, playerName, playerData.items.Rune);
    KeystoneCompanion.UI.RerenderItemCell(row.Potions, playerName, playerData.items.Potion);
    KeystoneCompanion.UI.RerenderItemCell(row.Flasks, playerName, playerData.items.Flask);
    KeystoneCompanion.UI.RerenderItemCell(row.Weapon, playerName, playerData.items.WeaponEnchantment);
  end

  row:Show();
end

function KeystoneCompanion.UI.Rerender()
  local ownData = KeystoneCompanion.inventory.self;
  local topRow = UI['player1'];
  KeystoneCompanion.UI.RerenderPlayerRow(topRow, UnitName('player'), ownData);

  local numPartyMembers = GetNumGroupMembers(LE_PARTY_CATEGORY_HOME);
  for i = 2, 5 do
    UI['player' .. i]:Hide();
  end

  for i = 2, math.min(5, numPartyMembers) do
    local playerName = UnitName('Party' .. (i - 1));
    local playerRow = UI['player' .. i];
    local playerData = KeystoneCompanion.inventory[playerName] or KeystoneCompanion.inventory:NewEmptyInventory();
    KeystoneCompanion.UI.RerenderPlayerRow(playerRow, playerName, playerData);
  end
end
