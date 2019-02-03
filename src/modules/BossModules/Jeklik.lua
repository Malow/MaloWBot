function mb_BossModule_Jeklik_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_Jeklik_Unload
    mb_MakeRequest("palaAura", "fire", REQUEST_PRIORITY.COMMAND)
end
mb_RegisterBossModule("jeklik", mb_BossModule_Jeklik_Load)

function mb_BossModule_Jeklik_Unload()
end
