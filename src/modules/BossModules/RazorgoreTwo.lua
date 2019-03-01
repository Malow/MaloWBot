function mb_BossModule_RazorgoreTwo_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_RazorgoreTwo_Unload
    mb_currentBossModule.druidLogic = mb_BossModule_RazorgoreTwo_DruidLogic
    mb_currentBossModule.mageLogic = mb_BossModule_RazorgoreTwo_MageLogic
    mb_currentBossModule.warlockLogic = mb_BossModule_RazorgoreTwo_WarlockLogic
    mb_currentBossModule.hunterLogic = mb_BossModule_RazorgoreTwo_HunterLogic
    mb_currentBossModule.paladinLogic = mb_BossModule_RazorgoreTwo_PaladinLogic
    mb_currentBossModule.rogueLogic = mb_BossModule_RazorgoreTwo_RogueLogic
    mb_currentBossModule.warriorTankLogic = mb_BossModule_RazorgoreTwo_WarriorTankLogic
    mb_currentBossModule.warriorDpsLogic = mb_BossModule_RazorgoreTwo_WarriorDpsLogic
end

mb_RegisterBossModule("razorgoreTwo", mb_BossModule_RazorgoreTwo_Load)

function mb_BossModule_RazorgoreTwo_RogueLogic()
    if mb_BossModule_Razorgore_TargetMob("Sinister Strike", "Blackwing Mage", "Blackwing Legionnaire") then
        if GetComboPoints() == 1 and not max_HasDebuff("target", DEBUFF_TEXTURE_KIDNEYSHOT) then
            CastSpellByName("Kidney Shot")
            return
        end
    end
end

function mb_BossModule_RazorgoreTwo_MageLogic()
    local dmgSpell = "Frostbolt"
    if mb_mageIsFire then
        dmgSpell = "Fireball"
    end
    mb_BossModule_Razorgore_AutoDPS(dmgSpell, mb_Mage_DpsTarget)
    return true
end

function mb_BossModule_RazorgoreTwo_HunterLogic()
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

function mb_BossModule_RazorgoreTwo_warriorTankLogic()
    if not max_IsSpellNameOnCooldown("Concussion Blow") then
        if max_GetManaPercentage("player")>= 15 and not max_HasDebuff("target", DEBUFF_TEXTURE_CONCUSSION_BLOW) then
            CastSpellByName("Concussion Blow")
            return
        end
    end
end