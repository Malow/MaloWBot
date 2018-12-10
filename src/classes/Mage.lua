-- TODO:
---     Evocation
---     Polymorph requests
---     Counterspell, might be hard, gotta scan combat log for % begins casting %, check libcast in PFUI
---     Mage water trading is kinda buggy
---
function mb_Mage(commander)
    if mb_DoBasicCasterLogic() then
        return
    end

    if max_GetTableSize(mb_queuedRequests) > 0 then
        local request = mb_queuedRequests[1]
        if request.requestType == BUFF_ARCANE_INTELLECT.requestType then
            -- if off GCD
            TargetByName(request.requestBody, true)
            CastSpellByName("Arcane Intellect")
            table.remove(mb_queuedRequests, 1)
            return
        elseif request.requestType == REQUEST_WATER.requestType then
            if mb_isTrading then
                local bag, slot = mb_LocateWaterInBags()
                PickupContainerItem(bag, slot)
                DropItemOnUnit("target")
                table.remove(mb_queuedRequests, 1)
            else
                TargetByName(request.requestBody, true)
                InitiateTrade("target")
            end
        else
            max_SayRaid("Serious error, received request for " .. request.requestType)
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
        if not max_HasBuff("player", BUFF_TEXTURE_ICE_ARMOR) then
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

    AssistByName(commander)

    CastSpellByName("Fire Blast")
    CastSpellByName("Frostbolt")
end

function mb_Mage_OnLoad()
    mb_RegisterForRequest(BUFF_ARCANE_INTELLECT.requestType, mb_Mage_HandleArcaneIntRequest)
    mb_RegisterForRequest(REQUEST_WATER.requestType, mb_Mage_HandleWaterRequest)
    mb_AddDesiredBuff(BUFF_ARCANE_INTELLECT)
    mb_AddDesiredBuff(BUFF_POWER_WORD_FORTITUDE)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_WISDOM)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_KINGS)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_LIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_SALVATION)

    mb_Mage_AddDesiredTalents()
end

function mb_Mage_HandleArcaneIntRequest(requestId, requestType, requestBody)
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(requestBody), "Arcane Intellect") then
        mb_AcceptRequest(requestId, requestType, requestBody)
    end
end

function mb_Mage_HandleWaterRequest(requestId, requestType, requestBody)
    if mb_GetWaterCount() < 25 then
        return
    end
    local unit = max_GetUnitForPlayerName(requestBody)
    if mb_IsValidTarget(unit) then
        if CheckInteractDistance(unit, 2) then
            mb_AcceptRequest(requestId, requestType, requestBody)
        end
    end
end

function mb_Mage_AddDesiredTalents()
    if UnitLevel("player") == 60 then
        -- Raiding spec
        -- TODO: Decide between Ice Barrier and Presence of Mind, probably depends on whether or not we can detect movement
        mb_AddDesiredTalent(3, 2, 5) -- Improved Frostbolt
        mb_AddDesiredTalent(3, 3, 3) -- Elemental Precision
        mb_AddDesiredTalent(3, 4, 5) -- Ice Shards
        mb_AddDesiredTalent(3, 7, 3) -- Permafrost
        mb_AddDesiredTalent(3, 8, 3) -- Piercing Ice
        mb_AddDesiredTalent(3, 9, 1) -- Cold Snap
        mb_AddDesiredTalent(3, 10, 3) -- Improved Blizzard
        mb_AddDesiredTalent(3, 11, 2) -- Arctic reach
        mb_AddDesiredTalent(3, 12, 3) -- Frost Channeling
        mb_AddDesiredTalent(3, 14, 1) -- Ice Block
        mb_AddDesiredTalent(3, 16, 1) -- Winter's Chill
        -- mb_AddDesiredTalent(3, 14, 1) -- Ice Barrier
        mb_AddDesiredTalent(1, 1, 2) -- Arcane Subtlety
        mb_AddDesiredTalent(1, 2, 3) -- Arcane Focus
        mb_AddDesiredTalent(1, 5, 5) -- Magic Absorption
        mb_AddDesiredTalent(1, 6, 5) -- Arcane Concentration
        mb_AddDesiredTalent(1, 7, 2) -- Magic Attunement
        mb_AddDesiredTalent(1, 12, 3) -- Magic Meditation
        --mb_AddDesiredTalent(1, 13, 1) -- Presence of Mind
    else
        -- Leveling spec
        mb_AddDesiredTalent(3, 2, 5) -- Improved Frostbolt
        mb_AddDesiredTalent(3, 5, 3) -- Frostbite
        mb_AddDesiredTalent(3, 6, 2) -- Improved Frost Nova
        mb_AddDesiredTalent(3, 4, 5) -- Ice Shards
        mb_AddDesiredTalent(3, 13, 5) -- Shatter
        mb_AddDesiredTalent(3, 11, 2) -- Arctic reach
        mb_AddDesiredTalent(3, 3, 3) -- Elemental Precision
        mb_AddDesiredTalent(3, 16, 5) -- Winter's Chill
        mb_AddDesiredTalent(3, 8, 3) -- Piercing Ice
        mb_AddDesiredTalent(3, 12, 3) -- Frost Channeling
        mb_AddDesiredTalent(1, 1, 2) -- Arcane Subtlety
        mb_AddDesiredTalent(3, 7, 3) -- Permafrost
        mb_AddDesiredTalent(1, 2, 3) -- Arcane Focus
        mb_AddDesiredTalent(1, 6, 5) -- Arcane Concentration
        mb_AddDesiredTalent(1, 5, 2) -- Magic Absorption
    end
end