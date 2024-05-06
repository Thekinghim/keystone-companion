local _, Private = ...
local addon = Private.Addon
addon.dev = {};

function addon.dev.CloneInventory(from, to)
  Private.inventory[to] = Private.inventory[from];
  Private.UI.Rerender();
end

function addon:devPrint(...)
  if (self:isDev()) then
    self:Print("|cffff0000(Dev) |r", ...)
    if EventTrace then
      EventTrace:LogEvent(self.Name, ...)
    end

    if KeystoneCompanionDebug then
      if not KeystoneCompanionDebug.messages then KeystoneCompanionDebug.messages = {} end
      tinsert(KeystoneCompanionDebug.messages, { time = time(), entry = { ... } })
    end
  end
end
