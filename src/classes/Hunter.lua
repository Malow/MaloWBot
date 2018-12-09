function mb_Hunter(msg)
	if mb_DoBasicCasterLogic() then
		return
	end

	AssistByName(msg)
	FollowByName(msg, true)
	CastSpellByName("Arcane Shot")
end

function mb_Hunter_OnLoad()
	table.insert(mb_desiredBuffs, BUFF_ARCANE_INTELLECT)
	table.insert(mb_desiredBuffs, BUFF_POWER_WORD_FORTITUDE)
end