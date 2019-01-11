function mb_Hunter(commander)
	if mb_DoBasicCasterLogicThrottled() then
		return
	end
    if mb_IsCasting() or mb_IsUsingAbility("Aimed Shot") then
        return
    end

	if mb_Hunter_IsEmptyOnAmmo() then
		return
	end

	if mb_IsClassLeader() and mb_Hunter_TargetNeedsTranquilizing() then
		if mb_Hunter_DoOrRequestTranquilizingShot() then
			return
		end
	end

	local request = mb_GetQueuedRequest(true)
	if request ~= nil then
		if request.type == REQUEST_TRANQUILIZING_SHOT.type then
            if request.attempts > 90 then
                mb_RequestCompleted(request)
                max_SayRaid("Timed out Tranquilize request from " .. request.from)
                return
            end
			if mb_IsOnGCD() then
				return
			end
            max_AssistByPlayerName(request.from)
			CastSpellByName("Tranquilizing Shot")
			max_SayRaid("Tranquilizing " .. tostring(UnitName("target")))
			mb_RequestCompleted(request)
			return
		end
	end

	if not mb_Hunter_HasAspect() then
		CastSpellByName("Aspect of the Hawk")
		return
	end

	if not max_HasBuff("player", BUFF_TEXTURE_TRUESHOT_AURA) then
		CastSpellByName("Trueshot Aura")
	end

	max_AssistByPlayerName(commander)
	if not max_HasValidOffensiveTarget() then
		return
	end

	if CheckInteractDistance("target", 3) then
		if not mb_isAutoAttacking then
			CastSpellByName("Attack")
		end
		return
	else
		if mb_Hunter_HasFullImprovedHuntersMark() then
			if not max_HasDebuff("target", DEBUFF_TEXTURE_HUNTERS_MARK) then
				CastSpellByName("Hunter's Mark")
				return
			end
		end
		if not mb_isAutoShooting then
			CastSpellByName("Auto Shot")
			return
		end
	end

	if mb_isAutoShooting and not max_IsSpellNameOnCooldown("Rapid Fire") then
		CastSpellByName("Rapid Fire")
		return
	end

	if mb_GetTime() < mb_CombatLogModule_SwingTimer_GetLastAutoShotTime() + 0.3 and not max_IsSpellNameOnCooldown("Aimed Shot") then
		CastSpellByName("Aimed Shot")
		return
	end

	if not max_IsSpellNameOnCooldown("Multi-Shot") and max_GetTimeUntilSpellIsReady("Aimed Shot") > 1.5 then
		CastSpellByName("Multi-Shot")
		return
	end
end

mb_hunterHasWarnedForNoAmmo = false
function mb_Hunter_IsEmptyOnAmmo()
	local ammoSlot = GetInventorySlotInfo("AmmoSlot")
	local ammoCount = GetInventoryItemCount("player", ammoSlot)
	if ((ammoCount == 1) and (not GetInventoryItemTexture("player", ammoSlot))) then
		if not mb_hunterHasWarnedForNoAmmo then
			mb_hunterHasWarnedForNoAmmo = true
			max_SayRaid("I'm completely out of ammo.")
		end
		return true
	end
	return false
end

function mb_Hunter_HasAspect()
	if max_HasBuff("player", BUFF_TEXTURE_ASPECT_OF_THE_HAWK) then
		return true
	end
	if max_HasBuff("player", BUFF_TEXTURE_ASPECT_OF_THE_PACK) then
		return true
	end
	return false
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
    mb_AddDesiredBuff(BUFF_SHADOW_PROTECTION)
	mb_AddGCDCheckSpell("Serpent Sting")
	if max_HasSpell("Tranquilizing Shot") then
		mb_RegisterRangeCheckSpell("Tranquilizing Shot")
		mb_RegisterForRequest(REQUEST_TRANQUILIZING_SHOT.type, mb_Hunter_HandleTranquilizingShotRequest)
	end

	local itemSubType = max_GetItemSubTypeForSlot("RangedSlot")
	if itemSubType == "Bows" or itemSubType == "Crossbows" then
		mb_AddReagentWatch("Jagged Arrow", 2000)
	elseif itemSubType == "Guns" then
		mb_AddReagentWatch("Thorium Shells", 2000)
	end

	mb_Hunter_AddDesiredTalents()
	mb_CombatLogModule_SwingTimer_EnableAutoShot()
	mb_RegisterRangeCheckSpell("Multi-Shot")
	if mb_Hunter_HasAimedShot() then
		mb_RegisterRangeCheckSpell("Aimed Shot") -- Need Aimed Shot on the bars to be able to check if we're "casting" it
	end
	mb_GoToMaxRangeModule_RegisterMaxRangeSpell("Multi-Shot")
    mb_CombatLogModule_EnemyGainsWatch_Enable()
end

function mb_Hunter_HandleTranquilizingShotRequest(request)
	if request.from == UnitName("player") then
		return
	end
    max_AssistByPlayerName(request.from)
	if mb_Hunter_CanDoTranquilizingShot() then
		mb_AcceptRequest(request)
	end
end

function mb_Hunter_DoOrRequestTranquilizingShot()
	if mb_Hunter_CanDoTranquilizingShot() then
		CastSpellByName("Tranquilizing Shot")
		max_SayRaid("Tranquilizing " .. tostring(UnitName("target")))
		return true
	end
	mb_MakeThrottledRequest(REQUEST_TRANQUILIZING_SHOT, "tranqItYoBeastBeCrazy", REQUEST_PRIORITY.COMMAND)
	return false
end

