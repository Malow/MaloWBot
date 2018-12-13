-- TODO:
---     Tank VS DPS VS Healer distinction for Sanctuary/Salvation and Might
---
function mb_Druid(commander)
	if mb_DoBasicCasterLogic() then
		return
	end

	if max_GetTableSize(mb_queuedRequests) > 0 then
		local request = mb_queuedRequests[1]
		if request.requestType == BUFF_MARK_OF_THE_WILD.requestType then
			-- if gcd is ready
			TargetByName(request.requestBody, true)
			if mb_ShouldBuffGroupWide(request.requestBody, BUFF_MARK_OF_THE_WILD) then
				CastSpellByName("Gift of the Wild")
			else
				CastSpellByName("Mark of the Wild")
			end
			table.remove(mb_queuedRequests, 1)
			return
		else
			max_SayRaid("Serious error, received request for " .. request.requestType)
		end
	end

	AssistByName(commander)
	CastSpellByName("Moonfire")
end

function mb_Druid_OnLoad()
	mb_RegisterForRequest(BUFF_MARK_OF_THE_WILD.requestType, mb_Druid_HandleMarkOfTheWildRequest)
	mb_AddDesiredBuff(BUFF_MARK_OF_THE_WILD)
	mb_AddDesiredBuff(BUFF_ARCANE_INTELLECT)
	mb_AddDesiredBuff(BUFF_POWER_WORD_FORTITUDE)
	mb_AddDesiredBuff(BUFF_BLESSING_OF_WISDOM)
	mb_AddDesiredBuff(BUFF_BLESSING_OF_KINGS)
	mb_AddDesiredBuff(BUFF_BLESSING_OF_LIGHT)
	mb_AddDesiredBuff(BUFF_BLESSING_OF_SALVATION)
	mb_AddDesiredBuff(BUFF_DIVINE_SPIRIT)
	mb_Druid_AddDesiredTalents()
	mb_AddReagentWatch("Wild Thornroot", 20)
end

function mb_Druid_HandleMarkOfTheWildRequest(requestId, requestType, requestBody)
	if not mb_Druid_HasImprovedMOTW() then
		return
	end
	if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(requestBody), "Mark of the Wild") then
		mb_AcceptRequest(requestId, requestType, requestBody)
	end
end

function mb_Druid_HasImprovedMOTW()
	local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(3, 1)
	return currentRank == 5
end

function mb_Druid_AddDesiredTalents()
	mb_AddDesiredTalent(3, 1, 5) -- Improved Mark of the Wild
	mb_AddDesiredTalent(3, 2, 5) -- Furor
	mb_AddDesiredTalent(3, 3, 5) -- Improved Healing Touch
	mb_AddDesiredTalent(3, 4, 5) -- Nature's Focus
	mb_AddDesiredTalent(3, 6, 3) -- Reflection
	mb_AddDesiredTalent(3, 7, 1) -- Insect Swarm
	mb_AddDesiredTalent(3, 8, 5) -- Subtlety
	mb_AddDesiredTalent(3, 9, 5) -- Tranquil Spirit
	mb_AddDesiredTalent(3, 10, 3) -- Improved Rejuvenation
	mb_AddDesiredTalent(3, 11, 1) -- Nature's Swiftness
	mb_AddDesiredTalent(3, 12, 5) -- Gift of Nature
	mb_AddDesiredTalent(3, 13, 2) -- Improved Tranquility
	mb_AddDesiredTalent(3, 14, 5) -- Improved Regrowth
	mb_AddDesiredTalent(3, 15, 1) -- Swiftmend
end