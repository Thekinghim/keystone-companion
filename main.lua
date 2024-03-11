KeystoneCompanion.loaded = false;

local characterName, realmName = UnitFullName("player");
local playerName = characterName .. '-' .. realmName;

KeystoneCompanion.EventFrame = CreateFrame("Frame", "KeystoneCompanionEventFrame")
KeystoneCompanion.EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
KeystoneCompanion.EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
KeystoneCompanion.EventFrame:RegisterEvent("BAG_UPDATE")
KeystoneCompanion.EventFrame:SetScript("OnEvent", function(self, event, ...)
  if event == "PLAYER_ENTERING_WORLD" then
    if(UnitInParty("player")) then
      KeystoneCompanion.communication.SendPartyMessage(KeystoneCompanion.communication.messageTypes.LOGON)
    end
  elseif event == "GROUP_ROSTER_UPDATE" and KeystoneCompanion.loaded == true then
    if UnitInRaid("player") then return end
    if not UnitInParty("player") then return end
    print('party updated!')
  elseif event == "BAG_UPDATE" and KeystoneCompanion.loaded == true then
  end
end)

KeystoneCompanion.communication:RegisterMessageHandler(KeystoneCompanion.communication.messageTypes.LOGON, function(sender, channel)
  if(sender == playerName) then
    print("own logon event")
    --return
  end

  KeystoneCompanion.communication.SendDirectMessage(sender, KeystoneCompanion.communication.messageTypes.INVENTORY_UPDATE, KeystoneCompanion.inventory:GetInventoryString())
end)

KeystoneCompanion.communication:RegisterMessageHandler(KeystoneCompanion.communication.messageTypes.INVENTORY_UPDATE, function(sender, channel, data)
  print("INVENTORY_UPDATE", data)
end)