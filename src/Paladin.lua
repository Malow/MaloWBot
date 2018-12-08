function mb_Paladin(msg)
	FollowByName(msg, true)
	local healSpell = "Flash of Light"
	local healTargetUnit, missingHealth = mb_GetMostDamagedFriendly(healSpell)
	if missingHealth > 50 then
		TargetUnit(healTargetUnit)
		CastSpellByName(healSpell)
	end
end

function mb_Paladin_OnLoad()
	table.insert(mb_desiredBuffs, BUFF_ARCANE_INTELLECT)
	table.insert(mb_desiredBuffs, BUFF_POWER_WORD_FORTITUDE)
end