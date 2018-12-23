mb_warlockIsCursingElements = false
mb_warlockIsCursingShadow = false
mb_warlockIsCursingRecklessness = false
function mb_Warlock(commander)
    if mb_DoBasicCasterLogic() then
        return
    end
    if mb_isCasting then
        return
    end

    local request = mb_GetQueuedRequest(true)
    if request ~= nil then
        if request.type == "summon" then
            if mb_IsOnGCD() then
                return
            end
            max_SayRaid("I'm summoning " .. request.body)
            TargetByName(request.body, true)
            CastSpellByName("Ritual of Summoning")
            mb_RequestCompleted(request)
            return
        elseif request.type == "soulstone" then
            if mb_HasItem("Soulstone") then
                if mb_IsOnGCD() then
                    return
                end
                max_SayRaid("I'm soulstoning " .. request.body)
                TargetByName(request.body, true)
                mb_UseItem("Soulstone")
                mb_RequestCompleted(request)
            else
                CastSpellByName("Create Soulstone()")
            end
            return
        end
    end

    if not UnitAffectingCombat("player") then
        if not max_HasBuff("player", BUFF_TEXTURE_DEMON_ARMOR) then
            CastSpellByName("Demon Armor")
            return
        elseif mb_shouldRequestBuffs then
            if not max_HasBuff("player", BUFF_TEXTURE_SACRIFICED_SUCCUBUS) then
                if max_IsPetAliveAndActive() then
                    CastSpellByName("Demonic Sacrifice")
                    return
                else
                    CastSpellByName("Summon Succubus")
                    return
                end
            end
            if not mb_HasItem("Soulstone") then
                CastSpellByName("Create Soulstone()")
                return
            end
            if not mb_HasItem("Major Healthstone") then
                CastSpellByName("Create Healthstone()")
                return
            end
        end
    end

    if UnitAffectingCombat("player") then
        if max_GetManaPercentage("player") < 10 and max_GetHealthPercentage("player") > 75 then
            CastSpellByName("Life Tap")
            return
        end
    end

    max_AssistByPlayerName(commander)
    if not UnitExists("target") or not UnitIsEnemy("player", "target") then
        return
    end

    if max_GetHealthPercentage("player") < 25 and mb_IsSpellInRange("Drain Life", "target") then
        CastSpellByName("Drain Life")
        return
    end

    if mb_Warlock_DrainSoul() then
        return
    end

    if mb_Warlock_Curse() then
        return
    end

    CastSpellByName("Shadow Bolt")
end

function mb_Warlock_DrainSoul()
    if not mb_IsSpellInRange("Drain Soul", "target") then
        return false
    end
    local cur, max, found = MobHealth3:GetUnitHealth("target")
    if not found then
        return false
    end
    if cur > 15000 then
        return false
    end
    if max_GetFreeBagSlots() > 5 and max_GetLevelDifferenceFromSelf("target") > -10 then
        CastSpellByName("Drain Soul")
        return true
    end
    return false
end

function mb_Warlock_Curse()
    if not mb_IsSpellInRange("Curse of the Elements", "target") then
        return false
    end
    if mb_warlockIsCursingElements and not max_HasDebuff("target", DEBUFF_TEXTURE_CURSE_OF_THE_ELEMENTS) then
        CastSpellByName("Curse of the Elements")
        return true
    elseif mb_warlockIsCursingShadow and not max_HasDebuff("target", DEBUFF_TEXTURE_CURSE_OF_SHADOW) then
        CastSpellByName("Curse of Shadow")
        return true
    elseif mb_warlockIsCursingRecklessness and not max_HasDebuff("target", DEBUFF_TEXTURE_CURSE_OF_RECKLESSNESS) then
        CastSpellByName("Curse of Recklessness")
        return true
    end
    return false
end

