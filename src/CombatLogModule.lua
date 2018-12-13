local f = CreateFrame("frame", "MaloWBotCombatLogModuleFrame", UIParent)
f:Show()

function mb_CombatLogModule_OnEvent()

end

f:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS")
f:SetScript("OnEvent", mb_CombatLogModule_OnEvent)