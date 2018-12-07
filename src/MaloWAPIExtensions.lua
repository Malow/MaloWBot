function max_GetClass(unit)
	local _, class = UnitClass(unit)
	return class
end

function max_GetNumPartyOrRaidMembers()
	if UnitInRaid("player") then
		return GetNumRaidMembers()
	else
		return GetNumPartyMembers()
	end
	return 0
end

function max_GetUnitFromPartyOrRaidIndex(index)
	if index ~= 0 then
		if UnitInRaid("player") then
			return "raid" .. index
		else
			return "party" .. index
		end
	end
	return "player"
end

-- Returns true/false depending on if the unit has the buff
function max_HasBuff(unit, buff)
	for i = 1, MAX_BUFFS do
		local b = UnitBuff(unit, i)
		if b and b == buff then
			return true
		end
	end
	return false
end

-- Calculates missing health from maxHealth - currentHealth
function max_GetMissingHealth(unit)
	return UnitHealthMax(unit) - UnitHealth(unit)
end

-- Returns true if said spell is in range to unit. NEEDS autoself cast off.
function max_IsSpellInRange(spell, unit)
	TargetUnit(unit)
	return IsActionInRange(1)
	--local can = false
	--ClearTarget()
	--CastSpellByName(spell, false)
	--if SpellCanTargetUnit(unit) then
	--	can = true
	--end
	--SpellStopTargeting()
	--return can
end

