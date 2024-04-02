KeystoneCompanion.loaded = false;
local print, colorise, devPrint = KeystoneCompanion.print, KeystoneCompanion.colorise, KeystoneCompanion.dev.print
local LibSerialize = LibStub:GetLibrary("LibSerialize");

local playerName = UnitName('player');

KeystoneCompanion.EventFrame = CreateFrame('Frame', 'KeystoneCompanionEventFrame')
KeystoneCompanion.EventFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
KeystoneCompanion.EventFrame:RegisterEvent('GROUP_ROSTER_UPDATE')
KeystoneCompanion.EventFrame:RegisterEvent('BAG_UPDATE')
KeystoneCompanion.EventFrame:SetScript('OnEvent', function(self, event, ...)
  devPrint('event - ' .. event);
  if event == 'PLAYER_ENTERING_WORLD' then
      if (KeystoneCompanionDB.UI ~= nil) then
        KeystoneCompanion.UI.Frame:SetPoint(KeystoneCompanionDB.UI.point, KeystoneCompanionDB.UI.relativeTo, KeystoneCompanionDB.UI.relativePoint, KeystoneCompanionDB.UI.offsetX, KeystoneCompanionDB.UI.offsetY)
      else
        KeystoneCompanion.UI.Frame:SetPoint('CENTER', UIParent, 'CENTER')
      end

      if(UnitInParty("player") or KeystoneCompanion.isDev()) then
        devPrint('world loaded and player in party - Sending LOGON and UPDATE messages')
        KeystoneCompanion.communication.SendMessage(KeystoneCompanion.communication.messageTypes.LOGON)
        KeystoneCompanion.communication.SendMessage(KeystoneCompanion.communication.messageTypes.UPDATE, KeystoneCompanion.inventory:GetInventoryString())
      end
      KeystoneCompanion.loaded = true
  elseif event == 'GROUP_ROSTER_UPDATE' and KeystoneCompanion.loaded == true then
    local playersByName = {};
    local homePartyPlayers = GetHomePartyInfo();
    if(homePartyPlayers ~= nil) then
      for _, v in ipairs(homePartyPlayers) do playersByName[v] = true end
    end
    for key, value in pairs(KeystoneCompanion.inventory) do
      if(type(value) == "table" and key ~= 'self' and playersByName[key] == nil) then
        KeystoneCompanion.inventory[key] = nil;
      end
    end
    KeystoneCompanion.UI.Rerender();
  elseif event == 'BAG_UPDATE' and KeystoneCompanion.loaded == true then
    local currentInventoryData = LibSerialize:Serialize(KeystoneCompanion.inventory.self);
  
    KeystoneCompanion.inventory:ScanInventory();
    local inventoryDataAfterScan = LibSerialize:Serialize(KeystoneCompanion.inventory.self);

    if(currentInventoryData ~= inventoryDataAfterScan) then
      KeystoneCompanion.communication.SendMessage(KeystoneCompanion.communication.messageTypes.UPDATE, KeystoneCompanion.inventory:GetInventoryString())
    end
  end
end)

KeystoneCompanion.communication:RegisterMessageHandler(KeystoneCompanion.communication.messageTypes.LOGON, function(sender, channel)
  if(sender == playerName) then return end

  devPrint('sending inventory info to ' .. sender)
  KeystoneCompanion.communication.SendMessage(sender, KeystoneCompanion.communication.messageTypes.UPDATE, KeystoneCompanion.inventory:GetInventoryString())
end)

KeystoneCompanion.communication:RegisterMessageHandler(KeystoneCompanion.communication.messageTypes.UPDATE, function(sender, channel, data)
  if(sender == playerName and not KeystoneCompanion.isDev()) then return end
  devPrint('received UPDATE message from ' .. sender)
  KeystoneCompanion.inventory:LoadString(sender, data)
end)

SLASH_KEYSTONECOMPANION1, SLASH_KEYSTONECOMPANION2 = '/keystonecompanion', '/kc';
function SlashCmdList.KEYSTONECOMPANION(msg, editBox)
  local args = {}
  for word in msg:gmatch('%S+') do args[#args+1] = word end

  if(#args == 0) then
    if(KeystoneCompanion.UI.Frame:IsShown()) then
      KeystoneCompanion.UI.Frame:Hide();
    else
      KeystoneCompanion.UI.Rerender();
      KeystoneCompanion.UI.Frame:Show();
    end
  end

  if(args[1] == 'dev') then
    if(args[2] == 'on' or args[2] == 'enable') then
      KeystoneCompanionDB.settings.DevMode = true;
      print('Developer mode ' .. colorise('38ee45', 'enabled'));
    elseif(args[2] == 'off' or args[2] == 'disables') then
      KeystoneCompanionDB.settings.DevMode = false;
      print('Developer mode ' .. colorise('00ffff', 'disabled'));
    else
      print('/kc dev [enable|on|disable|off]')
    end
  end
end

if(KeystoneCompanion.buildType == 'alpha') then
  print('You\'re running an ' .. colorise('ff0000', 'Alpha') .. ' build of the addon. Features may be broken or only half finished in alpha versions!')
end

print('type ' .. colorise('00ffff', '/kc') .. ' to open the KeystoneCompanion UI.')
KeystoneCompanion.inventory.self.class = select(2, UnitClass('player'))
KeystoneCompanion.UI.Frame:Show();