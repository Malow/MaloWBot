function mb_Paladin(commander)
    if mb_DoBasicCasterLogic() then
        return
    end

    if max_GetTableSize(mb_queuedRequests) > 0 then
        local request = mb_queuedRequests[1]
        if request.requestType == BUFF_BLESSING_OF_WISDOM.requestType then
            TargetByName(request.requestBody, true)
            CastSpellByName("Blessing of Wisdom")
            table.remove(mb_queuedRequests, 1)
            return
        elseif request.requestType == BUFF_BLESSING_OF_MIGHT.requestType then
            TargetByName(request.requestBody, true)
            CastSpellByName("Blessing of Might")
            table.remove(mb_queuedRequests, 1)
            return
        elseif request.requestType == BUFF_BLESSING_OF_KINGS.requestType then
            TargetByName(request.requestBody, true)
            CastSpellByName("Blessing of Kings")
            table.remove(mb_queuedRequests, 1)
            return
        elseif request.requestType == BUFF_BLESSING_OF_LIGHT.requestType then
            TargetByName(request.requestBody, true)
            CastSpellByName("Blessing of Light")
            table.remove(mb_queuedRequests, 1)
            return
        elseif request.requestType == BUFF_BLESSING_OF_SANCTUARY.requestType then
            TargetByName(request.requestBody, true)
            CastSpellByName("Blessing of Sanctuary")
            table.remove(mb_queuedRequests, 1)
            return
        elseif request.requestType == BUFF_BLESSING_OF_SALVATION.requestType then
            TargetByName(request.requestBody, true)
            CastSpellByName("Blessing of Salvation")
            table.remove(mb_queuedRequests, 1)
            return
        elseif request.requestType == REQUEST_RESURRECT.requestType then
            TargetByName(request.requestBody, true)
            CastSpellByName("Redemption")
            table.remove(mb_queuedRequests, 1)
            return
        else
            max_SayRaid("Serious error, received request for " .. request.requestType)
        end
    end

    local healSpell = "Flash of Light"
    local healTargetUnit, missingHealth = mb_GetMostDamagedFriendly(healSpell)
    if missingHealth > 50 then
        TargetUnit(healTargetUnit)
        CastSpellByName(healSpell)
        return
    end
end

function mb_Paladin_OnLoad()
    mb_AddDesiredBuff(BUFF_ARCANE_INTELLECT)
    mb_AddDesiredBuff(BUFF_POWER_WORD_FORTITUDE)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_WISDOM)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_MIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_KINGS)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_LIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_SALVATION)
    mb_AddDesiredBuff(BUFF_DIVINE_SPIRIT)
    mb_RegisterForRequest(REQUEST_RESURRECT.requestType, mb_Paladin_HandleResurrectionRequest)
    mb_RegisterForRequest(BUFF_BLESSING_OF_WISDOM.requestType, mb_Paladin_HandleBlessingOfWisdomRequest)
    mb_RegisterForRequest(BUFF_BLESSING_OF_MIGHT.requestType, mb_Paladin_HandleBlessingOfMightRequest)
    mb_RegisterForRequest(BUFF_BLESSING_OF_KINGS.requestType, mb_Paladin_HandleBlessingOfKingsRequest)
    mb_RegisterForRequest(BUFF_BLESSING_OF_LIGHT.requestType, mb_Paladin_HandleBlessingOfLightRequest)
    mb_RegisterForRequest(BUFF_BLESSING_OF_SANCTUARY.requestType, mb_Paladin_HandleBlessingOfSanctuaryRequest)
    mb_RegisterForRequest(BUFF_BLESSING_OF_SALVATION.requestType, mb_Paladin_HandleBlessingOfSalvationRequest)
    mb_Paladin_AddDesiredTalents()
end

function mb_Paladin_HandleResurrectionRequest(requestId, requestType, requestBody)
    if mb_CanResurrectUnitWithSpell(max_GetUnitForPlayerName(requestBody), "Redemption") then
        mb_AcceptRequest(requestId, requestType, requestBody)
    end
end

function mb_Paladin_HandleBlessingOfWisdomRequest(requestId, requestType, requestBody)
    if not mb_Paladin_HasImprovedWisdom() then
        return
    end
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(requestBody), "Blessing of Wisdom") then
        mb_AcceptRequest(requestId, requestType, requestBody)
    end
end

