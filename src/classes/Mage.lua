mb_mageLastScorch = 0
mb_mageIsFire = false
function mb_Mage(commander)
    if mb_DoBasicCasterLogicThrottled() then
        return
    end

    if mb_CrowdControlModule_Run() then
        return
    end

    local request = mb_GetQueuedRequest(true)
    if request ~= nil and request.type == REQUEST_INTERRUPT.type then
        if request.attempts > 90 then
            mb_RequestCompleted(request)
            max_SayRaid("Timed out interrupt request from " .. request.from)
            return
        end
        if mb_IsCasting() then
            mb_StopCasting()
        end
        max_AssistByPlayerName(request.from)
        max_SayRaid("Interrupting " .. tostring(UnitName("target")))
        CastSpellByName("Counterspell")
        mb_RequestCompleted(request)
        return
    end

    if not mb_IsReadyForNewCast() then
        return
    end

    if request ~= nil then
        if mb_CompleteStandardBuffRequest(request) then
            return
        elseif request.type == REQUEST_WATER.type then
            if request.attempts > 50 then
                mb_RequestCompleted(request)
                return
            end
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
            max_CastSpellOnRaidMemberByPlayerName("Remove Lesser Curse", request.body)
            mb_RequestCompleted(request)
            return
        elseif request.type == REQUEST_CROWD_CONTROL.type then
            max_AssistByPlayerName(request.from)
            mb_CrowdControlModule_RegisterTarget("Polymorph", DEBUFF_TEXTURE_POLYMORPH)
            mb_RequestCompleted(request)
            return
        end
    end

    if not max_HasBuff("player", BUFF_TEXTURE_MAGE_ARMOR) then
        CastSpellByName("Mage Armor")
        return
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
        if mb_Mage_HasIceBarrier() then
            if not max_IsSpellNameOnCooldown("Ice Barrier") then
                CastSpellByName("Ice Barrier")
                return
            end
        end
    end

    if UnitAffectingCombat("player") then
        if mb_Mage_HasIceBlock() then
            if max_IsSpellNameOnCooldown("Ice Block") and not max_IsSpellNameOnCooldown("Cold Snap") then
                CastSpellByName("Cold Snap")
                return
            end
            if max_GetHealthPercentage("player") < 30 and not max_IsSpellNameOnCooldown("Ice Block") then
                CastSpellByName("Ice Block")
                return
            end
        end
        if mb_Mage_HasIceBarrier() then
            if max_GetHealthPercentage("player") < 30 and not max_IsSpellNameOnCooldown("Ice Barrier") then
                CastSpellByName("Ice Barrier")
                return
            end
        end
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

    if mb_CleanseRaidMemberThrottled("Remove Lesser Curse", "Curse") then
        return
    end

    if mb_areaOfEffectMode then
        max_UseEquippedItemIfReady("Trinket0Slot")
        max_UseEquippedItemIfReady("Trinket1Slot")
        CastSpellByName("Arcane Explosion")
        return
    end

    max_AssistByPlayerName(commander)
    if not max_HasValidOffensiveTarget() then
        return
    end

    if UnitAffectingCombat("player") and max_GetManaPercentage("player") > 25 then
        if not mb_mageIsFire then
            if max_GetDebuffStackCount("target", DEBUFF_TEXTURE_WINTERS_CHILL) == 5 then
                mb_Mage_UseCooldowns()
            end
        else
            if max_GetDebuffStackCount("target", DEBUFF_TEXTURE_IMPROVED_SCORCH) == 5 then
                mb_Mage_UseCooldowns()
            end
        end
    end

    if mb_mageIsFire then
        if max_GetDebuffStackCount("target", DEBUFF_TEXTURE_IMPROVED_SCORCH) < 5 then
            CastSpellByName("Scorch")
            mb_mageLastScorch = mb_GetTime()
        elseif mb_IsClassLeader() and mb_mageLastScorch + 20 < mb_GetTime() then
            CastSpellByName("Scorch")
            mb_mageLastScorch = mb_GetTime()
        else
            CastSpellByName("Fireball")
        end
    else
        CastSpellByName("Frostbolt")
    end
    CastSpellByName("Fire Blast")
