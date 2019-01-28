
-- Returns the count of item with specified name
function mb_GetItemCount(itemName)
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

function mb_HasItem(itemName)
	local itemCount = mb_GetItemCount(itemName)
	return itemCount > 0
end

-- returns boolean found, bagId, slotId for an item of specified quality
function mb_GetTradeableItemWithQuality(desiredQuality)
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag, slot)
			if texture ~= nil and desiredQuality == quality and not locked then
				local name = GetItemInfo(max_GetItemStringFromItemLink(GetContainerItemLink(bag, slot)))
				if not mb_IsIgnoredTradeItem(name) and not mb_IsItemSoulbound(bag, slot) then
					return true, bag, slot
				end
			end
		end
	end
	return false
end

-- returns boolean found, bagId, slotId for an item of specified quality or above
function mb_GetTradeableItem()
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag, slot)
			if texture ~= nil and not locked then
				local name = GetItemInfo(max_GetItemStringFromItemLink(GetContainerItemLink(bag, slot)))
				if not mb_IsIgnoredTradeItem(name) and not mb_IsItemSoulbound(bag, slot) then
					return true, bag, slot
				end
			end
		end
	end
	return false
end

-- returns bag and slot for itemName
function mb_GetItemLocation(itemName)
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag, slot)
			if texture ~= nil then
				local name = GetItemInfo(max_GetItemStringFromItemLink(GetContainerItemLink(bag, slot)))
				if itemName == name then
					return bag, slot
				end
			end
		end
	end
	return nil
end

-- True/false whether the item is on cooldown. True if item doesn't exist
function mb_IsItemOnCooldown(itemName)
	local bag, slot = mb_GetItemLocation(itemName)
	if bag ~= nil then
		local startTime, duration, isEnabled = GetContainerItemCooldown(bag, slot)
		return startTime ~= 0
	end
	return true
end

-- Use item by name, returns true on success
function mb_UseItem(itemName)
	local bag, slot = mb_GetItemLocation(itemName)
	if bag ~= nil then
		UseContainerItem(bag, slot)
		return true
	end
	return false
end

-- returns bag and slot for conjured water
function mb_LocateWaterInBags()
	for i = max_GetTableSize(ITEMS_WATER), 1, -1 do
		local bag, slot = mb_GetItemLocation(ITEMS_WATER[i])
		if bag ~= nil then
			return bag, slot
		end
	end
	return nil
end

-- Returns the count of conjured water the player has
function mb_GetWaterCount()
	local totalItemCount = 0
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag, slot)
			if itemCount ~= nil then
				local name = GetItemInfo(max_GetItemStringFromItemLink(GetContainerItemLink(bag, slot)))
				for i = max_GetTableSize(ITEMS_WATER), 1, -1 do
					if name == ITEMS_WATER[i] then
						totalItemCount = totalItemCount + itemCount
					end
				end
			end
		end
	end
	return totalItemCount
end

-- Contains a list of items that are ignored for trading, returns true/false.
function mb_IsIgnoredTradeItem(itemName)
	for _, watchedReagent in pairs(mb_watchedReagents) do
		if watchedReagent.itemName == itemName then
			return true
		end
	end

	if itemName == "Blacksmith Hammer" then
		return true
	elseif itemName == "Mining Pick" then
		return true
	elseif itemName == "Skinning Knife" then
		return true
	elseif itemName == "Unadorned Seal of Ascension" then
		return true
	elseif itemName == "Ironwood Seed" then
		return true
	elseif itemName == "Major Healthstone" then
		return true
	elseif itemName == "Gyromatic Micro-Adjustor" then
		return true
    elseif itemName == "Arclight Spanner" then
        return true
	elseif itemName == "Field Repair Bot 74A" then
		return true
	elseif itemName == "Fishing Pole" then
		return true
	elseif itemName == "Big Iron Fishing Pole" then
		return true
	elseif itemName == "Bright Baubles" then
		return true
	elseif itemName == "Aquadynamic Fish Attractor" then
		return true
	elseif itemName == "Flint and Tinder" then
		return true
	elseif itemName == "Simple Wood" then
		return true
	elseif itemName == "Salt Shaker" then
		return true
	end
	for i = max_GetTableSize(ITEMS_WATER), 1, -1 do
		if itemName == ITEMS_WATER[i] then
			return true
		end
	end
	for i = max_GetTableSize(ITEMS_MANA_GEM), 1, -1 do
		if itemName == ITEMS_MANA_GEM[i] then
			return true
		end
	end
	return false
