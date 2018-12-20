
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
			if texture ~= nil then
			end
			if texture ~= nil and desiredQuality == quality and not locked then
				local name = GetItemInfo(max_GetItemStringFromItemLink(GetContainerItemLink(bag, slot)))
				if not mb_IsIgnoredTradeItem(name) then
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
				if not mb_IsIgnoredTradeItem(name) then
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

function mb_AddItemToIgnoredForTrade(itemName)
	if mb_SV.ignoredTradeItems == nil then
		mb_SV.ignoredTradeItems = {}
	end
	table.insert(mb_SV.ignoredTradeItems, itemName)
end

-- Contains a list of items that are ignored for trading, returns true/false. Any BOP-items should be added to the mb_SV.ignoredTradeItems automatically in SharedBehaviour
function mb_IsIgnoredTradeItem(itemName)
	if mb_SV.ignoredTradeItems ~= nil then
		if max_TableContains(mb_SV.ignoredTradeItems, itemName) then
			return true
		end
	end

	if itemName == "Rough Arrow" then
		return true
	elseif itemName == "Jagged Arrow" then
		return true
	elseif itemName == "Accurate Slugs" then
		return true
	elseif itemName == "Blacksmith Hammer" then
		return true
	elseif itemName == "Mining Pick" then
		return true
	elseif itemName == "Skinning Knife" then
		return true
	elseif itemName == "Unadorned Seal of Ascension" then
		return true
	elseif itemName == "Wild Thornroot" then
		return true
	elseif itemName == "Symbol of Kings" then
		return true
	elseif itemName == "Rune of Portals" then
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

-- Checks if target exists, is visible, is friendly and if it's dead or ghost AND if it's in range of spell if a spell is provided.
function mb_IsUnitValidTarget(unit, spell)
	if UnitExists(unit) and UnitIsVisible(unit) and not UnitIsEnemy("player", unit) and not UnitIsDeadOrGhost(unit) and not max_HasBuff(unit, BUFF_TEXTURE_SPIRIT_OF_REDEMPTION) then
		if spell ~= nil then
			if mb_IsSpellInRange(spell, unit) then
				return true
			end
		else
			return true
		end
	end 
	return false
end

-- Drinks conjured mage-water if possible, returns true/false
function mb_DrinkIfPossible()
	if not UnitAffectingCombat("player") and not mb_IsDrinking() then
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
function mb_CanResurrectUnitWithSpell(unit, spell)
	if UnitAffectingCombat("player") then
		return false
	elseif max_GetManaPercentage("player") < 30 then
		return false
	elseif mb_IsDrinking() then
		return false
	end
	if UnitExists(unit) and UnitIsVisible(unit) and UnitIsFriend("player", unit) and UnitIsDead(unit) and mb_IsSpellInRange(spell, unit) then
		return true
	end
end

-- Checks combat and mana and target
function mb_CanBuffUnitWithSpell(unit, spell)
	if UnitAffectingCombat("player") then
		return false
	elseif max_GetManaPercentage("player") < 50 then
		return false
	elseif mb_IsDrinking() then
		return false
	end
	if mb_IsUnitValidTarget(unit, spell) and max_GetLevelDifferenceFromSelf(unit) > -8 then
		return true
	end
end

mb_lastAcceptedTrade = 0
function mb_AcceptTradeThrottled()
	if mb_lastAcceptedTrade + 0.5 < GetTime() then
		mb_lastAcceptedTrade = GetTime()
		AcceptTrade()
	end
end

-- Optional unitFilter used for Arcane Int / Divine Spirit
function mb_ShouldBuffGroupWide(unitName, buff, unitFilter)
	local groupUnits = max_GetGroupUnitsFor(unitName)
	local count = 0
	for i = 1, max_GetTableSize(groupUnits) do
		if mb_IsUnitValidTarget(groupUnits[i]) and not max_HasBuffWithMultipleTextures(groupUnits[i], buff.textures) then
			if unitFilter == nil then
				count = count + 1
			elseif mb_CheckFilter(groupUnits[i], unitFilter) then
				count = count + 1
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