end

function mb_Mage_UseCooldowns()
    if not mb_IsMoving() then
        max_UseEquippedItemIfReady("Trinket0Slot")
        max_UseEquippedItemIfReady("Trinket1Slot")
        if mb_Mage_HasArcanePower() and not max_IsSpellNameOnCooldown("Arcane Power") then
            CastSpellByName("Arcane Power")
        end
        if mb_Mage_HasCombustion() and not max_IsSpellNameOnCooldown("Combustion") then
            CastSpellByName("Combustion")
        end
    elseif mb_Mage_HasPresenceOfMind() and not max_IsSpellNameOnCooldown("Presence of Mind") then
        CastSpellByName("Presence of Mind")
    end
end

function mb_Mage_OnLoad()
    mb_RegisterForStandardBuffRequest(BUFF_ARCANE_INTELLECT)
    mb_RegisterForRequest(REQUEST_WATER.type, mb_Mage_HandleWaterRequest)
    mb_RegisterForRequest(REQUEST_REMOVE_CURSE.type, mb_Mage_HandleDecurseRequest)
    mb_RegisterForRequest(REQUEST_INTERRUPT.type, mb_Mage_HandleInterruptRequest)
    mb_RegisterForRequest(REQUEST_CROWD_CONTROL.type, mb_Mage_HandleCrowdControlRequest)
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
    mb_RegisterRangeCheckSpell("Counterspell")
    mb_RegisterRangeCheckSpell("Polymorph")
    mb_AddReagentWatch("Arcane Powder", 50)
    mb_AddReagentWatch("Rune of Portals", 10)
    mb_RegisterRangeCheckSpell("Frostbolt")

    if mb_GetMySpecName() == "DeepFire" then
        mb_mageIsFire = true
        mb_GoToMaxRangeModule_RegisterMaxRangeSpell("Fireball")
    else
        mb_GoToMaxRangeModule_RegisterMaxRangeSpell("Frostbolt")
    end
end

function mb_Mage_HandleWaterRequest(request)
    if not mb_IsFreeToAcceptRequest() then
        return
    end
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
    if not mb_IsFreeToAcceptRequest() then
        return
    end
    if mb_IsUnitValidTarget(max_GetUnitForPlayerName(request.body), "Remove Lesser Curse") and UnitMana("player") > 500 then
        mb_AcceptRequest(request)
    end
end

function mb_Mage_HandleInterruptRequest(request)
    if not mb_IsFreeToAcceptRequest() then
        return
    end
    max_AssistByPlayerName(request.from)
    if not mb_IsSpellInRange("Counterspell", "target") then
        return
    end
    if max_IsSpellNameOnCooldown("Counterspell") then
        return
    end
    if UnitMana("player") > 500 then
        mb_AcceptRequest(request)
    end
end

function mb_Mage_HandleCrowdControlRequest(request)
    if not mb_IsFreeToAcceptRequest() then
        return
    end
    max_AssistByPlayerName(request.from)
    local creatureType = UnitCreatureType("target")
    if creatureType == "Humanoid" or creatureType == "Beast" then
        mb_AcceptRequest(request)
    end
end

function mb_Mage_IsReady()
    if mb_CancelExpiringBuffWithTexture(BUFF_TEXTURE_MAGE_ARMOR, 8) then
        return false
    end
    return true
end

function mb_Mage_HasIceBlock()
    local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(3, 14)
    return currentRank == 1
end

function mb_Mage_HasPresenceOfMind()
    local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(1, 13)
    return currentRank == 1
end

function mb_Mage_HasIceBarrier()
    local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(3, 17)
    return currentRank == 1
end

function mb_Mage_HasArcanePower()
    local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(1, 16)
    return currentRank == 1
end

function mb_Mage_HasCombustion()
    local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(2, 16)
    return currentRank == 1
end

