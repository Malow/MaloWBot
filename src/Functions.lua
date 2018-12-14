
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
	elseif itemName == "Blacksmith Hammer" then
		return true
	elseif itemName == "Mining Pick" then
		return true
	elseif itemName == "Skinning Knife" then
		return true
	elseif itemName == "Thieves' Tools" then
		return true
	elseif itemName == "Core Fragment" then
		return true
	elseif itemName == "Blackhand's Command" then
		return true
	elseif itemName == "Major Soulstone" then
		return true
	elseif itemName == "General Drakkisath's Command" then
		return true
	elseif itemName == "Bijou's Information" then
		return true
	elseif itemName == "Unadorned Seal of Ascension" then
		return true
	elseif itemName == "Doomshot" then
		return true
	elseif itemName == "Wild Thornroot" then
		return true
	elseif itemName == "Symbol of Kings" then
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
	if UnitExists(unit) and UnitIsVisible(unit) and UnitIsFriend("player", unit) and not UnitIsDeadOrGhost(unit) and not max_HasBuff(unit, BUFF_TEXTURE_SPIRIT_OF_REDEMPTION) then
		if spell ~= nil then
			if max_IsSpellInRange(spell, unit) then
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
	return max_HasBuff("player", BUFF_TEXTURE_DRINK)
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
	if UnitExists(unit) and UnitIsVisible(unit) and UnitIsFriend("player", unit) and UnitIsDead(unit) and max_IsSpellInRange(spell, unit) then
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

function mb_ShouldBuffGroupWide(unitName, buff)
	local groupUnits = max_GetGroupUnitsFor(unitName)
	local count = 0
	for i = 1, max_GetTableSize(groupUnits) do
		if mb_IsUnitValidTarget(groupUnits[i]) then
			local hasBuff = false
			for u = 1, max_GetTableSize(buff.textures) do
				if max_HasBuff(groupUnits[i], buff.textures[u]) then
					hasBuff = true
				end
			end
			if not hasBuff then
				count = count + 1
			end
		end
	end
	if count > 1 then
		return true
	end
	return false
end
