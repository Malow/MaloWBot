function mb_Mage(commander)
    if mb_DoBasicCasterLogic() then
        return
    end
    if mb_isCasting then
        return
    end

    local request = mb_GetQueuedRequest(true)
    if request ~= nil then
        if mb_CompleteStandardBuffRequest(request) then
            return
        elseif request.type == REQUEST_WATER.type then
            if not CursorHasItem() then
                local bag, slot = mb_LocateWaterInBags()
                PickupContainerItem(bag, slot)
                InitiateTrade(max_GetUnitForPlayerName(request.body))
                return
            else
                DropItemOnUnit(max_GetUnitForPlayerName(request.body))
                mb_RequestCompleted(request)
                return
            end
        elseif request.type == REQUEST_REMOVE_CURSE.type then
            if mb_IsOnGCD() then
                return
            end
            max_CastSpellOnRaidMemberByPlayerName("Remove Lesser Curse", request.body)
            mb_RequestCompleted(request)
            return
        end
    end

    if not UnitAffectingCombat("player") then
        if mb_GetWaterCount() < 60 then
            CastSpellByName("Conjure Water")
            return
        end
        for i = max_GetTableSize(ITEMS_MANA_GEM), 1, -1 do
            if not mb_HasItem(ITEMS_MANA_GEM[i]) then
                CastSpellByName("Conjure " .. ITEMS_MANA_GEM[i])
                return
            end
        end
        if not max_HasBuff("player", BUFF_TEXTURE_MAGE_ARMOR) then
            CastSpellByName("Mage Armor")
            return
        end
    end

    if UnitAffectingCombat("player") then
        if max_GetManaPercentage("player") < 10 and not max_IsSpellNameOnCooldown("Evocation") then
            CastSpellByName("Evocation")
            return
        elseif max_GetManaPercentage("player") < 20 then
            for i = max_GetTableSize(ITEMS_MANA_GEM), 1, -1 do
                if mb_UseItem(ITEMS_MANA_GEM[i]) then
                    break
                end
            end
        end
    end

    local debuffTarget = mb_GetDebuffedRaidMember("Remove Lesser Curse", "Curse")
    if debuffTarget ~= nil then
        max_CastSpellOnRaidMember("Remove Lesser Curse", debuffTarget)
        return
    end

    --- Time to do some actual combat
    if mb_areaOfEffectMode then
        CastSpellByName("Arcane Explosion")
        return
    end

    max_AssistByPlayerName(commander)
    if not UnitExists("target") or not UnitIsEnemy("player", "target") then
        return
    end

    CastSpellByName("Frostbolt")
    CastSpellByName("Fire Blast")
end

function mb_Mage_OnLoad()
    mb_RegisterForStandardBuffRequest(BUFF_ARCANE_INTELLECT)
    mb_RegisterForRequest(REQUEST_WATER.type, mb_Mage_HandleWaterRequest)
    mb_RegisterForRequest(REQUEST_REMOVE_CURSE.type, mb_Mage_HandleDecurseRequest)
    mb_AddDesiredBuff(BUFF_MARK_OF_THE_WILD)
    mb_AddDesiredBuff(BUFF_ARCANE_INTELLECT)
    mb_AddDesiredBuff(BUFF_POWER_WORD_FORTITUDE)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_WISDOM)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_KINGS)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_LIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_SALVATION)
    mb_AddDesiredBuff(BUFF_DIVINE_SPIRIT)
    mb_AddDesiredBuff(BUFF_SHADOW_PROTECTION)

    mb_Mage_AddDesiredTalents()
    mb_AddGCDCheckSpell("Frostbolt")
    mb_RegisterRangeCheckSpell("Arcane Intellect")
    mb_RegisterRangeCheckSpell("Remove Lesser Curse")
    mb_AddReagentWatch("Arcane Powder", 40)
end

function mb_Mage_HandleWaterRequest(request)
    if mb_GetWaterCount() < 25 then
        return
    end
    local unit = max_GetUnitForPlayerName(request.body)
    if mb_IsUnitValidTarget(unit) then
        if CheckInteractDistance(unit, 2) then
            mb_AcceptRequest(request)
        end
    end
end

function mb_Mage_HandleDecurseRequest(request)
    if mb_IsUnitValidTarget(max_GetUnitForPlayerName(request.body), "Remove Lesser Curse") and UnitMana("player") > 500 then
        mb_AcceptRequest(request)
    end
end

function mb_Mage_AddDesiredTalents()
    if UnitLevel("player") == 60 then
        -- Raiding spec
        -- TODO: Decide between Ice Barrier and Presence of Mind, probably depends on whether or not we can detect movement (use the error text like the rogue addon for that?)
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
        -- Leveling/Dungeon spec
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