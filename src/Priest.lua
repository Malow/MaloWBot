function mb_Priest(msg)
	AssistByName(msg)
	FollowByName(msg, true)
	if mb_Priest_PWS() then
		return
	end
	CastSpellByName("Smite")
end

function mb_Priest_PWS()
	local spell = "Power Word: Shield"
	local healTargetUnit, healthOfTarget = mb_GetLowestHealthFriendly(spell)
	if max_GetHealthPercentage(healTargetUnit) < 50 then
		TargetUnit(healTargetUnit)
		CastSpellByName(spell)
		return true
	end
	return false
end