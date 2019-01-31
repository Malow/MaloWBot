function mb_BossModule_Razorgore_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_Razorgore_Unload
    mb_currentBossModule.druidLogic = mb_BossModule_Razorgore_DruidLogic
    mb_currentBossModule.mageLogic = mb_BossModule_Razorgore_MageLogic
    mb_currentBossModule.warlockLogic = mb_BossModule_Razorgore_WarlockLogic
    mb_currentBossModule.hunterLogic = mb_BossModule_Razorgore_HunterLogic
    mb_currentBossModule.paladinLogic = mb_BossModule_Razorgore_PaladinLogic
    mb_currentBossModule.rogueLogic = mb_BossModule_Razorgore_RogueLogic
    mb_currentBossModule.warriorTankLogic = mb_BossModule_Razorgore_WarriorTankLogic
    mb_currentBossModule.warriorDpsLogic = mb_BossModule_Razorgore_WarriorDpsLogic

    mb_shouldAutoTarget = true
    if mb_warriorIsTank then
        mb_shouldAutoTurnToFace = false
    end
    if max_GetClass("player") == "HUNTER" then
        mb_RemoveDesiredBuff(BUFF_BLESSING_OF_SALVATION)
    end
end
mb_RegisterBossModule("razorgore", mb_BossModule_Razorgore_Load)

function mb_BossModule_Razorgore_Unload()
    mb_shouldAutoTurnToFace = true
    mb_shouldAutoTarget = false
    if max_GetClass("player") == "HUNTER" then
        mb_AddDesiredBuff(BUFF_BLESSING_OF_SALVATION)
    end
end

function mb_BossModule_Razorgore_MageLogic()
    local dmgSpell = "Frostbolt"
    if mb_mageIsFire then
        dmgSpell = "Fireball"
    end
    mb_BossModule_Razorgore_AutoDPS(dmgSpell, mb_Mage_DpsTarget)
    return true
end

function mb_BossModule_Razorgore_WarlockLogic()
    mb_BossModule_Razorgore_AutoDPS("Shadow Bolt", mb_Warlock_DpsTarget)
    return true
end

function mb_BossModule_Razorgore_WarriorDpsLogic()
    mb_BossModule_Razorgore_AutoDPS("Sunder Armor", mb_Warrior_DpsTarget)
    return true
end

function mb_BossModule_Razorgore_RogueLogic()
    mb_BossModule_Razorgore_AutoDPS("Sinister Strike", mb_Rogue_DpsTarget)
    return true
end

function mb_BossModule_Razorgore_AutoDPS(rangeCheckSpell, dpsFunction)
    if mb_BossModule_Razorgore_TargetMob(rangeCheckSpell, "Blackwing Mage", "Grethok the Controller") then
        dpsFunction()
    elseif mb_BossModule_Razorgore_TargetAnyMobExcept(rangeCheckSpell, "Death Talon Dragonspawn") then
        dpsFunction()
    end
end

function mb_BossModule_Razorgore_HunterLogic()
    if max_HasBuffWithMultipleTextures("player", BUFF_BLESSING_OF_SALVATION.textures) then
        max_CancelBuff(BUFF_TEXTURE_BLESSING_OF_SALVATION)
        max_CancelBuff(BUFF_TEXTURE_GREATER_BLESSING_OF_SALVATION)
    end
    if mb_BossModule_Razorgore_TargetMob("Multi-Shot", "Blackwing Mage") then
        if max_CastSpellIfReady("Distracting Shot") then
            return true
        end
        if max_CastSpellIfReady("Arcane Shot") then
            return true
        end
    end
    return true
end

function mb_BossModule_Razorgore_DruidLogic()
    if mb_BossModule_Razorgore_TargetMob("Hibernate", "Death Talon Dragonspawn") then
        if not max_HasDebuff("target", DEBUFF_TEXTURE_HIBERNATE) and GetRaidTargetIndex("target") == nil then
            SetRaidTarget("target", mb_GetMyClassOrder())
            CastSpellByName("Hibernate")
            return true
        end
    end
    ClearTarget()
    return false
end

function mb_BossModule_Razorgore_WarriorTankLogic()
    if not max_IsSpellNameOnCooldown("Concussion Blow") then
        if mb_BossModule_Razorgore_TargetMob("Sunder Armor", "Blackwing Mage") then
            if not mb_IsTargetStunned() then
                CastSpellByName("Concussion Blow")
                return true
            end
        end
    end

    for i = 1, 5 do
        if UnitName("target") ~= "Death Talon Dragonspawn" and UnitExists("targettarget") then
            if mb_GetConfig()["specs"][UnitName("targettarget")] ~= "WarrTank" then
                return false
            end
        end
        TargetNearestEnemy()
    end

    if UnitName("target") == "Death Talon Dragonspawn" then
        ClearTarget()
        return true
    end
    return false
end

function mb_BossModule_Razorgore_PaladinLogic()
    if not max_IsSpellNameOnCooldown("Hammer of Justice") then
        if mb_BossModule_Razorgore_TargetMob("Hammer of Justice", "Blackwing Mage") then
            if not mb_IsTargetStunned() then
                CastSpellByName("Hammer of Justice")
                return true
            end
        end
    end
    return false
end

function mb_BossModule_Razorgore_TargetMob(rangeCheckSpell, mobName, mobName2)
    for i = 1, 5 do
        TargetNearestEnemy()
        if max_HasValidOffensiveTarget(rangeCheckSpell) then
            local unitName = UnitName("target")
            if unitName ~= nil and (unitName == mobName or unitName == mobName2) then
                return true
            end
        end
    end
    ClearTarget()
    return false
end

function mb_BossModule_Razorgore_TargetAnyMobExcept(rangeCheckSpell, mobName)
    for i = 1, 5 do
        TargetNearestEnemy()
        if max_HasValidOffensiveTarget(rangeCheckSpell) then
            if UnitName("target") ~= mobName then
                return true
            end
        end
    end
    ClearTarget()
    return false
end