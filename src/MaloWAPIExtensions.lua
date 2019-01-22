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
function max_HasBuff(unit, buffTexture)
	for i = 1, MAX_BUFFS do
		local b = UnitBuff(unit, i)
		if b and b == buffTexture then
			return true
		end
	end
	return false
end

-- Returns true/false depending on if the unit has any of the buffs
function max_HasBuffWithMultipleTextures(unit, textures)
	for u = 1, max_GetTableSize(textures) do
		if max_HasBuff(unit, textures[u]) then
			return true
		end
	end
	return false
end

-- Returns true/false depending on if the unit has the buff
function max_HasDebuff(unit, debuffTexture)
	for i = 1, MAX_DEBUFFS do
		local b = UnitDebuff(unit, i)
		if b and b == debuffTexture then
			return true
		end
	end
	return false
end

-- Get number of Debuff Stacks
function max_GetDebuffStackCount(unit, debuffTexture)
	for i = 1, MAX_DEBUFFS do
		local b, stacks = UnitDebuff(unit, i)
		if b and b == debuffTexture then
			return stacks
		end
	end
	return 0
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

-- Casts the spell on the unit-reference, doesn't work with target. NEEDS auto self-cast off.
function max_CastSpellOnRaidMember(spellName, unit)
	if UnitIsFriend("player", "target") then
		ClearTarget()
	end
	CastSpellByName(spellName, false)
	SpellTargetUnit(unit)
	SpellStopTargeting()
end

function max_CastSpellOnRaidMemberByPlayerName(spellName, playerName)
	max_CastSpellOnRaidMember(spellName, max_GetUnitForPlayerName(playerName))
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

function max_SayGuild(msg)
    SendChatMessage(msg, "GUILD", "Common")
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

-- Returns true / false depending on if any element in the table == the provided element
function max_TableContains(table, element)
	for _, item in pairs(table) do
		if item == element then
			return true
		end
	end
	return false
end

-- Returns which subgroup the unit with the specified raidIndex is in
function max_GetSubgroupForRaidIndex(raidIndex)
	local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(raidIndex)
	return subgroup
end

-- Returns a list of units of the group that the provided unit's name is part of
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
	local highestRank = -1
	local highestRankId = -1
	for i = 1, 200 do
		local name, rankString = GetSpellName(i, "BOOKTYPE_SPELL")
		if name == spellName then
			local rank = 0
			if string.find(rankString, "Rank %d+") then
				rank = tonumber(string.sub(rankString, 5))
			end
			if rank > highestRank then
				highestRankId = i
				highestRank = rank
			end
		end
	end
	if highestRankId == nil then
		max_SayRaid("Serious error, I don't know the spell: " .. tostring(spellName))
	end
	return highestRankId
end

-- Returns true/false depending on if you know that spell
function max_HasSpell(spellName)
	for i = 1, 200 do
		local name, rank = GetSpellName(i, "BOOKTYPE_SPELL")
		if name == spellName then
			return true
		end
	end
	return false
end

-- Returns true/false depending on if the spell with this name is on cooldown
function max_IsSpellNameOnCooldown(spellName)
	local start, duration = GetSpellCooldown(max_GetSpellbookId(spellName), "BOOKTYPE_SPELL ")
	return start ~= 0
end

function max_GetTimeUntilSpellIsReady(spellName)
    local start, duration = GetSpellCooldown(max_GetSpellbookId(spellName), "BOOKTYPE_SPELL ")
    if start ~= 0 then
        return (start + duration) - mb_GetTime()
    else
        return 0
    end
end

-- Returns true/false depending on if the spell with this spellbookId is on cooldown
function max_IsSpellbookIdOnCooldown(spellbookId)
	local start, duration = GetSpellCooldown(spellbookId, "BOOKTYPE_SPELL ")
	return start ~= 0
end

-- Targets the provided player's target. If the player doesn't have a target then clear target. If there is a target return true
-- Also doesn't change target if the target to be set is your current target, to prevent auto-attacks from stopping
function max_AssistByPlayerName(playerName)
	if playerName == UnitName("player") then
		return true
	end
	local assistUnit = max_GetUnitForPlayerName(playerName)
	if assistUnit == nil then
		return true
	end
	if UnitIsUnit("target", assistUnit .. "target") then
		return true
	end
	if UnitExists(assistUnit .. "target") then
		TargetUnit(assistUnit .. "target")
		return true
	else
		ClearTarget()
		return false
	end
end

function max_IsPetAliveAndActive()
	return UnitExists("pet") and not UnitIsDeadOrGhost("pet")
end

function max_GetActiveStance()
	for i = 1, 10 do
		local icon, name, active, castable = GetShapeshiftFormInfo(i);
		if active then
			return i
		end
	end
	return nil
end

