
-- Returns the count of item with specified name
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

-- returns boolean found, bagId, slotId for an item of specified quality
function mb_GetTradeableItemWithQuality(desiredQuality)
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag, slot)
			if texture ~= nil then
			end
			if texture ~= nil and desiredQuality == quality then
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
			if texture ~= nil then
				local name = GetItemInfo(max_GetItemStringFromItemLink(GetContainerItemLink(bag, slot)))
				if not mb_IsIgnoredTradeItem(name) then
					return true, bag, slot
				end
			end
		end
	end
	return false
end

-- Contains a list of items that are ignored for trading, returns true/false
function mb_IsIgnoredTradeItem(itemName)
	if itemName == "Soul Shard" then
		return true
	elseif itemName == "Hearthstone" then
		return true
	elseif itemName == "Rough Arrow" then
		return true
	elseif itemName == "Runed Copper Rod" then
		return true
	end
	return false
end

-- Checks if target exists, is visible, is friendly and if it's dead or ghost AND if it's in range of spell if a spell is provided.
function mb_IsValidTarget(unit, spell)
	if UnitExists(unit) and UnitIsVisible(unit) and UnitIsFriend("player", unit) and not UnitIsDeadOrGhost(unit) and not max_HasBuff(unit, BUFF_SPIRIT_OF_REDEMPTION) then
		if max_IsSpellInRange(spell, unit) then
			return true
		end
	end 
	return false
end 