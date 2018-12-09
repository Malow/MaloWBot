function mb_Priest(msg)
	AssistByName(msg)
	FollowByName(msg, true)

	if max_GetTableSize(mb_queuedRequests) > 0 then
		local queuedSpell = table.remove(mb_queuedRequests, 1)
		TargetByName(queuedSpell.target, true)
		CastSpellByName(queuedSpell.name)
		return
	end

	if mb_Priest_PWS() then
		return
	end

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
	mb_RegisterForProposedRequest(BUFF_POWER_WORD_FORTITUDE.requestType, mb_Priest_HandleProposedPowerWordFortitudeRequest)
	mb_RegisterForAcceptedRequest(BUFF_POWER_WORD_FORTITUDE.requestType, mb_Priest_HandleAcceptedPowerWordFortitudeRequest)
	mb_RegisterForProposedRequest(REQUEST_RESURRECT.requestType, mb_Priest_HandleProposedResurrectionRequest)
	mb_RegisterForAcceptedRequest(REQUEST_RESURRECT.requestType, mb_Priest_HandleAcceptedResurrectionRequest)
	table.insert(mb_desiredBuffs, BUFF_ARCANE_INTELLECT)
	table.insert(mb_desiredBuffs, BUFF_POWER_WORD_FORTITUDE)
end

function mb_Priest_HandleProposedPowerWordFortitudeRequest(requestId, requestType, requestBody)
	if UnitAffectingCombat("player") then
		return
	end
	if max_GetManaPercentage("player") < 80 then
		return
	end
	local unit = max_GetUnitForPlayerName(requestBody)
	if mb_IsValidTarget(unit,"Power Word: Fortitude") then
		mb_AcceptRequest(requestId, requestType, requestBody)
	end
end

function mb_Priest_HandleAcceptedPowerWordFortitudeRequest(request)
	local queuedSpell = {}
	queuedSpell.target = request.requestBody
	queuedSpell.name = "Power Word: Fortitude"
	table.insert(mb_queuedRequests, queuedSpell)
end

function mb_Priest_HandleProposedResurrectionRequest(requestId, requestType, requestBody)
	if UnitAffectingCombat("player") then
		return
	end
	local unit = max_GetUnitForPlayerName(requestBody)
	if UnitExists(unit) and UnitIsVisible(unit) and UnitIsFriend("player", unit) and UnitIsDead(unit) and max_IsSpellInRange("Resurrection", unit) then
		mb_AcceptRequest(requestId, requestType, requestBody)
	end
end

function mb_Priest_HandleAcceptedResurrectionRequest(request)
	local queuedSpell = {}
	queuedSpell.target = request.requestBody
	queuedSpell.name = "Resurrection"
	table.insert(mb_queuedRequests, queuedSpell)
end
