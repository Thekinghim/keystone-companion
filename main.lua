KeystoneCompanion.loaded = false;
local print, colorise, devPrint = KeystoneCompanion.print, KeystoneCompanion.colorise, KeystoneCompanion.dev.print

local playerName = UnitName('player');

KeystoneCompanion.EventFrame = CreateFrame('Frame', 'KeystoneCompanionEventFrame')
KeystoneCompanion.EventFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
KeystoneCompanion.EventFrame:RegisterEvent('GROUP_ROSTER_UPDATE')
KeystoneCompanion.EventFrame:RegisterEvent('BAG_UPDATE')
KeystoneCompanion.EventFrame:SetScript('OnEvent', function(self, event, ...)
  devPrint('event - ' .. event);
  if event == 'PLAYER_ENTERING_WORLD' then
      if(UnitInParty("player") or KeystoneCompanion.isDev()) then
        devPrint('world loaded and player in party - Sending LOGON and UPDATE messages')
        KeystoneCompanion.communication.SendPartyMessage(KeystoneCompanion.communication.messageTypes.LOGON)
        KeystoneCompanion.communication.SendPartyMessage(KeystoneCompanion.communication.messageTypes.UPDATE, KeystoneCompanion.inventory:GetInventoryString())
      end
      KeystoneCompanion.loaded = true
  elseif event == 'GROUP_ROSTER_UPDATE' and KeystoneCompanion.loaded == true then
    
  elseif event == 'BAG_UPDATE' and KeystoneCompanion.loaded == true then
    devPrint('debug - scan inventory')
  end
end)

KeystoneCompanion.communication:RegisterMessageHandler(KeystoneCompanion.communication.messageTypes.LOGON, function(sender, channel)
  if(sender == playerName) then return end

  devPrint('sending inventory info to ' .. sender)
  KeystoneCompanion.communication.SendDirectMessage(sender, KeystoneCompanion.communication.messageTypes.UPDATE, KeystoneCompanion.inventory:GetInventoryString())
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
    print('TODO - open UI')
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