end

-- Drinks conjured mage-water if possible, returns true/false
function mb_DrinkIfPossible()
	if not mb_IsInCombat() and not mb_IsDrinking() then
		local bag, slot = mb_LocateWaterInBags()
		if bag ~= nil then
			UseContainerItem(bag, slot)
			return true
		end
	end
	return false
end

-- Returns true/false whether the player has the drink-buff
function mb_IsDrinking()
	return max_HasBuff("player", BUFF_TEXTURE_DRINK) or max_HasBuff("player", BUFF_TEXTURE_DRINK_2)
end

-- Checks combat and mana and target
function mb_CanResurrectUnitWithSpell(unit, spellName)
	if mb_IsInCombat() then
		return false
	elseif max_GetManaPercentage("player") < 30 then
		return false
	elseif mb_IsDrinking() then
		return false
	elseif UnitIsDead("player") then
		return false
	end
	if UnitExists(unit) and UnitIsVisible(unit) and UnitIsFriend("player", unit) and UnitIsDead(unit) and CheckInteractDistance(unit, 4) then --mb_IsSpellInRange(spellName, unit) then
		return true
	end
end

-- Checks combat and mana and target
function mb_CanBuffUnitWithSpell(unit, spell)
	if max_GetManaPercentage("player") < 50 then
		return false
	end
	if mb_IsDrinking() then
		return false
	end
	if UnitIsDead("player") then
		return false
	end
	if max_GetLevelDifferenceFromSelf(unit) < -8 then
		return false
	end
	return mb_IsUnitValidFriendlyTarget(unit, spell)
end

-- Optional unitFilter used for Arcane Int / Divine Spirit
function mb_ShouldBuffGroupWide(unitName, buff, unitFilter)
	local groupUnits = max_GetGroupUnitsFor(unitName)
	local count = 0
	for i = 1, max_GetTableSize(groupUnits) do
		if unitFilter == nil or mb_CheckFilter(groupUnits[i], unitFilter) then
			if not max_HasBuffWithMultipleTextures(groupUnits[i], buff.textures) then
				if mb_IsUnitValidFriendlyTarget(groupUnits[i]) then
					count = count + 1
				end
			end
		end
	end
	if count > 2 then
		return true
	end
	return false
end

-- Returns an alphabetically sorted list of the names of the players in your raid with the same class as you
function mb_GetClassMates(class)
	local classMates = {}
	local members = max_GetNumPartyOrRaidMembers()
	for i = 1, members do
		local unit = max_GetUnitFromPartyOrRaidIndex(i)
		if max_GetClass(unit) == class then
			local unitName = UnitName(unit)
			table.insert(classMates, unitName)
		end
	end
	table.sort(classMates)
	return classMates
end

-- Returns true if said spell is in range to unit. NEEDS auto self-cast off. Returns false if you're on GCD or if you're already casting something
-- Only benefit of using this over mb_IsSpellInRange is that it returns false if you're LoS of the unit
function mb_CanHelpfulSpellBeCastOn(spell, unit)
	if UnitIsFriend("player", "target") then
		if unit == "target" then
			unit = max_GetUnitForPlayerName(UnitName("target"))
		end
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

-- Returns the number of HoTs on the unit.
function mb_GetHoTCount(unit)
	local hotCount = 0
	if max_HasBuff(unit, BUFF_TEXTURE_RENEW) then
		hotCount = hotCount + 1
	end
	if max_HasBuff(unit, BUFF_TEXTURE_REJUVENATION) then
		hotCount = hotCount + 1
	end
	if max_HasBuff(unit, BUFF_TEXTURE_REGROWTH) then
		hotCount = hotCount + 1
	end
	return hotCount
end

-- Returns a number between 0.0 and 5.0 depending on how effective the group-heal would be, also returns a list of playerNames for the targets it will hit
function mb_GetGroupHealEffect(healValue, rangeCheckSpell)
    local groupUnits = mb_GetMyGroupUnitsThrottled()
    local totalHealEffect = 0
    local affectedPlayers = {}
	for _, unit in pairs(groupUnits) do
		local healEffect = max_GetMissingHealth(unit) / healValue
		if healEffect > 0.0 then
			if mb_IsUnitValidFriendlyTarget(unit, rangeCheckSpell) then
				if healEffect > 1.0 then
					healEffect = 1.0
				end
				local unitName = UnitName(unit)
				table.insert(affectedPlayers, unitName)
				totalHealEffect = totalHealEffect + healEffect
			end
		end
    end
    return totalHealEffect, affectedPlayers
