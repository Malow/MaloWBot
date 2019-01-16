function mb_BossModule_Hakkar_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_Hakkar_Unload
    mb_shouldDepoison = false
end

function mb_BossModule_Hakkar_Unload()
    mb_shouldDepoison = true
end