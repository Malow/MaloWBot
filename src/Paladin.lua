function mb_Paladin(msg)
	FollowByName(msg, true)
	local healTargetUnit, missingHealth = mb_GetMostDamagedFriendly("Flash of Light")
	if healTargetUnit ~= nil and missingHealth > 10 then 
		TargetUnit(healTargetUnit)
		CastSpellByName("Flash of Light")
	end
end