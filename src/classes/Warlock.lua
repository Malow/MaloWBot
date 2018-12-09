function mb_Warlock(msg)
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

	-- TODO: Use MobHealth addon and get the unit health from that instead of : UnitHealth("target") < 101 and
	if max_GetFreeBagSlots() > 5 then
		CastSpellByName("Drain Soul")
	else
		CastSpellByName("Shadow Bolt")
	end
end

function mb_Warlock_OnLoad()
	mb_RegisterForProposedRequest("summon", mb_Warlock_HandleProposedSummonRequest)
	mb_RegisterForAcceptedRequest("summon", mb_Warlock_HandleAcceptedSummonRequest)
	table.insert(mb_desiredBuffs, BUFF_ARCANE_INTELLECT)
	table.insert(mb_desiredBuffs, BUFF_POWER_WORD_FORTITUDE)
end

function mb_Warlock_HandleProposedSummonRequest(requestId, requestType, requestBody)
	local soulShardCount = mb_GetItemCount("Soul Shard")
	if soulShardCount > 0 and not mb_isCasting then
		mb_AcceptRequest(requestId, requestType, requestBody)
	end
end

function mb_Warlock_HandleAcceptedSummonRequest(request)
	SendChatMessage("I'm summoning " .. request.requestBody, "RAID", "Common")
	local queuedSpell = {}
	queuedSpell.target = request.requestBody
	queuedSpell.name = "Ritual of Summoning"
	table.insert(mb_queuedRequests, queuedSpell)
end