function max_GetPlayerNamesInSubgroup(subGroup)
	local names = {}
	local members = max_GetNumPartyOrRaidMembers()
	for i = 1, members do
		local name, rank, group, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i)
		if subGroup == group then
			table.insert(names, name)
		end
	end
	return names
end

function max_IsTable(t)
    return type(t) == "table"
end

--"HeadSlot"
--"NeckSlot"
--"ShoulderSlot"
--"BackSlot"
--"ChestSlot"
--"ShirtSlot"
--"TabardSlot"
--"WristSlot"
--"HandsSlot"
--"WaistSlot"
--"LegsSlot"
--"FeetSlot"
--"Finger0Slot"
--"Finger1Slot"
--"Trinket0Slot"
--"Trinket1Slot"
--"MainHandSlot"
--"SecondaryHandSlot"
--"RangedSlot"
--"AmmoSlot"
--"Bag0Slot"
--"Bag1Slot"
--"Bag2Slot"
--"Bag3Slot"
function max_UseEquippedItemIfReady(itemSlotName)
	local slotId, textureName = GetInventorySlotInfo(itemSlotName)
	local start, duration, enable = GetInventoryItemCooldown("player", slotId)
	if start == 0 then
		UseInventoryItem(slotId)
		return true
	end
	return false
end

function max_RaidTargetIndexToName(raidTargetIndex)
	if raidTargetIndex == nil then
		return "nil"
	elseif raidTargetIndex == 1 then
		return "Yellow Star"
	elseif raidTargetIndex == 2 then
		return "Orange Circle"
	elseif raidTargetIndex == 3 then
		return "Purple Diamond"
	elseif raidTargetIndex == 4 then
		return "Green Triangle"
	elseif raidTargetIndex == 5 then
		return "Moon"
	elseif raidTargetIndex == 6 then
		return "Blue Square"
	elseif raidTargetIndex == 7 then
		return "Red Cross"
	elseif raidTargetIndex == 8 then
		return "Skull"
	end
end

function max_HasValidOffensiveTarget()
	if UnitExists("target") and not UnitIsDeadOrGhost("target") and max_CanAttackUnit("target") then
		return true
	end
	return false
end

function max_GetItemSubTypeForSlot(itemSlotName)
    local itemLink = GetInventoryItemLink("player", GetInventorySlotInfo(itemSlotName))
    if itemLink == nil then
        return nil
    end
    local itemString = max_GetItemStringFromItemLink(itemLink)
    if itemString == nil then
        return nil
    end
    local itemName, itemLink, itemQuality, itemLevel, itemType, itemSubType, itemCount, itemTexture = GetItemInfo(itemString)
    return itemSubType
end

function max_IsItemSubTypeSharp(itemSubType)
    if itemSubType == "Daggers" then
        return true
    end
    if itemSubType == "One-Handed Axes" then
        return true
    end
    if itemSubType == "One-Handed Swords" then
        return true
    end
    if itemSubType == "Two-Handed Axes" then
        return true
    end
    if itemSubType == "Two-Handed Swords" then
        return true
    end
    return false
end

function max_IsItemSubTypeBlunt(itemSubType)
    if itemSubType == "One-Handed Maces" then
        return true
    end
    if itemSubType == "Two-Handed Maces" then
        return true
    end
	if itemSubType == "Fist Weapons" then
		return true
	end
    return false
end

function max_CastSpellIfReady(spellName)
	if not max_IsSpellNameOnCooldown(spellName) then
		CastSpellByName(spellName)
		return true
	end
	return false
end

function max_CanAttackUnit(unit)
    return UnitCanAttack("player", unit) == 1
end

function max_GetPlayerDebuffTimeLeft(debuffTexture)
	for i = 0, MAX_BUFFS do
		local buffIndex = GetPlayerBuff(i, "HARMFUL")
		if buffIndex >= 0 then
			if GetPlayerBuffTexture(buffIndex) == debuffTexture then
				return GetPlayerBuffTimeLeft(buffIndex)
			end
		else
			return 0
		end
	end
end

function max_CancelBuff(buffTexture)
	for i = 0, MAX_BUFFS do
		local buffIndex = GetPlayerBuff(i, "HELPFUL")
		if buffIndex >= 0 then
			if GetPlayerBuffTexture(buffIndex) == buffTexture then
				CancelPlayerBuff(buffIndex)
				return true
			end
		else
			return false
		end
	end
	return false
end

function max_CancelBuffWithRemainingDurationLessThan(buffTexture, remainingDuration)
	for i = 0, MAX_BUFFS do
		local buffIndex = GetPlayerBuff(i, "HELPFUL")
		if buffIndex >= 0 then
			if GetPlayerBuffTexture(buffIndex) == buffTexture then
				if GetPlayerBuffTimeLeft(buffIndex) < remainingDuration then
					CancelPlayerBuff(buffIndex)
					return true
				end
			end
		else
			return false
		end
	end
	return false
end