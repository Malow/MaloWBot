mb_paladinIsJudgingLight = false
mb_paladinIsJudgingWisdom = false
mb_paladinAura = "devo"
function mb_Paladin(commander)
    if mb_DoBasicCasterLogicThrottled() then
        return
    end

    if mb_IsCasting() then
        mb_StopCastingIfNeeded(mb_Paladin_ShouldStopCasting)
        return
    end

    if mb_IsOnGCD() then
        return
    end

    local request = mb_GetQueuedRequest(true)
    if request ~= nil then
        if mb_CompleteStandardBuffRequest(request) then
            return
        elseif request.type == REQUEST_RESURRECT.type then
            max_CastSpellOnRaidMemberByPlayerName("Redemption", request.body)
            max_SayRaid("I'm resurrecting " .. request.body)
            mb_RequestCompleted(request)
            return
        elseif request.type == REQUEST_REMOVE_MAGIC.type or request.type == REQUEST_REMOVE_DISEASE.type or request.type == REQUEST_REMOVE_POISON.type then
            max_CastSpellOnRaidMemberByPlayerName("Cleanse", request.body)
            mb_RequestCompleted(request)
            return
        end
    end

    if UnitAffectingCombat("player") and max_GetHealthPercentage("player") < 30 and not max_IsSpellNameOnCooldown("Divine Shield") then
        CastSpellByName("Divine Shield")
        return
    end

    if UnitAffectingCombat("player") and max_GetManaPercentage("player") < 80 then
        CastSpellByName("Divine Favor")
    end

    if not mb_Paladin_HasAura() then
        mb_Paladin_CastAura()
        return
    end

    --if mb_CleanseRaidMemberThrottled("Cleanse", "Magic", "Poison", "Disease", UNIT_FILTER_DOES_NOT_HAVE_MANA) then
    if mb_CleanseRaidMemberThrottled("Cleanse", "Magic", "Poison", "Disease") then
        return
    end

    if mb_Paladin_FlashOfLight() then
        return
    end

    max_AssistByPlayerName(commander)
    if not max_HasValidOffensiveTarget() then
        return
    end

    if mb_Paladin_Judge() then
        return
    end

    if not mb_isAutoAttacking then
        CastSpellByName("Attack")
        return
    end
end

function mb_Paladin_ShouldStopCasting(currentCast)
    if currentCast.spellName == "Flash of Light" then
        local targetMissingHealth = max_GetMissingHealth(currentCast.target)
        if (targetMissingHealth - (mb_GetHoTCount(currentCast.target) * 800)) < 500 then
            return true
        end
    end
    return false
end

function mb_Paladin_FlashOfLight()
    local spell = "Flash of Light"
    local healTargetUnit, missingHealth = mb_HealingModule_GetRaidHealTarget(spell)
    if missingHealth > 500 then
        --max_SayRaid("Started FoL on " .. UnitName(healTargetUnit) .. ". Current missing health: " .. max_GetMissingHealth(healTargetUnit) .. " - Calculated missing health: " .. missingHealth)
        local callBacks = {}
        callBacks.onStart = function(spellCast)
            mb_HealingModule_SendData(UnitName(spellCast.target), 600, mb_GetTime() + 1.5)
        end
        mb_CastSpellByNameOnRaidMemberWithCallbacks(spell, healTargetUnit, callBacks)
        return true
    end
    return false
end

function mb_Paladin_HasAura()
    if max_HasBuff("player", BUFF_TEXTURE_DEVOTION_AURA) then
        return true
    elseif max_HasBuff("player", BUFF_TEXTURE_RETRIBUTION_AURA) then
        return true
    elseif max_HasBuff("player", BUFF_TEXTURE_CONCENTRATION_AURA) then
        return true
    elseif max_HasBuff("player", BUFF_TEXTURE_SHADOW_RESISTANCE_AURA) then
        return true
    elseif max_HasBuff("player", BUFF_TEXTURE_FROST_RESISTANCE_AURA) then
        return true
    elseif max_HasBuff("player", BUFF_TEXTURE_FIRE_RESISTANCE_AURA) then
        return true
    end
    return false
end

function mb_Paladin_CastAura()
    if mb_paladinAura == "devo" then
        if not max_HasBuff("player", BUFF_TEXTURE_DEVOTION_AURA) then
            CastSpellByName("Devotion Aura")
        end
        return
    end
    if mb_paladinAura == "ret" then
        if not max_HasBuff("player", BUFF_TEXTURE_RETRIBUTION_AURA) then
            CastSpellByName("Retribution Aura")
        end
        return
    end
    if mb_paladinAura == "conc" then
        if not max_HasBuff("player", BUFF_TEXTURE_CONCENTRATION_AURA) then
            CastSpellByName("Concentration Aura")
        end
        return
    end
    if mb_paladinAura == "shadow" then
        if not max_HasBuff("player", BUFF_TEXTURE_SHADOW_RESISTANCE_AURA) then
            CastSpellByName("Shadow Resistance Aura")
        end
        return
    end
    if mb_paladinAura == "frost" then
        if not max_HasBuff("player", BUFF_TEXTURE_FROST_RESISTANCE_AURA) then
            CastSpellByName("Frost Resistance Aura")
        end
        return
    end
    if mb_paladinAura == "fire" then
        if not max_HasBuff("player", BUFF_TEXTURE_FIRE_RESISTANCE_AURA) then
            CastSpellByName("Fire Resistance Aura")
        end
        return
    end
end

