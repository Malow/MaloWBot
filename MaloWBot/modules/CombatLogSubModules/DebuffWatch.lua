mb_CombatLogModule_DebuffWatch_spellNames = {}
mb_CombatLogModule_DebuffWatch_enabled = false
function mb_CombatLogModule_DebuffWatch_RegisterSpell(spellName)
    for k, v in pairs(mb_CombatLogModule_DebuffWatch_spellNames) do
        if v == spellName then
            return
        end
    end
    table.insert(mb_CombatLogModule_DebuffWatch_spellNames, spellName)
    if not mb_CombatLogModule_DebuffWatch_enabled then
        mb_CombatLogModule_DebuffWatch_enabled = true
        mb_CombatLogModule_AddCallback("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", mb_CombatLogModule_DebuffWatch_OnEvent)
        mb_CombatLogModule_AddCallback("PLAYER_REGEN_DISABLED", mb_CombatLogModule_DebuffWatch_ResetLog)
    end
end

mb_CombatLogModule_DebuffWatch_log = {}
function mb_CombatLogModule_DebuffWatch_OnEvent(arg1)
    for k, v in pairs(mb_CombatLogModule_DebuffWatch_spellNames) do
        if string.find(arg1, "You are afflicted by " .. v) then
            mb_CombatLogModule_DebuffWatch_log[v] = mb_GetTime()
        end
    end
end

function mb_CombatLogModule_DebuffWatch_ResetLog()
    mb_CombatLogModule_DebuffWatch_log = {}
end

function mb_CombatLogModule_DebuffWatch_HasBeenAfflictedBy(spellName)
    if mb_CombatLogModule_DebuffWatch_log[spellName] == nil then
        return false
    end
    local has = mb_CombatLogModule_DebuffWatch_log[spellName] + 3 > mb_GetTime()
    mb_CombatLogModule_DebuffWatch_log[spellName] = nil
    return has
end