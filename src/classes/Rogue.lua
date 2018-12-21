mb_Rogue_usesDaggers = false
function mb_Rogue(commander)
    AssistByName(commander)
    if not mb_isAutoAttacking then
        CastSpellByName("Attack")
    end
    if GetComboPoints() == 4 then
        CastSpellByName("Slice and Dice")
        return
    end
    if mb_Rogue_usesDaggers == true then
        CastSpellByName("Backstab")
        return
    end
    CastSpellByName("Sinister Strike")
end

function mb_Rogue_ApplyPoison()
    if not UnitAffectingCombat("player") then
        local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo();
        if not mb_shouldRequestBuffs then
            return false
        end
        if hasMainHandEnchant == 0 then
            mb_UseItem("Instant Poison VI")
            PickupInventoryItem(16)
           -- mb_Print("1")
            return true
        end
        if hasOffHandEnchant == 0 then
            mb_UseItem("Instant Poison VI")
            PickupInventoryItem(17)
           -- mb_Print("2")
            return true
        end
        if mainHandCharges == nil or mainHandCharges <= 20 then
            mb_UseItem("Instant Poison VI")
            PickupInventoryItem(16)
            ReplaceEnchant()
            --mb_Print("3")
            return true
        end
        if offHandCharges == nil or offHandCharges <= 20 then
            mb_UseItem("Instant Poison VI")
            PickupInventoryItem(17)
            ReplaceEnchant()
            --mb_Print("4")
            return true
        end
        if mainHandExpiration <= 300000 then
            mb_UseItem("Instant Poison VI")
            PickupInventoryItem(16)
            ReplaceEnchant()
            --mb_Print("5")
            return true
        end
        if offHandExpiration <= 300000 then
            mb_UseItem("Instant Poison VI")
            PickupInventoryItem(17)
            ReplaceEnchant()
            --mb_Print("6")
            return true
        end
        return false
    end
end

function mb_Rogue_OnLoad()
    mb_AddDesiredBuff(BUFF_MARK_OF_THE_WILD)
    mb_AddDesiredBuff(BUFF_POWER_WORD_FORTITUDE)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_MIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_KINGS)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_LIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_SALVATION)
    mb_AddDesiredBuff(BUFF_SHADOW_PROTECTION)
    local meleeWeaponItemLink = GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot"))
    local meleeWeaponItemString = max_GetItemStringFromItemLink(meleeWeaponItemLink)
    local itemName, itemLink, itemQuality, itemLevel, itemType, itemSubType, itemCount, itemTexture = GetItemInfo(meleeWeaponItemString)
    if itemSubType ~= nil then
        if itemSubType == "Daggers" then
            mb_Rogue_usesDaggers = true
        end
    end
    mb_Rogue_AddDesiredTalents()
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