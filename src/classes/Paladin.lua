function mb_Paladin(commander)
    if mb_DoBasicCasterLogic() then
        return
    end

    local request = mb_GetQueuedRequest()
    if request ~= nil then
        if request.type == BUFF_BLESSING_OF_WISDOM.type then
            if mb_IsOnGCD() then
                return
            end
            max_CastSpellOnRaidMemberByPlayerName("Greater Blessing of Wisdom", request.body)
            mb_RequestCompleted(request)
            return
        elseif request.type == BUFF_BLESSING_OF_MIGHT.type then
            if mb_IsOnGCD() then
                return
            end
            max_CastSpellOnRaidMemberByPlayerName("Greater Blessing of Might", request.body)
            mb_RequestCompleted(request)
            return
        elseif request.type == BUFF_BLESSING_OF_KINGS.type then
            if mb_IsOnGCD() then
                return
            end
            max_CastSpellOnRaidMemberByPlayerName("Greater Blessing of Kings", request.body)
            mb_RequestCompleted(request)
            return
        elseif request.type == BUFF_BLESSING_OF_LIGHT.type then
            if mb_IsOnGCD() then
                return
            end
            max_CastSpellOnRaidMemberByPlayerName("Greater Blessing of Light", request.body)
            mb_RequestCompleted(request)
            return
        elseif request.type == BUFF_BLESSING_OF_SANCTUARY.type then
            if mb_IsOnGCD() then
                return
            end
            max_CastSpellOnRaidMemberByPlayerName("Greater Blessing of Sanctuary", request.body)
            mb_RequestCompleted(request)
            return
        elseif request.type == BUFF_BLESSING_OF_SALVATION.type then
            if mb_IsOnGCD() then
                return
            end
            max_CastSpellOnRaidMemberByPlayerName("Greater Blessing of Salvation", request.body)
            mb_RequestCompleted(request)
            return
        elseif request.type == REQUEST_RESURRECT.type then
            if mb_IsOnGCD() then
                return
            end
            max_CastSpellOnRaidMemberByPlayerName("Redemption", request.body)
            mb_RequestCompleted(request)
            return
        else
            max_SayRaid("Serious error, received request for " .. request.type)
        end
    end

    --local healSpell = "Flash of Light"
    --local healTargetUnit, missingHealth = mb_GetMostDamagedFriendly(healSpell)
    --if missingHealth > 50 then
    --    TargetUnit(healTargetUnit)
    --    CastSpellByName(healSpell)
    --    return
    --end
end

function mb_Paladin_OnLoad()
    mb_AddDesiredBuff(BUFF_MARK_OF_THE_WILD)
    mb_AddDesiredBuff(BUFF_ARCANE_INTELLECT)
    mb_AddDesiredBuff(BUFF_POWER_WORD_FORTITUDE)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_WISDOM)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_MIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_KINGS)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_LIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_SALVATION)
    mb_AddDesiredBuff(BUFF_DIVINE_SPIRIT)
    mb_RegisterForRequest(REQUEST_RESURRECT.type, mb_Paladin_HandleResurrectionRequest)
    mb_RegisterForRequest(BUFF_BLESSING_OF_WISDOM.type, mb_Paladin_HandleBlessingOfWisdomRequest)
    mb_RegisterForRequest(BUFF_BLESSING_OF_MIGHT.type, mb_Paladin_HandleBlessingOfMightRequest)
    mb_RegisterForRequest(BUFF_BLESSING_OF_KINGS.type, mb_Paladin_HandleBlessingOfKingsRequest)
    mb_RegisterForRequest(BUFF_BLESSING_OF_LIGHT.type, mb_Paladin_HandleBlessingOfLightRequest)
    mb_RegisterForRequest(BUFF_BLESSING_OF_SANCTUARY.type, mb_Paladin_HandleBlessingOfSanctuaryRequest)
    mb_RegisterForRequest(BUFF_BLESSING_OF_SALVATION.type, mb_Paladin_HandleBlessingOfSalvationRequest)
    mb_Paladin_AddDesiredTalents()
    mb_AddReagentWatch("Symbol of Kings", 100)
    mb_AddGCDCheckSpell("Holy Light")
end

function mb_Paladin_HandleResurrectionRequest(request)
    if mb_CanResurrectUnitWithSpell(max_GetUnitForPlayerName(request.body), "Redemption") then
        mb_AcceptRequest(request)
    end
end

function mb_Paladin_HandleBlessingOfWisdomRequest(request)
    if not mb_Paladin_HasImprovedWisdom() then
        return
    end
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(request.body), "Greater Blessing of Wisdom") then
        mb_AcceptRequest(request)
    end
end

function mb_Paladin_HandleBlessingOfMightRequest(request)
    if not mb_Paladin_HasImprovedMight() then
        return
    end
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(request.body), "Greater Blessing of Might") then
        mb_AcceptRequest(request)
    end
end

function mb_Paladin_HandleBlessingOfKingsRequest(request)
    if not mb_Paladin_HasKings() then
        return
    end
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(request.body), "Greater Blessing of Kings") then
        mb_AcceptRequest(request)
    end
end

function mb_Paladin_HandleBlessingOfLightRequest(request)
    if mb_GetConfig()["specs"][UnitName("player")] ~= "RetLight" then
        return
    end
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(request.body), "Greater Blessing of Light") then
        mb_AcceptRequest(request)
    end
end

function mb_Paladin_HandleBlessingOfSanctuaryRequest(request)
    if not mb_Paladin_HasSanctuary() then
        return
    end
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(request.body), "Greater Blessing of Sanctuary") then
        mb_AcceptRequest(request)
    end
end

function mb_Paladin_HandleBlessingOfSalvationRequest(request)
    if mb_GetConfig()["specs"][UnitName("player")] ~= "SanctuarySalvation" then
        return
    end
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(request.body), "Greater Blessing of Salvation") then
        mb_AcceptRequest(request)
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