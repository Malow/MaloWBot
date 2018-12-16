mb_paladinIsJudgingLight = false
mb_paladinIsJudgingWisdom = false
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
            mb_RequestCompleted(request)
            if not max_HasBuffWithMultipleTextures(max_GetUnitForPlayerName(request.body), BUFF_BLESSING_OF_WISDOM.textures) then
                max_CastSpellOnRaidMemberByPlayerName("Greater Blessing of Wisdom", request.body)
                return
            end
        elseif request.type == BUFF_BLESSING_OF_MIGHT.type then
            if mb_IsOnGCD() then
                return
            end
            mb_RequestCompleted(request)
            if not max_HasBuffWithMultipleTextures(max_GetUnitForPlayerName(request.body), BUFF_BLESSING_OF_MIGHT.textures) then
                max_CastSpellOnRaidMemberByPlayerName("Greater Blessing of Might", request.body)
                return
            end
        elseif request.type == BUFF_BLESSING_OF_KINGS.type then
            if mb_IsOnGCD() then
                return
            end
            mb_RequestCompleted(request)
            if not max_HasBuffWithMultipleTextures(max_GetUnitForPlayerName(request.body), BUFF_BLESSING_OF_KINGS.textures) then
                max_CastSpellOnRaidMemberByPlayerName("Greater Blessing of Kings", request.body)
                return
            end
        elseif request.type == BUFF_BLESSING_OF_LIGHT.type then
            if mb_IsOnGCD() then
                return
            end
            mb_RequestCompleted(request)
            if not max_HasBuffWithMultipleTextures(max_GetUnitForPlayerName(request.body), BUFF_BLESSING_OF_LIGHT.textures) then
                max_CastSpellOnRaidMemberByPlayerName("Greater Blessing of Light", request.body)
                return
            end
        elseif request.type == BUFF_BLESSING_OF_SANCTUARY.type then
            if mb_IsOnGCD() then
                return
            end
            mb_RequestCompleted(request)
            if not max_HasBuffWithMultipleTextures(max_GetUnitForPlayerName(request.body), BUFF_BLESSING_OF_SANCTUARY.textures) then
                max_CastSpellOnRaidMemberByPlayerName("Greater Blessing of Sanctuary", request.body)
                return
            end
        elseif request.type == BUFF_BLESSING_OF_SALVATION.type then
            if mb_IsOnGCD() then
                return
            end
            mb_RequestCompleted(request)
            if not max_HasBuffWithMultipleTextures(max_GetUnitForPlayerName(request.body), BUFF_BLESSING_OF_SALVATION.textures) then
                max_CastSpellOnRaidMemberByPlayerName("Greater Blessing of Salvation", request.body)
                return
            end
        elseif request.type == REQUEST_RESURRECT.type then
            if mb_IsOnGCD() then
                return
            end
            max_CastSpellOnRaidMemberByPlayerName("Redemption", request.body)
            mb_RequestCompleted(request)
            return
        elseif request.type == REQUEST_REMOVE_MAGIC.type or request.type == REQUEST_REMOVE_DISEASE.type or request.type == REQUEST_REMOVE_POISON.type then
            if mb_IsOnGCD() then
                return
            end
            max_CastSpellOnRaidMemberByPlayerName("Cleanse", request.body)
            mb_RequestCompleted(request)
            return
        else
            max_SayRaid("Serious error, received request for " .. request.type)
        end
    end

    if not mb_Paladin_HasAura() then
        CastSpellByName("Devotion Aura")
        return
    end

    if mb_Paladin_FlashOfLight() then
        return
    end

    max_AssistByPlayerName(commander)
    if not UnitExists("target") or not UnitIsEnemy("player", "target") then
        return
    end

    if mb_paladinIsJudgingLight then
        if not max_HasDebuff("target", DEBUFF_TEXTURE_JUDGEMENT_OF_LIGHT) then
            if max_HasBuff("player", BUFF_TEXTURE_SEAL_OF_LIGHT) then
                CastSpellByName("Judgement")
                return
            else
                CastSpellByName("Seal of Light")
                return
            end
        end
    end

    if mb_paladinIsJudgingWisdom then
        if not max_HasDebuff("target", DEBUFF_TEXTURE_JUDGEMENT_OF_WISDOM) then
            if max_HasBuff("player", BUFF_TEXTURE_SEAL_OF_WISDOM) then
                CastSpellByName("Judgement")
                return
            else
                CastSpellByName("Seal of Wisdom")
                return
            end
        end
    end

    --CastSpellByName("Attack")
end

function mb_Paladin_FlashOfLight()
    local spell = "Flash of Light"
    local healTargetUnit, missingHealth = mb_GetMostDamagedFriendly(spell)
    if missingHealth > 200 then
        max_CastSpellOnRaidMember(spell, healTargetUnit)
        return true
    end
    return false
end

