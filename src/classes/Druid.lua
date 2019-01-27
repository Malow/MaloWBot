MB_DRUID_TRANQUILITY_HEAL_AMOUNT = 2000
MB_DRUID_REGROWTH_HEAL_AMOUNT = 2000

function mb_Druid(commander)
    if mb_DoBasicCasterLogicThrottled() then
        return
    end

    if not mb_IsReadyForNewCast() then
        mb_StopAttemptedCastIfNeeded(mb_Druid_ShouldStopCasting)
        return
    end

    local request = mb_GetQueuedRequest(true)
    if request ~= nil then
        if mb_CompleteStandardBuffRequest(request) then
            return
        elseif request.type == REQUEST_REMOVE_CURSE.type then
            max_CastSpellOnRaidMemberByPlayerName("Remove Curse", request.body)
            mb_RequestCompleted(request)
            return
        elseif request.type == "HoT" then
            mb_HealingModule_CompleteHoTRequest(request)
            return
        elseif request.type == REQUEST_INNERVATE.type then
            local unit = max_GetUnitForPlayerName(request.body)
            if not max_HasBuff(unit, BUFF_TEXTURE_INNERVATE) then
                max_CastSpellOnRaidMemberByPlayerName("Innervate", request.body)
                max_SayRaid("Innervating " .. request.body)
            end
            mb_RequestCompleted(request)
            return
        end
    end

    if mb_Druid_InnervateSelf() then
        return
    end

    if mb_CleanseRaidMemberThrottled("Remove Curse", "Curse") then
        return
    end

    max_AssistByPlayerName(commander)

    if mb_IsClassLeader() and max_HasValidOffensiveTarget() then
        if mb_Druid_DebuffTargetThrottled() then
            return
        end
    end

    if UnitAffectingCombat("player") and mb_GetTimeInCombat() > 30 then
        max_UseEquippedItemIfReady("Trinket0Slot")
        max_UseEquippedItemIfReady("Trinket1Slot")
    end

    if mb_Druid_Tranquility() then
        return
    end

    if mb_Druid_Rejuvenation() then
        return
    end

    if mb_Druid_DoTankHealing() then
        return
    end

    -- Damage
    if not max_HasValidOffensiveTarget() then
        return
    end

    if max_GetManaPercentage("player") > 95 then
        CastSpellByName("Wrath")
        return
    end

    if not mb_isAutoAttacking then
        CastSpellByName("Attack")
        return
    end
end

function mb_Druid_ShouldStopCasting(currentCast)
    if currentCast.spellName == "Regrowth" then
        if currentCast.startCastTime + 1.5 < mb_GetTime() then
            if max_GetMissingHealth(currentCast.target) < MB_DRUID_REGROWTH_HEAL_AMOUNT or max_HasBuff(currentCast.target, BUFF_TEXTURE_REGROWTH) then
                return true
            end
        end
    end
    return false
end

function mb_Druid_InnervateSelf()
    if not UnitAffectingCombat("player") or mb_GetTimeInCombat() < 30 then
        return false
    end
    if max_IsSpellNameOnCooldown("Innervate") then
        return false
    end
    if max_HasBuff("player", BUFF_TEXTURE_INNERVATE) then
        return false
    end

    if UnitMana("player") < 1000 then
        max_CastSpellOnRaidMember("Innervate", "player")
        max_SayRaid("Innervating myself")
        return true
    end
    return false
end

function mb_Druid_Tranquility()
    if UnitMana("player") < 1000 then
        return false
    end
    if not UnitAffectingCombat("player") or max_IsSpellNameOnCooldown("Tranquility") then
        return false
    end
    local healEffect, affectedPlayers = mb_GetGroupHealEffect(MB_DRUID_TRANQUILITY_HEAL_AMOUNT, "Remove Curse")
    if healEffect > 4.0 then
        local callBacks = {}
        callBacks.onStart = function(spellCast) mb_HealingModule_SendData(affectedPlayers, MB_DRUID_TRANQUILITY_HEAL_AMOUNT, 10) end
        mb_CastSpellByNameOnRaidMemberWithCallbacks("Tranquility", "player", callBacks)
        return true
    end
    return false
end

function mb_Druid_OnLoad()
    if mb_Druid_HasImprovedMOTW() then
        mb_RegisterForStandardBuffRequest(BUFF_MARK_OF_THE_WILD)
    end
    mb_RegisterForStandardBuffRequest(BUFF_THORNS)
    mb_RegisterForRequest(REQUEST_REMOVE_CURSE.type, mb_Druid_HandleDecurseRequest)
    mb_RegisterForRequest("useConsumable", mb_HealerModule_HandleUseConsumableRequest)
    mb_RegisterForRequest(REQUEST_INNERVATE.type, mb_Druid_HandleInnervateRequest)
    mb_AddDesiredBuff(BUFF_MARK_OF_THE_WILD)
    mb_AddDesiredBuff(BUFF_ARCANE_INTELLECT)
    mb_AddDesiredBuff(BUFF_POWER_WORD_FORTITUDE)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_WISDOM)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_KINGS)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_LIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_SALVATION)
    mb_AddDesiredBuff(BUFF_DIVINE_SPIRIT)
    mb_AddDesiredBuff(BUFF_SHADOW_PROTECTION)
    mb_Druid_AddDesiredTalents()
    mb_AddReagentWatch("Wild Thornroot", 80)
    mb_AddReagentWatch("Major Mana Potion", 20)
    mb_AddReagentWatch("Brilliant Mana Oil", 2)
    mb_AddGCDCheckSpell("Rejuvenation")
    mb_RegisterFriendlyRangeCheckSpell("Remove Curse")
    mb_RegisterFriendlyRangeCheckSpell("Rejuvenation")
    mb_RegisterFriendlyRangeCheckSpell("Regrowth")
    mb_RegisterEnemyRangeCheckSpell("Insect Swarm")
    mb_RegisterEnemyRangeCheckSpell("Faerie Fire")
    mb_RegisterFriendlyRangeCheckSpell("Innervate")
    mb_HealingModule_Enable()
    mb_HealingModule_RegisterHoT("Rejuvenation", BUFF_TEXTURE_REJUVENATION, 335)
