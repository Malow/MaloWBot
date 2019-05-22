DEBUFF_TEXTURE_KAZZAK_THUNDERCLAP = "Interface\\Icons\\Spell_Nature_ThunderClap"

function mb_BossModule_Kazzak_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_Kazzak_Unload
    mb_currentBossModule.priestLogic = mb_BossModule_Kazzak_PriestLogic
    mb_currentBossModule.paladinLogic = mb_BossModule_Kazzak_PaladinLogic
    mb_shouldDispel = false
    if max_GetClass("player") == "PALADIN" then
        mb_Paladin_CastAura("conc")
    end
end
mb_RegisterBossModule("kazzak", mb_BossModule_Kazzak_Load)

function mb_BossModule_Kazzak_Unload()
    mb_shouldDispel = true
end

function mb_BossModule_Kazzak_PriestLogic()
    local unitFilter = UNIT_FILTER_DOES_NOT_HAVE_DEBUFF
    unitFilter.debuff = DEBUFF_TEXTURE_KAZZAK_THUNDERCLAP
    if mb_CleanseRaidMemberThrottled("Dispel Magic", "Magic", nil, nil, unitFilter, true) then
        return true
    end
    return false
end

function mb_BossModule_Kazzak_PaladinLogic()
    local unitFilter = UNIT_FILTER_DOES_NOT_HAVE_DEBUFF
    unitFilter.debuff = DEBUFF_TEXTURE_KAZZAK_THUNDERCLAP
    if mb_CleanseRaidMemberThrottled("Cleanse", "Magic", "Poison", "Disease", unitFilter, true) then
        return true
    end
    return false
end