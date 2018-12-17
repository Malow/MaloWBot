function mb_Priest(commander)
    if mb_DoBasicCasterLogic() then
        return
    end

    local request = mb_GetQueuedRequest()
    if request ~= nil then
        if request.type == BUFF_POWER_WORD_FORTITUDE.type then
            if mb_IsOnGCD() then
                return
            end
            mb_RequestCompleted(request)
            if mb_ShouldBuffGroupWide(request.body, BUFF_POWER_WORD_FORTITUDE) then
                max_CastSpellOnRaidMemberByPlayerName("Prayer of Fortitude", request.body)
                return
            elseif not max_HasBuffWithMultipleTextures(max_GetUnitForPlayerName(request.body), BUFF_POWER_WORD_FORTITUDE.textures) then
                max_CastSpellOnRaidMemberByPlayerName("Power Word: Fortitude", request.body)
                return
            end
        elseif request.type == BUFF_DIVINE_SPIRIT.type then
            if mb_IsOnGCD() then
                return
            end
            mb_RequestCompleted(request)
            if mb_ShouldBuffGroupWide(request.body, BUFF_DIVINE_SPIRIT, UNIT_FILTER_HAS_MANA) then
                max_CastSpellOnRaidMemberByPlayerName("Prayer of Spirit", request.body)
                return
            elseif not max_HasBuffWithMultipleTextures(max_GetUnitForPlayerName(request.body), BUFF_DIVINE_SPIRIT.textures) then
                max_CastSpellOnRaidMemberByPlayerName("Divine Spirit", request.body)
                return
            end
        elseif request.type == REQUEST_RESURRECT.type then
            if mb_IsOnGCD() then
                return
            end
            max_CastSpellOnRaidMemberByPlayerName("Resurrection", request.body)
            mb_RequestCompleted(request)
            return
        elseif request.type == REQUEST_REMOVE_MAGIC.type then
            if mb_IsOnGCD() then
                return
            end
            max_CastSpellOnRaidMemberByPlayerName("Dispel Magic", request.body)
            mb_RequestCompleted(request)
            return
        else
            max_SayRaid("Serious error, received request for " .. request.type)
        end
    end

    if mb_Priest_PrayerOfHealing() then
        return
    end

    if mb_GetMySpecName() == "Disc" then
        if mb_Priest_Disc() then
            return true
        end
    elseif mb_GetMySpecName() == "Holy" then
        if mb_Priest_Holy() then
            return true
        end
    else
        max_SayRaid("Serious error, bad spec for priest: " .. mySpec)
    end

    if mb_areaOfEffectMode then
        CastSpellByName("Holy Nova")
        return
    end

    max_AssistByPlayerName(commander)
    if not UnitExists("target") or not UnitIsEnemy("player", "target") then
        return
    end

    if max_GetManaPercentage("player") > 95 then
        CastSpellByName("Smite")
    end

    if not mb_isAutoAttacking then
        CastSpellByName("Attack")
        return
    end
end

function mb_Priest_Disc()
    if mb_Priest_PWS() then
        return true
    end
    if mb_Priest_Renew() then
        return true
    end
    return false
end

function mb_Priest_Holy()
    if mb_Priest_Renew() then
        return true
    end
    return false
end

function mb_Priest_PWS()
    local spell = "Power Word: Shield"
    if max_IsSpellNameOnCooldown(spell) then
        return false
    end
    local unitFilter = UNIT_FILTER_DOES_NOT_HAVE_DEBUFF
    unitFilter.debuff = DEBUFF_TEXTURE_WEAKENED_SOUL
    local healTargetUnit, healthOfTarget = mb_GetLowestHealthFriendly(spell, unitFilter)
    if max_GetHealthPercentage(healTargetUnit) < 50 then
        max_CastSpellOnRaidMember(spell, healTargetUnit)
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
        max_CastSpellOnRaidMember(spell, healTargetUnit)
        return true
    end
    return false
end

function mb_Priest_PrayerOfHealing()
    local groupUnits = max_GetGroupUnitsFor(UnitName("player"))
    local count = 0
    for i = 1, max_GetTableSize(groupUnits) do
        if mb_IsUnitValidTarget(groupUnits[i], "Dispel Magic") and max_GetMissingHealth(groupUnits[i]) > 1000 then
            -- Using Dispel Magic, a 30yd range spell, as range-check for the 36-yard effect of PoH
            count = count + 1
        end
    end
    if count > 3 then
        CastSpellByName("Prayer of Healing")
        return true
    end
    return false
end

function mb_Priest_OnLoad()
    if mb_Priest_HasImprovedFortitude() then
        mb_RegisterForRequest(BUFF_POWER_WORD_FORTITUDE.type, mb_Priest_HandlePowerWordFortitudeRequest)
        mb_RegisterRangeCheckSpell("Power Word: Fortitude")
        mb_RegisterRangeCheckSpell("Prayer of Fortitude")
    end
    if mb_Priest_HasDivineSpirit() then
        mb_RegisterForRequest(BUFF_DIVINE_SPIRIT.type, mb_Priest_HandleDivineSpiritRequest)
        mb_RegisterRangeCheckSpell("Divine Spirit")
        mb_RegisterRangeCheckSpell("Prayer of Spirit")
    end
    mb_RegisterForRequest(REQUEST_RESURRECT.type, mb_Priest_HandleResurrectionRequest)
    mb_RegisterForRequest(REQUEST_REMOVE_MAGIC.type, mb_Priest_HandleDispelRequest)
    mb_AddDesiredBuff(BUFF_MARK_OF_THE_WILD)
    mb_AddDesiredBuff(BUFF_ARCANE_INTELLECT)
    mb_AddDesiredBuff(BUFF_POWER_WORD_FORTITUDE)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_WISDOM)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_KINGS)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_LIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_SALVATION)
    mb_AddDesiredBuff(BUFF_DIVINE_SPIRIT)
    mb_Priest_AddDesiredTalents()
    mb_AddGCDCheckSpell("Renew")
    mb_AddReagentWatch("Sacred Candle", 20)
    mb_RegisterRangeCheckSpell("Resurrection")
    mb_RegisterRangeCheckSpell("Dispel Magic")
    mb_RegisterRangeCheckSpell("Renew")
    mb_RegisterRangeCheckSpell("Power Word: Shield")
end

function mb_Priest_HandlePowerWordFortitudeRequest(request)
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(request.body), "Power Word: Fortitude") then
        mb_AcceptRequest(request)
    end
end

function mb_Priest_HandleDivineSpiritRequest(request)
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(request.body), "Divine Spirit") then
        mb_AcceptRequest(request)
    end
end

function mb_Priest_HandleResurrectionRequest(request)
    if mb_CanResurrectUnitWithSpell(max_GetUnitForPlayerName(request.body), "Resurrection") then
        mb_AcceptRequest(request)
    end
end

function mb_Priest_HandleDispelRequest(request)
    if mb_IsUnitValidTarget(max_GetUnitForPlayerName(request.body), "Dispel Magic") then
        mb_AcceptRequest(request)
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