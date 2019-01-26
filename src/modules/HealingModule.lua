
mb_HealingModule_incomingHeals = {}
function mb_HealingModule_Enable()
    mb_RegisterForRequest("healerModuleData", mb_HealingModule_HandleDataRequest)
    mb_RegisterForRequest("tankingBroadcast", mb_HealingModule_HandleTankBroadcastRequest)
end

mb_HealingModule_registeredHoTs = {}
function mb_HealingModule_RegisterHoT(spellName, texture, manaCost)
    mb_HealingModule_registeredHoTs[spellName] = {}
    mb_HealingModule_registeredHoTs[spellName].manaCost = manaCost
    mb_HealingModule_registeredHoTs[spellName].texture = texture
    mb_RegisterForRequest("HoT", mb_HealingModule_HandleHoTRequest)
end

function mb_HealingModule_HandleHoTRequest(request)
    if UnitIsDead("player") then
        return
    end
    local unit = max_GetUnitForPlayerName(request.body)
    for k, v in pairs(mb_HealingModule_registeredHoTs) do
        if not max_HasBuff(unit, v.texture) then
            if mb_IsUnitValidFriendlyTarget(unit, k) and UnitMana("player") > mb_HealingModule_registeredHoTs[k].manaCost then
                mb_AcceptRequest(request)
                return
            end
        end
    end
end

function mb_HealingModule_CompleteHoTRequest(request)
    mb_RequestCompleted(request)
    local unit = max_GetUnitForPlayerName(request.body)
    for k, v in pairs(mb_HealingModule_registeredHoTs) do
        if not max_HasBuff(unit, v.texture) then
            if mb_IsUnitValidFriendlyTarget(unit, k) and UnitMana("player") > mb_HealingModule_registeredHoTs[k].manaCost then
                max_CastSpellOnRaidMember(k, unit)
                return
            end
        end
    end
end

function mb_HealingModule_HandleDataRequest(request)
    if request.from ~= UnitName("player") then
        local parts = max_SplitString(request.body, "/")
        local incomingHeal = {}
        incomingHeal.healAmount = tonumber(parts[2])
        incomingHeal.finishTime = mb_GetTime() + tonumber(parts[3])
        incomingHeal.from = request.from
        local playerNames = max_SplitString(parts[1], "#")
        for k, playerName in pairs(playerNames) do
            if mb_HealingModule_incomingHeals[playerName] == nil then
                mb_HealingModule_incomingHeals[playerName] = {}
            end
            table.insert(mb_HealingModule_incomingHeals[playerName], incomingHeal)
        end
    end
end

mb_HealingModule_tankingTanks = {}
function mb_HealingModule_HandleTankBroadcastRequest(request)
    local dtps = tonumber(request.body)
    if dtps == 0 then
        mb_HealingModule_tankingTanks[request.from] = nil
        return
    end
    if mb_HealingModule_tankingTanks[request.from] == nil then
        mb_HealingModule_tankingTanks[request.from] = {}
    end
    mb_HealingModule_tankingTanks[request.from].dtps = dtps
    mb_HealingModule_tankingTanks[request.from].lastReceived = mb_GetTime()
end

function mb_HealingModule_GetValidTankUnitWithHighestFutureMissingHealth(spellName, unitFilter)
    mb_HealingModule_ExpireTankingTanks()
    local lowestTank = nil
    local futureMissingHealth = nil
    for tankName, tankData in pairs(mb_HealingModule_tankingTanks) do
        local unit = max_GetUnitForPlayerName(tankName)
        if unitFilter ~= nil and not mb_CheckFilter(unit, unitFilter) then
            break
        end
        if mb_IsUnitValidFriendlyTarget(unit, spellName) then
            local missingHealth = mb_HealingModule_GetFutureMissingHealth(unit, 300)
            missingHealth = missingHealth + (tankData.dtps * 3)
            if lowestTank == nil or futureMissingHealth < missingHealth then
                lowestTank = unit
                futureMissingHealth = missingHealth
            end
        end
    end
    return lowestTank, futureMissingHealth
end

function mb_HealingModule_ExpireTankingTanks()
    local toBeExpired = {}
    for k, v in pairs(mb_HealingModule_tankingTanks) do
        if v.lastReceived + 7 < mb_GetTime() then
            table.insert(toBeExpired, k)
        end
    end
    for _, v in pairs(toBeExpired) do
        mb_HealingModule_tankingTanks[v] = nil
    end
end

function mb_HealingModule_GetFutureMissingHealth(unit, healOverTimeValue)
    local playerName = UnitName(unit)
    local missingHealth = max_GetMissingHealth(unit)
    if mb_HealingModule_incomingHeals[playerName] == nil then
        return missingHealth
    end
    for i = max_GetTableSize(mb_HealingModule_incomingHeals[playerName]), 1, -1 do
        if mb_HealingModule_incomingHeals[playerName][i].finishTime < mb_GetTime() then
            table.remove(mb_HealingModule_incomingHeals[playerName], i)
        else
            missingHealth = missingHealth - mb_HealingModule_incomingHeals[playerName][i].healAmount
        end
    end
    missingHealth = missingHealth - (mb_GetHoTCount(unit) * healOverTimeValue)
    return missingHealth
