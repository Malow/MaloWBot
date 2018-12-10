mb_shouldReloadUi = false
mb_tradeGreysTarget = nil
mb_tradeGoodiesTarget = nil
mb_desiredBuffs = {}
mb_shouldHearthstone = false
mb_shouldMount = false
mb_shouldLearnTalents = mb_GetConfig()["autoLearnTalents"]
mb_desiredTalentTree = {}

function mb_RegisterMassCommandRequestHandlers()
    mb_RegisterForRequest("reload", mb_ReloadRequestHandler)
    mb_RegisterForRequest("trademegreys", mb_TradeMeGreysRequestHandler)
    mb_RegisterForRequest("trademegoodies", mb_TradeMeGoodiesRequestHandler)
    mb_RegisterForRequest("inventoryDump", mb_InventoryDumpRequestHandler)
    mb_RegisterForRequest("promoteLeader", mb_PromoteLeaderRequestHandler)
    mb_RegisterForRequest("hearthstone", mb_HearthstoneRequestHandler)
    mb_RegisterForRequest("mount", mb_MountRequestHandler)
end

function mb_HandleSharedBehaviour(commander)
    AcceptGuild()
    AcceptGroup()
    if mb_isTrading then
        AcceptTrade()
    end
    RetrieveCorpse()
    AcceptQuest()
    ConfirmAcceptQuest()
    ConfirmSummon()
    if UnitIsDeadOrGhost("player") then
        AcceptResurrect()
        mb_RequestResurrection()
        return true
    end
    if mb_HandleMassCommandRequests() then
        return true
    end
    if mb_HandleQueuedSharedRequests() then
        return true
    end
    --CancelLogout()
    mb_CheckAndRequestBuffs()
    if mb_shouldLearnTalents then
        mb_LearnTalents()
    end

    if not mb_IsDrinking() then
        FollowByName(commander, true)
    end
    return false
end

function mb_HandleMassCommandRequests()
    if mb_shouldReloadUi then
        mb_shouldReloadUi = false
        ReloadUI()
        return true
    end
    if mb_shouldHearthstone then
        mb_shouldHearthstone = false
        if mb_UseItem("Hearthstone") then
            return true
        else
            max_SayRaid("Uh guys? I don't have a Hearthstone...")
        end
    end
    if mb_shouldMount then
        mb_shouldMount = false
        CastSpellByName("Summon Warhorse")
        CastSpellByName("Summon Felsteed")
        return true
    end
    return false
end

function mb_HandleQueuedSharedRequests()
    if max_GetTableSize(mb_queuedRequests) > 0 then
        local request = mb_queuedRequests[1]
        if request.requestType == "trademegreys" then
            mb_tradeGreysTarget = request.requestBody
            table.remove(mb_queuedRequests, 1)
        elseif request.requestType == "trademegoodies" then
            mb_tradeGoodiesTarget = request.requestBody
            table.remove(mb_queuedRequests, 1)
        elseif request.requestType == "inventoryDump" then
            TargetByName(request.requestBody)
            InitiateTrade("target")
            table.remove(mb_queuedRequests, 1)
        end
    end
    if mb_tradeGreysTarget ~= nil then
        mb_DoTradeGreys()
        return
    end
    if mb_tradeGoodiesTarget ~= nil then
        mb_DoTradeGoodies()
        return
    end
    return false
end

function mb_ReloadRequestHandler(requestId, requestType, requestBody, from)
    if from ~= UnitName("player") then
        mb_shouldReloadUi = true
    end
end

function mb_TradeMeGreysRequestHandler(requestId, requestType, requestBody)
    if mb_tradeGreysTarget ~= nil or mb_tradeGoodiesTarget ~= nil then
        return
    end
    if UnitName("player") ~= requestBody then
        local found, bag, slot = mb_GetTradeableItemWithQuality(0)
        if not found then
            return false
        end
        local unit = max_GetUnitForPlayerName(requestBody)
        if mb_IsValidTarget(unit) then
            if CheckInteractDistance(unit, 2) then
                mb_AcceptRequest(requestId, requestType, requestBody)
            end
        end
    end
end

function mb_TradeMeGoodiesRequestHandler(requestId, requestType, requestBody)
    if mb_tradeGreysTarget ~= nil or mb_tradeGoodiesTarget ~= nil then
        return
    end
    if UnitName("player") ~= requestBody then
        local found, bag, slot = mb_GetTradeableItem()
        if not found then
            return false
        end
        local unit = max_GetUnitForPlayerName(requestBody)
        if mb_IsValidTarget(unit) then
            if CheckInteractDistance(unit, 2) then
                mb_AcceptRequest(requestId, requestType, requestBody)
            end
        end
    end
end

function mb_InventoryDumpRequestHandler(requestId, requestType, requestBody)
    if mb_tradeGreysTarget ~= nil or mb_tradeGoodiesTarget ~= nil then
        return
    end
    if UnitName("player") ~= requestBody then
        if max_GetClass("player") == "WARLOCK" then
            return
        end
        if max_GetFreeBagSlots() < 10 then
            return
        end
        local unit = max_GetUnitForPlayerName(requestBody)
        if mb_IsValidTarget(unit) then
            if CheckInteractDistance(unit, 2) then
                mb_AcceptRequest(requestId, requestType, requestBody)
            end
        end
    end
end


function mb_PromoteLeaderRequestHandler(requestId, requestType, requestBody)
    if IsPartyLeader() then
        PromoteByName(mb_GetConfig()["followTarget"])
    end
end

function mb_HearthstoneRequestHandler(requestId, requestType, requestBody, from)
    if from ~= UnitName("player") then
        mb_shouldHearthstone = true
    end
end

