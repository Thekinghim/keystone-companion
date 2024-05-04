local f = CreateFrame("Frame")
f:RegisterEvent("CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN")
f:SetScript("OnEvent", function()
   for bagIndex = 0, NUM_BAG_SLOTS do
      for slotIndex = 1, C_Container.GetContainerNumSlots(bagIndex) do
         local itemID = C_Container.GetContainerItemID(bagIndex, slotIndex)
         if itemID and itemID == 180653 then
            local item = ItemLocation:CreateFromBagAndSlot(bagIndex, slotIndex)
            if C_ChallengeMode.CanUseKeystoneInCurrentMap(item) then
               C_Container.PickupContainerItem(bagIndex, slotIndex)
               C_Timer.After(0.1, function()
                  C_ChallengeMode.SlotKeystone()
               end)
               break
            end
         end
      end
   end
end)
