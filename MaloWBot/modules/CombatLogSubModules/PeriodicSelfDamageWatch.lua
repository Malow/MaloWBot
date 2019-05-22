
mb_CombatLogModule_PeriodicSelfDamageWatch_enabled = false
mb_CombatLogModule_PeriodicSelfDamageWatch_spellNames = {}

function mb_CombatLogModule_PeriodicSelfDamageWatch_RegisterSpell(spellName)
    for k, v in pairs(mb_CombatLogModule_PeriodicSelfDamageWatch_spellNames) do
        if v == spellName then
            return
        end
    end
    table.insert(mb_CombatLogModule_PeriodicSelfDamageWatch_spellNames, spellName)
    if not mb_CombatLogModule_PeriodicSelfDamageWatch_enabled then
        mb_CombatLogModule_PeriodicSelfDamageWatch_enabled = true
        mb_CombatLogModule_AddCallback("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", mb_CombatLogModule_PeriodicSelfDamageWatch_OnEvent)
        mb_CombatLogModule_AddCallback("PLAYER_REGEN_DISABLED", mb_CombatLogModule_PeriodicSelfDamageWatch_Reset)
    end
end

mb_CombatLogModule_PeriodicSelfDamageWatch_log = {}
function mb_CombatLogModule_PeriodicSelfDamageWatch_OnEvent(arg1)
    for k, v in pairs(mb_CombatLogModule_PeriodicSelfDamageWatch_spellNames) do
        if string.find(arg1, v) then
            mb_CombatLogModule_PeriodicSelfDamageWatch_log[v] = mb_GetTime()
        end
    end
end

function mb_CombatLogModule_PeriodicSelfDamageWatch_Reset()
    mb_CombatLogModule_PeriodicSelfDamageWatch_log = {}
end

function mb_CombatLogModule_PeriodicSelfDamageWatch_HasTakenDamageFrom(spellName)
    if mb_CombatLogModule_PeriodicSelfDamageWatch_log[spellName] == nil then
        return false
    end
    local has = mb_CombatLogModule_PeriodicSelfDamageWatch_log[spellName] + 3 > mb_GetTime()
    mb_CombatLogModule_PeriodicSelfDamageWatch_log[spellName] = nil
    return has
end