function mb_MountRequestHandler(requestId, requestType, requestBody, from)
    if from ~= UnitName("player") then
        mb_shouldMount = true
    end
end

function mb_DoTradeGreys()
    TargetByName(mb_tradeGreysTarget)
    if not mb_isTrading then
        InitiateTrade("target")
        return
    end
    local found, bag, slot = mb_GetTradeableItemWithQuality(0)
    if found then
        PickupContainerItem(bag, slot)
        DropItemOnUnit("target")
    else
        mb_tradeGreysTarget = nil
    end
end

function mb_DoTradeGoodies()
    TargetByName(mb_tradeGoodiesTarget)
    if not mb_isTrading then
        InitiateTrade("target")
        return
    end
    local found, bag, slot = mb_GetTradeableItem(0)
    if found then
        PickupContainerItem(bag, slot)
        DropItemOnUnit("target")
    else
        mb_tradeGoodiesTarget = nil
    end
end

function mb_CheckAndRequestBuffs()
    for i = 1, max_GetTableSize(mb_desiredBuffs) do
        if not max_HasBuff("player", mb_desiredBuffs[i].texture) then
            mb_MakeThrottledRequest(mb_desiredBuffs[i], UnitName("player"))
        end
    end
end

function mb_AddDesiredBuff(buff)
    table.insert(mb_desiredBuffs, buff)
    local hasSalvation = false
    local hasSanctuary = false
    for i = 1, max_GetTableSize(mb_desiredBuffs) do
        if mb_desiredBuffs[i].requestType == BUFF_BLESSING_OF_SALVATION.requestType then
            hasSalvation = true
        elseif mb_desiredBuffs[i].requestType == BUFF_BLESSING_OF_SANCTUARY.requestType then
            hasSanctuary = true
        end
    end
    if hasSalvation and hasSanctuary then
        max_SayRaid("Hey uh guys, can I get both Salvation and Sanctuary? (No, no you can't, fix your code)")
    end
end

mb_hasSaidReleasedMessage = false
function mb_RequestResurrection()
    if UnitIsGhost("player") then
        if not mb_hasSaidReleasedMessage then
            max_SayRaid("I'm dead and I released like a noob, gonna need manual res")
            mb_hasSaidReleasedMessage = true
        end
    else
        mb_MakeThrottledRequest(REQUEST_RESURRECT, UnitName("player"))
    end
end

mb_throttleData = {}
function mb_MakeThrottledRequest(request, requestBody)
    if mb_throttleData[request.requestType] == nil then
        mb_MakeRequest(request.requestType, requestBody)
        mb_throttleData[request.requestType] = {}
        mb_throttleData[request.requestType].nextRequestTime = GetTime() + UNACCEPTED_REQUEST_THROTTLE
        mb_throttleData[request.requestType].acceptedThrottle = request.throttle
    elseif mb_throttleData[request.requestType].nextRequestTime < GetTime() then
        mb_MakeRequest(request.requestType, requestBody)
        mb_throttleData[request.requestType].nextRequestTime = GetTime() + UNACCEPTED_REQUEST_THROTTLE
    end
end

function mb_MyPendingRequestWasAccepted(request)
    if mb_throttleData[request.requestType] ~= nil then
        mb_throttleData[request.requestType].nextRequestTime = mb_throttleData[request.requestType].nextRequestTime + mb_throttleData[request.requestType].acceptedThrottle
    end
end

function mb_AddDesiredTalent(tabIndex, talentIndex, count)
    table.insert(mb_desiredTalentTree, { tabIndex = tabIndex, talentIndex = talentIndex, count = count })
end

function mb_LearnTalents()
    if max_GetUnspentTalentPoints() > 0 and max_GetTableSize(mb_desiredTalentTree) > 0 then
        for i = 1, max_GetTableSize(mb_desiredTalentTree) do
            local desiredTalent = mb_desiredTalentTree[i]
            local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(desiredTalent.tabIndex, desiredTalent.talentIndex)
            if desiredTalent.count > currentRank then
                LearnTalent(desiredTalent.tabIndex, desiredTalent.talentIndex)
                return
            end
        end
        mb_shouldLearnTalents = false -- Already learned all that we can learn
    else
        mb_shouldLearnTalents = false
    end
end

function mb_DoBasicCasterLogic()
    if mb_isCasting then
        return true
    end

    if mb_IsDrinking() then
        if max_GetManaPercentage("player") < 95 then
            return true
        else
            SitOrStand()
        end
    end

    if max_GetManaPercentage("player") < 50 then
        if mb_DrinkIfPossible() then
            return true
        end
    end

    if not UnitAffectingCombat("player") then
        if mb_GetWaterCount() < 10 and max_GetClass("player") ~= "MAGE" then
            mb_MakeThrottledRequest(REQUEST_WATER, UnitName("player"))
        end
    end

    return false
end

-- Checks combat and mana and target
function mb_CanResurrectUnitWithSpell(unit, spell)
    if UnitAffectingCombat("player") then
        return false
    elseif max_GetManaPercentage("player") < 30 then
        return false
    elseif mb_IsDrinking() then
        return false
    end
    if UnitExists(unit) and UnitIsVisible(unit) and UnitIsFriend("player", unit) and UnitIsDead(unit) and max_IsSpellInRange(spell, unit) then
        return true
    end
end

-- Checks combat and mana and target
function mb_CanBuffUnitWithSpell(unit, spell)
    if UnitAffectingCombat("player") then
        return false
    elseif max_GetManaPercentage("player") < 50 then
        return false
    elseif mb_IsDrinking() then
        return false
    end
    if mb_IsValidTarget(unit,spell) and max_GetLevelDifferenceFromSelf(unit) > -8 then
        return true
    end
end

