local addonName, KeystoneCompanion = ...;
local getTexturePath = KeystoneCompanion.utils.path.getTexturePath;

KeystoneCompanion.loaded = false;
local print, colorise, devPrint = KeystoneCompanion.print, KeystoneCompanion.colorise, KeystoneCompanion.dev.print
local LibSerialize = LibStub:GetLibrary("LibSerialize");
local LibDataBroker = LibStub:GetLibrary("LibDataBroker-1.1");
local LibDBIcon = LibStub:GetLibrary("LibDBIcon-1.0")

local function ToggleUI()
  if (KeystoneCompanion.UI.Frame:IsShown()) then
    KeystoneCompanion.UI.Frame:Hide();
  else
    KeystoneCompanion.UI.Settings:Hide();
    KeystoneCompanion.UI.Frame.Party:Show();
    KeystoneCompanion.UI.Rerender();
    KeystoneCompanion.UI.Frame:Show();
  end
end

local dataBrokerObj = LibDataBroker:NewDataObject('Keystone Companion', {
  type = 'launcher',
  icon = getTexturePath('icons/addon'),
  OnClick = function() ToggleUI() end,
  OnTooltipShow = function(tooltip)
    tooltip:AddLine("Keystone Companion", 1, 1, 1)
    tooltip:AddLine("Click to open an overview of your party's keystones and dungeon items.", nil, nil, nil, true)
  end
});

local function InitDataBrokerIcon()
  KeystoneCompanionDB.libDBIcon = KeystoneCompanionDB.libDBIcon or { hide = false };
  if (not LibDBIcon:GetMinimapButton('Keystone Companion')) then
    LibDBIcon:Register('Keystone Companion', dataBrokerObj, KeystoneCompanionDB.libDBIcon);
  end
  if (KeystoneCompanionDB.settings.MinimapButton ~= false) then
    LibDBIcon:Show('Keystone Companion')
  else
    LibDBIcon:Hide('Keystone Companion')
  end
end

KeystoneCompanion.EventFrame = CreateFrame('Frame', 'KeystoneCompanionEventFrame')
KeystoneCompanion.EventFrame:RegisterEvent('PLAYER_ENTERING_WORLD');
KeystoneCompanion.EventFrame:RegisterEvent('GROUP_ROSTER_UPDATE');
KeystoneCompanion.EventFrame:RegisterEvent('BAG_UPDATE');
KeystoneCompanion.EventFrame:RegisterEvent('PARTY_LEADER_CHANGED');
KeystoneCompanion.EventFrame:RegisterEvent('ROLE_CHANGED_INFORM');
KeystoneCompanion.EventFrame:SetScript('OnEvent', function(self, event, ...)
  devPrint('event - ' .. event);
  if event == 'PLAYER_ENTERING_WORLD' then
    if (KeystoneCompanionDB.UI ~= nil) then
      KeystoneCompanion.UI.Frame:ClearAllPoints();
      KeystoneCompanion.UI.Frame:SetPoint(KeystoneCompanionDB.UI.point, KeystoneCompanionDB.UI.relativeTo,
        KeystoneCompanionDB.UI.relativePoint, KeystoneCompanionDB.UI.offsetX, KeystoneCompanionDB.UI.offsetY)
    else
      KeystoneCompanion.UI.Frame:SetPoint('CENTER', UIParent, 'CENTER')
    end

    if (UnitInParty("player") or KeystoneCompanion.isDev()) then
      devPrint('world loaded and player in party - Sending LOGON and UPDATE messages')
      KeystoneCompanion.communication.SendMessage(KeystoneCompanion.communication.messageTypes.LOGON)
      KeystoneCompanion.communication.SendMessage(KeystoneCompanion.communication.messageTypes.UPDATE,
        KeystoneCompanion.inventory:GetInventoryString())
      C_Timer.NewTimer(1, function() KeystoneCompanion.communication:RequestKeystoneInfoFromLibOpenRaid() end);
    end

    KeystoneCompanion.inventory:ScanInventory();
    KeystoneCompanion.loaded = true

    if (KeystoneCompanion.isDev()) then
      KeystoneCompanion.UI.Frame:Show();
      KeystoneCompanion.UI.Rerender();
    end

    InitDataBrokerIcon();
  elseif event == 'GROUP_ROSTER_UPDATE' and KeystoneCompanion.loaded == true then
    local playersByName = {};
    local homePartyPlayers = GetHomePartyInfo();
    local numExistingPlayersInInventory = 0;
    if (homePartyPlayers ~= nil) then
      for _, v in ipairs(homePartyPlayers) do playersByName[v] = true end
    end
    for key, value in pairs(KeystoneCompanion.inventory) do
      if (type(value) == "table" and key ~= 'self' and playersByName[key] == nil) then
        KeystoneCompanion.inventory[key] = nil;
      elseif (type(value) == "table" and key ~= 'self') then
        numExistingPlayersInInventory = numExistingPlayersInInventory + 1;
      end
    end

    --if we encountered no pre-existing player entries in inventory data at all, the player just joined a party,
    --in which case LOGON and UPDATE messages should be sent.
    if (numExistingPlayersInInventory == 0) then
      KeystoneCompanion.communication.SendMessage(KeystoneCompanion.communication.messageTypes.LOGON);
      KeystoneCompanion.communication.SendMessage(KeystoneCompanion.communication.messageTypes.UPDATE,
        KeystoneCompanion.inventory:GetInventoryString())
      C_Timer.NewTimer(1, function() KeystoneCompanion.communication:RequestKeystoneInfoFromLibOpenRaid() end);
    end

    KeystoneCompanion.UI.Rerender();
  elseif event == 'BAG_UPDATE' and KeystoneCompanion.loaded == true then
    local currentInventoryData = LibSerialize:Serialize(KeystoneCompanion.inventory.self);

    KeystoneCompanion.inventory:ScanInventory();

    local inventoryDataAfterScan = LibSerialize:Serialize(KeystoneCompanion.inventory.self);
    if (currentInventoryData ~= inventoryDataAfterScan) then
      if (KeystoneCompanion.UI.Frame:IsShown()) then
        KeystoneCompanion.UI.Rerender();
      end

      KeystoneCompanion.communication.SendMessage(KeystoneCompanion.communication.messageTypes.UPDATE,
        KeystoneCompanion.inventory:GetInventoryString())
    end
  elseif (event == 'PARTY_LEADER_CHANGED' or event == 'ROLE_CHANGED_INFORM') and KeystoneCompanion.loaded == true then
    KeystoneCompanion.UI.Rerender();
  end
end)

