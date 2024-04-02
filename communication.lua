KeystoneCompanion.communication = { prefix = "keystonecomp", messageTypes = {LOGON = "LOGON", QUERY = "QUERY", UPDATE = "UPDATE"}, handlers = {}}
local devPrint = KeystoneCompanion.dev.print;

function KeystoneCompanion.communication.SendMessage(...)
  local messageType, data = select(1, ...)
  local message = messageType .. '::';
  if(data ~= nil and strlen(data) > 0) then message = message .. data end

  if(UnitInParty('player') == false and KeystoneCompanion.isDev()) then
    C_ChatInfo.SendAddonMessage(KeystoneCompanion.communication.prefix, message, "WHISPER", UnitName('player'))
  else
    C_ChatInfo.SendAddonMessage(KeystoneCompanion.communication.prefix, message, "PARTY")
  end
end

function KeystoneCompanion.communication:RegisterMessageHandler(messageType, callbackFunc)
  self.handlers[messageType] = self.handlers[messageType] or {};
  table.insert(self.handlers[messageType], callbackFunc);
end

function KeystoneCompanion.communication:OnMessageReceived(prefix, text, channel, sender)
  sender = Ambiguate(sender, "none")
  if (prefix ~= KeystoneCompanion.communication.prefix) then return end

  local prefixSeparatorIndex = string.find(text, '::');
  if (prefixSeparatorIndex == nil) then return end

  local messageType = string.sub(text, 1, prefixSeparatorIndex - 1);
  local handlers = self.handlers[messageType];
  if (handlers == nil) then return end

  local messageData = '';
  if(strlen(text) > prefixSeparatorIndex + 1) then
    messageData = string.sub(text, prefixSeparatorIndex + 2);
  end

  for _, handler in ipairs(handlers) do
    handler(sender, channel, messageData)
  end
end

KeystoneCompanion.communication.EventFrame = CreateFrame("Frame", "KeystoneCompanionCommunicationFrame")
KeystoneCompanion.communication.EventFrame:RegisterEvent("CHAT_MSG_ADDON");
KeystoneCompanion.communication.EventFrame:SetScript("OnEvent", function(self, event, prefix, text, channel, sender)
  KeystoneCompanion.communication:OnMessageReceived(prefix, text, channel, sender)
end)
C_ChatInfo.RegisterAddonMessagePrefix(KeystoneCompanion.communication.prefix)