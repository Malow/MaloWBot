-- Scans through the raid or party for the unit missing the most health.
function mb_GetMostDamagedFriendly(spell)
    local healTarget = 0
    local missingHealthOfTarget = max_GetMissingHealth("player")
    local members = max_GetNumPartyOrRaidMembers()
    for i = 1, members do
        local unit = max_GetUnitFromPartyOrRaidIndex(i)
        local missingHealth = max_GetMissingHealth(unit)
        if mb_IsValidTarget(unit, spell) then
            if missingHealth > missingHealthOfTarget then
                missingHealthOfTarget = missingHealth
                healTarget = i
            end
        end
    end
    if healTarget == 0 then
        return "player", missingHealthOfTarget
    else
        return max_GetUnitFromPartyOrRaidIndex(healTarget), missingHealthOfTarget
    end
end

-- Scans through the raid or party for the unit with the lowest current health that specified spell can be cast on.
function mb_GetLowestHealthFriendly(spell)
    local healTarget = 0
    local healthOfTarget = UnitHealth("player")
    local members = max_GetNumPartyOrRaidMembers()
    for i = 1, members do
        local unit = max_GetUnitFromPartyOrRaidIndex(i)
        local health = UnitHealth(unit)
        if mb_IsValidTarget(unit, spell) then
            if health < healthOfTarget then
                healthOfTarget = health
                healTarget = i
            end
        end
    end
    if healTarget == 0 then
        return "player", healthOfTarget
    else
        return max_GetUnitFromPartyOrRaidIndex(healTarget), healthOfTarget
    end
end

-- Scans through the raid or party for a unit missing a specific buff, nil if none is found.
function mb_GetFriendlyMissingBuff(buff, spell, unitFilter)
    local members = max_GetNumPartyOrRaidMembers()
    for i = 1, members do
        local unit = max_GetUnitFromPartyOrRaidIndex(i)
        if mb_CheckFilter(unit, unitFilter) and mb_IsValidTarget(unit, spell) and max_GetLevelDifferenceFromSelf(unit) > -10 and not max_HasBuff(unit, buff) then
            return unit
        end
    end
    return nil
end

-- Checks the unit against the unitFilter, returns true if the unit passes (is not filtered)
function mb_CheckFilter(unit, unitFilter)
    if unitFilter == UNIT_FILTER_HAS_MANA then
        if max_GetClass(unit) == "WARRIOR" or max_GetClass(unit) == "ROGUE" then
            return false
        end
        return true
    end
    mb_Print("Error: No implementation for filter: " + unitFilter)
    return false
end