function mb_Hunter_CanDoTranquilizingShot()
	if not max_HasSpell("Tranquilizing Shot") then
		return false
	end
	if UnitIsDead("player") then
		return false
	end
	if max_IsSpellNameOnCooldown("Tranquilizing Shot") then
		return false
	end
    if mb_IsFacingWrongWay() then
        return false
    end
	if mb_IsSpellInRange("Tranquilizing Shot") and UnitMana("player") > 500 then
		return true
	end
	return false
end

function mb_Hunter_TargetNeedsTranquilizing()
    if mb_CombatLogModule_EnemyGainsWatch_HasGained(UnitName("target"), "Frenzy") then
        max_SayRaid("Automatic Frenzy detection on target, Tranquilizing.")
        return true
    end
	for _, buffTexture in pairs(BUFF_TEXTURES_TRANQUILIZING_SHOT) do
		if max_HasBuff("target", buffTexture) then
			return true
		end
	end
	return false
end

function mb_Hunter_IsReady()
	if mb_CancelExpiringBuffWithTexture(BUFF_TEXTURE_TRUESHOT_AURA, 8) then
		return false
	end
	return true
end

function mb_Hunter_HasFullImprovedHuntersMark()
	local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(2, 3)
	return currentRank == 5
end

function mb_Hunter_HasAimedShot()
	local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(2, 5)
	return currentRank == 1
end

function mb_Hunter_AddDesiredTalents()
	if mb_GetMySpecName() == "MM" then
		mb_AddDesiredTalent(1, 1, 2) -- Improved Aspect of the Hawk
		mb_AddDesiredTalent(2, 2, 5) -- Efficiency
		mb_AddDesiredTalent(2, 3, 2) -- Improved Hunter's Mark
		mb_AddDesiredTalent(2, 4, 5) -- Lethal Shots
		mb_AddDesiredTalent(2, 5, 1) -- Aimed Shot
		mb_AddDesiredTalent(2, 7, 3) -- Hawk Eye
		mb_AddDesiredTalent(2, 9, 5) -- Mortal Shots
		mb_AddDesiredTalent(2, 10, 1) -- Scatter Shot
		mb_AddDesiredTalent(2, 11, 3) -- Barrage
		mb_AddDesiredTalent(2, 13, 5) -- Ranged Weapon Specialization
		mb_AddDesiredTalent(2, 14, 1) -- Trueshot
		mb_AddDesiredTalent(3, 1, 3) -- Monster Slaying
		mb_AddDesiredTalent(3, 2, 3) -- Humanoid Slaying
		mb_AddDesiredTalent(3, 4, 2) -- Entrapment
		mb_AddDesiredTalent(3, 5, 2) -- Savage Strikes
		mb_AddDesiredTalent(3, 7, 2) -- Clever Traps
		mb_AddDesiredTalent(3, 8, 2) -- Survivalist
		mb_AddDesiredTalent(3, 9, 1) -- Deterrence
		mb_AddDesiredTalent(3, 11, 3) -- Surefooted
	elseif mb_GetMySpecName() == "MMFullHM" then
		mb_AddDesiredTalent(1, 1, 2) -- Improved Aspect of the Hawk
		mb_AddDesiredTalent(2, 2, 5) -- Efficiency
		mb_AddDesiredTalent(2, 3, 5) -- Improved Hunter's Mark
		mb_AddDesiredTalent(2, 4, 5) -- Lethal Shots
		mb_AddDesiredTalent(2, 5, 1) -- Aimed Shot
		mb_AddDesiredTalent(2, 7, 1) -- Hawk Eye
		mb_AddDesiredTalent(2, 9, 5) -- Mortal Shots
		mb_AddDesiredTalent(2, 11, 3) -- Barrage
		mb_AddDesiredTalent(2, 13, 5) -- Ranged Weapon Specialization
		mb_AddDesiredTalent(2, 14, 1) -- Trueshot
		mb_AddDesiredTalent(3, 1, 3) -- Monster Slaying
		mb_AddDesiredTalent(3, 2, 3) -- Humanoid Slaying
		mb_AddDesiredTalent(3, 4, 2) -- Entrapment
		mb_AddDesiredTalent(3, 5, 2) -- Savage Strikes
		mb_AddDesiredTalent(3, 7, 2) -- Clever Traps
		mb_AddDesiredTalent(3, 8, 2) -- Survivalist
		mb_AddDesiredTalent(3, 9, 1) -- Deterrence
		mb_AddDesiredTalent(3, 11, 3) -- Surefooted
    elseif mb_GetMySpecName() == "Kite" then
        mb_AddDesiredTalent(1, 1, 5) -- Improved Aspect of the Hawk
        mb_AddDesiredTalent(1, 2, 2) -- Endurance Training
        mb_AddDesiredTalent(1, 5, 3) -- Thick Hide
        mb_AddDesiredTalent(1, 7, 2) -- Pathfinding
        mb_AddDesiredTalent(2, 2, 5) -- Efficiency
        mb_AddDesiredTalent(2, 4, 5) -- Lethal Shots
        mb_AddDesiredTalent(2, 6, 2) -- Improved Arcane Shot
        mb_AddDesiredTalent(2, 7, 3) -- Hawk Eye
        mb_AddDesiredTalent(2, 8, 4) -- Improved Serpent Sting
        mb_AddDesiredTalent(3, 2, 3) -- Humanoid Slaying
        mb_AddDesiredTalent(3, 3, 5) -- Deflection
        mb_AddDesiredTalent(3, 5, 2) -- Savage Strikes
        mb_AddDesiredTalent(3, 8, 4) -- Survivalist
        mb_AddDesiredTalent(3, 9, 1) -- Deterrence
        mb_AddDesiredTalent(3, 11, 3) -- Surefooted
        mb_AddDesiredTalent(3, 12, 2) -- Improved Feign Death
	end
end