
mb_shouldReloadUi = false
mb_tradeGreysTarget = nil
mb_tradeGoodiesTarget = nil
mb_queuedRequests = {}
mb_desiredBuffs = {}

function mb_RegisterSharedRequestHandlers()
    mb_RegisterForProposedRequest("reload", mb_ReloadRequestHandler)
    mb_RegisterForProposedRequest("trademegreys", mb_TradeMeGreysRequestHandler)
    mb_RegisterForProposedRequest("trademegoodies", mb_TradeMeGoodiesRequestHandler)
end

function mb_HandleSharedBehaviour()
    if UnitIsDeadOrGhost("player") then
        mb_RequestResurrection()
        return true
    end
    if mb_HandleQueuedSharedRequests() then
        return true
    end
    AcceptGuild()
    AcceptGroup()
    AcceptTrade()
    AcceptResurrect()
    RetrieveCorpse()
    AcceptQuest()
    ConfirmAcceptQuest()
    ConfirmSummon()
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
            if mb_desiredBuffs[i].lastRequested == nil then
                mb_MakeRequest(mb_desiredBuffs[i].requestType, UnitName("player"))
                mb_desiredBuffs[i].lastRequested = GetTime()
            elseif mb_desiredBuffs[i].lastRequested + mb_desiredBuffs[i].throttle < GetTime() then
                mb_MakeRequest(mb_desiredBuffs[i].requestType, UnitName("player"))
                mb_desiredBuffs[i].lastRequested = GetTime()
            end
        end
    end
end

mb_lastRequestedResurrect = nil
function mb_RequestResurrection()
    if UnitIsGhost("player") then
        SendChatMessage("I'm dead and I released like a noob, gonna need manual res", "RAID", "Common")
    else
        if mb_lastRequestedResurrect == nil then
            mb_MakeRequest(REQUEST_RESURRECT.requestType, UnitName("player"))
            mb_lastRequestedResurrect = GetTime()
        elseif mb_lastRequestedResurrect + REQUEST_RESURRECT.throttle < GetTime() then
            mb_MakeRequest(REQUEST_RESURRECT.requestType, UnitName("player"))
            mb_lastRequestedResurrect = GetTime()
        end
    end
end