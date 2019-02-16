
mb_warriorIsTank = false
mb_warriorMainHandTemporaryWeaponEnchant = nil
mb_warriorOffHandTemporaryWeaponEnchant = nil
mb_warriorShouldBerserkerRageNow = false
mb_warriorShouldAutomaticallyTaunt = true
mb_warriorOffTanksShouldMaximizeTps = false

function mb_Warrior(commander)
    if mb_warriorShouldBerserkerRageNow then
        if not max_IsSpellNameOnCooldown("Berserker Rage") then
            if max_GetActiveStance() ~= 3 then
                CastSpellByName("Berserker Stance")
                return
            end
            CastSpellByName("Berserker Rage")
            mb_warriorShouldBerserkerRageNow = false
            return
        end
    end
    if not mb_IsInCombat() then
        if mb_shouldRequestBuffs and mb_consumablesLevel > 0 then
            if mb_ApplyTemporaryWeaponEnchantsThrottled(mb_warriorMainHandTemporaryWeaponEnchant, mb_warriorOffHandTemporaryWeaponEnchant) then
                return
            end
        end
    end

    if mb_warriorIsTank then
        mb_Warrior_Tank()
        return
    end

    if max_GetActiveStance() ~= 3 then
        CastSpellByName("Berserker Stance")
    end

    if mb_IsInCombat() and max_GetHealthPercentage("player") > 80 and max_GetManaPercentage("player") < 30 then
        CastSpellByName("Bloodrage")
    end

    if mb_Warrior_BattleShout() then
        return
    end

    if mb_currentBossModule.warriorDpsLogic ~= nil then
        if mb_currentBossModule.warriorDpsLogic() then
            return
        end
    end

    if not mb_AcquireOffensiveTarget("Sunder Armor") then
        return
    end

    mb_Warrior_DpsTarget()
end

function mb_Warrior_DpsTarget()
    if not mb_isAutoAttacking then
        CastSpellByName("Attack")
    end

    if mb_Warrior_UseDpsCooldownsIfGood() then
        return
    end

    if not mb_areaOfEffectMode then
        if max_GetHealthPercentage("target") < 25 then
            CastSpellByName("Execute")
            return
        end

        if mb_Warrior_Overpower() then
            return
        end

        if not max_IsSpellNameOnCooldown("Bloodthirst") then
            if max_GetManaPercentage("player") >= 30 then
                CastSpellByName("Bloodthirst")
            end
            return
        end

        if CheckInteractDistance("target", 3) and not max_IsSpellNameOnCooldown("Whirlwind") then
            CastSpellByName("Whirlwind")
            return
        end

        if max_GetManaPercentage("player") >= 75 then
            CastSpellByName("Heroic Strike")
        end
    else
        if CheckInteractDistance("target", 3) and not max_IsSpellNameOnCooldown("Whirlwind") then
            CastSpellByName("Whirlwind")
            return
        end
        if max_GetManaPercentage("player") >= 60 then
            CastSpellByName("Cleave")
        end
    end
end

mb_warriorShouldOverpowerNow = false
function mb_Warrior_Overpower()
    if max_IsSpellNameOnCooldown("Overpower") then
        return false
    end

    if max_GetActiveStance() == 1 then
        CastSpellByName("Overpower")
        return true
    end

    if mb_GetMySpecName() ~= "Fury2H" then
        return false
    end

    if max_GetManaPercentage("player") > 30 then
        return false
    end

    if max_GetManaPercentage("player") < 5 then
        return false
    end

    local lastDodge = mb_CombatLogModule_SelfMissWatch_GetLastDodgedAttackTime()
    if lastDodge + 2 < mb_GetTime() then
        return false
    end

    if max_GetActiveStance() ~= 1 then
        CastSpellByName("Battle Stance")
        return true
    end
    return false
end

