MB_PRIEST_POH_HEAL_AMOUNT = 1300
MB_PRIEST_GHR1_HEAL_AMOUNT = 1600
MB_PRIEST_GHR4_HEAL_AMOUNT = 3000

mb_priestIsHoly = true
function mb_Priest(commander)
    if mb_DoBasicCasterLogicThrottled() then
        return
    end

    if not mb_IsReadyForNewCast() then
        mb_StopAttemptedCastIfNeeded(mb_Priest_ShouldStopCasting)
        return
    end

    if mb_currentBossModule.priestLogic ~= nil then
        if mb_currentBossModule.priestLogic() then
            return
        end
    end

    local request = mb_GetQueuedRequest(true)
    if request ~= nil then
        if mb_CompleteStandardBuffRequest(request) then
            return
        elseif request.type == REQUEST_RESURRECT.type then
            if mb_CanResurrectUnitWithSpell(max_GetUnitForPlayerName(request.body), "Resurrection") then
                max_CastSpellOnRaidMemberByPlayerName("Resurrection", request.body)
                max_SayRaid("I'm resurrecting " .. request.body)
            end
            mb_RequestCompleted(request)
            return
        elseif request.type == REQUEST_REMOVE_MAGIC.type then
            max_CastSpellOnRaidMemberByPlayerName("Dispel Magic", request.body)
            mb_RequestCompleted(request)
            return
        elseif request.type == "fearWard" then
            if max_HasBuff(max_GetUnitForPlayerName(request.body), BUFF_TEXTURE_FEAR_WARD) then
                mb_RequestCompleted(request)
                return
            end
            if max_IsSpellNameOnCooldown("Fear Ward") then
                mb_RequestCompleted(request)
                return
            end
            max_SayRaid("I'm Fear Warding " .. request.body)
            max_CastSpellOnRaidMemberByPlayerName("Fear Ward", request.body)
            return
        elseif request.type == "HoT" then
            mb_HealingModule_CompleteHoTRequest(request)
        elseif request.type == "aoeFear" then
            if max_IsSpellNameOnCooldown("Psychic Scream") then
                mb_RequestCompleted(request)
                return
            end
            max_SayRaid("AoE Fearing!")
            CastSpellByName("Psychic Scream")
            return
        end
    end

    if not mb_IsInCombat() then
        if not max_HasBuff("player", BUFF_TEXTURE_INNER_FIRE) then
            CastSpellByName("Inner Fire")
            return
        end
    end

    if mb_IsInCombat() and max_GetHealthPercentage("player") < 30 then
        if max_CastSpellIfReady("Desperate Prayer") then
            return
        end
    end

    if mb_IsInCombat() and mb_GetTimeInCombat() > 30 and UnitMana("player") < 1000 and not max_HasBuff("player", BUFF_TEXTURE_INNERVATE) then
        mb_MakeThrottledRequest(REQUEST_INNERVATE, UnitName("player"), REQUEST_PRIORITY.IMPORTANT_BUFF)
    end

    local tankUnit, tankFutureMissingHealth = mb_HealingModule_GetValidTankUnitWithHighestFutureMissingHealth("Greater Heal")
    if tankUnit ~= nil and tankFutureMissingHealth > (UnitHealthMax(tankUnit) / 2) then
        mb_Priest_DoTankHealing(tankUnit)
        return
    end

    if mb_CleanseRaidMemberThrottled("Dispel Magic", "Magic") then
        return
    end

    if mb_IsInCombat() and mb_GetTimeInCombat() > 30 then
        max_UseEquippedItemIfReady("Trinket0Slot")
        max_UseEquippedItemIfReady("Trinket1Slot")
    end

    if mb_Priest_PrayerOfHealing() then
        return
    end

    if tankUnit ~= nil and tankFutureMissingHealth > 0 then
        mb_Priest_DoTankHealing(tankUnit)
        return
    end

    if mb_priestIsHoly then
        if mb_Priest_Renew(55) then
            return true
        end
    else
        if mb_Priest_PWS(40) then
            return true
        end
        if mb_Priest_Renew(65) then
            return true
        end
    end

    if tankUnit ~= nil then
        mb_Priest_DoTankHealing(tankUnit)
        return
    end

    max_AssistByPlayerName(commander)
    if not max_HasValidOffensiveTarget() then
        return
    end

    if max_GetManaPercentage("player") > 95 then
        CastSpellByName("Smite")
        return
    end

    if not mb_isAutoAttacking then
        CastSpellByName("Attack")
        return
    end
