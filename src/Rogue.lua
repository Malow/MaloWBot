function mb_Rogue(msg)
	AssistByName(msg)
	FollowByName(msg, true)
	--mb_Print(GetSpellCooldown("Feint"))
	CastSpellByName("attack")
	--if PlayerHasSpells("Feint") and GetSpellCooldown("Feint") == 0 then
	--	CastSpellByName("Feint")
	--elseif GetSpellCooldown("Feint") > 0 then
	CastSpellByName("Sinister Strike")
end