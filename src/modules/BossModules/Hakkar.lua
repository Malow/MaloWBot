function mb_BossModule_Hakkar_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_Hakkar_Unload
    mb_currentBossModule.warriorTankLogic = mb_BossModule_Hakkar_WarriorTankLogic
    mb_shouldDepoison = false
end
mb_RegisterBossModule("hakkar", mb_BossModule_Hakkar_Load)

function mb_BossModule_Hakkar_Unload()
    mb_shouldDepoison = true
end

function mb_BossModule_Hakkar_WarriorTankLogic()
    return max_CastSpellIfReady("Intimidating Shout")
end