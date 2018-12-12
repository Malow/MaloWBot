mb_shouldReloadUi = false
mb_tradeGreysTarget = nil
mb_tradeGoodiesTarget = nil
mb_desiredBuffs = {}
mb_shouldHearthstone = false
mb_shouldMount = false
mb_shouldReleaseCorpse = false
mb_shouldLearnTalents = mb_GetConfig()["autoLearnTalents"]
mb_desiredTalentTree = {}
mb_ShouldTrainSpells = false

function mb_RegisterMassCommandRequestHandlers()
    mb_RegisterForRequest("reload", mb_ReloadRequestHandler)
    mb_RegisterForRequest("trademegreys", mb_TradeMeGreysRequestHandler)
    mb_RegisterForRequest("trademegoodies", mb_TradeMeGoodiesRequestHandler)
    mb_RegisterForRequest("inventoryDump", mb_InventoryDumpRequestHandler)
    mb_RegisterForRequest("promoteLeader", mb_PromoteLeaderRequestHandler)
    mb_RegisterForRequest("hearthstone", mb_HearthstoneRequestHandler)
    mb_RegisterForRequest("mount", mb_MountRequestHandler)
    mb_RegisterForRequest("releaseCorpse", mb_ReleaseCorpseRequestHandler)
    mb_RegisterForRequest("haveQuest", mb_HaveQuestRequestHandler)
    mb_RegisterForRequest("doesNotHaveQuest", mb_DoesNotHaveQuestRequestHandler)
end

function mb_HandleSharedBehaviour(commander)
    AcceptGuild()
    AcceptGroup()
    if mb_isTrading then
        AcceptTrade()
    end
    RetrieveCorpse()
    ConfirmAcceptQuest()
    ConfirmSummon()
    if mb_isTraining then
        mb_TrainSpells()
        return true
    end
    if mb_isGossiping then
        mb_HandleGossiping()
        return true
    end
    if mb_isVendoring then
        mb_HandleVendoring()
        return true
    end
    if mb_HandleMassCommandRequests() then
        return true
    end
    if UnitIsDeadOrGhost("player") then
        AcceptResurrect()
        mb_RequestResurrection()
        FollowByName(commander, true)
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
    if mb_shouldReleaseCorpse then
        mb_shouldReleaseCorpse = false
        RepopMe()
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

function mb_ReleaseCorpseRequestHandler(requestId, requestType, requestBody, from)
    if from ~= UnitName("player") then
        mb_shouldReleaseCorpse = true
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

mb_saidQuestCompleteHelpMessageTime = 0
function mb_HandleGossiping()
    -- QuestHaste addon takes care of accepting/completing of quests.

    if GetNumQuestChoices() > 1 and mb_saidQuestCompleteHelpMessageTime + 10 < GetTime() then
        max_SayRaid("I need help deciding which quest-reward to pick.")
        mb_hasSaidQuestCompleteHelpMessage = GetTime()
        return
    end

    local _, gossip1, _, gossip2, _, gossip3, _, gossip4, _, gossip5 = GetGossipOptions()
    if mb_GetConfig()["autoTrainSpells"] then
        if gossip1 == "trainer" then
            SelectGossipOption(1)
            return
        elseif gossip2 == "trainer" then
            SelectGossipOption(2)
            return
        elseif gossip3 == "trainer" then
            SelectGossipOption(3)
            return
        elseif gossip4 == "trainer" then
            SelectGossipOption(4)
            return
        elseif gossip5 == "trainer" then
            SelectGossipOption(5)
            return
        end
    end
end

mb_trainAttemptsLeft = 15 -- Used to train all ranks
function mb_TrainSpells()
    for i = 200, 1, -1 do
        BuyTrainerService(i)
    end
    mb_trainAttemptsLeft = mb_trainAttemptsLeft - 1
    if mb_trainAttemptsLeft < 1 then
        mb_ShouldTrainSpells = false
        mb_trainAttemptsLeft = 15
        CloseTrainer()
    end
end

function mb_HandleVendoring()
    if GetRepairAllCost() > GetMoney() then
        max_SayRaid("Guys, I'm broke and can't afford my repairs :(")
    end
    RepairAllItems()
    local found, bag, slot = mb_GetTradeableItemWithQuality(0)
    while found do
        UseContainerItem(bag, slot)
        found, bag, slot = mb_GetTradeableItemWithQuality(0)
    end
    CloseMerchant()
end

function mb_HaveQuestRequestHandler(requestId, requestType, requestBody)
    for i = 1, 50 do
        local name = GetQuestLogTitle(i)
        if name == requestBody then
            max_SayRaid("I have quest: " .. requestBody)
            return
        end
    end
end

function mb_DoesNotHaveQuestRequestHandler(requestId, requestType, requestBody)
    for i = 1, 50 do
        local name = GetQuestLogTitle(i)
        if name == requestBody then
            return
        end
    end
    max_SayRaid("I do not have quest: " .. requestBody)
end


