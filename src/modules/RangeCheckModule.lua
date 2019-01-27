MB_RANGE_CHECK_MODULE_CACHE_PLAYERS_PER_RUN = 5

mb_uniqueFriendlyRangeSpells = {}
mb_registeredEnemyRangeCheckSpells = {}
mb_registeredFriendlyRangeCheckSpells = {}
mb_lastCachedId = 1
mb_cachedRangeChecks = {}
mb_RangeCheckModule_shouldCacheFriendlyRanges = false

function mb_RegisterEnemyRangeCheckSpell(spellName)
    local slot = max_GetTableSize(mb_registeredFriendlyRangeCheckSpells) + max_GetTableSize(mb_registeredEnemyRangeCheckSpells) + 25
    if slot > 36 then
        max_SayRaid("Serious error, I have too many spells registered for range-check")
    end
    if not max_HasSpell(spellName) then
        max_SayRaid("Warning: I'm trying to add " .. spellName .. " to range-check, but I don't know this spell")
        return
    end
    mb_registeredEnemyRangeCheckSpells[spellName] = slot
    PickupSpell(max_GetSpellbookId(spellName), "BOOKTYPE_SPELL ")
    PlaceAction(slot)
    ClearCursor()
end

function mb_RegisterFriendlyRangeCheckSpell(spellName)
    local slot = max_GetTableSize(mb_registeredFriendlyRangeCheckSpells) + max_GetTableSize(mb_registeredEnemyRangeCheckSpells) + 25
    if slot > 36 then
        max_SayRaid("Serious error, I have too many spells registered for range-check")
    end
    if not max_HasSpell(spellName) then
        max_SayRaid("Warning: I'm trying to add " .. spellName .. " to range-check, but I don't know this spell")
        return
    end
    mb_registeredFriendlyRangeCheckSpells[spellName] = {}
    mb_registeredFriendlyRangeCheckSpells[spellName].slot = slot
    local range = mb_GetSpellRange(slot)
    if range == nil then
        max_SayRaid("Serious error, unable to get range for spell " .. spellName)
        return
    end
    mb_registeredFriendlyRangeCheckSpells[spellName].range = range
    PickupSpell(max_GetSpellbookId(spellName), "BOOKTYPE_SPELL ")
    PlaceAction(slot)
    ClearCursor()

    if mb_uniqueFriendlyRangeSpells[range] == nil then
        mb_uniqueFriendlyRangeSpells[range] = slot
    end
    mb_RangeCheckModule_shouldCacheFriendlyRanges = true
end

-- Changes target if you don't try to use it on your existing target, will break auto-attacks
function mb_IsActionInRange(actionSlot, unit)
    SpellStopTargeting()
    if unit == nil or UnitIsUnit("target", unit) then
        return IsActionInRange(actionSlot) == 1
    end

    local hadTarget = UnitExists("target")

    TargetUnit(unit)
    local isInRange = IsActionInRange(actionSlot) == 1

    if hadTarget then
        TargetLastTarget()
    else
        ClearTarget()
    end
    return isInRange
end

function mb_IsSpellInRangeOnEnemy(spellName, unit)
    if mb_registeredEnemyRangeCheckSpells[spellName] == nil then
        max_SayRaid("Serious error, don't have spell " .. spellName .. " registered for rangeCheck, but still tried to check range with it.")
    end
    return mb_IsActionInRange(mb_registeredEnemyRangeCheckSpells[spellName], unit)
end

-- Checks if target exists, is visible, is friendly and if it's dead or ghost AND if it's in range of spell if a spell is provided.
function mb_IsUnitValidFriendlyTarget(unit, spellName)
    if mb_cachedRangeChecks[unit] == nil then
        return false
    end
    if not mb_cachedRangeChecks[unit].isValid then
        return false
    end
    if spellName == nil then
        return true
    end
    if mb_registeredFriendlyRangeCheckSpells[spellName] == nil then
        max_SayRaid("Serious error, don't have spell " .. spellName .. " registered for rangeCheck, but still tried to check range with it.")
        return false
    end
    return mb_cachedRangeChecks[unit][mb_registeredFriendlyRangeCheckSpells[spellName].range] == true
end

-- Like IsCasting but works on specific abilities that doesn't "cast" like aimed shot. Abilities needs to be registered for range-check for them to work. Only works on enemies
function mb_IsUsingAbility(abilityName)
    if mb_registeredEnemyRangeCheckSpells[abilityName] == nil then
        max_SayRaid("Error in mb_IsUsingAbility, I haven't registered ability " .. abilityName)
        return false
    end
    return IsCurrentAction(mb_registeredEnemyRangeCheckSpells[abilityName]) == 1
end

function mb_RangeCheckModule_CacheRangesToFriendlies()
    if not mb_RangeCheckModule_shouldCacheFriendlyRanges then
        return
    end

    local endNumber = mb_lastCachedId + (MB_RANGE_CHECK_MODULE_CACHE_PLAYERS_PER_RUN - 1)
    local members = max_GetNumPartyOrRaidMembers()
    if endNumber > members then
        endNumber = members
    end
    while mb_lastCachedId <= endNumber do
        local unit = max_GetUnitFromPartyOrRaidIndex(mb_lastCachedId)
        mb_cachedRangeChecks[unit] = {}
        if UnitExists(unit) and UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) and not max_HasBuff(unit, BUFF_TEXTURE_SPIRIT_OF_REDEMPTION) and not max_CanAttackUnit(unit) then
            mb_cachedRangeChecks[unit].isValid = true
        else
            mb_cachedRangeChecks[unit].isValid = false
        end
        for range, actionSlot in pairs(mb_uniqueFriendlyRangeSpells) do
            mb_cachedRangeChecks[unit][range] = mb_IsActionInRange(actionSlot, unit)
        end
        mb_lastCachedId = mb_lastCachedId + 1
    end
    if mb_lastCachedId > members then
        mb_lastCachedId = 1
    end
end