end

function mb_Druid_DoTankHealing()
    local unitFilter = UNIT_FILTER_DOES_NOT_HAVE_BUFF
    unitFilter.buff = BUFF_TEXTURE_REGROWTH
    local tankUnit = mb_HealingModule_GetValidTankUnitWithHighestFutureMissingHealth("Regrowth", unitFilter)
    if tankUnit ~= nil then
        local callBacks = {}
        callBacks.onStart = function(spellCast)
            mb_HealingModule_SendData(UnitName(spellCast.target), MB_DRUID_REGROWTH_HEAL_AMOUNT, 2)
        end
        mb_CastSpellByNameOnRaidMemberWithCallbacks("Regrowth", tankUnit, callBacks)
        return true
    end
    -- TODO: Do healing touch instead
    return false
end

function mb_Druid_Rejuvenation()
    local spell = "Rejuvenation"
    local unitFilter = UNIT_FILTER_DOES_NOT_HAVE_BUFF
    unitFilter.buff = BUFF_TEXTURE_REJUVENATION
    local healTargetUnit, missingHealthOfTarget = mb_HealingModule_GetRaidHealTarget(spell, unitFilter)
    if max_GetHealthPercentage(healTargetUnit) < 65 then
        max_CastSpellOnRaidMember(spell, healTargetUnit)
        return true
    end
    return false
end

mb_druidLastDebuffTargetTime = 0
function mb_Druid_DebuffTargetThrottled()
    if mb_druidLastDebuffTargetTime + 1.0 > mb_GetTime() then
        return false
    end
    mb_druidLastDebuffTargetTime = mb_GetTime()
    if mb_Druid_InsectSwarm() then
        return true
    end
    if mb_Druid_FaerieFire() then
        return true
    end
    return false
end

function mb_Druid_InsectSwarm()
    local cur, max, found = MobHealth3:GetUnitHealth("target")
    if found and cur < APPLY_DEBUFFS_HEALTH_ABOVE then
        return false
    end
    if not max_HasDebuff("target", DEBUFF_TEXTURE_INSECT_SWARM) and mb_IsSpellInRangeOnEnemy("Insect Swarm", "target") then
        CastSpellByName("Insect Swarm(Rank 1)")
        return true
    end
    return false
end

function mb_Druid_FaerieFire()
    local cur, max, found = MobHealth3:GetUnitHealth("target")
    if found and cur < APPLY_DEBUFFS_HEALTH_ABOVE then
        return false
    end
    if not max_HasDebuff("target", DEBUFF_TEXTURE_FAERIE_FIRE) and mb_IsSpellInRangeOnEnemy("Faerie Fire", "target") then
        CastSpellByName("Faerie Fire")
        return true
    end
    return false
end

function mb_Druid_HandleDecurseRequest(request)
    if UnitIsDead("player") then
        return
    end
    if UnitMana("player") < 500 then
        return
    end
    if mb_IsUnitValidFriendlyTarget(max_GetUnitForPlayerName(request.body), "Remove Curse") then
        mb_AcceptRequest(request)
    end
end

function mb_Druid_HandleInnervateRequest(request)
    if not UnitAffectingCombat("player") then
        return
    end
    if not mb_IsFreeToAcceptRequest() then
        return
    end
    if max_IsSpellNameOnCooldown("Innervate") then
        return
    end

    if mb_IsUnitValidFriendlyTarget(max_GetUnitForPlayerName(request.body), "Innervate") then
        mb_AcceptRequest(request)
    end
end



function mb_Druid_HasImprovedMOTW()
    local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(3, 1)
    return currentRank == 5
end

function mb_Druid_AddDesiredTalents()
    mb_AddDesiredTalent(3, 1, 5) -- Improved Mark of the Wild
    mb_AddDesiredTalent(3, 2, 5) -- Furor
    mb_AddDesiredTalent(3, 3, 5) -- Improved Healing Touch
    mb_AddDesiredTalent(3, 4, 5) -- Nature's Focus
    mb_AddDesiredTalent(3, 6, 3) -- Reflection
    mb_AddDesiredTalent(3, 7, 1) -- Insect Swarm
    mb_AddDesiredTalent(3, 8, 5) -- Subtlety
    mb_AddDesiredTalent(3, 9, 5) -- Tranquil Spirit
    mb_AddDesiredTalent(3, 10, 3) -- Improved Rejuvenation
    mb_AddDesiredTalent(3, 11, 1) -- Nature's Swiftness
    mb_AddDesiredTalent(3, 12, 5) -- Gift of Nature
    mb_AddDesiredTalent(3, 13, 2) -- Improved Tranquility
    mb_AddDesiredTalent(3, 14, 5) -- Improved Regrowth
    mb_AddDesiredTalent(3, 15, 1) -- Swiftmend
end