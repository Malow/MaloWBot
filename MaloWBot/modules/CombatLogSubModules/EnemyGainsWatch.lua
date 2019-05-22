
function mb_CombatLogModule_EnemyGainsWatch_Enable()
    mb_CombatLogModule_AddCallback("CHAT_MSG_SPELL_CREATURE_VS_SELF_BUFF", mb_CombatLogModule_EnemyGainsWatch_OnEvent)
    mb_CombatLogModule_AddCallback("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", mb_CombatLogModule_EnemyGainsWatch_OnEvent)
    mb_CombatLogModule_AddCallback("PLAYER_REGEN_DISABLED", mb_CombatLogModule_EnemyGainsWatch_Reset)
end

mb_CombatLogModule_EnemyGainsWatch_log = {}
function mb_CombatLogModule_EnemyGainsWatch_OnEvent()
    local unitName, spellName = mb_CombatLogModule_ExtractGainsNames(arg1)
    if unitName ~= nil and spellName ~= nil then
        if mb_CombatLogModule_EnemyGainsWatch_log[unitName] == nil then
            mb_CombatLogModule_EnemyGainsWatch_log[unitName] = {}
        end
        mb_CombatLogModule_EnemyGainsWatch_log[unitName][spellName] = mb_GetTime()
    end
end

function mb_CombatLogModule_EnemyGainsWatch_Reset()
    mb_CombatLogModule_EnemyGainsWatch_log = {}
end

function mb_CombatLogModule_EnemyGainsWatch_HasGained(unitName, spellName)
    if mb_CombatLogModule_EnemyGainsWatch_log[unitName] ~= nil then
        if mb_CombatLogModule_EnemyGainsWatch_log[unitName][spellName] ~= nil then
            if mb_CombatLogModule_EnemyGainsWatch_log[unitName][spellName] + 3 > mb_GetTime() then
                mb_CombatLogModule_EnemyGainsWatch_log[unitName][spellName] = nil
                return true
            end
        end
    end
    return false
end