function mb_Paladin_OnLoad()
    mb_AddDesiredBuff(BUFF_MARK_OF_THE_WILD)
    mb_AddDesiredBuff(BUFF_ARCANE_INTELLECT)
    mb_AddDesiredBuff(BUFF_POWER_WORD_FORTITUDE)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_WISDOM)
    --mb_AddDesiredBuff(BUFF_BLESSING_OF_MIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_KINGS)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_LIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_SALVATION)
    mb_AddDesiredBuff(BUFF_DIVINE_SPIRIT)
    mb_AddDesiredBuff(BUFF_SHADOW_PROTECTION)
    mb_RegisterForRequest(REQUEST_RESURRECT.type, mb_Paladin_HandleResurrectionRequest)
    mb_RegisterForRequest(REQUEST_REMOVE_MAGIC.type, mb_Paladin_HandleCleanseRequest)
    mb_RegisterForRequest(REQUEST_REMOVE_POISON.type, mb_Paladin_HandleCleanseRequest)
    mb_RegisterForRequest(REQUEST_REMOVE_DISEASE.type, mb_Paladin_HandleCleanseRequest)
    mb_RegisterForRequest("palaAura", mb_Paladin_HandleAuraRequest)
    mb_RegisterForRequest("useConsumable", mb_Healer_HandleUseConsumableRequest)
    if mb_GetMySpecName() == "Wisdom" then
        mb_RegisterForStandardBuffRequest(BUFF_BLESSING_OF_WISDOM)
        mb_RegisterForStandardBuffRequest(BUFF_BLESSING_OF_MIGHT)
    elseif mb_GetMySpecName() == "MightJudge" then
        mb_RegisterForStandardBuffRequest(BUFF_BLESSING_OF_MIGHT)
    elseif mb_GetMySpecName() == "KingsJudge" then
        mb_RegisterForStandardBuffRequest(BUFF_BLESSING_OF_KINGS)
    elseif mb_GetMySpecName() == "RetLight" or mb_GetMySpecName() == "LightHoly" then
        mb_RegisterForStandardBuffRequest(BUFF_BLESSING_OF_LIGHT)
    elseif mb_GetMySpecName() == "SanctuarySalvation" then
        mb_RegisterForStandardBuffRequest(BUFF_BLESSING_OF_SALVATION)
        mb_RegisterForStandardBuffRequest(BUFF_BLESSING_OF_SANCTUARY)
    end
    mb_Paladin_AddDesiredTalents()
    mb_AddReagentWatch("Symbol of Kings", 400)
    mb_AddReagentWatch("Major Mana Potion", 10)
    mb_AddGCDCheckSpell("Holy Light")
    mb_RegisterClassSyncDataFunctions(mb_Paladin_CreateClassSyncData, mb_Paladin_ReceivedClassSyncData)
    mb_RegisterRangeCheckSpell("Flash of Light")
    mb_RegisterRangeCheckSpell("Cleanse")
    mb_RegisterRangeCheckSpell("Redemption")
    mb_RegisterRangeCheckSpell("Judgement")
    mb_HealingModule_Enable()
end

function mb_Paladin_HandleResurrectionRequest(request)
    if mb_CanResurrectUnitWithSpell(max_GetUnitForPlayerName(request.body), "Redemption") then
        mb_AcceptRequest(request)
    end
end

function mb_Paladin_HandleAuraRequest(request)
    mb_paladinAura = request.body
    mb_Paladin_CastAura()
end

function mb_Paladin_HandleCleanseRequest(request)
    if UnitIsDead("player") then
        return
    end
    if mb_IsUnitValidTarget(max_GetUnitForPlayerName(request.body), "Cleanse") and UnitMana("player") > 500 then
        mb_AcceptRequest(request)
    end
end

function mb_Paladin_Judge()
    local cur, max, found = MobHealth3:GetUnitHealth("target")
    if found and cur < APPLY_DEBUFFS_HEALTH_ABOVE then
        return false
    end

    if not mb_IsSpellInRange("Judgement", "target") then
        return false
    end

    if mb_paladinIsJudgingLight then
        if not max_HasDebuff("target", DEBUFF_TEXTURE_JUDGEMENT_OF_LIGHT) then
            if max_HasBuff("player", BUFF_TEXTURE_SEAL_OF_LIGHT) then
                CastSpellByName("Judgement")
                return true
            else
                CastSpellByName("Seal of Light")
                return true
            end
        end
    end

    if mb_paladinIsJudgingWisdom then
        if not max_HasDebuff("target", DEBUFF_TEXTURE_JUDGEMENT_OF_WISDOM) then
            if max_HasBuff("player", BUFF_TEXTURE_SEAL_OF_WISDOM) then
                CastSpellByName("Judgement")
                return true
            else
                CastSpellByName("Seal of Wisdom")
                return true
            end
        end
    end
    return false
end

function mb_Paladin_CreateClassSyncData()
    local classMates = mb_GetClassMates(max_GetClass("player"))
    if max_GetTableSize(classMates) < 2 then
        return ""
    end
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
    elseif mb_GetMySpecName() == "LightHoly" then
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
        mb_AddDesiredTalent(1, 14, 1) -- Holy Shock
        mb_AddDesiredTalent(2, 1, 5) -- Improved Devotion Aura
        mb_AddDesiredTalent(2, 4, 2) -- Guardian's Favor
        mb_AddDesiredTalent(2, 5, 5) -- Toughness
        mb_AddDesiredTalent(2, 9, 5) -- Anticipation
        mb_AddDesiredTalent(2, 11, 3) -- Improved Concentration Aura
    else
        max_SayRaid("Serious error, bad spec for paladin: " .. mb_GetMySpecName())
    end
end