end

function mb_Priest_ShouldStopCasting(currentCast)
    if currentCast.spellName == "Greater Heal(Rank 1)" then
        if currentCast.startCastTime + 2 < mb_GetTime() then
            if max_GetMissingHealth(currentCast.target) < (MB_PRIEST_GHR1_HEAL_AMOUNT * mb_HealingModule_overhealCoef) then
                return true
            end
        end
    elseif currentCast.spellName == "Greater Heal" then
            if currentCast.startCastTime + 2 < mb_GetTime() then
                if max_GetMissingHealth(currentCast.target) < (MB_PRIEST_GHR4_HEAL_AMOUNT * mb_HealingModule_overhealCoef) then
                    return true
                end
            end
    elseif currentCast.spellName == "Prayer of Healing" then
        if mb_GetGroupHealEffect(MB_PRIEST_POH_HEAL_AMOUNT, "Dispel Magic") < 2.5 then
            return true
        end
    end
    return false
end

function mb_Priest_DoTankHealing(tankUnit)
    if mb_Priest_InnerFocus() then
        return
    end
    local healAmount = MB_PRIEST_GHR1_HEAL_AMOUNT
    local spellName = "Greater Heal(Rank 1)"
    if max_HasBuff("player", BUFF_TEXTURE_INNER_FOCUS) then
        healAmount = MB_PRIEST_GHR4_HEAL_AMOUNT
        spellName = "Greater Heal"
    end
    local callBacks = {}
    callBacks.onStart = function(spellCast)
        mb_HealingModule_SendData(UnitName(spellCast.target), healAmount, 2.5)
    end
    mb_CastSpellByNameOnRaidMemberWithCallbacks(spellName, tankUnit, callBacks)
end

function mb_Priest_PWS(healthPercentage)
    local spell = "Power Word: Shield"
    if max_IsSpellNameOnCooldown(spell) then
        return false
    end
    local unitFilter = UNIT_FILTER_DOES_NOT_HAVE_DEBUFF
    unitFilter.debuff = DEBUFF_TEXTURE_WEAKENED_SOUL
    local healTargetUnit, healthOfTarget = mb_GetLowestHealthFriendly(spell, unitFilter)
    if max_GetHealthPercentage(healTargetUnit) < healthPercentage then
        max_CastSpellOnRaidMember(spell, healTargetUnit)
        return true
    end
    return false
end

function mb_Priest_Renew(healthPercentage)
    local spell = "Renew"
    local unitFilter = UNIT_FILTER_DOES_NOT_HAVE_BUFF
    unitFilter.buff = BUFF_TEXTURE_RENEW
    local healTargetUnit, missingHealthOfTarget = mb_HealingModule_GetRaidHealTarget(spell, unitFilter)
    if max_GetHealthPercentage(healTargetUnit) < healthPercentage then
        max_CastSpellOnRaidMember(spell, healTargetUnit)
        return true
    end
    return false
end

function mb_Priest_InnerFocus()
    if not mb_IsInCombat() or mb_GetTimeInCombat() < 30 then
        return false
    end
    if max_IsSpellNameOnCooldown("Inner Focus") or max_GetManaPercentage("player") > 75 then
        return false
    end
    CastSpellByName("Inner Focus")
    return true
end

