mb_Rogue_usesDaggers = false
mb_rogueShouldUsePoisons = true
mb_rogueMainHandTemporaryWeaponEnchant = nil
mb_rogueOffHandTemporaryWeaponEnchant = nil
mb_rogueShouldUseCooldownsOnCooldown = true
function mb_Rogue(commander)
    local request = mb_GetQueuedRequest(true)
    if request ~= nil then
        if request.type == REQUEST_INTERRUPT.type then
            if request.attempts > 90 then
                mb_RequestCompleted(request)
                max_SayRaid("Timed out interrupt request from " .. request.from)
                return
            end
            if mb_IsOnGCD() then
                return
            end
            if UnitMana("player") < 25 then
                return
            end
            max_AssistByPlayerName(request.from)
            max_SayRaid("Interrupting " .. tostring(UnitName("target")))
            CastSpellByName("Kick")
            mb_RequestCompleted(request)
            return
        end
    end

    if not UnitAffectingCombat("player") then
        if mb_shouldRequestBuffs then
            if mb_rogueShouldUsePoisons then
                if mb_ApplyTemporaryWeaponEnchantsThrottled("Instant Poison VI", "Instant Poison VI") then
                    return
                end
            else
                if mb_ApplyTemporaryWeaponEnchantsThrottled(mb_rogueMainHandTemporaryWeaponEnchant, mb_rogueOffHandTemporaryWeaponEnchant) then
                    return
                end
            end
        end
    end

    if mb_currentBossModule.rogueLogic ~= nil then
        if mb_currentBossModule.rogueLogic() then
            return
        end
    end

    max_AssistByPlayerName(commander)

    if not max_HasValidOffensiveTarget() then
        return
    end

    if not mb_isAutoAttacking then
        CastSpellByName("Attack")
    end

    if mb_Rogue_UseCooldownsIfGood() then
        return
    end

    if not max_HasBuff("player", BUFF_TEXTURE_SLICE_AND_DICE) and GetComboPoints() > 0 then
        CastSpellByName("Slice and Dice")
        return
    end

    if not mb_Rogue_usesDaggers and GetComboPoints() == 5 then
        CastSpellByName("Eviscerate")
        return
    end

    if mb_Rogue_usesDaggers then
        CastSpellByName("Backstab")
        return
    end
    CastSpellByName("Sinister Strike")
end

function mb_Rogue_UseCooldownsIfGood()
    if not mb_rogueShouldUseCooldownsOnCooldown then
        return false
    end
    if not CheckInteractDistance("target", 3) or not max_GetDebuffStackCount("target", DEBUFF_TEXTURE_SUNDER_ARMOR) == 5 then
        return false
    end
    return mb_Rogue_UseCooldowns()
end

function mb_Rogue_UseCooldowns()
    max_UseEquippedItemIfReady("Trinket0Slot")
    max_UseEquippedItemIfReady("Trinket1Slot")
    if max_CastSpellIfReady("Adrenaline Rush") then
        return true
    end
    if max_CastSpellIfReady("Blade Flurry") then
        return true
    end
    return false
end

function mb_Rogue_HandleInterruptRequest(request)
    if UnitIsDead("player") then
        return
    end
    max_AssistByPlayerName(request.from)
    if not mb_IsSpellInRange("Kick", "target") then
        return
    end
    if max_IsSpellNameOnCooldown("Kick") then
        return
    end
    if UnitMana("player") > 5 then
        mb_AcceptRequest(request)
    end
end

function mb_Rogue_HandleUsePoisonRequest(request)
    mb_rogueShouldUsePoisons = request.body == "on"
end

--[[function mb_Rogue_Finisher_Swords()
    if not max_HasBuff("player", BUFF_TEXTURE_SLICE_AND_DICE) and GetComboPoints() > 0 then
        CastSpellByName("Slice and Dice")
        return
    end
    if GetPlayerBuffTimeLeft(BUFF_TEXTURE_SLICE_AND_DICE) < 6 then
        return
    elseif GetComboPoints() >= 4 then
        CastSpellByName("Eviscerate")
        return
    end
end ]]--

