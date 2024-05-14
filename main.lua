---@class KeystoneCompanionPrivate
local Private = select(2, ...)
---@class KeystoneCompanion
local addon = Private.Addon
local loc = addon.Loc
local styles = Private.constants.styles

Private.loaded = false

function addon:ToggleUI()
  if (Private.UI.Frame:IsShown()) then
    Private.UI.Frame:Hide()
  else
    Private.UI.Settings:Hide()
    Private.UI.Frame.Party:Show()
    Private.UI.Rerender()
    Private.UI.Frame:Show()
  end
end

addon:RegisterEvent("PLAYER_ENTERING_WORLD", "MAIN.LUA", function(self, event)
  ---@cast self KeystoneCompanion
  if event == "PLAYER_ENTERING_WORLD" then
    if self:GetDatabaseValue("UI") then
      local point = self:GetDatabaseValue("UI")
      Private.UI.Frame:ClearAllPoints()
      Private.UI.Frame:SetPoint(point.point, point.relativeTo,
        point.relativePoint, point.offsetX, point.offsetY)
    else
      Private.UI.Frame:SetPoint("CENTER", UIParent, "CENTER")
    end

    if (UnitInParty("player") or self:isDev()) then
      self:devPrint("world loaded and player in party - Sending LOGON and UPDATE messages")
      Private.communication.SendMessage(Private.communication.messageTypes.LOGON)
      Private.communication.SendMessage(Private.communication.messageTypes.UPDATE,
        Private.inventory:GetInventoryString())
      C_Timer.NewTimer(1, function() Private.communication:RequestKeystoneInfoFromLibOpenRaid() end)
    end

    Private.inventory:ScanInventory()
    Private.loaded = true

    if (self:isDev()) then
      Private.UI.Frame:Show()
      Private.UI.Rerender()
    end

    --InitDataBrokerIcon()
  end
end)
addon:RegisterEvent("GROUP_ROSTER_UPDATE", "MAIN.LUA", function(_, event)
  if event == "GROUP_ROSTER_UPDATE" and Private.loaded == true then
    local playersByName = {}
    local homePartyPlayers = GetHomePartyInfo()
    local numExistingPlayersInInventory = 0
    if (homePartyPlayers ~= nil) then
      for _, v in ipairs(homePartyPlayers) do playersByName[v] = true end
    end
    for key, value in pairs(Private.inventory) do
      if (type(value) == "table" and key ~= "self" and playersByName[key] == nil) then
        Private.inventory[key] = nil
      elseif (type(value) == "table" and key ~= "self") then
        numExistingPlayersInInventory = numExistingPlayersInInventory + 1
      end
    end

    --if we encountered no pre-existing player entries in inventory data at all, the player just joined a party,
    --in which case LOGON and UPDATE messages should be sent.
    if (numExistingPlayersInInventory == 0) then
      Private.communication.SendMessage(Private.communication.messageTypes.LOGON)
      Private.communication.SendMessage(Private.communication.messageTypes.UPDATE,
        Private.inventory:GetInventoryString())
      C_Timer.NewTimer(1, function() Private.communication:RequestKeystoneInfoFromLibOpenRaid() end)
    end

    Private.UI.Rerender()
  end
end)
addon:RegisterEvent("BAG_UPDATE", "MAIN.LUA", function(_, event)
  if event == "BAG_UPDATE" and Private.loaded == true then
    local currentInventoryData = Private.LibSerialize:Serialize(Private.inventory.self)

    Private.inventory:ScanInventory()

    local inventoryDataAfterScan = Private.LibSerialize:Serialize(Private.inventory.self)
    if (currentInventoryData ~= inventoryDataAfterScan) then
      if (Private.UI.Frame:IsShown()) then
        Private.UI.Rerender()
      end

      Private.communication.SendMessage(Private.communication.messageTypes.UPDATE,
        Private.inventory:GetInventoryString())
    end
  end
end)
addon:RegisterEvent("PARTY_LEADER_CHANGED", "MAIN.LUA", function(_, event)
  if event == "PARTY_LEADER_CHANGED" and Private.loaded == true then
    Private.UI.Rerender()
  end
end)
addon:RegisterEvent("ROLE_CHANGED_INFORM", "MAIN.LUA", function(_, event)
  if event == "ROLE_CHANGED_INFORM" and Private.loaded == true then
    Private.UI.Rerender()
  end
end)

Private.communication:RegisterMessageHandler(Private.communication.messageTypes.LOGON,
  function(sender)
    if (sender == UnitName("player")) then return end
    addon:devPrint("received LOGON message from " .. sender)

    Private.communication.SendMessage(Private.communication.messageTypes.UPDATE,
      Private.inventory:GetInventoryString())
  end)

Private.communication:RegisterMessageHandler(Private.communication.messageTypes.UPDATE,
  function(sender, _, data)
    addon:devPrint("received UPDATE message from " .. sender)
    if (sender == UnitName("player") and not addon:isDev()) then return end
    Private.inventory:LoadString(sender, data)

    if (Private.UI.Frame:IsShown()) then
      Private.UI.Rerender()
    end
  end)

local onOffArgs = {
  ["on"] = true,
  ["enable"] = true,
  ["off"] = false,
  ["disable"] = false,
}

local function isOnOff(arg)
  return arg and onOffArgs[arg] ~= nil
end

addon:RegisterCommand({ "keystonecompanion", "kc" }, function(self, args)
  ---@cast self KeystoneCompanion
  if #args == 0 then
    self:ToggleUI()
  end
  local enabled = self.colorise(styles.COLORS.GREEN_LIGHT, loc["enabled"])
  local disabled = self.colorise(styles.COLORS.RED_LIGHT, loc["disabled"])

  if args[1] == "error" then
    error("Test Error")
  elseif args[1] == "dev" then
    if args[2] and isOnOff(args[3]) then
      local state = onOffArgs[args[3]]
      local cmdType = loc["Developer " .. args[2]]
      if args[2] == "mode" then
        self:ToggleDevMode(state)
      elseif args[2] == "chat" then
        self:ToggleDevChat(state)
      end
      self:FPrint("%s %s", cmdType, (state and enabled or disabled))
      return
    end
    self:Print("/kc dev [mode|chat] [enable|on|disable|off]")
  elseif (args[1] == "minimap") then
    if isOnOff(args[2]) then
      local state = onOffArgs[args[2]]
      local minimapBtn = loc["Minimap button"]
      self:ToggleMinimapButton(state)
      self:FPrint("%s %s", minimapBtn, (state and enabled or disabled))
      return
    end
    self:Print("/kc minimap [enable|on|disable|off]")
  end
end)

if (addon.buildType == "alpha") then
  addon:Print(loc["You're running an"] ..
    addon.colorise("ff0000", " Alpha ") ..
    loc["build of the addon. Features may be broken or only half finished in alpha versions!"])
elseif (addon.buildType == "alpha") then
  addon:Print(loc["You're running an"] ..
    addon.colorise("ddca2e", " Beta ") ..
    loc
    ["version of the addon. Thank you for helping test, and please report any issues on the Github so they can be fixed before release. :)"])
end

addon:Print(loc["type"] ..
  addon.colorise("ddca2e", " /kc ") .. loc["to open the KeystoneCompanion UI, or click the minimap button."])
