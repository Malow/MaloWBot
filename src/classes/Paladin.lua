function mb_Paladin(msg)
	if mb_isCasting then
		return
	end

	if not UnitAffectingCombat("player") then
		if mb_GetWaterCount() < 10 then
			mb_MakeThrottledRequest(REQUEST_WATER, UnitName("player"))
		end
	end

	if mb_IsDrinking() then
		if max_GetManaPercentage("player") < 95 then
			return
		else
			SitOrStand()
		end
	end

	if max_GetManaPercentage("player") < 50 then
		if mb_DrinkIfPossible() then
			return
		end
	end

	FollowByName(msg, true)
	local healSpell = "Flash of Light"
	local healTargetUnit, missingHealth = mb_GetMostDamagedFriendly(healSpell)
	if missingHealth > 50 then
		TargetUnit(healTargetUnit)
		CastSpellByName(healSpell)
		return
	end
end

function mb_Paladin_OnLoad()
	table.insert(mb_desiredBuffs, BUFF_ARCANE_INTELLECT)
	table.insert(mb_desiredBuffs, BUFF_POWER_WORD_FORTITUDE)
end