function mb_Warlock_OnLoad()
    mb_RegisterForRequest("summon", mb_Warlock_HandleSummonRequest)
    mb_RegisterForRequest("soulstone", mb_Warlock_HandleSoulstoneRequest)
    mb_AddDesiredBuff(BUFF_MARK_OF_THE_WILD)
    mb_AddDesiredBuff(BUFF_ARCANE_INTELLECT)
    mb_AddDesiredBuff(BUFF_POWER_WORD_FORTITUDE)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_WISDOM)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_KINGS)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_LIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_SALVATION)
    mb_AddDesiredBuff(BUFF_DIVINE_SPIRIT)
    mb_AddDesiredBuff(BUFF_SHADOW_PROTECTION)
    mb_Warlock_AddDesiredTalents()
    mb_AddGCDCheckSpell("Shadow Bolt")
    mb_RegisterClassSyncDataFunctions(mb_Warlock_CreateClassSyncData, mb_Warlock_ReceivedClassSyncData)
    mb_RegisterRangeCheckSpell("Unending Breath")
    mb_RegisterRangeCheckSpell("Drain Life")
    mb_RegisterRangeCheckSpell("Drain Soul")
    mb_RegisterRangeCheckSpell("Curse of the Elements")
end

function mb_Warlock_HandleSummonRequest(request)
    if mb_isCasting then
        return
    end
    local soulShardCount = mb_GetItemCount("Soul Shard")
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(request.from), "Unending Breath") and soulShardCount > 0 then
        mb_AcceptRequest(request)
    end
end

function mb_Warlock_HandleSoulstoneRequest(request)
    if mb_IsItemOnCooldown("Greater Soulstone") then
        return
    end
    local soulShardCount = mb_GetItemCount("Soul Shard")
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(request.body), "Unending Breath") and soulShardCount > 0 then
        mb_AcceptRequest(request)
    end
end

function mb_Warlock_CreateClassSyncData()
    local classMates = mb_GetClassMates(max_GetClass("player"))
    if max_GetTableSize(classMates) > 2 then
        return classMates[1] .. "/" .. classMates[2] .. "/" .. classMates[3]
    else
        return ""
    end
end

function mb_Warlock_ReceivedClassSyncData()
    if mb_classSyncData ~= "" then
        local assignments = max_SplitString(mb_classSyncData, "/")
        mb_warlockIsCursingElements = assignments[1] == UnitName("player")
        mb_warlockIsCursingShadow = assignments[2] == UnitName("player")
        mb_warlockIsCursingRecklessness = assignments[3] == UnitName("player")
    else
        mb_warlockIsCursingElements = false
        mb_warlockIsCursingShadow = false
        mb_warlockIsCursingRecklessness = false
    end
end

function mb_Warlock_AddDesiredTalents()
    -- Ordered for leveling
    mb_AddDesiredTalent(3, 1, 5) -- Improved Shadow Bolt
    mb_AddDesiredTalent(3, 2, 3) -- Cataclysm
    mb_AddDesiredTalent(3, 3, 5) -- Bane
    mb_AddDesiredTalent(3, 7, 5) -- Devastation
    mb_AddDesiredTalent(3, 10, 2) -- Destructive Reach
    mb_AddDesiredTalent(3, 14, 1) -- Ruin
    mb_AddDesiredTalent(1, 1, 5) -- Suppression
    mb_AddDesiredTalent(1, 5, 2) -- Improved Life Tap
    mb_AddDesiredTalent(2, 1, 2) -- Improved Healthstone
    mb_AddDesiredTalent(2, 2, 3) -- Improved Imp
    mb_AddDesiredTalent(2, 3, 5) -- Demonic Embrace
    mb_AddDesiredTalent(2, 6, 2) -- Demonic Embrace
    mb_AddDesiredTalent(2, 8, 1) -- Fel Domination
    mb_AddDesiredTalent(2, 9, 5) -- Fel Stamina
    mb_AddDesiredTalent(2, 10, 2) -- Master Summoner
    mb_AddDesiredTalent(2, 13, 1) -- Demonic Sacrifice
    mb_AddDesiredTalent(3, 2, 5) -- Cataclysm (last two)
end