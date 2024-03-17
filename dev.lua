KeystoneCompanion.dev = {};

function KeystoneCompanion.dev:LogonTest()
  KeystoneCompanion.communication.SendPartyMessage("LOGON", "");
end

function KeystoneCompanion.dev:SendInventory()
  
end

function KeystoneCompanion.dev.print(...) 
  if(KeystoneCompanion.isDev()) then
    print('|cffddca2eKeystoneCompanion|r|cffff0000Dev|r: ' .. ...)
  end
end