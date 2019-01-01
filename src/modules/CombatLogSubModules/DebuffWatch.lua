mb_CombatLogModule_DebuffWatch_spellNames = nil
function mb_CombatLogModule_DebuffWatch_Enable(spellNames)
    mb_CombatLogModule_DebuffWatch_spellNames = spellNames
    mb_CombatLogModule_AddCallback("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", mb_CombatLogModule_DebuffWatch_OnEvent)
    mb_CombatLogModule_AddCallback("PLAYER_REGEN_DISABLED", mb_CombatLogModule_DebuffWatch_Reset)
end

mb_CombatLogModule_DebuffWatch_log = {}
function mb_CombatLogModule_DebuffWatch_OnEvent(arg1)
    for k, v in pairs(mb_CombatLogModule_DebuffWatch_spellNames) do
        if string.find(arg1, "You are afflicted by " .. v) then
            mb_CombatLogModule_DebuffWatch_log[v] = GetTime()
        end
    end
end

function mb_CombatLogModule_DebuffWatch_Reset()
    mb_CombatLogModule_DebuffWatch_log = {}
end

function mb_CombatLogModule_DebuffWatch_ResetForSpellName(spellName)
    mb_CombatLogModule_DebuffWatch_log[spellName] = nil
end

function mb_CombatLogModule_DebuffWatch_GetTimeForSpellName(spellName)
    return mb_CombatLogModule_DebuffWatch_log[spellName]
end