KeystoneCompanion.communication:RegisterMessageHandler(KeystoneCompanion.communication.messageTypes.LOGON,
  function(sender)
    if (sender == UnitName('player')) then return end
    devPrint('received LOGON message from ' .. sender)

    KeystoneCompanion.communication.SendMessage(KeystoneCompanion.communication.messageTypes.UPDATE,
      KeystoneCompanion.inventory:GetInventoryString())
  end)

KeystoneCompanion.communication:RegisterMessageHandler(KeystoneCompanion.communication.messageTypes.UPDATE,
  function(sender, _, data)
    devPrint('received UPDATE message from ' .. sender)
    if (sender == UnitName('player') and not KeystoneCompanion.isDev()) then return end
    KeystoneCompanion.inventory:LoadString(sender, data)

    if (KeystoneCompanion.UI.Frame:IsShown()) then
      KeystoneCompanion.UI.Rerender();
    end
  end)

SLASH_KEYSTONECOMPANION1, SLASH_KEYSTONECOMPANION2 = '/keystonecompanion', '/kc';
function SlashCmdList.KEYSTONECOMPANION(msg, editBox)
  local args = {}
  for word in msg:gmatch('%S+') do args[#args + 1] = word end

  if (#args == 0) then
    ToggleUI();
  end

  if (args[1] == 'dev') then
    if (args[2] == 'on' or args[2] == 'enable') then
      KeystoneCompanionDB.settings.DevMode = true;
      print('Developer mode ' .. colorise('38ee45', 'enabled'));
    elseif (args[2] == 'off' or args[2] == 'disable') then
      KeystoneCompanionDB.settings.DevMode = false;
      print('Developer mode ' .. colorise('00ffff', 'disabled'));
    else
      print('/kc dev [enable|on|disable|off]')
    end
  elseif (args[1] == 'minimap') then
    if (args[2] == 'on' or args[2] == 'enable') then
      KeystoneCompanionDB.settings.MinimapButton = true;
      print('Minimap button ' .. colorise('38ee45', 'enabled'));
      LibDBIcon:Show('Keystone Companion')
    elseif (args[2] == 'off' or args[2] == 'disable') then
      KeystoneCompanionDB.settings.MinimapButton = false;
      print('Minimap button ' .. colorise('00ffff', 'disabled'));
      LibDBIcon:Hide('Keystone Companion')
    else
      print('/kc minimap [enable|on|disable|off]')
    end
  end
end

if (KeystoneCompanion.buildType == 'alpha') then
  print('You\'re running an ' ..
  colorise('ff0000', 'Alpha') .. ' build of the addon. Features may be broken or only half finished in alpha versions!')
elseif (KeystoneCompanion.buildType == 'beta') then
  print('You\'re running a ' ..
  colorise('ddca2e', 'Beta') ..
  ' version of the addon. Thank you for helping test, and please report any issues on the Github so they can be fixed before release. :)')
end

print('type ' .. colorise('ddca2e', '/kc') .. ' to open the KeystoneCompanion UI, or click the minimap button.')
