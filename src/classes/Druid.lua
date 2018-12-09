function mb_Druid(msg)
	if mb_DoBasicCasterLogic() then
		return
	end

	AssistByName(msg)
	FollowByName(msg, true)
	CastSpellByName("Moonfire")
end

function mb_Druid_OnLoad()
	table.insert(mb_desiredBuffs, BUFF_ARCANE_INTELLECT)
	table.insert(mb_desiredBuffs, BUFF_POWER_WORD_FORTITUDE)
end