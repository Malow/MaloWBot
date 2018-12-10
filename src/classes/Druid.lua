function mb_Druid(commander)
	if mb_DoBasicCasterLogic() then
		return
	end

	AssistByName(commander)
	CastSpellByName("Moonfire")
end

function mb_Druid_OnLoad()
	table.insert(mb_desiredBuffs, BUFF_ARCANE_INTELLECT)
	table.insert(mb_desiredBuffs, BUFF_POWER_WORD_FORTITUDE)
end