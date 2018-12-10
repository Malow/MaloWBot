-- TODO:
---     Tank VS DPS distinction for Sanctuary/Salvation
---
function mb_Warrior(commander)
	AssistByName(commander)
	CastSpellByName("Attack")
	CastSpellByName("Heroic Strike")
end

function mb_Warrior_OnLoad()
	mb_AddDesiredBuff(BUFF_POWER_WORD_FORTITUDE)
	mb_AddDesiredBuff(BUFF_BLESSING_OF_MIGHT)
	mb_AddDesiredBuff(BUFF_BLESSING_OF_KINGS)
	mb_AddDesiredBuff(BUFF_BLESSING_OF_LIGHT)
	mb_AddDesiredBuff(BUFF_BLESSING_OF_SANCTUARY)
end