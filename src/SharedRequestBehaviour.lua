
mb_shouldReloadUi = false
mb_tradeGreysTarget = nil
mb_tradeGoodiesTarget = nil
mb_queuedRequests = {}
mb_desiredBuffs = {}

function mb_RegisterSharedRequestHandlers()
    mb_RegisterForProposedRequest("reload", mb_ReloadRequestHandler)
    mb_RegisterForProposedRequest("trademegreys", mb_TradeMeGreysRequestHandler)
    mb_RegisterForProposedRequest("trademegoodies", mb_TradeMeGoodiesRequestHandler)
    mb_RegisterForProposedRequest("promoteLeader", mb_PromoteLeaderRequestHandler)
end

function mb_HandleSharedBehaviour()
    AcceptResurrect()
    AcceptGuild()
    AcceptGroup()
    AcceptTrade()
    RetrieveCorpse()
    AcceptQuest()
    ConfirmAcceptQuest()
    ConfirmSummon()
    if UnitIsDeadOrGhost("player") then
        mb_RequestResurrection()
        return true
    end
    if mb_HandleQueuedSharedRequests() then
        return true
    end
    --CancelLogout()
    mb_CheckAndRequestBuffs()
    return false
end

function mb_HandleQueuedSharedRequests()
    if mb_shouldReloadUi then
        mb_shouldReloadUi = false
        ReloadUI()
        return true
    end
    if mb_tradeGreysTarget ~= nil then
        mb_DoTradeGreys()
        return true
    end
    if mb_tradeGoodiesTarget ~= nil then
        mb_DoTradeGoodies()
        return true
    end
    return false
end

function mb_ReloadRequestHandler(requestId, requestType, requestBody, from)
    if from ~= UnitName("player") then
        mb_shouldReloadUi = true
    end
end

function mb_TradeMeGreysRequestHandler(requestId, requestType, requestBody)
    if UnitName("player") ~= requestBody then
        mb_tradeGreysTarget = requestBody
    end
end

function mb_TradeMeGoodiesRequestHandler(requestId, requestType, requestBody)
    if UnitName("player") ~= requestBody then
        mb_tradeGoodiesTarget = requestBody
    end
end

function mb_PromoteLeaderRequestHandler(requestId, requestType, requestBody)
    if IsPartyLeader() then
        PromoteByName(mb_GetConfig()["followTarget"])
    end
end

function mb_DoTradeGreys()
    local found, bag, slot = mb_GetTradeableItemWithQuality(0)
    if found then
        TargetByName(mb_tradeGreysTarget)
        InitiateTrade("target")
        PickupContainerItem(bag, slot)
        DropItemOnUnit("target")
    else
        mb_tradeGreysTarget = nil
    end
end

function mb_DoTradeGoodies()
    local found, bag, slot = mb_GetTradeableItem()
    if found then
        TargetByName(mb_tradeGoodiesTarget)
        InitiateTrade("target")
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

function mb_RequestResurrection()
    if UnitIsGhost("player") then
        SendChatMessage("I'm dead and I released like a noob, gonna need manual res", "RAID", "Common")
    else
        mb_MakeThrottledRequest(REQUEST_RESURRECT, UnitName("player"))
    end
end

mb_lastRequestedRequests = {}
function mb_MakeThrottledRequest(request, requestBody)
    if mb_lastRequestedRequests[request.requestType] == nil then
        mb_MakeRequest(request.requestType, requestBody)
        mb_lastRequestedRequests[request.requestType] = GetTime()
    elseif mb_lastRequestedRequests[request.requestType] + request.throttle < GetTime() then
        mb_MakeRequest(request.requestType, requestBody)
        mb_lastRequestedRequests[request.requestType] = GetTime()
    end
end

function mb_LearnTalent(tabIndex, talentIndex)
    if not mb_GetConfig()["autoLearnTalents"] then
        return
    end
    LearnTalent(tabIndex, talentIndex);
end
