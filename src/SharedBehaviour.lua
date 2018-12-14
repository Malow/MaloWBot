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
    mb_RegisterForRequest("areaOfEffectMode", mb_AreaOfEffectModeRequestHandler)
end

function mb_HandleSharedBehaviour(commander)
    AcceptGuild()
    AcceptGroup()
    if mb_isTrading then
        mb_AcceptTradeThrottled()
    end
    RetrieveCorpse()
    ConfirmAcceptQuest()
    ConfirmSummon()
    AcceptQuest()
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
    mb_CheckAndRequestDispels()
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
        CastSpellByName("Travel Form")
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
    local request = mb_GetQueuedRequest()
    if request ~= nil then
        if request.type == "trademegreys" then
            mb_tradeGreysTarget = request.body
            mb_RequestCompleted(request)
        elseif request.type == "trademegoodies" then
            mb_tradeGoodiesTarget = request.body
            mb_RequestCompleted(request)
        elseif request.type == "inventoryDump" then
            InitiateTrade(max_GetUnitForPlayerName(request.body))
            mb_RequestCompleted(request)
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

function mb_ReloadRequestHandler(request)
    if request.from ~= UnitName("player") then
        mb_shouldReloadUi = true
    end
end

function mb_TradeMeGreysRequestHandler(request)
    if mb_tradeGreysTarget ~= nil or mb_tradeGoodiesTarget ~= nil then
        return
    end
    if UnitName("player") ~= request.body then
        local found, bag, slot = mb_GetTradeableItemWithQuality(0)
        if not found then
            return false
        end
        local unit = max_GetUnitForPlayerName(request.body)
        if mb_IsUnitValidTarget(unit) then
            if CheckInteractDistance(unit, 2) then
                mb_AcceptRequest(request)
            end
        end
    end
end

function mb_TradeMeGoodiesRequestHandler(request)
    if mb_tradeGreysTarget ~= nil or mb_tradeGoodiesTarget ~= nil then
        return
    end
    if UnitName("player") ~= request.body then
        local found, bag, slot = mb_GetTradeableItem()
        if not found then
            return false
        end
        local unit = max_GetUnitForPlayerName(request.body)
        if mb_IsUnitValidTarget(unit) then
            if CheckInteractDistance(unit, 2) then
                mb_AcceptRequest(request)
            end
        end
    end
end

function mb_InventoryDumpRequestHandler(request)
    if mb_tradeGreysTarget ~= nil or mb_tradeGoodiesTarget ~= nil then
        return
    end
    if UnitName("player") ~= request.body then
        if max_GetClass("player") == "WARLOCK" then
            return
        end
        if max_GetFreeBagSlots() < 10 then
            return
        end
        local unit = max_GetUnitForPlayerName(request.body)
        if mb_IsUnitValidTarget(unit) then
            if CheckInteractDistance(unit, 2) then
                mb_AcceptRequest(request)
            end
        end
    end
end

function mb_PromoteLeaderRequestHandler(request)
    if IsPartyLeader() then
        PromoteByName(mb_GetConfig()["followTarget"])
    end
end

function mb_HearthstoneRequestHandler(request)
    if request.from ~= UnitName("player") then
        mb_shouldHearthstone = true
    end
end

function mb_MountRequestHandler(request)
    if request.from ~= UnitName("player") then
        mb_shouldMount = true
    end
end

function mb_ReleaseCorpseRequestHandler(request)
    if request.from ~= UnitName("player") then
        mb_shouldReleaseCorpse = true
    end
end

function mb_DoTradeGreys()
    if not mb_isTrading then
        InitiateTrade(max_GetUnitForPlayerName(mb_tradeGreysTarget))
        return
    end
    local found, bag, slot = mb_GetTradeableItemWithQuality(0)
    if found then
        PickupContainerItem(bag, slot)
        DropItemOnUnit(max_GetUnitForPlayerName(mb_tradeGreysTarget))
    else
        mb_tradeGreysTarget = nil
    end
end

function mb_DoTradeGoodies()
    if not mb_isTrading then
        InitiateTrade(max_GetUnitForPlayerName(mb_tradeGoodiesTarget))
        return
    end
    local found, bag, slot = mb_GetTradeableItem(0)
    if found then
        PickupContainerItem(bag, slot)
        DropItemOnUnit(max_GetUnitForPlayerName(mb_tradeGoodiesTarget))
    else
        mb_tradeGoodiesTarget = nil
    end
end

function mb_CheckAndRequestBuffs()
    if GetRealZoneText() == "Ironforge" or GetRealZoneText() == "Stormwind" then
        return
    end
    for i = 1, max_GetTableSize(mb_desiredBuffs) do
        if not max_HasBuffWithMultipleTextures("player", mb_desiredBuffs[i].textures) then
            mb_MakeThrottledRequest(mb_desiredBuffs[i], UnitName("player"), 5)
        end
    end
