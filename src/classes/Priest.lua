function mb_Priest(msg)
	if mb_DoBasicCasterLogic() then
		return
	end

	if max_GetTableSize(mb_queuedRequests) > 0 then
		local queuedRequest = mb_queuedRequests[1]
		if queuedRequest.requestType == BUFF_POWER_WORD_FORTITUDE.requestType then
			-- if gcd is ready
			TargetByName(queuedRequest.requestBody, true)
			CastSpellByName("Power Word: Fortitude")
			table.remove(mb_queuedRequests, 1)
			return
		elseif queuedRequest.requestType == REQUEST_RESURRECT.requestType then
			TargetByName(queuedRequest.requestBody, true)
			CastSpellByName("Resurrection")
			table.remove(mb_queuedRequests, 1)
			return
		else
			SendChatMessage("Serious error, received request for " .. request.requestType, "RAID", "Common")
		end
	end

	if mb_Priest_PWS() then
		return
	end

	AssistByName(msg)
	FollowByName(msg, true)
	CastSpellByName("Smite")
end

function mb_Priest_PWS()
	local spell = "Power Word: Shield"
	local healTargetUnit, healthOfTarget = mb_GetLowestHealthFriendly(spell)
	if max_GetHealthPercentage(healTargetUnit) < 50 then
		TargetUnit(healTargetUnit)
		CastSpellByName(spell)
		return true
	end
	return false
end

function mb_Priest_OnLoad()
	mb_RegisterForRequest(BUFF_POWER_WORD_FORTITUDE.requestType, mb_Priest_HandlePowerWordFortitudeRequest)
	mb_RegisterForRequest(REQUEST_RESURRECT.requestType, mb_Priest_HandleResurrectionRequest)
	table.insert(mb_desiredBuffs, BUFF_ARCANE_INTELLECT)
	table.insert(mb_desiredBuffs, BUFF_POWER_WORD_FORTITUDE)
end

function mb_Priest_HandlePowerWordFortitudeRequest(requestId, requestType, requestBody)
	if UnitAffectingCombat("player") then
		return
	elseif max_GetManaPercentage("player") < 80 then
		return
	end
	local unit = max_GetUnitForPlayerName(requestBody)
	if mb_IsValidTarget(unit,"Power Word: Fortitude") then
		mb_AcceptRequest(requestId, requestType, requestBody)
	end
end

function mb_Priest_HandleResurrectionRequest(requestId, requestType, requestBody)
	if UnitAffectingCombat("player") then
		return
	elseif max_GetManaPercentage("player") < 30 then
		return
	end
	local unit = max_GetUnitForPlayerName(requestBody)
	if UnitExists(unit) and UnitIsVisible(unit) and UnitIsFriend("player", unit) and UnitIsDead(unit) and max_IsSpellInRange("Resurrection", unit) then
		mb_AcceptRequest(requestId, requestType, requestBody)
	end
end
