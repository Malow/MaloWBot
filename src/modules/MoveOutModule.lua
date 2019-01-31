
mb_MoveOutModule_autoFollowMoveOutOnDamageSpells = {}
mb_MoveOutModule_automaticFuckOffDebuffSpells = {}
mb_MoveOutModule_enabled = false

function mb_MoveOutModule_Disable()
    mb_MoveOutModule_enabled = false
end

function mb_MoveOutModule_RegisterAutomaticFuckOffDebuffSpell(spellName)
    mb_MoveOutModule_enabled = true
    table.insert(mb_MoveOutModule_automaticFuckOffDebuffSpells, spellName)
    mb_CombatLogModule_DebuffWatch_RegisterSpell(spellName)
end

function mb_MoveOutModule_RegisterAutoFollowMoveOutOnDamageSpell(spellName)
    mb_MoveOutModule_enabled = true
    table.insert(mb_MoveOutModule_autoFollowMoveOutOnDamageSpells, spellName)
    mb_CombatLogModule_PeriodicSelfDamageWatch_RegisterSpell(spellName)
end

mb_MoveOutModule_startedFollowing = 0
mb_MoveOutModule_warnedNoTarget = 0
function mb_MoveOutModule_Update()
    if not mb_MoveOutModule_enabled then
        return false
    end
    if mb_MoveOutModule_HandleAutomaticFuckOff() then
        return true
    end
    if mb_shouldFollow then
        return false
    end
    if mb_MoveOutModule_IsStandingInShit() then
        if mb_MoveOutModule_startedFollowing + 3 > mb_GetTime() then
            return true
        end
        local followTarget = mb_MoveOutModule_FindFollowTarget()
        if followTarget ~= nil then
            FollowUnit(followTarget)
            max_SayRaid("Started following " .. UnitName(followTarget) .. " to move out of shit on the ground.")
            mb_MoveOutModule_startedFollowing = mb_GetTime()
            return true
        elseif mb_MoveOutModule_warnedNoTarget + 3 < mb_GetTime() then
            max_SayRaid("Couldn't find any target to start following to move out of shit on the ground.")
            mb_MoveOutModule_warnedNoTarget = mb_GetTime()
        end
    end
    return false
end

function mb_MoveOutModule_IsStandingInShit()
    for k, v in pairs(mb_MoveOutModule_autoFollowMoveOutOnDamageSpells) do
        if mb_CombatLogModule_PeriodicSelfDamageWatch_HasTakenDamageFrom(v) then
            return true
        end
    end
    return false
end

function mb_MoveOutModule_FindFollowTarget()
    local members = max_GetNumPartyOrRaidMembers()
    for i = 1, members do
        local unit = max_GetUnitFromPartyOrRaidIndex(i)
        if max_GetClass(unit) ~= "ROGUE" and max_GetClass(unit) ~= "WARRIOR" then
            if UnitExists(unit) and UnitIsVisible(unit) and not mb_IsDead(unit) and not max_HasBuff(unit, BUFF_TEXTURE_SPIRIT_OF_REDEMPTION) then
                if not CheckInteractDistance(unit, 2) and CheckInteractDistance(unit, 4) then
                    return unit
                end
            end
        end
    end
    return nil
end

function mb_MoveOutModule_HandleAutomaticFuckOff()
    if mb_GetMyCommanderName() == UnitName("player") then
        return false
    end
    for k, v in pairs(mb_MoveOutModule_automaticFuckOffDebuffSpells) do
        if mb_CombatLogModule_DebuffWatch_HasBeenAfflictedBy(v) then
            mb_shouldFuckOffAt = mb_GetTime()
            mb_shouldFollow = false
            max_SayRaid("I'm fucking off automatically!")
            return true
        end
    end
    return false
end