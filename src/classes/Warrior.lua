-- TODO:
---     Tank VS DPS distinction for Sanctuary/Salvation
---
mb_warriorIsTank = mb_GetMySpecName() == "WarrTank"
mb_warriorMainHandTemporaryWeaponEnchant = nil
mb_warriorOffHandTemporaryWeaponEnchant = nil
function mb_Warrior(commander)
    if not UnitAffectingCombat("player") then
        if mb_shouldRequestBuffs then
            if mb_ApplyTemporaryWeaponEnchantsThrottled(mb_warriorMainHandTemporaryWeaponEnchant, mb_warriorOffHandTemporaryWeaponEnchant) then
                return
            end
        end
    end

    if mb_warriorIsTank then
        mb_Warrior_Tank(commander)
        return
    end

    if max_GetActiveStance() ~= 3 then
        CastSpellByName("Berserker Stance")
    end

    max_AssistByPlayerName(commander)
    if not max_HasValidOffensiveTarget() then
        return
    end

    if UnitAffectingCombat("player") and max_GetHealthPercentage("player") > 80 then
        CastSpellByName("Bloodrage")
    end

    if not mb_isAutoAttacking then
        CastSpellByName("Attack")
    end

    if mb_Warrior_BattleShout() then
        return
    end

    if mb_Warrior_DeathWish() then
        return
    end

    if not mb_areaOfEffectMode then
        if max_GetHealthPercentage("target") < 25 then
            CastSpellByName("Execute")
            return
        end

        if not max_IsSpellNameOnCooldown("Bloodthirst") then
            CastSpellByName("Bloodthirst")
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

mb_Warrior_lastTankingBroadcast = 0
mb_Warrior_lastSunder = 0
function mb_Warrior_Tank(commander)
    if not max_HasValidOffensiveTarget() or UnitIsDead("target") then
        max_AssistByPlayerName(commander)
    end
    if not max_HasValidOffensiveTarget() then
        return
    end

    if not mb_isAutoAttacking then
        CastSpellByName("Attack")
    end

    if UnitAffectingCombat("player") and max_GetHealthPercentage("player") > 80 then
        CastSpellByName("Bloodrage")
    end

    if UnitExists("targettarget") then
        local targetOfTargetName = UnitName("targettarget")
        if mb_GetConfig()["specs"][targetOfTargetName] == "WarrTank" then
            if UnitIsUnit("player", "targettarget") then
                if max_GetActiveStance() ~= 2 then
                    CastSpellByName("Defensive Stance")
                end
            else
                mb_Warrior_DpsTank(commander)
                return
            end
        else
            if max_GetActiveStance() ~= 2 then
                CastSpellByName("Defensive Stance")
            end
            CastSpellByName("Taunt")
        end
    end

    if not UnitIsUnit("player", "targettarget") then
        return
    end

    mb_Warrior_RequestHoTs()

    if mb_Warrior_lastTankingBroadcast + 5 < mb_GetTime() then
        mb_Warrior_lastTankingBroadcast = mb_GetTime()
        mb_MakeRequest("tankingBroadcast", mb_CombatLogModule_DamageTakenPerSecond_GetDTPS(10), REQUEST_PRIORITY.TANKING_BROADCAST)
    end

    CastSpellByName("Revenge")

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

    if max_GetManaPercentage("player") >= 50 then
        CastSpellByName("Heroic Strike")
    end

    if max_GetManaPercentage("player") >= 12 then
        CastSpellByName("Sunder Armor")
        mb_Warrior_lastSunder = mb_GetTime()
        return
    end
end

function mb_Warrior_DpsTank(commander)
    if not max_HasValidOffensiveTarget() then
        max_AssistByPlayerName(commander)
        if not max_HasValidOffensiveTarget() then
            return
        end
    end

    if max_GetActiveStance() ~= 1 then
        CastSpellByName("Battle Stance")
    end
    if mb_Warrior_BattleShout() then
        return
    end
    if not max_HasDebuff("target", DEBUFF_TEXTURE_DEMORALIZING_SHOUT) and CheckInteractDistance("target", 3) then
        if mb_Warrior_HasImprovedDemoralizingShout() then
            CastSpellByName("Demoralizing Shout")
            return
        end
    end
    if not max_HasDebuff("target", DEBUFF_TEXTURE_THUNDER_CLAP) and CheckInteractDistance("target", 3) then
        CastSpellByName("Thunder Clap")
        return
    end
    if max_GetManaPercentage("player") >= 40 and not max_IsSpellNameOnCooldown("Shield Slam") then
        CastSpellByName("Shield Slam")
        return
    end
    if max_GetManaPercentage("player") >= 80 then
        CastSpellByName("Heroic Strike")
    end
end

