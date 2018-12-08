-- Scans through the raid or party for the unit missing the most health.
function mb_GetMostDamagedFriendly(spell)
	local healTarget = 0;
	local missingHealthOfTarget = max_GetMissingHealth("player");
	local members = max_GetNumPartyOrRaidMembers();
	for i = 1, members do 
		local unit = max_GetUnitFromPartyOrRaidIndex(i);
		local missingHealth = max_GetMissingHealth(unit);
		if mb_IsValidTarget(unit, spell) then
			if missingHealth > missingHealthOfTarget then 
				missingHealthOfTarget = missingHealth;
				healTarget = i; 
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
function mb_GetLowestHealthTarget(spell)
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
function mb_GetFriendlyMissingBuff(buff)
	local members = max_GetNumPartyOrRaidMembers();
	for i = 1, members do
		local unit = max_GetUnitFromPartyOrRaidIndex(i);
		if not max_HasBuff(unit, buff) then
			return unit
		end
	end
	return nil
end

function mb_GetItemCountWithName(itemName)
	local totalItemCount = 0
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag, slot)
			if itemCount ~= nil then
				local name = GetItemInfo(max_GetItemStringFromItemLink(GetContainerItemLink(bag, slot)))
				if name == itemName then
					totalItemCount = totalItemCount + itemCount
				end
			end
		end
	end
	return totalItemCount
end

-- Checks if target exists, is visible, is friendly and if it's dead or ghost AND if it's in range of spell.
function mb_IsValidTarget(unit, spell)
	if UnitExists(unit) and UnitIsVisible(unit) and UnitIsFriend("player", unit) and not UnitIsDeadOrGhost(unit) and not max_HasBuff(unit, BUFF_SPIRIT_OF_REDEMPTION) then
		if max_IsSpellInRange(spell, unit) then
			return true
		end
	end 
	return false
end 