function mb_Warrior_UseDpsCooldownsIfGood()
    if max_GetDebuffStackCount("target", DEBUFF_TEXTURE_SUNDER_ARMOR) < 5 then
        return false
    end
    if not mb_IsSpellInRangeOnEnemy("Sunder Armor", "target") then
        return false
    end

    max_UseEquippedItemIfReady("Trinket0Slot")
    max_UseEquippedItemIfReady("Trinket1Slot")

    if max_CastSpellIfReady("Death Wish") then
        return true
    end

    if UnitClassification("target") == "worldboss" and max_GetHealthPercentage("target") < 22 then
        max_UseEquippedItemIfReady("LegsSlot")
        if max_CastSpellIfReady("Recklessness") then
            return true
        end
    end
end

mb_Warrior_lastTankingBroadcast = 0
mb_Warrior_lastSunder = 0
mb_Warrior_wasTankingLastFrame = false
function mb_Warrior_Tank()
    if not max_HasValidOffensiveTarget() then
        if not mb_AcquireOffensiveTarget("Sunder Armor") then
            return
        end
    end

    if mb_currentBossModule.warriorTankLogic ~= nil then
        if mb_currentBossModule.warriorTankLogic() then
            return
        end
    end

    if not mb_isAutoAttacking then
        CastSpellByName("Attack")
    end

    if mb_IsInCombat() and max_GetHealthPercentage("player") > 80 and max_GetManaPercentage("player") < 30 then
        CastSpellByName("Bloodrage")
    end

    if UnitExists("targettarget") then
        if mb_IsUnitTank("targettarget") then
            if UnitIsUnit("player", "targettarget") then
                mb_Warrior_wasTankingLastFrame = true
                mb_Warrior_RequestHoTs()
                if max_GetActiveStance() ~= 2 then
                    CastSpellByName("Defensive Stance")
                end
            else
                if mb_Warrior_wasTankingLastFrame then
                    mb_Warrior_lastTankingBroadcast = 0
                    mb_MakeRequest("tankingBroadcast", 0, REQUEST_PRIORITY.TANKING_BROADCAST)
                    mb_Warrior_wasTankingLastFrame = false
                end
                mb_Warrior_DpsTank()
                return
            end
        elseif mb_warriorShouldAutomaticallyTaunt or mb_Warrior_wasTankingLastFrame then
            if max_GetActiveStance() ~= 2 then
                CastSpellByName("Defensive Stance")
            end
            CastSpellByName("Taunt")
        end
    end

    if not mb_IsInCombat() then
        return
    end


    if mb_Warrior_lastTankingBroadcast + 5 < mb_GetTime() then
        mb_Warrior_lastTankingBroadcast = mb_GetTime()
        local dtps = mb_CombatLogModule_DamageTakenPerSecond_GetDTPS(10)
        dtps = dtps + 1 -- Making sure we're not sending 0 here because sending 0 means that you're not actually tanking anymore
        mb_MakeRequest("tankingBroadcast", dtps, REQUEST_PRIORITY.TANKING_BROADCAST)
    end

    if not max_IsSpellNameOnCooldown("Shield Block") then
        if max_GetManaPercentage("player") >= 50 then
            CastSpellByName("Shield Block")
        end
    end

    CastSpellByName("Revenge")

    if max_GetManaPercentage("player") >= 70 then
        CastSpellByName("Heroic Strike")
    end

    if mb_IsOnGCD() then
        return
    end

    if max_GetDebuffStackCount("target", DEBUFF_TEXTURE_SUNDER_ARMOR) < 5 or mb_Warrior_lastSunder + 20 < mb_GetTime() then
        if max_GetManaPercentage("player") >= 12 then
            CastSpellByName("Sunder Armor")
            mb_Warrior_lastSunder = mb_GetTime()
        end
        return
    end

    if mb_Warrior_BattleShout() then
        return
    end

    if not max_IsSpellNameOnCooldown("Shield Slam") then
        if max_GetManaPercentage("player") >= 20 then
            CastSpellByName("Shield Slam")
        end
        return
    end

    if not max_IsSpellNameOnCooldown("Shield Block") then
        if max_GetManaPercentage("player") >= 10 then
            CastSpellByName("Shield Block")
        end
        return
    end

    if mb_Warrior_DemoShout() then
        return
    end

    if max_GetManaPercentage("player") >= 40 then
        CastSpellByName("Heroic Strike")
    end

    if max_GetManaPercentage("player") >= 12 then
        CastSpellByName("Sunder Armor")
        mb_Warrior_lastSunder = mb_GetTime()
        return
    end
