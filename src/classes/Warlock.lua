-- TODO:
---     Healthstones
---     Pets
---     Curses
---
function mb_Warlock(commander)
    if mb_DoBasicCasterLogic() then
        return
    end

    if max_GetTableSize(mb_queuedRequests) > 0 then
        local request = mb_queuedRequests[1]
        if request.requestType == "summon" then
            -- if gcd is ready
            max_SayRaid("I'm summoning " .. request.requestBody)
            TargetByName(request.requestBody, true)
            CastSpellByName("Ritual of Summoning")
            table.remove(mb_queuedRequests, 1)
            return
        else
            max_SayRaid("Serious error, received request for " .. request.requestType)
        end
    end

    if not UnitAffectingCombat("player") then
        if not max_HasBuff("player", BUFF_DEMON_ARMOR) then
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

    if max_GetHealthPercentage("player") < 20 then
        CastSpellByName("Drain Life")
    end

    -- TODO: Use MobHealth addon and get the unit health from that instead of : UnitHealth("target") < 20 and
    if max_GetFreeBagSlots() > 5 then
        CastSpellByName("Drain Soul")
    else
        CastSpellByName("Shadow Bolt")
    end
end

function mb_Warlock_OnLoad()
    mb_RegisterForRequest("summon", mb_Warlock_HandleSummonRequest)
    table.insert(mb_desiredBuffs, BUFF_ARCANE_INTELLECT)
    table.insert(mb_desiredBuffs, BUFF_POWER_WORD_FORTITUDE)

    mb_Warlock_AddDesiredTalents()
end

function mb_Warlock_HandleSummonRequest(requestId, requestType, requestBody)
    local soulShardCount = mb_GetItemCount("Soul Shard")
    if soulShardCount > 0 and not mb_isCasting and not UnitAffectingCombat("player") then
        mb_AcceptRequest(requestId, requestType, requestBody)
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