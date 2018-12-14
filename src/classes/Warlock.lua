function mb_Warlock(commander)
    if mb_DoBasicCasterLogic() then
        return
    end

    local request = mb_GetQueuedRequest()
    if request ~= nil then
        if request.type == "summon" then
            if mb_IsOnGCD() then
                return
            end
            max_SayRaid("I'm summoning " .. request.body)
            max_CastSpellOnRaidMemberByPlayerName("Ritual of Summoning", request.body)
            mb_RequestCompleted(request)
            return
        elseif request.type == "soulstone" then
            if mb_HasItem("Major Soulstone") then
                max_SayRaid("I'm soulstoning " .. request.body)
                TargetByName(request.body, true)
                mb_UseItem("Major Soulstone")
                mb_RequestCompleted(request)
            else
                CastSpellByName("Create Soulstone (Major)")
            end
            return
        else
            max_SayRaid("Serious error, received request for " .. request.type)
        end
    end

    if not UnitAffectingCombat("player") then
        if not max_HasBuff("player", BUFF_TEXTURE_DEMON_ARMOR) then
            CastSpellByName("Demon Armor")
            return
        end
    end

    if UnitAffectingCombat("player") then
        if max_GetManaPercentage("player") < 10 and max_GetHealthPercentage("player") > 80 then
            CastSpellByName("Life Tap")
        end
    end

    AssistByName(commander)

    if max_GetHealthPercentage("player") < 25 then
        CastSpellByName("Drain Life")
    end

    -- TODO: Use MobHealth addon and get the unit health from that instead of : UnitHealth("target") < 20 and
    if max_GetFreeBagSlots() > 5 and max_GetLevelDifferenceFromSelf("target") > -10 then
        CastSpellByName("Drain Soul")
        return
    end
    CastSpellByName("Shadow Bolt")
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
    mb_Warlock_AddDesiredTalents()
    mb_AddGCDCheckSpell("Shadow Bolt")
end

function mb_Warlock_HandleSummonRequest(request)
    if UnitAffectingCombat("player") then
        return
    elseif max_GetManaPercentage("player") < 30 then
        return
    elseif mb_IsDrinking() then
        return
    end
    local soulShardCount = mb_GetItemCount("Soul Shard")
    if soulShardCount > 0 and not mb_isCasting then
        mb_AcceptRequest(request)
    end
end

function mb_Warlock_HandleSoulstoneRequest(request)
    if UnitAffectingCombat("player") then
        return
    elseif max_GetManaPercentage("player") < 30 then
        return
    elseif mb_IsDrinking() then
        return
    end
    local soulShardCount = mb_GetItemCount("Soul Shard")
    if soulShardCount > 0 and not mb_isCasting then -- TODO: Add valid target and range check
        mb_AcceptRequest(request)
    end
end

function mb_Warlock_AddDesiredTalents()
    -- TODO: Decide SM/Ruin or Sacrifice/Ruin, for both
    if UnitLevel("player") == 60 then
        -- Raiding spec
        mb_AddDesiredTalent(3, 1, 5) -- Improved Shadow Bolt
        mb_AddDesiredTalent(3, 2, 3) -- Cataclysm
        mb_AddDesiredTalent(3, 3, 5) -- Bane
        mb_AddDesiredTalent(3, 7, 5) -- Devastation
        mb_AddDesiredTalent(3, 10, 2) -- Destructive Reach
        mb_AddDesiredTalent(3, 14, 1) -- Ruin
    else
        -- Leveling spec
        mb_AddDesiredTalent(3, 1, 5) -- Improved Shadow Bolt
        mb_AddDesiredTalent(3, 3, 5) -- Bane
        mb_AddDesiredTalent(3, 7, 5) -- Devastation
        mb_AddDesiredTalent(3, 10, 2) -- Destructive Reach
        mb_AddDesiredTalent(3, 2, 3) -- Cataclysm
        mb_AddDesiredTalent(3, 14, 1) -- Ruin
    end
end