function mb_Paladin_HandleBlessingOfMightRequest(requestId, requestType, requestBody)
    if not mb_Paladin_HasImprovedMight() then
        return
    end
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(requestBody), "Blessing of Might") then
        mb_AcceptRequest(requestId, requestType, requestBody)
    end
end

function mb_Paladin_HandleBlessingOfKingsRequest(requestId, requestType, requestBody)
    if not mb_Paladin_HasKings() then
        return
    end
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(requestBody), "Blessing of Kings") then
        mb_AcceptRequest(requestId, requestType, requestBody)
    end
end

function mb_Paladin_HandleBlessingOfLightRequest(requestId, requestType, requestBody)
    if mb_GetConfig()["specs"][UnitName("player")] ~= "RetLight" then
        return
    end
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(requestBody), "Blessing of Light") then
        mb_AcceptRequest(requestId, requestType, requestBody)
    end
end

function mb_Paladin_HandleBlessingOfSanctuaryRequest(requestId, requestType, requestBody)
    if not mb_Paladin_HasSanctuary() then
        return
    end
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(requestBody), "Blessing of Sanctuary") then
        mb_AcceptRequest(requestId, requestType, requestBody)
    end
end

function mb_Paladin_HandleBlessingOfSalvationRequest(requestId, requestType, requestBody)
    if mb_GetConfig()["specs"][UnitName("player")] ~= "RetLight" then
        return
    end
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(requestBody), "Blessing of Salvation") then
        mb_AcceptRequest(requestId, requestType, requestBody)
    end
end

function mb_Paladin_HasImprovedWisdom()
    local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(1, 10)
    return currentRank == 2
end

function mb_Paladin_HasImprovedMight()
    local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(3, 1)
    return currentRank == 5
end

function mb_Paladin_HasKings()
    local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(2, 6)
    return currentRank == 1
end

function mb_Paladin_HasSanctuary()
    local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(2, 12)
    return currentRank == 1
end


