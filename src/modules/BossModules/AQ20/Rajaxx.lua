DEBUFF_TEXTURE_RAJAXX_THUNDERCLAP = "Interface\\Icons\\Spell_Nature_ThunderClap"

function mb_BossModule_Rajaxx_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_Rajaxx_Unload
    mb_currentBossModule.hunterLogic = mb_BossModule_Rajaxx_HunterLogic
    mb_currentBossModule.priestLogic = mb_BossModule_Rajaxx_PriestLogic
    mb_currentBossModule.paladinLogic = mb_BossModule_Rajaxx_PaladinLogic
    mb_shouldDispel = false
    if max_GetClass("player") == "PALADIN" then
        mb_Paladin_CastAura("devo")
    end
end
mb_RegisterBossModule("rajaxx", mb_BossModule_Rajaxx_Load)

function mb_BossModule_Rajaxx_Unload()
    mb_shouldDispel = true
end

function mb_BossModule_Rajaxx_HunterLogic()
    if max_CastSpellIfReady("Feign Death") and not max_HasBuff("player", BUFF_TEXTURE_FEIGN_DEATH) then
        return true
    end
    if not mb_IsInCombat() then
        if max_CastSpellIfReady("Frost Trap") then
            return true
        end
    end
    return false
end

function mb_BossModule_Rajaxx_PriestLogic()
    local unitFilter = UNIT_FILTER_DOES_NOT_HAVE_DEBUFF
    unitFilter.debuff = DEBUFF_TEXTURE_RAJAXX_THUNDERCLAP
    if mb_CleanseRaidMemberThrottled("Dispel Magic", "Magic", nil, nil, unitFilter, true) then
        return true
    end
    return false
end

function mb_BossModule_Rajaxx_PaladinLogic()
    local unitFilter = UNIT_FILTER_DOES_NOT_HAVE_DEBUFF
    unitFilter.debuff = DEBUFF_TEXTURE_RAJAXX_THUNDERCLAP
    if mb_CleanseRaidMemberThrottled("Cleanse", "Magic", "Poison", "Disease", unitFilter, true) then
        return true
    end
    return false
end