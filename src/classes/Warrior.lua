-- TODO:
---     Tank VS DPS distinction for Sanctuary/Salvation
---
mb_warriorIsTank = mb_GetMySpecName() == "WarrTank"
function mb_Warrior(commander)
    if mb_warriorIsTank then
        mb_Warrior_Tank()
        return
    end

    AssistByName(commander)
    CastSpellByName("Attack")
    CastSpellByName("Bloodthirst")
    CastSpellByName("Whirlwind")
    --if config["specs"]["player"] == "Fury" then
    --    CastSpellByName("Berserker Stance")
     --   return
   -- end
    if max_GetHealthPercentage("target") < 25 then
        CastSpellByName("Execute")
        return
    end
    if max_GetHealthPercentage("target") < 90 then
        CastSpellByName("Bloodrage")
        return
    end
end

mb_Warrior_lastTankingBroadcast = 0
mb_Warrior_lastSunder = 0
function mb_Warrior_Tank()
    if max_GetActiveStance() ~= 2 then
        CastSpellByName("Defensive Stance")
    end

    if not UnitExists("target") or not UnitIsEnemy("player", "target") then
        return
    end

    if UnitAffectingCombat("player") and max_GetHealthPercentage("player") > 80 then
        CastSpellByName("Bloodrage")
    end

    if UnitExists("targettarget") then
        local targetOfTargetName = UnitName("targettarget")
        if mb_GetConfig()["specs"][targetOfTargetName] ~= "WarrTank" then
            CastSpellByName("Taunt")
        end
    end

    if not mb_isAutoAttacking then
        CastSpellByName("Attack")
    end

    if not UnitIsUnit("player", "targettarget") then
        return
    end

    mb_Warrior_RequestHoTs()

    if mb_Warrior_lastTankingBroadcast + 5 < GetTime() then
        mb_Warrior_lastTankingBroadcast = GetTime()
        mb_MakeRequest("tankingBroadcast", mb_CombatLogModule_GetDTPS(10), 10)
    end

    CastSpellByName("Revenge")

    if mb_IsOnGCD() then
        return
    end

    if max_GetManaPercentage("player") > 11 then
        if max_GetDebuffStackCount("target", DEBUFF_TEXTURE_SUNDER_ARMOR) < 5 then
            CastSpellByName("Sunder Armor")
            mb_Warrior_lastSunder = GetTime()
            return
        elseif mb_Warrior_lastSunder + 20 < GetTime() then
            CastSpellByName("Sunder Armor")
            mb_Warrior_lastSunder = GetTime()
            return
        end
    end

    if max_GetManaPercentage("player") > 20 and not max_IsSpellNameOnCooldown("Shield Slam") then
        CastSpellByName("Shield Slam")
        return
    end

    if max_GetManaPercentage("player") > 10 and not max_IsSpellNameOnCooldown("Shield Block") then
        CastSpellByName("Shield Block")
        return
    end

    if max_GetManaPercentage("player") > 11 then
        CastSpellByName("Sunder Armor")
        mb_Warrior_lastSunder = GetTime()
    end

    if max_GetManaPercentage("player") > 40 then
        CastSpellByName("Heroic Strike")
    end
end

mb_Warrior_lastHoTRequest = 0
function mb_Warrior_RequestHoTs()
    local myHotCount = mb_GetHoTCount("player")
    if myHotCount == 3 then
        return
    end
    local HoTValue = mb_CombatLogModule_GetDTPS(10) / (myHotCount + 1) -- +1 to avoid diving by zero
    if HoTValue > 100 and mb_Warrior_lastHoTRequest + 2.5 < GetTime() then
        mb_MakeRequest("HoT", UnitName("player"), 11)
        mb_Warrior_lastHoTRequest = GetTime()
    end
end

function mb_Warrior_OnLoad()
    mb_AddDesiredBuff(BUFF_MARK_OF_THE_WILD)
    mb_AddDesiredBuff(BUFF_POWER_WORD_FORTITUDE)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_MIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_KINGS)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_LIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_SANCTUARY)
    mb_Warrior_AddDesiredTalents()
    if mb_warriorIsTank then
        mb_CombatLogModule_EnableDTPS()
    end
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