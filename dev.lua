KeystoneCompanion.dev = {};

function KeystoneCompanion.dev.CloneInventory(from, to)
  KeystoneCompanion.inventory[to] = KeystoneCompanion.inventory[from];
  KeystoneCompanion.UI.Rerender();
end

function KeystoneCompanion.dev.print(...) 
  if(KeystoneCompanion.isDev()) then
    print('|cffddca2eKeystoneCompanion|r|cffff0000Dev|r: ' .. ...)
  end
end