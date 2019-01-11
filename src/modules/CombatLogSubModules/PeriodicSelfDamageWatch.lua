mb_CombatLogModule_PeriodicSelfDamageWatch_spellNames = nil
function mb_CombatLogModule_PeriodicSelfDamageWatch_Enable(spellNames)
    mb_CombatLogModule_PeriodicSelfDamageWatch_spellNames = spellNames
    mb_CombatLogModule_AddCallback("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", mb_CombatLogModule_PeriodicSelfDamageWatch_OnEvent)
    mb_CombatLogModule_AddCallback("PLAYER_REGEN_DISABLED", mb_CombatLogModule_PeriodicSelfDamageWatch_Reset)
end

mb_CombatLogModule_PeriodicSelfDamageWatch_log = {}
function mb_CombatLogModule_PeriodicSelfDamageWatch_OnEvent(arg1)
    for k, v in pairs(mb_CombatLogModule_PeriodicSelfDamageWatch_spellNames) do
        if string.find(arg1, v) then
            mb_CombatLogModule_PeriodicSelfDamageWatch_log[mb_GetTime()] = v
        end
    end
end

function mb_CombatLogModule_PeriodicSelfDamageWatch_Reset()
    mb_CombatLogModule_PeriodicSelfDamageWatch_log = {}
end

function mb_CombatLogModule_PeriodicSelfDamageWatch_HasTakenWatchedDamageIn(timeWindow)
    for k, v in pairs(mb_CombatLogModule_PeriodicSelfDamageWatch_log) do
        if k > mb_GetTime() - timeWindow then
            return true
        end
    end
    return false
end