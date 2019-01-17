function mb_BossModule_Garr_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_Garr_Unload
    mb_shouldDispel = false
end

function mb_BossModule_Garr_Unload()
    mb_shouldDispel = true
end
