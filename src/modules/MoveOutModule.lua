MB_MOVE_OUT_MODULE_DEBUFFS = {
    "Example"
}

mb_MoveOutModule_enabled = true

function mb_MoveOutModule_Load()
    local spellNames = {}
    table.insert(spellNames, "Flamestrike")
    table.insert(spellNames, "Rain of Fire")
    table.insert(spellNames, "Blizzard")
    mb_CombatLogModule_PeriodicSelfDamageWatch_Enable(spellNames)
    local debuffNames = {}
    table.insert(debuffNames, "Living Bomb")
    mb_CombatLogModule_DebuffWatch_Enable(debuffNames)
end

function mb_MoveOutModule_Enable()
    mb_MoveOutModule_enabled = true
end

function mb_MoveOutModule_Disable()
    mb_MoveOutModule_enabled = false
end

mb_MoveOutModule_startedFollowing = nil
mb_MoveOutModule_warnedNoTarget = nil
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
        if mb_MoveOutModule_startedFollowing ~= nil and mb_MoveOutModule_startedFollowing + 3 > mb_GetTime() then
            return true
        end
        local followTarget = mb_MoveOutModule_FindFollowTarget()
        if followTarget ~= nil then
            FollowUnit(followTarget)
            max_SayRaid("Started following " .. UnitName(followTarget) .. " to move out of shit on the ground.")
            mb_MoveOutModule_startedFollowing = mb_GetTime()
            return true
        elseif mb_MoveOutModule_warnedNoTarget == nil or mb_MoveOutModule_warnedNoTarget + 3 < mb_GetTime() then
            max_SayRaid("Couldn't find any target to start following to move out of shit on the ground.")
            mb_MoveOutModule_warnedNoTarget = mb_GetTime()
        end
    end
    return false
end

function mb_MoveOutModule_IsStandingInShit()
    if mb_MoveOutModule_HasBadDebuff() then
        return true
    end
    if mb_CombatLogModule_PeriodicSelfDamageWatch_HasTakenWatchedDamageIn(2) then
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
    return false
end

function mb_MoveOutModule_FindFollowTarget()
    local members = max_GetNumPartyOrRaidMembers()
    for i = 1, members do
        local unit = max_GetUnitFromPartyOrRaidIndex(i)
        if max_GetClass(unit) ~= "ROGUE" and max_GetClass(unit) ~= "WARRIOR" then
            if UnitExists(unit) and UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) and not max_HasBuff(unit, BUFF_TEXTURE_SPIRIT_OF_REDEMPTION) then
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
    local livingBombTime = mb_CombatLogModule_DebuffWatch_GetTimeForSpellName("Living Bomb")
    if livingBombTime ~= nil then
        mb_shouldFuckOffAt = mb_GetTime()
        mb_shouldFollow = false
        max_SayRaid("I'm fucking off automatically!")
        mb_CombatLogModule_DebuffWatch_ResetForSpellName("Living Bomb")
        return true
    end
    return false
end