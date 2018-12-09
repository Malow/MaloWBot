---
--- TODO:
---	Evocation
---	Polymorph requests
---
function mb_Mage(msg)
	if mb_isCasting then
		return
	end

	if mb_IsDrinking() then
		if max_GetManaPercentage("player") < 95 then
			return
		else
			SitOrStand()
		end
	end

	if max_GetTableSize(mb_queuedRequests) > 0 then
		local queuedRequest = mb_queuedRequests[1]
		if queuedRequest.name == "Arcane Intellect" then
			TargetByName(queuedRequest.target, true)
			CastSpellByName(queuedRequest.name)
			table.remove(mb_queuedRequests, 1)
			return
		elseif queuedRequest.name == "Water" then
			if mb_isTrading then
				local bag, slot = mb_LocateWaterInBags()
				PickupContainerItem(bag, slot)
				DropItemOnUnit("target")
				table.remove(mb_queuedRequests, 1)
			else
				TargetByName(queuedRequest.target, true)
				InitiateTrade("target")
			end
		end
	end

	if max_GetManaPercentage("player") < 50 then
		if mb_DrinkIfPossible() then
			return
		end
	end

	if not UnitAffectingCombat("player") then
		if mb_GetWaterCount() < 40 then
			CastSpellByName("Conjure Water")
			return
		end
		for i = max_GetTableSize(ITEMS_MANA_GEM), 1, -1 do
			if not mb_HasItem(ITEMS_MANA_GEM[i]) then
				CastSpellByName("Conjure " .. ITEMS_MANA_GEM[i])
				return
			end
		end
		if not max_HasBuff("player", BUFF_ICE_ARMOR) then
			CastSpellByName("Ice Armor")
			return
		end
	end

	if UnitAffectingCombat("player") then
		if max_GetManaPercentage("player") < 10 then
			for i = max_GetTableSize(ITEMS_MANA_GEM), 1, -1 do
				local bag, slot = mb_GetItemLocation(ITEMS_MANA_GEM[i])
				if bag ~= nil then
					UseContainerItem(bag, slot)
				end
			end
		end
	end

	--- Time to do some actual combat

	AssistByName(msg)
	FollowByName(msg, true)

	CastSpellByName("Fire Blast")
	CastSpellByName("Frostbolt")
end

function mb_Mage_OnLoad()
	mb_RegisterForProposedRequest(BUFF_ARCANE_INTELLECT.requestType, mb_Mage_HandleProposedArcaneIntRequest)
	mb_RegisterForAcceptedRequest(BUFF_ARCANE_INTELLECT.requestType, mb_Mage_HandleAcceptedArcaneIntRequest)
	mb_RegisterForProposedRequest(REQUEST_WATER.requestType, mb_Mage_HandleProposedWaterRequest)
	mb_RegisterForAcceptedRequest(REQUEST_WATER.requestType, mb_Mage_HandleAcceptedWaterRequest)
	table.insert(mb_desiredBuffs, BUFF_ARCANE_INTELLECT)
	table.insert(mb_desiredBuffs, BUFF_POWER_WORD_FORTITUDE)

	mb_Mage_LearnTalents()
end

function mb_Mage_HandleProposedArcaneIntRequest(requestId, requestType, requestBody)
	if UnitAffectingCombat("player") then
		return
	end
	if max_GetManaPercentage("player") < 80 then
		return
	end
	local unit = max_GetUnitForPlayerName(requestBody)
	if mb_IsValidTarget(unit,"Arcane Intellect") then
		mb_AcceptRequest(requestId, requestType, requestBody)
	end
end

function mb_Mage_HandleAcceptedArcaneIntRequest(request)
	local queuedSpell = {}
	queuedSpell.target = request.requestBody
	queuedSpell.name = "Arcane Intellect"
	table.insert(mb_queuedRequests, queuedSpell)
end

function mb_Mage_HandleProposedWaterRequest(requestId, requestType, requestBody)
	if mb_GetWaterCount() < 25 then
		return
	end
	local unit = max_GetUnitForPlayerName(requestBody)
	if mb_IsValidTarget(unit,"Arcane Intellect") then -- Using Arcane int for first range-check
		if CheckInteractDistance(unit, 2) then
			mb_AcceptRequest(requestId, requestType, requestBody)
		end
	end
end

function mb_Mage_HandleAcceptedWaterRequest(request)
	local queuedRequest = {}
	queuedRequest.target = request.requestBody
	queuedRequest.name = "Water"
	table.insert(mb_queuedRequests, queuedRequest)
end

function mb_Mage_LearnTalents()
	mb_LearnTalent(3, 2) -- Improved Frostbolt
	mb_LearnTalent(3, 5) -- Frostbite
end