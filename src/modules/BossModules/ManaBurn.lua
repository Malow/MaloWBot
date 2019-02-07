function mb_BossModule_ManaBurn_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_ManaBurn_Unload
    mb_currentBossModule.hunterLogic = mb_BossModule_ManaBurn_HunterLogic
    mb_currentBossModule.warlockLogic = mb_BossModule_ManaBurn_WarlockLogic
    mb_currentBossModule.priestLogic = mb_BossModule_ManaBurn_PriestLogic
end
mb_RegisterBossModule("manaBurn", mb_BossModule_ManaBurn_Load)

function mb_BossModule_ManaBurn_Unload()
end

function mb_BossModule_ManaBurn_HunterLogic()
    if UnitMana("target") > 1000 then
        if not max_HasDebuff("target", DEBUFF_TEXTURE_VIPER_STING) then
            CastSpellByName("Viper Sting")
            return true
        end
    end
    return false
end

function mb_BossModule_ManaBurn_WarlockLogic()
    if not mb_IsSpellInRangeOnEnemy("Drain Mana", "target") then
        return false
    end
    if UnitMana("target") > 2000 then
        CastSpellByName("Drain Mana")
        return true
    end
    return false
end

function mb_BossModule_ManaBurn_PriestLogic()
    if not mb_AcquireOffensiveTarget("Mana Burn") then
        return false
    end
    if UnitMana("target") > 3000 then
        CastSpellByName("Mana Burn")
        return true
    end
    return false
end


