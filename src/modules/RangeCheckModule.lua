mb_registeredRangeCheckSpells = {}

function mb_RegisterRangeCheckSpell(spellName)
    local slot = max_GetTableSize(mb_registeredRangeCheckSpells) + 25
    if slot > 36 then
        max_SayRaid("Serious error, I have too many spells registered for range-check")
    end
    if not max_HasSpell(spellName) then
        max_SayRaid("Warning: I'm trying to add " .. spellName .. " to range-check, but I don't know this spell")
        return
    end
    mb_registeredRangeCheckSpells[spellName] = slot
    PickupSpell(max_GetSpellbookId(spellName), "BOOKTYPE_SPELL ")
    PlaceAction(slot)
    ClearCursor()
end

-- Changes target if you don't try to use it on your existing target, will break auto-attacks
function mb_IsSpellInRange(spellName, unit)
    SpellStopTargeting()
    if mb_registeredRangeCheckSpells[spellName] == nil then
        max_SayRaid("Serious error, don't have spell " .. spellName .. " registered for rangeCheck, but still tried to check range with it.")
    end
    if unit == nil or UnitIsUnit("target", unit) then
        return IsActionInRange(mb_registeredRangeCheckSpells[spellName]) == 1
    end

    local hadTarget = UnitExists("target")

    TargetUnit(unit)
    local isInRange = IsActionInRange(mb_registeredRangeCheckSpells[spellName]) == 1

    if hadTarget then
        TargetLastTarget()
    else
        ClearTarget()
    end
    return isInRange
end

-- Like IsCasting but works on specific abilities that doesn't "cast" like aimed shot. Abilities needs to be registered for range-check for them to work.
function mb_IsUsingAbility(abilityName)
    if mb_registeredRangeCheckSpells[abilityName] == nil then
        max_SayRaid("Error in mb_IsUsingAbility, I haven't registered ability " .. abilityName)
        return false
    end
    return IsCurrentAction(mb_registeredRangeCheckSpells[abilityName]) == 1
end