end

function mb_Warrior_DpsTank()
    if mb_shouldAutoTarget then
        if mb_Warrior_FindUntankedTarget() then
            return
        end
    end
    if max_GetActiveStance() ~= 1 then
        CastSpellByName("Battle Stance")
    end

    if not max_HasDebuff("target", DEBUFF_TEXTURE_THUNDER_CLAP) and mb_IsSpellInRangeOnEnemy("Sunder Armor", "target") then
        CastSpellByName("Thunder Clap")
        return
    end

    if mb_Warrior_DemoShout() then
        return
    end

    if mb_Warrior_BattleShout() then
        return
    end

    if max_GetHealthPercentage("target") < 25 then
        CastSpellByName("Execute")
        return
    end

    if not max_IsSpellNameOnCooldown("Shield Slam") then
        if max_GetManaPercentage("player") >= 30 then
            CastSpellByName("Shield Slam")
        end
        return
    end

    if mb_warriorOffTanksShouldMaximizeTps then
        if max_GetManaPercentage("player") >= 50 then
            CastSpellByName("Sunder Armor")
        end
    end

    if max_GetManaPercentage("player") >= 80 then
        CastSpellByName("Heroic Strike")
    end
end

function mb_Warrior_DemoShout()
    if max_HasDebuff("target", DEBUFF_TEXTURE_DEMORALIZING_SHOUT) then
        return false
    end
    if not CheckInteractDistance("target", 3) then
        return false
    end

    if mb_Warrior_HasImprovedDemoralizingShout() then
        CastSpellByName("Demoralizing Shout")
        return true
    else
        local members = max_GetNumPartyOrRaidMembers()
        for i = 1, members do
            local unit = max_GetUnitFromPartyOrRaidIndex(i)
            if mb_GetConfig()["specs"][UnitName(unit)] == "BitchTank" and not mb_IsDead(unit) and CheckInteractDistance(unit, 4) then
                return false
            end
        end
        CastSpellByName("Demoralizing Shout")
        return true
    end

    return false
end

mb_Warrior_lastHoTRequest = 0
function mb_Warrior_RequestHoTs()
    local myHotCount = mb_GetHoTCount("player")
    if myHotCount > 1 then
        return
    end
    local HoTValue = mb_CombatLogModule_DamageTakenPerSecond_GetDTPS(10) / (myHotCount + 1) -- +1 to avoid diving by zero
    if HoTValue > 100 and mb_Warrior_lastHoTRequest + 2.5 < mb_GetTime() then
        mb_MakeRequest("HoT", UnitName("player"), REQUEST_PRIORITY.IMPORTANT_BUFF)
        mb_Warrior_lastHoTRequest = mb_GetTime()
    end
end

function mb_Warrior_BattleShout()
    if max_GetManaPercentage("player") < 10 then
        return false
    end
    if not max_HasBuff("player", BUFF_TEXTURE_BATTLE_SHOUT) then
        CastSpellByName("Battle Shout")
        return true
    end
    return false
end

function mb_Warrior_FindUntankedTarget()
    for i = 1, 10 do
        TargetNearestEnemy()
        if max_HasValidOffensiveTarget("Sunder Armor") and UnitAffectingCombat("target") then
            if UnitExists("targettarget") then
                if not mb_IsUnitTank("targettarget") then
                    return true
                end
            end
        else
            ClearTarget()
        end
    end
    return false
end

