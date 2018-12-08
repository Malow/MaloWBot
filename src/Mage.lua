function mb_Mage(msg)
	AssistByName(msg)
	FollowByName(msg, true)
	-- TargetTooLowLevel, skipping for now
	--local arcaneIntTarget = mb_GetFriendlyMissingBuff(BUFF_ARCANE_INTELLECT)
	--if arcaneIntTarget ~= nil then
	--	TargetUnit(arcaneIntTarget)
	--	CastSpellByName("Arcane Intellect")
	--	return
	--end
	CastSpellByName("Fire Blast")
	CastSpellByName("Fireball")
end