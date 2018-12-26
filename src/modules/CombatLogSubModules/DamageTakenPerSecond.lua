
function mb_CombatLogModule_DamageTakenPerSecond_Enable()
    mb_CombatLogModule_AddCallback("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", mb_CombatLogModule_DamageTakenPerSecond_OnEvent)
    mb_CombatLogModule_AddCallback("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", mb_CombatLogModule_DamageTakenPerSecond_OnEvent)
    mb_CombatLogModule_AddCallback("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS", mb_CombatLogModule_DamageTakenPerSecond_OnEvent)
    mb_CombatLogModule_AddCallback("PLAYER_REGEN_DISABLED", mb_CombatLogModule_DamageTakenPerSecond_Reset)
end

mb_CombatLogModule_DamageTakenPerSecond_log = {}
function mb_CombatLogModule_DamageTakenPerSecond_OnEvent(arg1)
    mb_CombatLogModule_DamageTakenPerSecond_log[GetTime()] = mb_CombatLogModule_ExtractDamage(arg1)
end

function mb_CombatLogModule_DamageTakenPerSecond_Reset()
    mb_CombatLogModule_DamageTakenPerSecond_log = {}
end

function mb_CombatLogModule_DamageTakenPerSecond_GetDTPS(averageOverPastSeconds)
    local damageTaken = 0
    local now = GetTime()
    for k, v in pairs(mb_CombatLogModule_DamageTakenPerSecond_log) do
        if k > now - averageOverPastSeconds then
            damageTaken = damageTaken + v
        end
    end
    return damageTaken / averageOverPastSeconds
end