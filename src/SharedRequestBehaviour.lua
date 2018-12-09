
mb_shouldReloadUi = false
mb_tradeGreysTarget = nil
mb_tradeGoodiesTarget = nil
mb_desiredBuffs = {}
mb_shouldHearthstone = false
mb_shouldMount = false

function mb_RegisterSharedRequestHandlers()
    mb_RegisterForRequest("reload", mb_ReloadRequestHandler)
    mb_RegisterForRequest("trademegreys", mb_TradeMeGreysRequestHandler)
    mb_RegisterForRequest("trademegoodies", mb_TradeMeGoodiesRequestHandler)
    mb_RegisterForRequest("promoteLeader", mb_PromoteLeaderRequestHandler)
    mb_RegisterForRequest("hearthstone", mb_HearthstoneRequestHandler)
    mb_RegisterForRequest("mount", mb_MountRequestHandler)
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
    if mb_shouldHearthstone then
        mb_shouldHearthstone = false
        if mb_UseItem("Hearthstone") then
            return
        else
            SendChatMessage("Uh guys? I don't have a Hearthstone...", "RAID", "Common")
        end
    end
    if mb_shouldMount then
        mb_shouldMount = false
        CastSpellByName("Summon Warhorse")
        CastSpellByName("Summon Felsteed")
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

function mb_LearnTalent(tabIndex, talentIndex, count)
    if not mb_GetConfig()["autoLearnTalents"] then
        return
    end
    if count == nil then
        LearnTalent(tabIndex, talentIndex)
        return
    end
    local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tabIndex, talentIndex)
    if count > currentRank then
        LearnTalent(tabIndex, talentIndex)
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