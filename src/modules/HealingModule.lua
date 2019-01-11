
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
            if mb_IsUnitValidTarget(unit, k) and UnitMana("player") > mb_HealingModule_registeredHoTs[k].manaCost then
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
            if mb_IsUnitValidTarget(unit, k) and UnitMana("player") > mb_HealingModule_registeredHoTs[k].manaCost then
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
        incomingHeal.finishTime = tonumber(parts[3])
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
    if mb_HealingModule_tankingTanks[request.from] == nil then
        mb_HealingModule_tankingTanks[request.from] = {}
    end
    mb_HealingModule_tankingTanks[request.from].dtps = tonumber(request.body)
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
        if mb_IsUnitValidTarget(unit, spellName) then
            local missingHealth = mb_HealingModule_GetFutureMissingHealth(unit, 300)
            missingHealth = missingHealth + (tankData.dtps * 3)
            if lowestTank == nil or futureMissingHealth < missingHealth then
                lowestTank = unit
                futureMissingHealth = missingHealth
            end
        end
    end
    return lowestTank
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
    local now = mb_GetTime()
    for i = max_GetTableSize(mb_HealingModule_incomingHeals[playerName]), 1, -1 do
        if mb_HealingModule_incomingHeals[playerName][i].finishTime < now then
            table.remove(mb_HealingModule_incomingHeals[playerName], i)
        else
            missingHealth = missingHealth - mb_HealingModule_incomingHeals[playerName][i].healAmount
        end
    end
    missingHealth = missingHealth - (mb_GetHoTCount(unit) * healOverTimeValue)
    return missingHealth
end

-- targetPlayerName can be either a string or a table of strings if the spell will hit multiple targets
function mb_HealingModule_SendData(targetPlayerName, healAmount, finishTime)
    if max_IsTable(targetPlayerName) then
        local targetPlayers = ""
        for _, playerName in pairs(targetPlayerName) do
            targetPlayers = targetPlayers .. playerName .. "#"
        end
        targetPlayers = string.sub(targetPlayers, 1, string.len(targetPlayers) - 1)
        local healData = targetPlayers .. "/" .. healAmount .. "/" .. finishTime
        mb_MakeRequest("healerModuleData", healData, REQUEST_PRIORITY.HEALER_MODULE_DATA)
    else
        local healData = targetPlayerName .. "/" .. healAmount .. "/" .. finishTime
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
            if mb_IsUnitValidTarget(unit, spell) then
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

function mb_Healer_HandleUseConsumableRequest(request)
    if not UnitAffectingCombat("player") then
        return
    end
    if max_GetMissingMana("player") > 2500 then
        mb_QueueUseConsumable("Major Mana Potion")
    end
end
