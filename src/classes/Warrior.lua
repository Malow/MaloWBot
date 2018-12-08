function mb_Warrior(msg)
	AssistByName(msg)
	FollowByName(msg, true)
	CastSpellByName("Attack")
	CastSpellByName("Heroic Strike")
end

function mb_Warrior_OnLoad()
	table.insert(mb_desiredBuffs, BUFF_POWER_WORD_FORTITUDE)
end