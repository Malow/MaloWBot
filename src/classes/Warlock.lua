function mb_Warlock(msg)
    if mb_DoBasicCasterLogic() then
        return
    end

    if max_GetTableSize(mb_queuedRequests) > 0 then
        local queuedRequest = mb_queuedRequests[1]
        if queuedRequest.requestType == "summon" then
            -- if gcd is ready
            SendChatMessage("I'm summoning " .. request.requestBody, "RAID", "Common")
            TargetByName(queuedRequest.requestBody, true)
            CastSpellByName("Ritual of Summoning")
            table.remove(mb_queuedRequests, 1)
            return
        else
            SendChatMessage("Serious error, received request for " .. request.requestType, "RAID", "Common")
        end
    end

    AssistByName(msg)
    FollowByName(msg, true)

    -- TODO: Use MobHealth addon and get the unit health from that instead of : UnitHealth("target") < 101 and
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
end

function mb_Warlock_HandleSummonRequest(requestId, requestType, requestBody)
    local soulShardCount = mb_GetItemCount("Soul Shard")
    if soulShardCount > 0 and not mb_isCasting and not UnitAffectingCombat("player") then
        mb_AcceptRequest(requestId, requestType, requestBody)
    end
end