function mb_Priest_PrayerOfHealing()
    local healEffect, affectedPlayers = mb_GetGroupHealEffect(MB_PRIEST_POH_HEAL_AMOUNT, "Dispel Magic")
    if healEffect > 3.0 then
        if mb_Priest_InnerFocus() then
            return true
        end
        local callBacks = {}
        callBacks.onStart = function(spellCast) mb_HealingModule_SendData(affectedPlayers, MB_PRIEST_POH_HEAL_AMOUNT, 3) end
        mb_CastSpellByNameOnRaidMemberWithCallbacks("Prayer of Healing", "player", callBacks)
        return true
    end
    return false
end

function mb_Priest_OnLoad()
    if mb_Priest_HasDivineSpirit() then
        mb_RegisterForStandardBuffRequest(BUFF_DIVINE_SPIRIT)
        if max_GetNumPartyOrRaidMembers() < 30 then
            mb_RegisterForStandardBuffRequest(BUFF_SHADOW_PROTECTION)
        end
    else
        if mb_Priest_HasImprovedFortitude() then
            mb_RegisterForStandardBuffRequest(BUFF_POWER_WORD_FORTITUDE)
        end
        mb_RegisterForStandardBuffRequest(BUFF_SHADOW_PROTECTION)
    end
    mb_RegisterForRequest("fearWard", mb_Priest_HandleFearWardRequest)
    mb_RegisterForRequest(REQUEST_RESURRECT.type, mb_Priest_HandleResurrectionRequest)
    mb_RegisterForRequest(REQUEST_REMOVE_MAGIC.type, mb_Priest_HandleDispelRequest)
    mb_RegisterForRequest("useConsumable", mb_HealerModule_HandleUseConsumableRequest)
    mb_RegisterForRequest("aoeFear", mb_Priest_HandleAoeFearRequest)
    mb_AddDesiredBuff(BUFF_MARK_OF_THE_WILD)
    mb_AddDesiredBuff(BUFF_ARCANE_INTELLECT)
    mb_AddDesiredBuff(BUFF_POWER_WORD_FORTITUDE)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_WISDOM)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_KINGS)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_LIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_SALVATION)
    mb_AddDesiredBuff(BUFF_DIVINE_SPIRIT)
    mb_AddDesiredBuff(BUFF_SHADOW_PROTECTION)
    mb_Priest_AddDesiredTalents()
    mb_AddGCDCheckSpell("Renew")
    mb_AddReagentWatch("Sacred Candle", 200)
    mb_AddReagentWatch("Major Mana Potion", 20)
    mb_AddReagentWatch("Brilliant Mana Oil", 2)
    mb_RegisterFriendlyRangeCheckSpell("Resurrection")
    mb_RegisterFriendlyRangeCheckSpell("Dispel Magic")
    mb_RegisterFriendlyRangeCheckSpell("Renew")
    mb_RegisterFriendlyRangeCheckSpell("Power Word: Shield")
    mb_RegisterFriendlyRangeCheckSpell("Greater Heal")
    mb_RegisterFriendlyRangeCheckSpell("Fear Ward")
    mb_RegisterEnemyRangeCheckSpell("Mana Burn")
    mb_HealingModule_Enable()
    mb_HealingModule_RegisterHoT("Renew", BUFF_TEXTURE_RENEW, 365)
    mb_priestIsHoly = mb_GetMySpecName() == "Holy"
end

function mb_Priest_HandleFearWardRequest(request)
    if max_IsSpellNameOnCooldown("Fear Ward") then
        return
    end
    if UnitIsDead("player") then
        return
    end
    local unit = max_GetUnitForPlayerName(request.body)
    if max_HasBuff(unit, BUFF_TEXTURE_FEAR_WARD) then
        return
    end
    if mb_IsUnitValidFriendlyTarget(unit, "Fear Ward") then
        max_SayRaid("Accepted fear-ward on " .. request.body .. " from " .. request.from)
        mb_AcceptRequest(request)
    end
end

function mb_Priest_HandleResurrectionRequest(request)
    if mb_CanResurrectUnitWithSpell(max_GetUnitForPlayerName(request.body), "Resurrection") then
        mb_AcceptRequest(request)
    end