function mb_Paladin_HasAura()
    if max_HasBuff("player", BUFF_TEXTURE_DEVOTION_AURA) then
        return true
    elseif max_HasBuff("player", BUFF_TEXTURE_FIRE_RESISTANCE_AURA) then
        return true
    end
    return false
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
    mb_RegisterForRequest(REQUEST_REMOVE_MAGIC.type, mb_Paladin_HandleCleanseRequest)
    mb_RegisterForRequest(REQUEST_REMOVE_POISON.type, mb_Paladin_HandleCleanseRequest)
    mb_RegisterForRequest(REQUEST_REMOVE_DISEASE.type, mb_Paladin_HandleCleanseRequest)
    if mb_GetMySpecName() == "Wisdom" then
        mb_RegisterForRequest(BUFF_BLESSING_OF_WISDOM.type, mb_Paladin_HandleBlessingOfWisdomRequest)
    elseif mb_GetMySpecName() == "MightJudge" then
        mb_RegisterForRequest(BUFF_BLESSING_OF_MIGHT.type, mb_Paladin_HandleBlessingOfMightRequest)
    elseif mb_GetMySpecName() == "KingsJudge" then
        mb_RegisterForRequest(BUFF_BLESSING_OF_KINGS.type, mb_Paladin_HandleBlessingOfKingsRequest)
    elseif mb_GetMySpecName() == "RetLight" then
        mb_RegisterForRequest(BUFF_BLESSING_OF_LIGHT.type, mb_Paladin_HandleBlessingOfLightRequest)
    elseif mb_GetMySpecName() == "SanctuarySalvation" then
        mb_RegisterForRequest(BUFF_BLESSING_OF_SALVATION.type, mb_Paladin_HandleBlessingOfSalvationRequest)
        mb_RegisterForRequest(BUFF_BLESSING_OF_SANCTUARY.type, mb_Paladin_HandleBlessingOfSanctuaryRequest)
    end
    mb_Paladin_AddDesiredTalents()
    mb_AddReagentWatch("Symbol of Kings", 100)
    mb_AddGCDCheckSpell("Holy Light")
    mb_RegisterClassSyncDataFunctions(mb_Paladin_CreateClassSyncData, mb_Paladin_ReceivedClassSyncData)
end

function mb_Paladin_HandleResurrectionRequest(request)
    if mb_CanResurrectUnitWithSpell(max_GetUnitForPlayerName(request.body), "Redemption") then
        mb_AcceptRequest(request)
    end
end

function mb_Paladin_HandleBlessingOfWisdomRequest(request)
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(request.body), "Greater Blessing of Wisdom") then
        mb_AcceptRequest(request)
    end
end

function mb_Paladin_HandleBlessingOfMightRequest(request)
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(request.body), "Greater Blessing of Might") then
        mb_AcceptRequest(request)
    end
end

function mb_Paladin_HandleBlessingOfKingsRequest(request)
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(request.body), "Greater Blessing of Kings") then
        mb_AcceptRequest(request)
    end
end

function mb_Paladin_HandleBlessingOfLightRequest(request)
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(request.body), "Greater Blessing of Light") then
        mb_AcceptRequest(request)
    end
end

function mb_Paladin_HandleBlessingOfSanctuaryRequest(request)
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(request.body), "Greater Blessing of Sanctuary") then
        mb_AcceptRequest(request)
    end
end

function mb_Paladin_HandleBlessingOfSalvationRequest(request)
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(request.body), "Greater Blessing of Salvation") then
        mb_AcceptRequest(request)
    end
end

function mb_Paladin_HandleCleanseRequest(request)
    if mb_IsUnitValidTarget(max_GetUnitForPlayerName(request.body), "Cleanse") then
        mb_AcceptRequest(request)
    end
end

function mb_Paladin_CreateClassSyncData()
    local classMates = mb_GetClassMates(max_GetClass("player"))
    local kingsJudger = nil
    local mightJudger = nil
    for k, v in pairs(mb_GetConfig()["specs"]) do
        if v == "KingsJudge" then
            kingsJudger = k
        elseif v == "MightJudge" then
            mightJudger = k
        end
    end
    local data = ""
    if kingsJudger ~= nil and max_TableContains(classMates, kingsJudger) then
        data = data .. kingsJudger
    end
    data = data .. "/"
    if mightJudger ~= nil and max_TableContains(classMates, mightJudger) then
        data = data .. mightJudger
    end
    return data
end

function mb_Paladin_ReceivedClassSyncData()
    if mb_classSyncData ~= "" then
        local assignments = max_SplitString(mb_classSyncData, "/")
        mb_paladinIsJudgingWisdom = assignments[1] == UnitName("player")
        mb_paladinIsJudgingLight = assignments[2] == UnitName("player")
    else
        mb_paladinIsJudgingWisdom = false
        mb_paladinIsJudgingLight = false
    end
end

function mb_Paladin_AddDesiredTalents()
    if mb_GetMySpecName() == "SanctuarySalvation" then
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
    elseif mb_GetMySpecName() == "KingsJudge" then
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
    elseif mb_GetMySpecName() == "Wisdom" then
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
    elseif mb_GetMySpecName() == "MightJudge" then
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
    elseif mb_GetMySpecName() == "RetLight" then
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