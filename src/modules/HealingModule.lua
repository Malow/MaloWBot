
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
    if mb_IsOnGCD() then
        return
    end
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
        local playerName = parts[1]
        if mb_HealingModule_incomingHeals[playerName] == nil then
            mb_HealingModule_incomingHeals[playerName] = {}
        end
        local incomingHeal = {}
        incomingHeal.healAmount = tonumber(parts[2])
        incomingHeal.finishTime = tonumber(parts[3])
        incomingHeal.from = request.from
        table.insert(mb_HealingModule_incomingHeals[playerName], incomingHeal)
    end
end

mb_HealingModule_tankingTanks = {}
function mb_HealingModule_HandleTankBroadcastRequest(request)
    if mb_HealingModule_tankingTanks[request.from] == nil then
        mb_HealingModule_tankingTanks[request.from] = {}
    end
    mb_HealingModule_tankingTanks[request.from].dtps = tonumber(request.body)
    mb_HealingModule_tankingTanks[request.from].lastReceived = GetTime()
end

function mb_HealingModule_GetValidTankUnitWithHighestFutureMissingHealth(spellName)
    mb_HealingModule_ExpireTankingTanks()
    local lowestTank = nil
    local futureMissingHealth = nil
    for tankName, tankData in pairs(mb_HealingModule_tankingTanks) do
        local unit = max_GetUnitForPlayerName(tankName)
        if mb_IsUnitValidTarget(unit, spellName) then
            local missingHealth = mb_HealingModule_GetFutureMissingHealth(unit)
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
        if v.lastReceived + 7 < GetTime() then
            table.insert(toBeExpired, k)
        end
    end
    for _, v in pairs(toBeExpired) do
        mb_HealingModule_tankingTanks[v] = nil
    end
end

function mb_HealingModule_GetFutureMissingHealth(unit)
    local playerName = UnitName(unit)
    local missingHealth = max_GetMissingHealth(unit)
    if mb_HealingModule_incomingHeals[playerName] == nil then
        return missingHealth
    end
    local now = GetTime()
    for i = max_GetTableSize(mb_HealingModule_incomingHeals[playerName]), 1, -1 do
        if mb_HealingModule_incomingHeals[playerName][i].finishTime < now then
            table.remove(mb_HealingModule_incomingHeals[playerName], i)
        else
            missingHealth = missingHealth - mb_HealingModule_incomingHeals[playerName][i].healAmount
        end
    end
    missingHealth = missingHealth - (mb_GetHoTCount(unit) * 500)
    return missingHealth
end

function mb_HealingModule_SendData(targetPlayerName, healAmount, finishTime)
    local healData = targetPlayerName .. "/" .. healAmount .. "/" .. finishTime
    mb_MakeRequest("healerModuleData", healData, REQUEST_PRIORITY.HEALER_MODULE_DATA)
end

function mb_HealingModule_GetRaidHealTarget(spell, unitFilter)
    local healTarget = 0
    local missingHealthOfTarget = mb_HealingModule_GetFutureMissingHealth("player")
    local members = max_GetNumPartyOrRaidMembers()
    for i = 1, members do
        local unit = max_GetUnitFromPartyOrRaidIndex(i)
        if unitFilter ~= nil and not mb_CheckFilter(unit, unitFilter) then
            break
        end
        local missingHealth = mb_HealingModule_GetFutureMissingHealth(unit)
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