function mb_Mage_AddDesiredTalents()
    if UnitLevel("player") == 60 then
        -- Raiding specs
        if mb_GetMySpecName() == "ImpBlizzWC" then
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
            mb_AddDesiredTalent(3, 16, 3) -- Winter's Chill
            mb_AddDesiredTalent(3, 17, 1) -- Ice Barrier
            mb_AddDesiredTalent(1, 1, 2) -- Arcane Subtlety
            mb_AddDesiredTalent(1, 2, 3) -- Arcane Focus
            mb_AddDesiredTalent(1, 5, 5) -- Magic Absorption
            mb_AddDesiredTalent(1, 6, 5) -- Arcane Concentration
            mb_AddDesiredTalent(1, 12, 3) -- Arcane Meditation
        elseif  mb_GetMySpecName() == "ArcaneInstability" then
            mb_AddDesiredTalent(3, 2, 5) -- Improved Frostbolt
            mb_AddDesiredTalent(3, 3, 3) -- Elemental Precision
            mb_AddDesiredTalent(3, 4, 5) -- Ice Shards
            mb_AddDesiredTalent(3, 8, 3) -- Piercing Ice
            mb_AddDesiredTalent(3, 9, 1) -- Cold Snap
            mb_AddDesiredTalent(3, 11, 2) -- Arctic reach
            mb_AddDesiredTalent(3, 12, 3) -- Frost Channeling
            mb_AddDesiredTalent(3, 14, 1) -- Ice Block
            mb_AddDesiredTalent(1, 1, 2) -- Arcane Subtlety
            mb_AddDesiredTalent(1, 2, 3) -- Arcane Focus
            mb_AddDesiredTalent(1, 5, 5) -- Magic Absorption
            mb_AddDesiredTalent(1, 6, 5) -- Arcane Concentration
            mb_AddDesiredTalent(1, 8, 3) -- Improved Arcane Explosion
            mb_AddDesiredTalent(1, 9, 1) -- Arcane Resilience
            mb_AddDesiredTalent(1, 12, 3) -- Arcane Meditation
            mb_AddDesiredTalent(1, 13, 1) -- Presence of Mind
            mb_AddDesiredTalent(1, 14, 2) -- Arcane Mind
            mb_AddDesiredTalent(1, 15, 3) -- Arcane Instability
        elseif  mb_GetMySpecName() == "ArcanePowerFrost" then
            mb_AddDesiredTalent(3, 2, 5) -- Improved Frostbolt
            mb_AddDesiredTalent(3, 3, 3) -- Elemental Precision
            mb_AddDesiredTalent(3, 4, 5) -- Ice Shards
            mb_AddDesiredTalent(3, 8, 3) -- Piercing Ice
            mb_AddDesiredTalent(3, 11, 2) -- Arctic reach
            mb_AddDesiredTalent(3, 12, 2) -- Frost Channeling
            mb_AddDesiredTalent(1, 1, 2) -- Arcane Subtlety
            mb_AddDesiredTalent(1, 2, 3) -- Arcane Focus
            mb_AddDesiredTalent(1, 5, 5) -- Magic Absorption
            mb_AddDesiredTalent(1, 6, 5) -- Arcane Concentration
            mb_AddDesiredTalent(1, 8, 3) -- Improved Arcane Explosion
            mb_AddDesiredTalent(1, 9, 1) -- Arcane Resilience
            mb_AddDesiredTalent(1, 12, 3) -- Arcane Meditation
            mb_AddDesiredTalent(1, 13, 1) -- Presence of Mind
            mb_AddDesiredTalent(1, 14, 4) -- Arcane Mind
            mb_AddDesiredTalent(1, 15, 3) -- Arcane Instability
            mb_AddDesiredTalent(1, 16, 1) -- Arcane Power
        elseif  mb_GetMySpecName() == "DeepFire" then
            mb_AddDesiredTalent(1, 1, 2) -- Arcane Subtlety
            mb_AddDesiredTalent(1, 2, 3) -- Arcane Focus
            mb_AddDesiredTalent(1, 5, 5) -- Magic Absorption
            mb_AddDesiredTalent(1, 6, 5) -- Arcane Concentration
            mb_AddDesiredTalent(1, 12, 2) -- Arcane Meditation
            -- TODO: Add Fire talents
            mb_AddDesiredTalent(3, 3, 3) -- Elemental Precision
        end
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