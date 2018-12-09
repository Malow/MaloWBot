
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
	if UnitExists(unit) and UnitIsVisible(unit) and UnitIsFriend("player", unit) and not UnitIsDeadOrGhost(unit) and not max_HasBuff(unit, BUFF_TEXTURE_SPIRIT_OF_REDEMPTION) then
		if max_IsSpellInRange(spell, unit) then
			return true
		end
	end 
	return false
end

-- When there's a gossip opened this will first press "I want to train" and then learn everything available. Requires multiple runs with delay between to learn all ranks of all spells
function mb_TrainAll()
	local title1, gossip1, title2, gossip2, title3, gossip3, title4, gossip4, title5, gossip5 = GetGossipOptions()
	if gossip1 == "trainer" then
		SelectGossipOption(1)
	elseif gossip2 == "trainer" then
		SelectGossipOption(2)
	elseif gossip3 == "trainer" then
		SelectGossipOption(3)
	elseif gossip4 == "trainer" then
		SelectGossipOption(4)
	elseif gossip5 == "trainer" then
		SelectGossipOption(5)
	end
	for i = 200, 1, -1 do
		BuyTrainerService(i)
	end
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
	return max_HasBuff("player", BUFF_DRINK)
end