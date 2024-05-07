local _, Private = ...

Private.communication = { prefix = "keystonecomp", messageTypes = { LOGON = "LOGON", QUERY = "QUERY", UPDATE = "UPDATE" }, handlers = {} }
local LIB_OPEN_RAID_COMM_PREFIX = 'LRS'
local LIB_OPEN_RAID_KEYSTONE_PREFIX = 'K'
local LIB_OPEN_RAID_KEYSTONE_REQUEST_PREFIX = 'J'
local addon = Private.Addon

function Private.communication.SendMessage(...)
  local messageType, data = select(1, ...)
  local message = messageType .. '::'
  if (data ~= nil and strlen(data) > 0) then message = message .. data end

  if (UnitInParty('player') == false and addon:isDev()) then
    C_ChatInfo.SendAddonMessage(Private.communication.prefix, message, "WHISPER", UnitName('player'))
  else
    C_ChatInfo.SendAddonMessage(Private.communication.prefix, message, "PARTY")
  end
end

function Private.communication:RegisterMessageHandler(messageType, callbackFunc)
  self.handlers[messageType] = self.handlers[messageType] or {}
  table.insert(self.handlers[messageType], callbackFunc)
end

function Private.communication:RequestKeystoneInfoFromLibOpenRaid()
  local payload = Private.LibDeflate:CompressDeflate(LIB_OPEN_RAID_KEYSTONE_REQUEST_PREFIX, { level = 9 })
  local encodedPayload = Private.LibDeflate:EncodeForWoWAddonChannel(payload)
  C_ChatInfo.SendAddonMessage(LIB_OPEN_RAID_COMM_PREFIX, encodedPayload, "PARTY")
end

function Private.communication:OnLibOpenRaidMessageReceived(text, sender)
  if (sender == UnitName("player")) then return end

  local compressedData = Private.LibDeflate:DecodeForWoWAddonChannel(text)
  local data = Private.LibDeflate:DecompressDeflate(compressedData)

  if (not data or type(data) ~= 'string' or string.len(data) == 0) then return end
  if (data:sub(1, 1) ~= LIB_OPEN_RAID_KEYSTONE_PREFIX) then return end

  addon:devPrint('received details! keystone info from ' .. sender)
  local keystoneInfo = { strsplit(',', data) }
  Private.inventory:LoadFromDetailsInfo(sender, tonumber(keystoneInfo[2]), tonumber(keystoneInfo[3]))
end

function Private.communication:OnMessageReceived(prefix, text, channel, sender)
  sender = Ambiguate(sender, 'short')

  if (prefix == LIB_OPEN_RAID_COMM_PREFIX) then
    self:OnLibOpenRaidMessageReceived(text, sender)
    return
  end

  if (prefix ~= Private.communication.prefix) then return end

  local prefixSeparatorIndex = string.find(text, '::')
  if (prefixSeparatorIndex == nil) then return end

  local messageType = string.sub(text, 1, prefixSeparatorIndex - 1)
  local handlers = self.handlers[messageType]
  if (handlers == nil) then return end

  local messageData = ''
  if (strlen(text) > prefixSeparatorIndex + 1) then
    messageData = string.sub(text, prefixSeparatorIndex + 2)
  end

  for _, handler in ipairs(handlers) do
    handler(sender, channel, messageData)
  end
end

addon:RegisterEvent("CHAT_MSG_ADDON", "communication.lua", function (self, event, prefix, text, channel, sender)
  Private.communication:OnMessageReceived(prefix, text, channel, sender)
end)

C_ChatInfo.RegisterAddonMessagePrefix(Private.communication.prefix)
C_ChatInfo.RegisterAddonMessagePrefix(LIB_OPEN_RAID_COMM_PREFIX)
