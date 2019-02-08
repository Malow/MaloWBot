function mb_CombatLogModule_SelfMissWatch_Enable()
    mb_CombatLogModule_AddCallback("CHAT_MSG_COMBAT_SELF_MISSES", mb_CombatLogModule_SelfMissWatch_OnSelfMissEvent)
    mb_CombatLogModule_AddCallback("CHAT_MSG_SPELL_SELF_DAMAGE", mb_CombatLogModule_SelfMissWatch_OnSpellSelfDamageEvent)
end

mb_CombatLogModule_SelfMissWatch_lastDodgedAttackTime = 0
function mb_CombatLogModule_SelfMissWatch_OnSelfMissEvent(arg1)
    if string.find(arg1, "dodges") then
        mb_CombatLogModule_SelfMissWatch_lastDodgedAttackTime = mb_GetTime()
    end
end

function mb_CombatLogModule_SelfMissWatch_OnSpellSelfDamageEvent(arg1)
    if string.find(arg1, "dodged") then
        mb_CombatLogModule_SelfMissWatch_lastDodgedAttackTime = mb_GetTime()
    end
end

function mb_CombatLogModule_SelfMissWatch_GetLastDodgedAttackTime()
    return mb_CombatLogModule_SelfMissWatch_lastDodgedAttackTime
end