function mb_Rogue_OnLoad()
    mb_AddDesiredBuff(BUFF_MARK_OF_THE_WILD)
    mb_AddDesiredBuff(BUFF_POWER_WORD_FORTITUDE)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_MIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_KINGS)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_LIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_SALVATION)
    mb_AddDesiredBuff(BUFF_SHADOW_PROTECTION)

    local itemSubType = max_GetItemSubTypeForSlot("MainHandSlot")
    if itemSubType == "Daggers" then
        mb_Rogue_usesDaggers = true
    end

    mb_Rogue_AddDesiredTalents()
    mb_RegisterRangeCheckSpell("Kick")
    mb_AddGCDCheckSpell("Sinister Strike")
    mb_RegisterForRequest(REQUEST_INTERRUPT.type, mb_Rogue_HandleInterruptRequest)
    mb_RegisterForRequest("usePoison", mb_Rogue_HandleUsePoisonRequest)
    mb_AddReagentWatch("Instant Poison VI", 100)

    local mainHandItemSubType = max_GetItemSubTypeForSlot("MainHandSlot")
    if max_IsItemSubTypeSharp(mainHandItemSubType) then
        mb_rogueMainHandTemporaryWeaponEnchant = "Dense Sharpening Stone"
    elseif max_IsItemSubTypeBlunt(mainHandItemSubType) then
        mb_rogueMainHandTemporaryWeaponEnchant = "Dense Weightstone"
    end
    local offHandItemSubType = max_GetItemSubTypeForSlot("SecondaryHandSlot")
    if max_IsItemSubTypeSharp(offHandItemSubType) then
        mb_rogueOffHandTemporaryWeaponEnchant = "Dense Sharpening Stone"
    elseif max_IsItemSubTypeBlunt(offHandItemSubType) then
        mb_rogueOffHandTemporaryWeaponEnchant = "Dense Weightstone"
    end

    local sharpWatch = 0
    local bluntWatch = 0
    if max_IsItemSubTypeSharp(mainHandItemSubType) then
        sharpWatch = sharpWatch + 20
    end
    if max_IsItemSubTypeSharp(offHandItemSubType) then
        sharpWatch = sharpWatch + 20
    end
    if max_IsItemSubTypeBlunt(mainHandItemSubType) then
        bluntWatch = bluntWatch + 20
    end
    if max_IsItemSubTypeBlunt(offHandItemSubType) then
        bluntWatch = bluntWatch + 20
    end
    if sharpWatch > 0 then
        mb_AddReagentWatch("Dense Sharpening Stone", sharpWatch)
    end
    if bluntWatch > 0 then
        mb_AddReagentWatch("Dense Weightstone", bluntWatch)
    end
end

function mb_Rogue_AddDesiredTalents()
    if mb_Rogue_usesDaggers == true then
        mb_AddDesiredTalent(1, 3, 5) -- Malice
        mb_AddDesiredTalent(1, 5, 2) -- Murder
        mb_AddDesiredTalent(1, 6, 3) -- Imp. SnD
        mb_AddDesiredTalent(1, 7, 1) -- Relentless Strikes
        mb_AddDesiredTalent(1, 9, 4) -- Lethality
        mb_AddDesiredTalent(2, 2, 2) -- Imp. SS
        mb_AddDesiredTalent(2, 3, 5) -- Dodge
        mb_AddDesiredTalent(2, 4, 3) -- Imp. Backstab
        mb_AddDesiredTalent(2, 6, 5) -- 5% Hit
        mb_AddDesiredTalent(2, 10, 2) -- Imp. Kick
        mb_AddDesiredTalent(2, 11, 5) -- Dagger Spec
        mb_AddDesiredTalent(2, 12, 5) -- Imp. Dual-Wield
        mb_AddDesiredTalent(2, 14, 1) -- Blade Flurry
        mb_AddDesiredTalent(2, 17, 2) -- Expertise
        mb_AddDesiredTalent(2, 19, 1) -- Adrenaline Rush
        mb_AddDesiredTalent(3, 2, 5) -- Opportunity

    else
        -- Sword Spec
        mb_AddDesiredTalent(1, 1, 2) --Imp. Evisc
        mb_AddDesiredTalent(1, 3, 5) -- Malice
        mb_AddDesiredTalent(1, 4, 3) -- Ruthlessness
        mb_AddDesiredTalent(1, 5, 2) -- Murder
        mb_AddDesiredTalent(1, 6, 3) -- Imp. SnD
        mb_AddDesiredTalent(1, 7, 1) -- Relentless Strikes
        mb_AddDesiredTalent(1, 9, 3) -- Lethality 3/5
        mb_AddDesiredTalent(2, 2, 2) -- Imp. Sinister Strike
        mb_AddDesiredTalent(2, 3, 5) -- Dodge
        mb_AddDesiredTalent(2, 6, 5) -- 5% Hit
        mb_AddDesiredTalent(2, 7, 2) -- Endurance
        mb_AddDesiredTalent(2, 9, 1) -- Imp. Sprint
        mb_AddDesiredTalent(2, 12, 5) -- Imp. Dual-Wield
        mb_AddDesiredTalent(2, 14, 1) -- Blade Flurry
        mb_AddDesiredTalent(2, 15, 5) -- Sword Spec
        mb_AddDesiredTalent(2, 17, 2) -- Expertise
        mb_AddDesiredTalent(2, 18, 3) -- Aggression
        mb_AddDesiredTalent(2, 19, 1) -- Adrenaline Rush
    end
end