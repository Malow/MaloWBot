function mb_Mage(msg)
	if mb_isCasting then
		return
	end

	if max_GetTableSize(mb_queuedRequests) > 0 then
		local queuedSpell = table.remove(mb_queuedRequests, 1)
		TargetByName(queuedSpell.target, true)
		CastSpellByName(queuedSpell.name)
		return
	end

	AssistByName(msg)
	FollowByName(msg, true)

	CastSpellByName("Fire Blast")
	CastSpellByName("Frostbolt")
end

function mb_Mage_OnLoad()
	mb_RegisterForProposedRequest(BUFF_ARCANE_INTELLECT.requestType, mb_Mage_ProposedArcaneIntRequest)
	mb_RegisterForAcceptedRequest(BUFF_ARCANE_INTELLECT.requestType, mb_Mage_HandleAcceptedArcaneIntRequest)
	table.insert(mb_desiredBuffs, BUFF_ARCANE_INTELLECT)
	table.insert(mb_desiredBuffs, BUFF_POWER_WORD_FORTITUDE)
end

function mb_Mage_ProposedArcaneIntRequest(requestId, requestType, requestBody)
	mb_AcceptRequest(requestId, requestType, requestBody)
end

function mb_Mage_HandleAcceptedArcaneIntRequest(request)
	local queuedSpell = {}
	queuedSpell.target = request.requestBody
	queuedSpell.name = "Arcane Intellect"
	table.insert(mb_queuedRequests, queuedSpell)
end