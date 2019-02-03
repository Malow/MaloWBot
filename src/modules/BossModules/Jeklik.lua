function mb_BossModule_Jeklik_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_Jeklik_Unload
    if max_GetClass("player") == "PALADIN" then
        mb_Paladin_CastAura("fire")
    end
end
mb_RegisterBossModule("jeklik", mb_BossModule_Jeklik_Load)

function mb_BossModule_Jeklik_Unload()
end