mb_Warrior_lastHoTRequest = 0
function mb_Warrior_RequestHoTs()
    local myHotCount = mb_GetHoTCount("player")
    if myHotCount > 1 then
        return
    end
    local HoTValue = mb_CombatLogModule_DamageTakenPerSecond_GetDTPS(10) / (myHotCount + 1) -- +1 to avoid diving by zero
    if HoTValue > 100 and mb_Warrior_lastHoTRequest + 2.5 < mb_GetTime() then
        mb_MakeRequest("HoT", UnitName("player"), REQUEST_PRIORITY.HEALING_OVER_TIME)
        mb_Warrior_lastHoTRequest = mb_GetTime()
    end
end

function mb_Warrior_BattleShout()
    if not max_HasBuff("player", BUFF_TEXTURE_BATTLE_SHOUT) then
        CastSpellByName("Battle Shout")
        return true
    end
    return false
end

function mb_Warrior_DeathWish()
    local cur, max, found = MobHealth3:GetUnitHealth("target")
    if not found or cur == 0 then
        return false
    end
    if UnitAffectingCombat("player") and cur > 20000 and max_GetHealthPercentage("target") < 20 then
        CastSpellByName("Death Wish")
        return
    end
    return false
end

function mb_Warrior_OnLoad()
    mb_AddDesiredBuff(BUFF_MARK_OF_THE_WILD)
    mb_AddDesiredBuff(BUFF_POWER_WORD_FORTITUDE)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_MIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_KINGS)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_LIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_SANCTUARY)
    mb_AddDesiredBuff(BUFF_SHADOW_PROTECTION)
    mb_Warrior_AddDesiredTalents()
	mb_AddGCDCheckSpell("Sunder Armor")
    if mb_warriorIsTank then
        mb_CombatLogModule_DamageTakenPerSecond_Enable()
        mb_AddDesiredBuff(BUFF_THORNS)
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

    if max_IsItemSubTypeSharp(mainHandItemSubType) or max_IsItemSubTypeSharp(offHandItemSubType) then
        mb_AddReagentWatch("Dense Sharpening Stone", 100)
    end
    if max_IsItemSubTypeBlunt(mainHandItemSubType) or max_IsItemSubTypeBlunt(offHandItemSubType) then
        mb_AddReagentWatch("Dense Weightstone", 100)
    end
end

function mb_Warrior_HasImprovedDemoralizingShout()
    local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(2, 3)
    return currentRank == 5
end

function mb_Warrior_AddDesiredTalents()
    local mySpec = mb_GetConfig()["specs"][UnitName("player")]
    if mySpec == "WarrTank" then
        mb_AddDesiredTalent(1, 1, 1)
        mb_AddDesiredTalent(1, 1, 3)
        mb_AddDesiredTalent(1, 2, 5)
        mb_AddDesiredTalent(2, 2, 5)
        mb_AddDesiredTalent(3, 1, 5)
        mb_AddDesiredTalent(3, 2, 5)
        mb_AddDesiredTalent(3, 3, 2)
        mb_AddDesiredTalent(3, 4, 5)
        mb_AddDesiredTalent(3, 6, 1)
        mb_AddDesiredTalent(3, 7, 2)
        mb_AddDesiredTalent(3, 9, 5)
        mb_AddDesiredTalent(3, 10, 3)
        mb_AddDesiredTalent(2, 12, 2)
        mb_AddDesiredTalent(3, 13, 1)
        mb_AddDesiredTalent(3, 14, 1)
        mb_AddDesiredTalent(3, 16, 5)
        mb_AddDesiredTalent(3, 17, 1)
        mb_AddDesiredTalent(3, 6, 1)
        mb_AddDesiredTalent(3, 7, 2)
        mb_AddDesiredTalent(3, 7, 2)
    elseif mySpec == "Fury" then
        mb_AddDesiredTalent(1, 1, 3)
        mb_AddDesiredTalent(1, 3, 3)
        mb_AddDesiredTalent(1, 5, 5)
        mb_AddDesiredTalent(1, 7, 1)
        mb_AddDesiredTalent(1, 9, 3)
        mb_AddDesiredTalent(1, 10, 3)
        mb_AddDesiredTalent(1, 11, 2)
        mb_AddDesiredTalent(2, 2, 5)
        mb_AddDesiredTalent(2, 4, 5)
        mb_AddDesiredTalent(2, 8, 5)
        mb_AddDesiredTalent(2, 9, 2)
        mb_AddDesiredTalent(2, 10, 2)
        mb_AddDesiredTalent(2, 11, 5)
        mb_AddDesiredTalent(2, 13, 1)
        mb_AddDesiredTalent(2, 16, 5)
        mb_AddDesiredTalent(2, 17, 1)
    end
end