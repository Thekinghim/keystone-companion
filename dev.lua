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
  end
end
