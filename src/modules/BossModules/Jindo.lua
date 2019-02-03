DEBUFF_TEXTURE_JINDO_CURSE = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy"

function mb_BossModule_Jindo_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_Jindo_Unload
    mb_currentBossModule.hunterLogic = mb_BossModule_Jindo_HunterLogic
    mb_currentBossModule.mageLogic = mb_BossModule_Jindo_MageLogic
    mb_currentBossModule.rogueLogic = mb_BossModule_Jindo_RogueLogic
    mb_currentBossModule.warlockLogic = mb_BossModule_Jindo_WarlockLogic
    mb_currentBossModule.warriorDpsLogic = mb_BossModule_Jindo_WarriorDpsLogic
    mb_rogueShouldUseCooldownsOnCooldown = false
    mb_shouldDecurse = false
    mb_MakeRequest("palaAura", "ret", REQUEST_PRIORITY.COMMAND)
end
mb_RegisterBossModule("jindo", mb_BossModule_Jindo_Load)

function mb_BossModule_Jindo_Unload()
    mb_rogueShouldUseCooldownsOnCooldown = true
    mb_shouldDecurse = true
end

function mb_BossModule_Jindo_HunterLogic()
    if max_HasDebuff("player", DEBUFF_TEXTURE_JINDO_CURSE) then
        if mb_BossModule_Jindo_TargetShade() then
            if not mb_isAutoAttacking then
                CastSpellByName("Attack")
            end
            return true
        end
    end
    return false
end

function mb_BossModule_Jindo_MageLogic()
    if max_HasDebuff("player", DEBUFF_TEXTURE_JINDO_CURSE) then
        if mb_BossModule_Jindo_TargetShade() then
            max_UseEquippedItemIfReady("Trinket0Slot")
            max_UseEquippedItemIfReady("Trinket1Slot")
            CastSpellByName("Arcane Explosion")
            return true
        end
    end
    return false
end

function mb_BossModule_Jindo_RogueLogic()
    if max_HasDebuff("player", DEBUFF_TEXTURE_JINDO_CURSE) then
        if mb_BossModule_Jindo_TargetShade() then
            if mb_Rogue_UseCooldowns() then
                return true
            end
            CastSpellByName("Sinister Strike")
            return true
        end
    end
    return false
end

function mb_BossModule_Jindo_WarlockLogic()
    if max_HasDebuff("player", DEBUFF_TEXTURE_JINDO_CURSE) then
        if mb_BossModule_Jindo_TargetShade() then
            max_UseEquippedItemIfReady("Trinket0Slot")
            max_UseEquippedItemIfReady("Trinket1Slot")
            CastSpellByName("Hellfire")
            return true
        end
    end
    return false
end

function mb_BossModule_Jindo_WarriorDpsLogic()
    if max_HasDebuff("player", DEBUFF_TEXTURE_JINDO_CURSE) then
        if mb_BossModule_Jindo_TargetShade() then
            if not mb_isAutoAttacking then
                CastSpellByName("Attack")
            end
            if max_GetManaPercentage("player") >= 60 then
                CastSpellByName("Cleave")
            end
            max_CastSpellIfReady("Whirlwind")
            return true
        end
    end
    return false
end

function mb_BossModule_Jindo_TargetShade()
    for i = 1, 10 do
        TargetNearestEnemy()
        if UnitName("target") == "Shade of Jin'do" then
            return true
        end
    end
    return false
end