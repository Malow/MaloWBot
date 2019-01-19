function mb_BossModule_Magmadar_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_Magmadar_Unload
    mb_currentBossModule.priestLogic = mb_BossModule_Magmadar_PriestLogic
    mb_shouldDispel = false
    mb_warriorShouldAutomaticallyTaunt = false
end
mb_RegisterBossModule("magmadar", mb_BossModule_Magmadar_Load)

function mb_BossModule_Magmadar_Unload()
    mb_shouldDispel = true
    mb_warriorShouldAutomaticallyTaunt = true
end

function mb_BossModule_Magmadar_PriestLogic()
    if not max_IsSpellNameOnCooldown("Fear Ward") and not max_HasBuff("player", BUFF_TEXTURE_FEAR_WARD) then
        max_CastSpellOnRaidMember("Fear Ward", "player")
        return true
    end
    return false
end
