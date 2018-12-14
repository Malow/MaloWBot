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

-- Returns the unit that has specified raidIndex
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

-- Returns true/false depending on if the unit has the buff
function max_HasDebuff(unit, debuff)
	for i = 1, MAX_DEBUFFS do
		local b = UnitDebuff(unit, i)
		if b and b == debuff then
			return true
		end
	end
	return false
end

-- Calculates missing health from maxHealth - currentHealth
function max_GetMissingHealth(unit)
	return UnitHealthMax(unit) - UnitHealth(unit)
end

function max_GetHealthPercentage(unit)
	return (UnitHealth(unit) / UnitHealthMax(unit)) * 100
end

function max_GetMissingMana(unit)
	return UnitManaMax(unit) - UnitMana(unit)
end

function max_GetManaPercentage(unit)
	return (UnitMana(unit) / UnitManaMax(unit)) * 100
end

-- Converts an ItemLink to an ItemString
function max_GetItemStringFromItemLink(itemLink)
	local found, _, itemString = string.find(itemLink, "^|%x+|H(.+)|h%[.+%]")
	return itemString
end

-- Returns true if said spell is in range to unit. NEEDS auto self-cast off.
function max_IsSpellInRange(spell, unit)
	if UnitIsFriend("player", "target") then
		ClearTarget()
	end

	local can = false
	CastSpellByName(spell, false)
	if SpellCanTargetUnit(unit) then
		can = true
	end
	SpellStopTargeting()
	return can
end

-- Casts the spell on the unit-reference, doesn't work with target. NEEDS auto self-cast off.
function max_CastSpellOnRaidMember(spellName, unit)
	if UnitIsFriend("player", "target") then
		ClearTarget()
	end
	CastSpellByName(spellName, false)
	SpellTargetUnit(unit)
end

function max_CastSpellOnRaidMemberByPlayerName(spellName, playerName)
	local unit = max_GetUnitForPlayerName(playerName)
	if UnitIsFriend("player", "target") then
		ClearTarget()
	end
	CastSpellByName(spellName, false)
	SpellTargetUnit(unit)
end

function max_GetLevelDifferenceFromSelf(unit)
	return UnitLevel(unit) - UnitLevel("player")
end

function max_GetFreeBagSlots()
	local count = 0
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag, slot)
			if texture == nil then
				count = count + 1
			end
		end
	end
	return count
end

-- Turns a playerName into a unit-reference, nil if not found
function max_GetUnitForPlayerName(playerName)
	local members = max_GetNumPartyOrRaidMembers()
	for i = 1, members do
		local unit = max_GetUnitFromPartyOrRaidIndex(i)
		if UnitName(unit) == playerName then
			return unit
		end
	end
	return nil
end

-- Turns a playerName into a raid-index, nil if not found
function max_GetRaidIndexForPlayerName(playerName)
	local members = max_GetNumPartyOrRaidMembers()
	for i = 1, members do
		local unit = max_GetUnitFromPartyOrRaidIndex(i)
		if UnitName(unit) == playerName then
			return i
		end
	end
	return nil
end

-- Splits a string where a character is found
function max_SplitString(str, char)
	local strings = {}
	while string.find(str, char) do
		table.insert(strings, string.sub(str, 1, string.find(str, char) - 1))
		str = string.sub(str, string.find(str, char) + 1)
	end
	table.insert(strings, str)
	return strings
end

-- Says the text in raid
function max_SayRaid(msg)
	SendChatMessage(msg, "RAID", "Common")
end

-- Returns the amount of unspent talent points
function max_GetUnspentTalentPoints()
	local spentPoints = 0
	for tabIndex = 1, 3 do
		for talentIndex = 1, 28 do
			local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tabIndex, talentIndex)
			if nameTalent ~= nil then
				spentPoints = spentPoints + currentRank
			end
		end
	end
	return UnitLevel("player") - 9 - spentPoints
end

-- Returns the size of a List/Table/Array
function max_GetTableSize(t)
	local count = 0
	for _ in pairs(t) do count = count + 1 end
	return count
end

-- Returns which subgroup the unit with the specified raidIndex is in
function max_GetSubgroupForRaidIndex(raidIndex)
	local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(raidIndex)
	return subgroup
end

-- Returns a list of names of units of the group that the provided unit's name is part of
function max_GetGroupUnitsFor(unitName)
	local targetRaidIndex = max_GetRaidIndexForPlayerName(unitName)
	local targetSubGroup = max_GetSubgroupForRaidIndex(targetRaidIndex)
	local groupMembers = {}

	local membersCount = max_GetNumPartyOrRaidMembers()
	for i = 1, membersCount do
		local unit = max_GetUnitFromPartyOrRaidIndex(i)
		local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i)
		if subgroup == targetSubGroup then
			table.insert(groupMembers, unit)
		end
	end
	return groupMembers
end

-- Returns the spellbookId of the spell
function max_GetSpellbookId(spellName)
	for i = 1, 200 do
		local name, rank = GetSpellName(i, "BOOKTYPE_SPELL")
		if name == spellName then
			return i
		end
	end
	max_SayRaid("Serious error, I don't know the spell: " .. tostring(spellName))
end

-- Returns true/false depending on if the spell with this name is on cooldown
function max_IsSpellNameOnCooldown(spellName)
	local start, duration = GetSpellCooldown(max_GetSpellbookId(spellName), "BOOKTYPE_SPELL ")
	return start ~= 0
end

-- Returns true/false depending on if the spell with this spellbookId is on cooldown
function max_IsSpellbookIdOnCooldown(spellbookId)
	local start, duration = GetSpellCooldown(spellbookId, "BOOKTYPE_SPELL ")
	return start ~= 0
end