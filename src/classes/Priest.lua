function mb_Priest(commander)
    if mb_DoBasicCasterLogic() then
        return
    end

    if max_GetTableSize(mb_queuedRequests) > 0 then
        local request = mb_queuedRequests[1]
        if request.requestType == BUFF_POWER_WORD_FORTITUDE.requestType then
            -- if gcd is ready
            TargetByName(request.requestBody, true)
            CastSpellByName("Power Word: Fortitude")
            table.remove(mb_queuedRequests, 1)
            return
        elseif request.requestType == BUFF_DIVINE_SPIRIT.requestType then
            -- if gcd is ready
            TargetByName(request.requestBody, true)
            CastSpellByName("Divine Spirit")
            table.remove(mb_queuedRequests, 1)
            return
        elseif request.requestType == REQUEST_RESURRECT.requestType then
            TargetByName(request.requestBody, true)
            CastSpellByName("Resurrection")
            table.remove(mb_queuedRequests, 1)
            return
        else
            max_SayRaid("Serious error, received request for " .. request.requestType)
        end
    end

    if mb_Priest_HasImprovedPWS() then
        if mb_Priest_PWS() then
            return
        end
    end

    if mb_Priest_Renew() then
        return
    end

    AssistByName(commander)
    CastSpellByName("Smite")
end

function mb_Priest_PWS()
    local spell = "Power Word: Shield"
    local unitFilter = UNIT_FILTER_DOES_NOT_HAVE_DEBUFF
    unitFilter.debuff = DEBUFF_TEXTURE_WEAKENED_SOUL
    local healTargetUnit, healthOfTarget = mb_GetLowestHealthFriendly(spell, unitFilter)
    if max_GetHealthPercentage(healTargetUnit) < 50 then
        TargetUnit(healTargetUnit)
        CastSpellByName(spell)
        return true
    end
    return false
end

function mb_Priest_Renew()
    local spell = "Renew"
    local unitFilter = UNIT_FILTER_DOES_NOT_HAVE_BUFF
    unitFilter.buff = BUFF_TEXTURE_RENEW
    local healTargetUnit, missingHealthOfTarget = mb_GetMostDamagedFriendly(spell, unitFilter)
    if max_GetHealthPercentage(healTargetUnit) < 75 then
        TargetUnit(healTargetUnit)
        CastSpellByName(spell)
        return true
    end
    return false
end

function mb_Priest_OnLoad()
    mb_RegisterForRequest(BUFF_POWER_WORD_FORTITUDE.requestType, mb_Priest_HandlePowerWordFortitudeRequest)
    mb_RegisterForRequest(BUFF_DIVINE_SPIRIT.requestType, mb_Priest_HandleDivineSpiritRequest)
    mb_RegisterForRequest(REQUEST_RESURRECT.requestType, mb_Priest_HandleResurrectionRequest)
    mb_AddDesiredBuff(BUFF_MARK_OF_THE_WILD)
    mb_AddDesiredBuff(BUFF_ARCANE_INTELLECT)
    mb_AddDesiredBuff(BUFF_POWER_WORD_FORTITUDE)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_WISDOM)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_KINGS)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_LIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_SALVATION)
    mb_AddDesiredBuff(BUFF_DIVINE_SPIRIT)
    mb_Priest_AddDesiredTalents()
end

function mb_Priest_HandlePowerWordFortitudeRequest(requestId, requestType, requestBody)
    if not mb_Priest_HasImprovedFortitude() then
        return
    end
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(requestBody), "Power Word: Fortitude") then
        mb_AcceptRequest(requestId, requestType, requestBody)
    end
end

function mb_Priest_HandleDivineSpiritRequest(requestId, requestType, requestBody)
    if not mb_Priest_HasDivineSpirit() then
        return
    end
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(requestBody), "Divine Spirit") then
        mb_AcceptRequest(requestId, requestType, requestBody)
    end
end

function mb_Priest_HandleResurrectionRequest(requestId, requestType, requestBody)
    if mb_CanResurrectUnitWithSpell(max_GetUnitForPlayerName(requestBody), "Resurrection") then
        mb_AcceptRequest(requestId, requestType, requestBody)
    end
end

function mb_Priest_HasImprovedFortitude()
    local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(1, 4)
    return currentRank == 2
end

function mb_Priest_HasDivineSpirit()
    local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(1, 13)
    return currentRank == 1
end

function mb_Priest_HasImprovedPWS()
    local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(1, 5)
    return currentRank == 3
end

function mb_Priest_AddDesiredTalents()
    local mySpec = mb_GetConfig()["specs"][UnitName("player")]
    if mySpec == "Disc" then
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
    elseif mySpec == "Holy" then
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