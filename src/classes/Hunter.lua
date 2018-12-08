function mb_Hunter(msg)
	AssistByName(msg)
	FollowByName(msg, true)
	CastSpellByName("Arcane Shot")
end

function mb_Hunter_OnLoad()
	table.insert(mb_desiredBuffs, BUFF_ARCANE_INTELLECT)
	table.insert(mb_desiredBuffs, BUFF_POWER_WORD_FORTITUDE)
end