function mb_Mage(msg)
	if mb_isCasting then
		return
	end

	AssistByName(msg)
	FollowByName(msg, true)

	if mb_Mage_BuffArcaneInt() then
		return
	end

	CastSpellByName("Fire Blast")
	CastSpellByName("Fireball")
end

function mb_Mage_BuffArcaneInt()
	local arcaneIntTarget = mb_GetFriendlyMissingBuff(BUFF_ARCANE_INTELLECT, "Arcane Intellect", UNIT_FILTER_HAS_MANA)
	if arcaneIntTarget ~= nil then
		TargetUnit(arcaneIntTarget)
		CastSpellByName("Arcane Intellect")
		return true
	end
	return false
end