function mb_Warlock(msg)
	AssistByName(msg)
	FollowByName(msg, true)

	if max_GetTableSize(mb_queuedSpellCasts) > 0 then
		local queuedSpell = table.remove(mb_queuedSpellCasts, 1)
		TargetByName(queuedSpell.target, true)
		CastSpellByName(queuedSpell.name)
	end
	local soulShardCount = mb_GetItemCountWithName("Soul Shard")
	-- TODO: Use MobHealth addon and get the unit health from that instead of : UnitHealth("target") < 101 and
	if soulShardCount < 12 then
		if not mb_isCasting then
			CastSpellByName("Drain Soul")
		end
	else
		CastSpellByName("Shadow Bolt")
	end
end

function mb_Warlock_ProposedRequest(requestId, requestType, requestBody)
	local soulShardCount = mb_GetItemCountWithName("Soul Shard")
	-- TODO: Use MobHealth addon and get the unit health from that instead of : UnitHealth("target") < 101 and
	if soulShardCount > 0 and not mb_isCasting then
		mb_AcceptRequest(requestId, requestType, requestBody)
	end
end

function mb_Warlock_HandleAcceptedRequest(request)
	SendChatMessage("I'm summoning " .. request.requestBody, "RAID", "Common")
	local queuedSpell = {}
	queuedSpell.target = request.requestBody
	queuedSpell.name = "Ritual of Summoning"
	table.insert(mb_queuedSpellCasts, queuedSpell)
end