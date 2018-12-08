function mb_Paladin(msg)
	FollowByName(msg, true)
	local healSpell = "Holy Light" -- "Flash of Light"
	local healTargetUnit, missingHealth = mb_GetMostDamagedFriendly(healSpell)
	if missingHealth > 50 then
		TargetUnit(healTargetUnit)
		CastSpellByName(healSpell)
	end
end