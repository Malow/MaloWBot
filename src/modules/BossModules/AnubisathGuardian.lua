function mb_BossModule_AnubisathGuardian_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_AnubisathGuardian_Unload
    mb_MoveOutModule_RegisterAutomaticFuckOffDebuffSpell("Plague Effect")
end
mb_RegisterBossModule("anubisathGuardian", mb_BossModule_AnubisathGuardian_Load)

function mb_BossModule_AnubisathGuardian_Unload()
    mb_MoveOutModule_Disable()
end