end

function mb_Priest_HandleAoeFearRequest(request)
    if not mb_IsFreeToAcceptRequest() then
        return
    end
    if UnitMana("player") < 500 then
        return
    end
    if max_IsSpellNameOnCooldown("Psychic Scream") then
        return
    end
    mb_AcceptRequest(request)
end

function mb_Priest_HandleDispelRequest(request)
    if UnitIsDead("player") then
        return
    end
    if UnitMana("player") < 500 then
        return
    end
    if mb_IsUnitValidFriendlyTarget(max_GetUnitForPlayerName(request.body), "Dispel Magic") then
        mb_AcceptRequest(request)
    end
end

function mb_Priest_IsReady()
    if max_CancelBuffWithRemainingDurationLessThan(BUFF_TEXTURE_INNER_FIRE, 8 * 60) then
        return false
    end
    return true
end

function mb_Priest_HasImprovedFortitude()
    local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(1, 4)
    return currentRank == 2
end

function mb_Priest_HasDivineSpirit()
    local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(1, 13)
    return currentRank == 1
end

function mb_Priest_AddDesiredTalents()
    if mb_GetMySpecName() == "Disc" then
        mb_AddDesiredTalent(1, 1, 5) -- Unbreakable Will
        mb_AddDesiredTalent(1, 3, 3) -- Silent Resolve
        mb_AddDesiredTalent(1, 5, 3) -- Improved Power Word: Shield
        mb_AddDesiredTalent(1, 7, 1) -- Inner Focus
        mb_AddDesiredTalent(1, 8, 3) -- Meditation
        mb_AddDesiredTalent(1, 10, 5) -- Mental Agility
        mb_AddDesiredTalent(1, 13, 1) -- Divine Spirit
        mb_AddDesiredTalent(2, 1, 2) -- Healing Focus
        mb_AddDesiredTalent(2, 2, 3) -- Improved Renew
        mb_AddDesiredTalent(2, 3, 5) -- Holy Specialization
        mb_AddDesiredTalent(2, 5, 5) -- Divine Fury
        mb_AddDesiredTalent(2, 9, 2) -- Holy Reach
        mb_AddDesiredTalent(2, 10, 3) -- Improved Healing
        mb_AddDesiredTalent(2, 14, 5) -- Spiritual Guidance
        mb_AddDesiredTalent(2, 15, 5) -- Spiritual Healing
    elseif mb_GetMySpecName() == "Holy" then
        mb_AddDesiredTalent(1, 1, 5) -- Unbreakable Will
        mb_AddDesiredTalent(1, 4, 2) -- Improved Power Word: Fortitude
        -- Imp Fort first, out of order
        mb_AddDesiredTalent(2, 1, 2) -- Healing Focus
        mb_AddDesiredTalent(2, 2, 3) -- Improved Renew
        mb_AddDesiredTalent(2, 3, 5) -- Holy Specialization
        mb_AddDesiredTalent(2, 5, 5) -- Divine Fury
        mb_AddDesiredTalent(2, 6, 1) -- Holy Nova
        mb_AddDesiredTalent(2, 8, 3) -- Inspiration
        mb_AddDesiredTalent(2, 9, 2) -- Holy Reach
        mb_AddDesiredTalent(2, 10, 3) -- Improved Healing
        mb_AddDesiredTalent(2, 12, 2) -- Improved Prayer of Healing
        mb_AddDesiredTalent(2, 14, 5) -- Spiritual Guidance
        mb_AddDesiredTalent(2, 15, 5) -- Spiritual Healing
        mb_AddDesiredTalent(1, 3, 4) -- Silent Resolve
        mb_AddDesiredTalent(1, 7, 1) -- Inner Focus
        mb_AddDesiredTalent(1, 8, 3) -- Meditation
    else
        max_SayRaid("Serious error, bad spec for priest: " .. mySpec)
    end
end