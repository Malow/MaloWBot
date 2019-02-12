function mb_BossModule_Hakkar_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_Hakkar_Unload
    mb_currentBossModule.warriorTankLogic = mb_BossModule_Hakkar_WarriorTankLogic
    mb_shouldDepoison = false
    mb_warriorOffTanksShouldMaximizeTps = true
    if max_GetClass("player") == "PALADIN" then
        mb_Paladin_CastAura("conc")
    end
end
mb_RegisterBossModule("hakkar", mb_BossModule_Hakkar_Load)

function mb_BossModule_Hakkar_Unload()
    mb_shouldDepoison = true
    mb_warriorOffTanksShouldMaximizeTps = false
end

function mb_BossModule_Hakkar_WarriorTankLogic()
    return max_CastSpellIfReady("Intimidating Shout")
end