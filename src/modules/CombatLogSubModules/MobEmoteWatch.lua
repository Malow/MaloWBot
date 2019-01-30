
function mb_CombatLogModule_MobEmoteWatch_Enable()
    mb_CombatLogModule_AddCallback("CHAT_MSG_MONSTER_EMOTE", mb_CombatLogModule_MobEmoteWatch_OnEvent)
    mb_CombatLogModule_AddCallback("PLAYER_REGEN_DISABLED", mb_CombatLogModule_MobEmoteWatch_Reset)
end

mb_CombatLogModule_MobEmoteWatch_log = {}
function mb_CombatLogModule_MobEmoteWatch_OnEvent()
    mb_CombatLogModule_MobEmoteWatch_log[arg1] = mb_GetTime()
end

function mb_CombatLogModule_MobEmoteWatch_Reset()
    mb_CombatLogModule_MobEmoteWatch_log = {}
end

function mb_CombatLogModule_MobEmoteWatch_HasEmoted(unitName, partialEmoteText)
    for k, v in pairs(mb_CombatLogModule_MobEmoteWatch_log) do
        if string.find(k, unitName) and string.find(k, partialEmoteText) then
            mb_CombatLogModule_MobEmoteWatch_log[k] = nil
            return true
        end
    end
    return false
end
