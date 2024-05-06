local _, Private = ...
Private.dev = {};

function Private.dev.CloneInventory(from, to)
  Private.inventory[to] = Private.inventory[from];
  Private.UI.Rerender();
end

function Private.dev.print(...)
  if (Private.Addon:isDev()) then
    print('|cffddca2eKeystoneCompanion|r|cffff0000Dev|r: ' .. ...)
  end
end