function mb_Warrior_OnLoad()
    mb_warriorIsTank = mb_IsUnitTank("player")
    mb_RegisterForRequest("berserkerRage", mb_Warrior_HandleBerserkerRageRequest)
    mb_AddDesiredBuff(BUFF_MARK_OF_THE_WILD)
    mb_AddDesiredBuff(BUFF_POWER_WORD_FORTITUDE)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_MIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_KINGS)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_LIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_SANCTUARY)
    mb_AddDesiredBuff(BUFF_SHADOW_PROTECTION)
    mb_Warrior_AddDesiredTalents()
    mb_AddGCDCheckSpell("Sunder Armor")
    mb_RegisterEnemyRangeCheckSpell("Sunder Armor")
    if mb_warriorIsTank then
        mb_CombatLogModule_DamageTakenPerSecond_Enable()
        mb_AddDesiredBuff(BUFF_THORNS)

        local itemSubType = max_GetItemSubTypeForSlot("RangedSlot")
        if itemSubType == "Bows" or itemSubType == "Crossbows" then
            mb_AddReagentWatch("Jagged Arrow", 200)
        elseif itemSubType == "Guns" then
            mb_AddReagentWatch("Accurate Slugs", 200)
        end
        mb_AddReagentWatch("Gift of Arthas", 20)
        mb_AddReagentWatch("Major Healing Potion", 20)
    end

    local mainHandItemSubType = max_GetItemSubTypeForSlot("MainHandSlot")
    if max_IsItemSubTypeSharp(mainHandItemSubType) then
        mb_warriorMainHandTemporaryWeaponEnchant = "Dense Sharpening Stone"
    elseif max_IsItemSubTypeBlunt(mainHandItemSubType) then
        mb_warriorMainHandTemporaryWeaponEnchant = "Dense Weightstone"
    end
    local offHandItemSubType = max_GetItemSubTypeForSlot("SecondaryHandSlot")
    if max_IsItemSubTypeSharp(offHandItemSubType) then
        mb_warriorOffHandTemporaryWeaponEnchant = "Dense Sharpening Stone"
    elseif max_IsItemSubTypeBlunt(offHandItemSubType) then
        mb_warriorOffHandTemporaryWeaponEnchant = "Dense Weightstone"
    end

    local sharpWatch = 0
    local bluntWatch = 0
    if max_IsItemSubTypeSharp(mainHandItemSubType) then
        sharpWatch = sharpWatch + 25
    end
    if max_IsItemSubTypeSharp(offHandItemSubType) then
        sharpWatch = sharpWatch + 25
    end
    if max_IsItemSubTypeBlunt(mainHandItemSubType) then
        bluntWatch = bluntWatch + 25
    end
    if max_IsItemSubTypeBlunt(offHandItemSubType) then
        bluntWatch = bluntWatch + 25
    end
    if sharpWatch > 0 then
        mb_AddReagentWatch("Dense Sharpening Stone", sharpWatch)
    end
    if bluntWatch > 0 then
        mb_AddReagentWatch("Dense Weightstone", bluntWatch)
    end

    if mb_GetMySpecName() == "Fury2H" then
        mb_CombatLogModule_SelfMissWatch_Enable()
    end
end

function mb_Warrior_HasImprovedDemoralizingShout()
    local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(2, 3)
    return currentRank == 5
end

function mb_Warrior_HandleBerserkerRageRequest(request)
    mb_warriorShouldBerserkerRageNow = true
end

function mb_IsUnitTank(unit)
    local specName = mb_GetConfig()["specs"][UnitName(unit)]
    if specName == "ProperTank" then
        return true
    end
    if specName == "BitchTank" then
        return true
    end
    return false
end