function mb_Paladin_AddDesiredTalents()
    local mySpec = mb_GetConfig()["specs"][UnitName("player")]
    if mySpec == "SanctuarySalvation" then
        mb_AddDesiredTalent(2, 1, 5) -- Improved Devotion Aura
        mb_AddDesiredTalent(2, 4, 2) -- Guardian's Favor
        mb_AddDesiredTalent(2, 5, 5) -- Toughness
        mb_AddDesiredTalent(2, 9, 5) -- Anticipation
        mb_AddDesiredTalent(2, 11, 3) -- Improved Concentration Aura
        mb_AddDesiredTalent(2, 12, 1) -- Blessing of Sanctuary
        -- Sanctuary first, out of order
        mb_AddDesiredTalent(1, 1, 1) -- Divine Strength
        mb_AddDesiredTalent(1, 2, 5) -- Divine Intellect
        mb_AddDesiredTalent(1, 3, 5) -- Spiritual Focus
        mb_AddDesiredTalent(1, 5, 3) -- Healing Light
        mb_AddDesiredTalent(1, 6, 1) -- Consecration
        mb_AddDesiredTalent(1, 7, 2) -- Improved Lay on Hands
        mb_AddDesiredTalent(1, 8, 2) -- Unyielding Faith
        mb_AddDesiredTalent(1, 9, 5) -- Illumination
        mb_AddDesiredTalent(1, 11, 1) -- Divine Favor
        mb_AddDesiredTalent(1, 13, 5) -- Holy Power
    elseif mySpec == "KingsJudge" then
        mb_AddDesiredTalent(2, 1, 5) -- Improved Devotion Aura
        mb_AddDesiredTalent(2, 4, 2) -- Guardian's Favor
        mb_AddDesiredTalent(2, 5, 3) -- Toughness
        mb_AddDesiredTalent(2, 6, 1) -- Blessing of Kings
        -- Kings first, out of order
        mb_AddDesiredTalent(1, 2, 5) -- Divine Intellect
        mb_AddDesiredTalent(1, 3, 5) -- Spiritual Focus
        mb_AddDesiredTalent(1, 5, 3) -- Healing Light
        mb_AddDesiredTalent(1, 6, 1) -- Consecration
        mb_AddDesiredTalent(1, 7, 2) -- Improved Lay on Hands
        mb_AddDesiredTalent(1, 8, 2) -- Unyielding Faith
        mb_AddDesiredTalent(1, 9, 5) -- Illumination
        mb_AddDesiredTalent(1, 11, 1) -- Divine Favor
        mb_AddDesiredTalent(1, 12, 3) -- Lasting Judgement
        mb_AddDesiredTalent(1, 13, 5) -- Holy Power
        mb_AddDesiredTalent(1, 14, 1) -- Holy Shock
        mb_AddDesiredTalent(3, 2, 5) -- Benediction
        mb_AddDesiredTalent(3, 3, 2) -- Improved Judgement
    elseif mySpec == "Wisdom" then
        mb_AddDesiredTalent(1, 2, 5) -- Divine Intellect
        mb_AddDesiredTalent(1, 3, 5) -- Spiritual Focus
        mb_AddDesiredTalent(1, 5, 3) -- Healing Light
        mb_AddDesiredTalent(1, 6, 1) -- Consecration
        mb_AddDesiredTalent(1, 7, 2) -- Improved Lay on Hands
        mb_AddDesiredTalent(1, 8, 2) -- Unyielding Faith
        mb_AddDesiredTalent(1, 9, 5) -- Illumination
        mb_AddDesiredTalent(1, 10, 2) -- Improved Blessing of Wisdom
        mb_AddDesiredTalent(1, 11, 1) -- Divine Favor
        mb_AddDesiredTalent(1, 13, 5) -- Holy Power
        mb_AddDesiredTalent(1, 14, 1) -- Holy Shock
        mb_AddDesiredTalent(2, 1, 5) -- Improved Devotion Aura
        mb_AddDesiredTalent(2, 4, 2) -- Guardian's Favor
        mb_AddDesiredTalent(2, 5, 5) -- Toughness
        mb_AddDesiredTalent(2, 9, 4) -- Anticipation
        mb_AddDesiredTalent(2, 11, 3) -- Improved Concentration Aura
    elseif mySpec == "MightJudge" then
        mb_AddDesiredTalent(3, 1, 5) -- Improved Blessing of Might
        -- Might first, out of order
        mb_AddDesiredTalent(1, 2, 5) -- Divine Intellect
        mb_AddDesiredTalent(1, 3, 5) -- Spiritual Focus
        mb_AddDesiredTalent(1, 5, 3) -- Healing Light
        mb_AddDesiredTalent(1, 6, 1) -- Consecration
        mb_AddDesiredTalent(1, 7, 2) -- Improved Lay on Hands
        mb_AddDesiredTalent(1, 8, 2) -- Unyielding Faith
        mb_AddDesiredTalent(1, 9, 5) -- Illumination
        mb_AddDesiredTalent(1, 11, 1) -- Divine Favor
        mb_AddDesiredTalent(1, 12, 3) -- Lasting Judgement
        mb_AddDesiredTalent(1, 13, 5) -- Holy Power
        mb_AddDesiredTalent(2, 1, 5) -- Improved Devotion Aura
        mb_AddDesiredTalent(3, 2, 5) -- Benediction
        mb_AddDesiredTalent(3, 3, 2) -- Improved Judgement
        mb_AddDesiredTalent(3, 9, 2) -- Pursuit of Justice
    elseif mySpec == "RetLight" then
        mb_AddDesiredTalent(1, 1, 5) -- Divine Strength
        mb_AddDesiredTalent(1, 2, 5) -- Divine Intellect
        mb_AddDesiredTalent(1, 6, 1) -- Consecration
        mb_AddDesiredTalent(2, 1, 5) -- Improved Devotion Aura
        mb_AddDesiredTalent(2, 3, 3) -- Precision
        mb_AddDesiredTalent(3, 2, 5) -- Benediction
        mb_AddDesiredTalent(3, 3, 2) -- Improved Judgement
        mb_AddDesiredTalent(3, 5, 3) -- Deflection
        mb_AddDesiredTalent(3, 6, 3) -- Vindication
        mb_AddDesiredTalent(3, 7, 5) -- Conviction
        mb_AddDesiredTalent(3, 8, 1) -- Seal of Command
        mb_AddDesiredTalent(3, 9, 2) -- Pursuit of Justice
        mb_AddDesiredTalent(3, 11, 2) -- Improved Retribution Aura
        mb_AddDesiredTalent(3, 12, 3) -- Two-Handed Weapon Specialization
        mb_AddDesiredTalent(3, 13, 1) -- Sanctity Aura
        mb_AddDesiredTalent(3, 14, 5) -- Vengeance
    else
        max_SayRaid("Serious error, bad spec for paladin: " .. mySpec)
    end
end