end

mb_lastTargetSkullTime = 0
mb_lastTargetSkullResult = false
function mb_TargetSkullThrottled()
	if mb_lastTargetSkullTime + 1 > mb_GetTime() then
		return mb_lastTargetSkullResult
	end
	mb_lastTargetSkullTime = mb_GetTime()

    if UnitExists("target") and GetRaidTargetIndex("target") == 8 then
		mb_lastTargetSkullResult = true
        return mb_lastTargetSkullResult
    end

	local members = max_GetNumPartyOrRaidMembers()
	for i = 1, members do
		local unit = max_GetUnitFromPartyOrRaidIndex(i)
		if UnitExists(unit .. "target") and GetRaidTargetIndex(unit .. "target") == 8 then
			AssistUnit(unit)
			mb_lastTargetSkullResult = true
			return mb_lastTargetSkullResult
		end
	end

	mb_lastTargetSkullResult = false
	return mb_lastTargetSkullResult
end

mb_lastGetMyGroupUnitsTime = 0
mb_lastGetMyGroupUnitsResult = {}
function mb_GetMyGroupUnitsThrottled()
	if mb_lastGetMyGroupUnitsTime + 3 > mb_GetTime() then
		return mb_lastGetMyGroupUnitsResult
	end
	mb_lastGetMyGroupUnitsTime = mb_GetTime()

	mb_lastGetMyGroupUnitsResult = max_GetGroupUnitsFor(UnitName("player"))
	return mb_lastGetMyGroupUnitsResult
end

function mb_GetLowestDurabilityPercentage()
	local durabilitySlots = { 1, 3, 5, 6, 7, 8, 9, 10, 16, 17, 18 }
	local lowestDurability = 100
	for _, v in pairs(durabilitySlots) do
		local percentage = mb_GetDurabilityPercentageForItemSlot(v)
		if percentage ~= nil then
			if percentage < lowestDurability then
				lowestDurability = percentage
			end
		end
	end
	return lowestDurability
end

function mb_GetDurabilityPercentageForItemSlot(itemSlot)
	MaloWBotToolTip:SetOwner(UIParent, "ANCHOR_NONE")
	MaloWBotToolTip:ClearLines()
	MaloWBotToolTip:SetInventoryItem("player", itemSlot)
	for i = 1, 10 do
		local line = getglobal("MaloWBotToolTipTextLeft" .. i):GetText()
		if line ~= nil then
			local percentage = mb_GetDurabilityPercentageFromLine(line)
			if percentage ~= nil then
				return percentage
			end
		end
	end
	return nil
end

function mb_GetDurabilityPercentageFromLine(line)
	local start = string.find(line, "Durability %d+ / %d+")
	if start == nil then
		return nil
	end
	line = string.sub(line, 12)
	local slashPos = string.find(line, "/")
	local firstPart = string.sub(line, 1, slashPos - 1)
	local secondPart = string.sub(line, slashPos + 2, string.len(line))
	return (tonumber(firstPart) / tonumber(secondPart)) * 100
end

function mb_IsItemSoulbound(bag, slot)
	MaloWBotToolTip:SetOwner(UIParent, "ANCHOR_NONE")
	MaloWBotToolTip:ClearLines()
	MaloWBotToolTip:SetBagItem(bag, slot)
	for i = 1, 10 do
		local line = getglobal("MaloWBotToolTipTextLeft" .. i):GetText()
		if line == "Soulbound" then
			return true
		end
	end
	return false
end

function mb_GetSpellRange(actionSlot)
    MaloWBotToolTip:SetOwner(UIParent, "ANCHOR_NONE")
    MaloWBotToolTip:ClearLines()
    MaloWBotToolTip:SetAction(actionSlot)
    for i = 1, 10 do
        local line = getglobal("MaloWBotToolTipTextRight" .. i):GetText()
        if line ~= nil and string.find(line, "yd range") then
            local spacePos = string.find(line, " ")
            local range = tonumber(string.sub(line, 1, spacePos - 1))
            return range
        end
    end
    return nil
end

mb_lastStartTradeTime = 0
function mb_StartTradeThrottled(unit)
	if mb_lastStartTradeTime + 1 > mb_GetTime() then
		return
	end
	mb_lastStartTradeTime = mb_GetTime()
	InitiateTrade(unit)
end