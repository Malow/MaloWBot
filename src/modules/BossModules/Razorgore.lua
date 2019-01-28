function mb_BossModule_Razorgore_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_Razorgore_Unload
    mb_currentBossModule.hunterLogic = mb_BossModule_Razorgore_HunterLogic
end
mb_RegisterBossModule("Razorgore", mb_BossModule_Razorgore_Load)

function mb_BossModule_Razorgore_Unload()

end

function mb_BossModule_Razorgore_HunterLogic()
    if max_CastSpellIfReady("Feign Death") then
        return true
    end
    if max_CastSpellIfReady("Frost Trap") then
        return true
    end
end