function mb_BossModule_Rajaxx_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_Rajaxx_Unload
    mb_currentBossModule.hunterLogic = mb_BossModule_Rajaxx_HunterLogic
end
mb_RegisterBossModule("rajaxx", mb_BossModule_Rajaxx_Load)

function mb_BossModule_Rajaxx_Unload()
end

function mb_BossModule_Rajaxx_HunterLogic()
    if max_CastSpellIfReady("Feign Death") then
        return true
    end
    if max_HasBuff("player", BUFF_TEXTURE_FEIGN_DEATH) then
        if max_CastSpellIfReady("Frost Trap") then
            return true
        end
    end
    return false
end