
function mb_CombatLogModule_FriendlyGainsWatch_Enable()
    mb_CombatLogModule_AddCallback("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS", mb_CombatLogModule_FriendlyGainsWatch_OnEvent)
    mb_CombatLogModule_AddCallback("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS", mb_CombatLogModule_FriendlyGainsWatch_OnEvent)
end

function mb_CombatLogModule_FriendlyGainsWatch_OnEvent()
    local spellName = mb_CombatLogModule_ExtractGainsSpellName(arg1)
    if spellName ~= nil then
        -- Maybe do something in the future
    end
end