end

-- targetPlayerName can be either a string or a table of strings if the spell will hit multiple targets
function mb_HealingModule_SendData(targetPlayerName, healAmount, castLength)
    if max_IsTable(targetPlayerName) then
        local targetPlayers = ""
        for _, playerName in pairs(targetPlayerName) do
            targetPlayers = targetPlayers .. playerName .. "#"
        end
        targetPlayers = string.sub(targetPlayers, 1, string.len(targetPlayers) - 1)
        local healData = targetPlayers .. "/" .. healAmount .. "/" .. castLength
        mb_MakeRequest("healerModuleData", healData, REQUEST_PRIORITY.HEALER_MODULE_DATA)
    else
        local healData = targetPlayerName .. "/" .. healAmount .. "/" .. castLength
        mb_MakeRequest("healerModuleData", healData, REQUEST_PRIORITY.HEALER_MODULE_DATA)
    end
end

function mb_HealingModule_GetRaidHealTarget(spell, unitFilter)
    local healTarget = 0
    local missingHealthOfTarget = mb_HealingModule_GetFutureMissingHealth("player", 800)
    local members = max_GetNumPartyOrRaidMembers()
    for i = 1, members do
        local unit = max_GetUnitFromPartyOrRaidIndex(i)
        if unitFilter ~= nil and not mb_CheckFilter(unit, unitFilter) then
            break
        end
        local missingHealth = mb_HealingModule_GetFutureMissingHealth(unit, 800)
        if missingHealth > missingHealthOfTarget then
            if mb_IsUnitValidFriendlyTarget(unit, spell) then
                missingHealthOfTarget = missingHealth
                healTarget = i
            end
        end
    end
    if healTarget == 0 then
        return "player", missingHealthOfTarget
    else
        return max_GetUnitFromPartyOrRaidIndex(healTarget), missingHealthOfTarget
    end
end

function mb_HealerModule_HandleUseConsumableRequest(request)
    if not UnitAffectingCombat("player") then
        return
    end
    if max_GetManaPercentage("player") < 20 then
        mb_QueueUseConsumable("Major Mana Potion")
    end
end

function mb_HealerModule_ShouldCancelHealToDecoupleMyHealingFromHigherPrioritizedHealers()
    -- TODO for priests and druids to make sure they're all not synced up in their healing as they probably will be with the stop-casting logic
end

function mb_HealerModule_GetIncomingHealAmountFromHigherPrioritizedHealersOnUnit(unit)
    local playerName = UnitName(unit)
    local incomingHeal = 0
    if mb_HealingModule_incomingHeals[playerName] == nil then
        return 0
    end
    for i = max_GetTableSize(mb_HealingModule_incomingHeals[playerName]), 1, -1 do
        if mb_HealingModule_incomingHeals[playerName][i].finishTime < mb_GetTime() then
            table.remove(mb_HealingModule_incomingHeals[playerName], i)
        else
            if mb_HealerModule_HasHealerHigherPriorityThanMe(mb_HealingModule_incomingHeals[playerName][i].from) then
                incomingHeal = incomingHeal + mb_HealingModule_incomingHeals[playerName][i].healAmount
            end
        end
    end
    return incomingHeal
end

function mb_HealerModule_HasHealerHigherPriorityThanMe(healerName)
    local healOrder = mb_HealerModule_GetHealersPriorityThrottled()
    return healOrder[UnitName("player")] > healOrder[healerName]
end

mb_HealerModule_lastGetHealersPriorityTime = 0
mb_HealerModule_healerPriority = nil
function mb_HealerModule_GetHealersPriorityThrottled()
    if mb_HealerModule_healerPriority ~= nil and mb_HealerModule_lastGetHealersPriorityTime + 60 > mb_GetTime() then
        return mb_HealerModule_healerPriority
    end
    mb_HealerModule_lastGetHealersPriorityTime = mb_GetTime()
    mb_HealerModule_healerPriority = {}

    local priests = {}
    local druids = {}
    local paladins = {}
    local members = max_GetNumPartyOrRaidMembers()
    for i = 1, members do
        local unit = max_GetUnitFromPartyOrRaidIndex(i)
        local unitName = UnitName(unit)
        if max_GetClass(unit) == "PRIEST" then
            table.insert(priests, unitName)
        elseif max_GetClass(unit) == "DRUID" then
            table.insert(druids, unitName)
        elseif max_GetClass(unit) == "PALADIN" then
            table.insert(paladins, unitName)
        end
    end
    table.sort(priests)
    table.sort(druids)
    table.sort(paladins)

    local i = 1
    for _, priest in pairs(priests) do
        mb_HealerModule_healerPriority[priest] = i
        i = i + 1
    end
    for _, druid in pairs(druids) do
        mb_HealerModule_healerPriority[druid] = i
        i = i + 1
    end
    for _, paladin in pairs(paladins) do
        mb_HealerModule_healerPriority[paladin] = i
        i = i + 1
    end

    return mb_HealerModule_healerPriority
end