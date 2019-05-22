function mb_BossModule_Onyxia_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_Onyxia_Unload
    mb_warriorOffTanksShouldMaximizeTps = true
    if max_GetClass("player") == "PALADIN" then
        mb_Paladin_CastAura("fire")
    end
end
mb_RegisterBossModule("onyxia", mb_BossModule_Onyxia_Load)

function mb_BossModule_Onyxia_Unload()
    mb_warriorOffTanksShouldMaximizeTps = false
end