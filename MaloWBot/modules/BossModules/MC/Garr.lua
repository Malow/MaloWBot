function mb_BossModule_Garr_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_Garr_Unload
    mb_shouldDispel = false
end
mb_RegisterBossModule("garr", mb_BossModule_Garr_Load)

function mb_BossModule_Garr_Unload()
    mb_shouldDispel = true
end
