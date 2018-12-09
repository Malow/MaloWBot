---
--- TODO:
---     Evocation
---     Polymorph requests
---     Counterspell, might be hard, gotta scan combat log for % begins casting %, check libcast in PFUI
---
function mb_Mage(msg)
    if mb_DoBasicCasterLogic() then
        return
    end

    if max_GetTableSize(mb_queuedRequests) > 0 then
        local queuedRequest = mb_queuedRequests[1]
        mb_Print("Doing req: " .. queuedRequest.requestType)
        if queuedRequest.requestType == BUFF_ARCANE_INTELLECT.requestType then
            -- if off GCD
            TargetByName(queuedRequest.requestBody, true)
            CastSpellByName("Arcane Intellect")
            table.remove(mb_queuedRequests, 1)
            return
        elseif queuedRequest.requestType == REQUEST_WATER.requestType then
            if mb_isTrading then
                local bag, slot = mb_LocateWaterInBags()
                PickupContainerItem(bag, slot)
                DropItemOnUnit("target")
                table.remove(mb_queuedRequests, 1)
            else
                TargetByName(queuedRequest.requestBody, true)
                InitiateTrade("target")
            end
        else
            mb_Print("It was not:" .. BUFF_ARCANE_INTELLECT.requestType)
            --SendChatMessage("Serious error, received request for " .. queuedRequest.requestType, "RAID", "Common")
        end
    end

    if not UnitAffectingCombat("player") then
        if mb_GetWaterCount() < 40 then
            CastSpellByName("Conjure Water")
            return
        end
        for i = max_GetTableSize(ITEMS_MANA_GEM), 1, -1 do
            if not mb_HasItem(ITEMS_MANA_GEM[i]) then
                CastSpellByName("Conjure " .. ITEMS_MANA_GEM[i])
                return
            end
        end
        if not max_HasBuff("player", BUFF_ICE_ARMOR) then
            CastSpellByName("Ice Armor")
            return
        end
    end

    if UnitAffectingCombat("player") then
        if max_GetManaPercentage("player") < 10 then
            for i = max_GetTableSize(ITEMS_MANA_GEM), 1, -1 do
                if mb_UseItem(ITEMS_MANA_GEM[i]) then
                    break
                end
            end
        end
    end

    --- Time to do some actual combat

    AssistByName(msg)
    FollowByName(msg, true)

    CastSpellByName("Fire Blast")
    CastSpellByName("Frostbolt")
end

function mb_Mage_OnLoad()
    mb_RegisterForRequest(BUFF_ARCANE_INTELLECT.requestType, mb_Mage_HandleArcaneIntRequest)
    mb_RegisterForRequest(REQUEST_WATER.requestType, mb_Mage_HandleWaterRequest)
    table.insert(mb_desiredBuffs, BUFF_ARCANE_INTELLECT)
    table.insert(mb_desiredBuffs, BUFF_POWER_WORD_FORTITUDE)

    mb_Mage_LearnTalents()
end

function mb_Mage_HandleArcaneIntRequest(requestId, requestType, requestBody)
    if UnitAffectingCombat("player") then
        return
    elseif max_GetManaPercentage("player") < 80 then
        return
    elseif mb_IsDrinking() then
        return
    end

    local unit = max_GetUnitForPlayerName(requestBody)
    if mb_IsValidTarget(unit, "Arcane Intellect") then
        mb_AcceptRequest(requestId, requestType, requestBody)
    end
end

function mb_Mage_HandleWaterRequest(requestId, requestType, requestBody)
    if mb_GetWaterCount() < 25 then
        return
    end
    local unit = max_GetUnitForPlayerName(requestBody)
    if mb_IsValidTarget(unit, "Arcane Intellect") then -- Using Arcane int for first range-check
        if CheckInteractDistance(unit, 2) then
            mb_AcceptRequest(requestId, requestType, requestBody)
        end
    end
end

function mb_Mage_LearnTalents()
    mb_LearnTalent(3, 2) -- Improved Frostbolt
    mb_LearnTalent(3, 5) -- Frostbite
end