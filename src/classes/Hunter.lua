function mb_Hunter(commander)
	if mb_DoBasicCasterLogic() then
		return
	end

	AssistByName(commander)
	CastSpellByName("Arcane Shot")
end

function mb_Hunter_OnLoad()
	mb_AddDesiredBuff(BUFF_MARK_OF_THE_WILD)
	mb_AddDesiredBuff(BUFF_ARCANE_INTELLECT)
	mb_AddDesiredBuff(BUFF_POWER_WORD_FORTITUDE)
	mb_AddDesiredBuff(BUFF_BLESSING_OF_WISDOM)
	mb_AddDesiredBuff(BUFF_BLESSING_OF_KINGS)
	mb_AddDesiredBuff(BUFF_BLESSING_OF_LIGHT)
	mb_AddDesiredBuff(BUFF_BLESSING_OF_SALVATION)
	mb_AddDesiredBuff(BUFF_DIVINE_SPIRIT)
end