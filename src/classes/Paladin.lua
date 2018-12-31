mb_paladinIsJudgingLight = false
mb_paladinIsJudgingWisdom = false
mb_paladinCurrentHealTarget = nil
function mb_Paladin(commander)
    if mb_DoBasicCasterLogic() then
        return
    end
    if mb_isCasting then
        if mb_paladinCurrentHealTarget ~= nil then
            local targetMissingHealth = max_GetMissingHealth(mb_paladinCurrentHealTarget)
            if (targetMissingHealth - (mb_GetHoTCount(mb_paladinCurrentHealTarget) * 500)) < 500 then
                SpellStopCasting()
            end
        end
        return
    else
        mb_paladinCurrentHealTarget = nil
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
        CastSpellByName("Devotion Aura")
        return
    end

    local debuffTarget = mb_GetDebuffedRaidMember("Cleanse", "Magic", "Poison", "Disease")
    if debuffTarget ~= nil then
        max_CastSpellOnRaidMember("Cleanse", debuffTarget)
        return
    end

    if mb_Paladin_FlashOfLight() then
        return
    end

    max_AssistByPlayerName(commander)
    if not UnitExists("target") or not UnitIsEnemy("player", "target") then
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

function mb_Paladin_FlashOfLight()
    local spell = "Flash of Light"
    local healTargetUnit, missingHealth = mb_HealingModule_GetRaidHealTarget(spell)
    if missingHealth > 500 then
        --max_SayRaid("Started FoL on " .. UnitName(healTargetUnit) .. ". Current missing health: " .. max_GetMissingHealth(healTargetUnit) .. " - Calculated missing health: " .. missingHealth)
        local callBacks = {}
        callBacks.onStart = function(spellCast) mb_HealingModule_SendData(UnitName(spellCast.target), 600, spellCast.startTime + 1.5) end
        mb_CastSpellByNameOnRaidMemberWithCallbacks(spell, healTargetUnit, callBacks)
        mb_paladinCurrentHealTarget = healTargetUnit
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
    mb_AddReagentWatch("Symbol of Kings", 200)
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
    if not found or cur < APPLY_DEBUFFS_HEALTH_ABOVE then
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