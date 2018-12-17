function mb_Druid(commander)
    if mb_DoBasicCasterLogic() then
        return
    end

    local request = mb_GetQueuedRequest()
    if request ~= nil then
        if request.type == BUFF_MARK_OF_THE_WILD.type then
            if mb_IsOnGCD() then
                return
            end
            mb_RequestCompleted(request)
            if mb_ShouldBuffGroupWide(request.body, BUFF_MARK_OF_THE_WILD) then
                max_CastSpellOnRaidMemberByPlayerName("Gift of the Wild", request.body)
                return
            elseif not max_HasBuffWithMultipleTextures(max_GetUnitForPlayerName(request.body), BUFF_MARK_OF_THE_WILD.textures) then
                max_CastSpellOnRaidMemberByPlayerName("Mark of the Wild", request.body)
                return
            end
        elseif request.type == REQUEST_REMOVE_CURSE.type then
            if mb_IsOnGCD() then
                return
            end
            max_CastSpellOnRaidMemberByPlayerName("Remove Curse", request.body)
            mb_RequestCompleted(request)
            return
        else
            max_SayRaid("Serious error, received request for " .. request.type)
        end
    end

    if mb_Druid_Rejuvenation() then
        return
    end

    if mb_Druid_Regrowth() then
        return
    end

    -- Damage
    max_AssistByPlayerName(commander)
    if not UnitExists("target") or not UnitIsEnemy("player", "target") then
        return
    end

    if mb_Druid_InsectSwarm() then
        return
    end

    if max_GetManaPercentage("player") > 95 then
        CastSpellByName("Wrath")
    end

    if not mb_isAutoAttacking then
        CastSpellByName("Attack")
        return
    end
end

function mb_Druid_OnLoad()
    mb_RegisterForRequest(BUFF_MARK_OF_THE_WILD.type, mb_Druid_HandleMarkOfTheWildRequest)
    mb_RegisterForRequest(REQUEST_REMOVE_CURSE.type, mb_Druid_HandleDecurseRequest)
    mb_AddDesiredBuff(BUFF_MARK_OF_THE_WILD)
    mb_AddDesiredBuff(BUFF_ARCANE_INTELLECT)
    mb_AddDesiredBuff(BUFF_POWER_WORD_FORTITUDE)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_WISDOM)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_KINGS)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_LIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_SALVATION)
    mb_AddDesiredBuff(BUFF_DIVINE_SPIRIT)
    mb_Druid_AddDesiredTalents()
    mb_AddReagentWatch("Wild Thornroot", 20)
    mb_AddGCDCheckSpell("Rejuvenation")
    mb_RegisterRangeCheckSpell("Mark of the Wild")
    mb_RegisterRangeCheckSpell("Gift of the Wild")
    mb_RegisterRangeCheckSpell("Remove Curse")
    mb_RegisterRangeCheckSpell("Rejuvenation")
    mb_RegisterRangeCheckSpell("Regrowth")
end

function mb_Druid_Rejuvenation()
    local spell = "Rejuvenation"
    local unitFilter = UNIT_FILTER_DOES_NOT_HAVE_BUFF
    unitFilter.buff = BUFF_TEXTURE_REJUVENATION
    local healTargetUnit, missingHealthOfTarget = mb_GetMostDamagedFriendly(spell, unitFilter)
    if max_GetHealthPercentage(healTargetUnit) < 75 then
        max_CastSpellOnRaidMember(spell, healTargetUnit)
        return true
    end
    return false
end

function mb_Druid_Regrowth()
    local spell = "Regrowth"
    local unitFilter = UNIT_FILTER_DOES_NOT_HAVE_BUFF
    unitFilter.buff = BUFF_TEXTURE_REGROWTH
    local healTargetUnit, missingHealthOfTarget = mb_GetMostDamagedFriendly(spell, unitFilter)
    if max_GetHealthPercentage(healTargetUnit) < 60 then
        max_CastSpellOnRaidMember(spell, healTargetUnit)
        return true
    end
    return false
end

function mb_Druid_InsectSwarm()
    if not max_HasDebuff("target", DEBUFF_INSECT_SWARM) then
        CastSpellByName("Insect Swarm")
        return true
    end
    return false
end

function mb_Druid_HandleMarkOfTheWildRequest(request)
    if not mb_Druid_HasImprovedMOTW() then
        return
    end
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(request.body), "Mark of the Wild") then
        mb_AcceptRequest(request)
    end
end

function mb_Druid_HandleDecurseRequest(request)
    if mb_IsUnitValidTarget(max_GetUnitForPlayerName(request.body), "Remove Curse") then
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