function mb_Warrior_AddDesiredTalents()
    local mySpec = mb_GetConfig()["specs"][UnitName("player")]
    if mySpec == "ProperTank" then
        mb_AddDesiredTalent(1, 1, 3) -- Improved Heroic Strike
        mb_AddDesiredTalent(1, 2, 5) -- Deflection
        mb_AddDesiredTalent(2, 2, 5) -- Cruelty
        mb_AddDesiredTalent(3, 1, 5) -- Shield Specialization
        mb_AddDesiredTalent(3, 2, 5) -- Anticipation
        mb_AddDesiredTalent(3, 3, 2) -- Improved Bloodrage
        mb_AddDesiredTalent(3, 4, 5) -- Toughness
        mb_AddDesiredTalent(3, 6, 1) -- Last Stand
        mb_AddDesiredTalent(3, 7, 1) -- Improved Shield Block
        mb_AddDesiredTalent(3, 9, 5) -- Defiance
        mb_AddDesiredTalent(3, 10, 3) -- Improved Sunder Armor
        mb_AddDesiredTalent(3, 12, 2) -- Improved Taunt
        mb_AddDesiredTalent(3, 13, 2) -- Improved Shield Wall
        mb_AddDesiredTalent(3, 14, 1) -- Concussion Blow
        mb_AddDesiredTalent(3, 16, 5) -- One-Handed Weapon Specialization
        mb_AddDesiredTalent(3, 17, 1) -- Shield Slam
    elseif mySpec == "BitchTank" then
        mb_AddDesiredTalent(1, 2, 5) -- Deflection
        mb_AddDesiredTalent(1, 5, 5) -- Tactical Mastery
        mb_AddDesiredTalent(2, 1, 5) -- Booming Voice
        mb_AddDesiredTalent(2, 3, 5) -- Improved Demoralizing Shout
        mb_AddDesiredTalent(3, 1, 5) -- Shield Specialization
        mb_AddDesiredTalent(3, 2, 5) -- Anticipation
        mb_AddDesiredTalent(3, 4, 5) -- Toughness
        mb_AddDesiredTalent(3, 7, 1) -- Improved Shield Block
        mb_AddDesiredTalent(3, 9, 3) -- Defiance
        mb_AddDesiredTalent(3, 10, 3) -- Improved Sunder Armor
        mb_AddDesiredTalent(3, 12, 2) -- Improved Taunt
        mb_AddDesiredTalent(3, 14, 1) -- Concussion Blow
        mb_AddDesiredTalent(3, 16, 5) -- One-Handed Weapon Specialization
        mb_AddDesiredTalent(3, 17, 1) -- Shield Slam
    elseif mySpec == "FuryDW" then
        mb_AddDesiredTalent(1, 1, 3) -- Improved Heroic Strike
        mb_AddDesiredTalent(1, 2, 5) -- Deflection
        mb_AddDesiredTalent(1, 3, 3) -- Improved Rend
        mb_AddDesiredTalent(1, 5, 1) -- Tactical Mastery
        mb_AddDesiredTalent(1, 9, 3) -- Deep Wounds
        mb_AddDesiredTalent(1, 11, 2) -- Impale
        mb_AddDesiredTalent(2, 2, 5) -- Cruelty
        mb_AddDesiredTalent(2, 4, 5) -- Unbridled Wrath
        mb_AddDesiredTalent(2, 8, 5) -- Improved Battle Shout
        mb_AddDesiredTalent(2, 9, 5) -- Dual Wield Specialization
        mb_AddDesiredTalent(2, 10, 2) -- Improved Execute
        mb_AddDesiredTalent(2, 11, 5) -- Enrage
        mb_AddDesiredTalent(2, 13, 1) -- Death Wish
        mb_AddDesiredTalent(2, 16, 5) -- Flurry
        mb_AddDesiredTalent(2, 17, 1) -- Bloodthirst
    elseif mySpec == "Fury2H" then
        mb_AddDesiredTalent(1, 1, 2) -- Improved Heroic Strike
        mb_AddDesiredTalent(1, 3, 3) -- Improved Rend
        mb_AddDesiredTalent(1, 5, 5) -- Tactical Mastery
        mb_AddDesiredTalent(1, 7, 2) -- Improved Overpower
        mb_AddDesiredTalent(1, 9, 3) -- Deep Wounds
        mb_AddDesiredTalent(1, 10, 3) -- Two-Handed Weapon Specialization
        mb_AddDesiredTalent(1, 11, 2) -- Impale
        mb_AddDesiredTalent(2, 2, 5) -- Cruelty
        mb_AddDesiredTalent(2, 4, 5) -- Unbridled Wrath
        mb_AddDesiredTalent(2, 5, 2) -- Improved Cleave
        mb_AddDesiredTalent(2, 8, 5) -- Improved Battle Shout
        mb_AddDesiredTalent(2, 10, 2) -- Improved Execute
        mb_AddDesiredTalent(2, 11, 5) -- Enrage
        mb_AddDesiredTalent(2, 13, 1) -- Death Wish
        mb_AddDesiredTalent(2, 16, 5) -- Flurry
        mb_AddDesiredTalent(2, 17, 1) -- Bloodthirst
    end
end