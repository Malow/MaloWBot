-- Scans through the raid or party for the unit missing the most health.
function mb_GetMostDamagedFriendly(spell, unitFilter)
    local healTarget = 0
    local missingHealthOfTarget = max_GetMissingHealth("player")
    local members = max_GetNumPartyOrRaidMembers()
    for i = 1, members do
        local unit = max_GetUnitFromPartyOrRaidIndex(i)
        if unitFilter ~= nil and not mb_CheckFilter(unit, unitFilter) then
            break
        end
        local missingHealth = max_GetMissingHealth(unit)
        if missingHealth > missingHealthOfTarget then
            if mb_IsUnitValidTarget(unit, spell) then
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
function mb_GetLowestHealthFriendly(spell, unitFilter)
    local healTarget = 0
    local healthOfTarget = UnitHealth("player")
    local members = max_GetNumPartyOrRaidMembers()
    for i = 1, members do
        local unit = max_GetUnitFromPartyOrRaidIndex(i)
        if unitFilter ~= nil and not mb_CheckFilter(unit, unitFilter) then
            break
        end
        local health = UnitHealth(unit)
        if mb_IsUnitValidTarget(unit, spell) then
            if health < healthOfTarget then
                healthOfTarget = health
                healTarget = i
            end
        end
        if healTarget == 0 then
            return "player", healthOfTarget
        else
            return max_GetUnitFromPartyOrRaidIndex(healTarget), healthOfTarget
        end
    end
end

-- Returns the unit of a raid-member that has a debuff of the specific type and that you can cast the specific spell on.
function mb_GetDebuffedRaidMember(spell, debuffType1, debuffType2, debuffType3)
    local members = max_GetNumPartyOrRaidMembers()
    for i = 1, members do
        local unit = max_GetUnitFromPartyOrRaidIndex(i)
        for u = 1, MAX_DEBUFFS do
            local debuffTexture, debuffApplications, debuffDispelType = UnitDebuff(unit, u)
            if debuffDispelType ~= nil and (debuffDispelType == debuffType1 or debuffDispelType == debuffType2 or debuffDispelType == debuffType3) then
                if mb_IsUnitValidTarget(unit, spell) then
                    return unit
                end
            end
        end
    end
    return nil
end

-- Checks the unit against the unitFilter, returns true if the unit passes (is not filtered)
function mb_CheckFilter(unit, unitFilter)
    if unitFilter.name == UNIT_FILTER_HAS_MANA.name then
        if max_GetClass(unit) == "WARRIOR" or max_GetClass(unit) == "ROGUE" then
            return false
        end
        return true
    elseif unitFilter.name == UNIT_FILTER_DOES_NOT_HAVE_DEBUFF.name then
        if max_HasDebuff(unit, unitFilter.debuff) then
            return false
        end
        return true
    elseif unitFilter.name == UNIT_FILTER_DOES_NOT_HAVE_BUFF.name then
        if max_HasBuff(unit, unitFilter.buff) then
            return false
        end
        return true
    end
    mb_Print("Error: No implementation for filter: " + unitFilter)
    return false
end