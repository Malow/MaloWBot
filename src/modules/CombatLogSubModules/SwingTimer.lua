function mb_CombatLogModule_SwingTimer_EnableAutoShot()
    mb_CombatLogModule_AddCallback("BAG_UPDATE", mb_CombatLogModule_SwingTimer_AutoShot_OnEvent)
end

mb_CombatLogModule_SwingTimer_lastAutoShotTime = 0
function mb_CombatLogModule_SwingTimer_AutoShot_OnEvent(arg1)
    if arg1 == 4 then
        mb_CombatLogModule_SwingTimer_lastAutoShotTime = GetTime()
    end
end

function mb_CombatLogModule_SwingTimer_GetLastAutoShotTime()
    return mb_CombatLogModule_SwingTimer_lastAutoShotTime
end