end

function mb_CheckAndRequestDispels()
    for i = 1, MAX_DEBUFFS do
        local debuffTexture, debuffApplications, debuffDispelType = UnitDebuff("player", i)
        if debuffDispelType and debuffDispelType == "Magic" then
            mb_MakeThrottledRequest(REQUEST_DISPEL, UnitName("player"), 10)
        end
        if debuffDispelType and debuffDispelType == "Curse" then
            mb_MakeThrottledRequest(REQUEST_DECURSE, UnitName("player"), 10)
        end
    end
end

function mb_AddDesiredBuff(buff)
    table.insert(mb_desiredBuffs, buff)
    local hasSalvation = false
    local hasSanctuary = false
    for i = 1, max_GetTableSize(mb_desiredBuffs) do
        if mb_desiredBuffs[i].type == BUFF_BLESSING_OF_SALVATION.type then
            hasSalvation = true
        elseif mb_desiredBuffs[i].type == BUFF_BLESSING_OF_SANCTUARY.type then
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
        mb_MakeThrottledRequest(REQUEST_RESURRECT, UnitName("player"), mb_GetMyResurrectionPriority())
    end
end

function mb_GetMyResurrectionPriority()
    local myClass = max_GetClass("player")
    if myClass == "PRIEST" or myClass == "PALADIN" then
        return 9
    end
    if myClass == "ROGUE" or myClass == "WARRIOR" then
        return 7
    end
    return 8
end

mb_throttleData = {}
function mb_MakeThrottledRequest(request, requestBody, requestPriority)
    if mb_throttleData[request.type] == nil then
        mb_MakeRequest(request.type, requestBody, requestPriority)
        mb_throttleData[request.type] = {}
        mb_throttleData[request.type].nextRequestTime = GetTime() + UNACCEPTED_REQUEST_THROTTLE
        mb_throttleData[request.type].acceptedThrottle = request.throttle
    elseif mb_throttleData[request.type].nextRequestTime < GetTime() then
        mb_MakeRequest(request.type, requestBody, requestPriority)
        mb_throttleData[request.type].nextRequestTime = GetTime() + UNACCEPTED_REQUEST_THROTTLE
    end
end

function mb_MyPendingRequestWasAccepted(request)
    if mb_throttleData[request.type] ~= nil then
        mb_throttleData[request.type].nextRequestTime = mb_throttleData[request.type].nextRequestTime + mb_throttleData[request.type].acceptedThrottle
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
            mb_MakeThrottledRequest(REQUEST_WATER, UnitName("player"), 6)
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
    mb_WarnForWatchedReagents()
    local found, bag, slot = mb_GetTradeableItemWithQuality(0)
    if found then
        UseContainerItem(bag, slot)
    else
        if GetRepairAllCost() > GetMoney() then
            max_SayRaid("Guys, I'm broke and can't afford my repairs :(")
        else
            RepairAllItems()
        end
        CloseMerchant()
    end
end

function mb_HaveQuestRequestHandler(request)
    for i = 1, 50 do
        local name = GetQuestLogTitle(i)
        if name == request.body then
            max_SayRaid("I have quest: " .. request.body)
            return
        end
    end
end

function mb_DoesNotHaveQuestRequestHandler(request)
    for i = 1, 50 do
        local name = GetQuestLogTitle(i)
        if name == request.body then
            return
        end
    end
    max_SayRaid("I do not have quest: " .. request.body)
end

function mb_AreaOfEffectModeRequestHandler(request)
    mb_areaOfEffectMode = request.body == "on"
end

mb_watchedReagents = {}
-- Adds an item-name together with a minimum count that the player will warn when repairing if it has too few of
function mb_AddReagentWatch(itemName, minimumCount)
    local reagent = {}
    reagent.itemName = itemName
    reagent.minimumCount = minimumCount
    reagent.hasWarned = false
    table.insert(mb_watchedReagents, reagent)
end

function mb_WarnForWatchedReagents()
    for i = 1, max_GetTableSize(mb_watchedReagents) do
        local itemCount = mb_GetItemCount(mb_watchedReagents[i].itemName)
        if itemCount < mb_watchedReagents[i].minimumCount then
            if not mb_watchedReagents[i].hasWarned then
                max_SayRaid("I'm down to " .. itemCount .. " " .. mb_watchedReagents[i].itemName .. ". I would like another " .. mb_watchedReagents[i].minimumCount - itemCount)
                mb_watchedReagents[i].hasWarned = true
            end
        end
    end
end

