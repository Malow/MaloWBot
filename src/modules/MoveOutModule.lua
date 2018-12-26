MB_MOVE_OUT_MODULE_DEBUFFS = {
    "Example"
}

function mb_MoveOutModule_Load()
    local spellNames = {}
    table.insert(spellNames, "Flamestrike")
    mb_CombatLogModule_PeriodicSelfDamageWatch_Enable(spellNames)
end

mb_MoveOutModule_startedFollowing = nil
mb_MoveOutModule_warnedNoTarget = nil
function mb_MoveOutModule_Update()
    if mb_shouldFollow then
        return false
    end
    if mb_MoveOutModule_IsStandingInShit() then
        if mb_MoveOutModule_startedFollowing ~= nil and mb_MoveOutModule_startedFollowing + 3 > GetTime() then
            return true
        end
        local followTarget = mb_MoveOutModule_FindFollowTarget()
        if followTarget ~= nil then
            FollowUnit(followTarget)
            max_SayRaid("Started following " .. UnitName(followTarget) .. " to move out of shit on the ground.")
            mb_MoveOutModule_startedFollowing = GetTime()
            return true
        elseif mb_MoveOutModule_warnedNoTarget == nil or mb_MoveOutModule_warnedNoTarget + 3 < GetTime() then
            max_SayRaid("Couldn't find any target to start following to move out of shit on the ground.")
            mb_MoveOutModule_warnedNoTarget = GetTime()
        end
    end
    return false
end

function mb_MoveOutModule_IsStandingInShit()
    if mb_MoveOutModule_HasBadDebuff() then
        return true
    end
    return false
end

function mb_MoveOutModule_HasBadDebuff()
    for _, v in pairs(MB_MOVE_OUT_MODULE_DEBUFFS) do
        if max_HasDebuff("player", v) then
            return true
        end
    end
    if mb_CombatLogModule_PeriodicSelfDamageWatch_HasTakenWatchedDamageIn(2) then
        return true
    end
    return false
end

function mb_MoveOutModule_FindFollowTarget()
    local members = max_GetNumPartyOrRaidMembers()
    for i = 1, members do
        local unit = max_GetUnitFromPartyOrRaidIndex(i)
        if not CheckInteractDistance(unit, 2) and CheckInteractDistance(unit, 4) then
            return unit
        end
    end
    return nil
end