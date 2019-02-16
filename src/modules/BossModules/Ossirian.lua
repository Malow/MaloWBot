function mb_BossModule_Ossirian_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_Ossirian_Unload
    mb_HealingModule_overhealCoef = 0.3
end
mb_RegisterBossModule("ossirian", mb_BossModule_Ossirian_Load)

function mb_BossModule_Ossirian_Unload()
    mb_HealingModule_overhealCoef = 1.0
end
