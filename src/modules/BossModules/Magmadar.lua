function mb_BossModule_Magmadar_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_Magmadar_Unload
    mb_currentBossModule.priestLogic = mb_BossModule_Magmadar_PriestLogic
end

function mb_BossModule_Magmadar_Unload()
end

function mb_BossModule_Magmadar_PriestLogic()
    if not max_IsSpellNameOnCooldown("Fear Ward") then
        max_CastSpellOnRaidMember("Fear Ward", "player")
        return true
    end
    return false
end
