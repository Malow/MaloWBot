DEBUFF_TEXTURE_MANDOKIR_WATCH = "Interface\\Icons\\Spell_Shadow_Charm"

function mb_BossModule_Mandokir_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_Mandokir_Unload
    mb_currentBossModule.preRun = mb_BossModule_Mandokir_PreRun
end

function mb_BossModule_Mandokir_Unload()

end

function mb_BossModule_Mandokir_PreRun()
    if max_HasDebuff("player", DEBUFF_TEXTURE_MANDOKIR_WATCH) then
        SpellStopCasting()
        TargetUnit("player")
        return true
    end
    return false
end