function mb_Priest(commander)
	if mb_DoBasicCasterLogic() then
		return
	end

	if max_GetTableSize(mb_queuedRequests) > 0 then
		local request = mb_queuedRequests[1]
		if request.requestType == BUFF_POWER_WORD_FORTITUDE.requestType then
			-- if gcd is ready
			TargetByName(request.requestBody, true)
			CastSpellByName("Power Word: Fortitude")
			table.remove(mb_queuedRequests, 1)
			return
		elseif request.requestType == REQUEST_RESURRECT.requestType then
			TargetByName(request.requestBody, true)
			CastSpellByName("Resurrection")
			table.remove(mb_queuedRequests, 1)
			return
		else
			max_SayRaid("Serious error, received request for " .. request.requestType)
		end
	end

	if mb_Priest_PWS() then
		return
	end

	if mb_Priest_Renew() then
		return
	end

	AssistByName(commander)
	CastSpellByName("Smite")
end

function mb_Priest_PWS()
	local spell = "Power Word: Shield"
	local unitFilter = UNIT_FILTER_DOES_NOT_HAVE_DEBUFF
	unitFilter.debuff = DEBUFF_TEXTURE_WEAKENED_SOUL
	local healTargetUnit, healthOfTarget = mb_GetLowestHealthFriendly(spell, unitFilter)
	if max_GetHealthPercentage(healTargetUnit) < 50 then
		TargetUnit(healTargetUnit)
		CastSpellByName(spell)
		return true
	end
	return false
end

function mb_Priest_Renew()
	local spell = "Renew"
	local unitFilter = UNIT_FILTER_DOES_NOT_HAVE_BUFF
	unitFilter.buff = BUFF_TEXTURE_RENEW
	local healTargetUnit, missingHealthOfTarget = mb_GetMostDamagedFriendly(spell, unitFilter)
	if max_GetHealthPercentage(healTargetUnit) < 75 then
		TargetUnit(healTargetUnit)
		CastSpellByName(spell)
		return true
	end
	return false
end

function mb_Priest_OnLoad()
	mb_RegisterForRequest(BUFF_POWER_WORD_FORTITUDE.requestType, mb_Priest_HandlePowerWordFortitudeRequest)
	mb_RegisterForRequest(REQUEST_RESURRECT.requestType, mb_Priest_HandleResurrectionRequest)
	mb_AddDesiredBuff(BUFF_ARCANE_INTELLECT)
	mb_AddDesiredBuff(BUFF_POWER_WORD_FORTITUDE)
	mb_AddDesiredBuff(BUFF_BLESSING_OF_WISDOM)
	mb_AddDesiredBuff(BUFF_BLESSING_OF_KINGS)
	mb_AddDesiredBuff(BUFF_BLESSING_OF_LIGHT)
	mb_AddDesiredBuff(BUFF_BLESSING_OF_SALVATION)
end

function mb_Priest_HandlePowerWordFortitudeRequest(requestId, requestType, requestBody)
	if not mb_Priest_HasImprovedFortitude() then
		return
	end
	if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(requestBody), "Power Word: Fortitude") then
		mb_AcceptRequest(requestId, requestType, requestBody)
	end
end

function mb_Priest_HandleResurrectionRequest(requestId, requestType, requestBody)
	if mb_CanResurrectUnitWithSpell(max_GetUnitForPlayerName(requestBody), "Resurrection") then
		mb_AcceptRequest(requestId, requestType, requestBody)
	end
end

function mb_Priest_HasImprovedFortitude()
	local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(1, 4)
	return currentRank == 2
end