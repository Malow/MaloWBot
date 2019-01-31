mb_shouldReloadUi = false
mb_tradeGoodiesTarget = nil
mb_desiredBuffs = {}
mb_shouldHearthstone = false
mb_shouldMount = false
mb_shouldReleaseCorpse = false
mb_shouldLearnTalents = mb_GetConfig()["autoLearnTalents"]
mb_desiredTalentTree = {}
mb_shouldTrainSpells = false
mb_shouldFollow = true
mb_shouldRequestBuffs = false
mb_classSyncData = nil
mb_shouldAutoTarget = false

function mb_HandleSharedBehaviour(commander)
    mb_RangeCheckModule_CacheRangesToFriendlies()

    if mb_HandleThrottledSharedBehaviour(commander) then
        return true
    end

    if mb_IsInCombat() then
        if max_GetHealthPercentage("player") < 25 then
            mb_UseItem("Major Healthstone")
            return true
        end
    end

    if mb_shouldLearnTalents then
        mb_LearnTalents()
    end
    if mb_isTraining then
        mb_TrainSpells()
        return true
    end
    if mb_isVendoring then
        mb_HandleVendoring()
        return true
    end
    if mb_tradeGoodiesTarget ~= nil then
        mb_DoTradeGoodies()
        return true
    end
    --CancelLogout()

    if mb_MoveOutModule_Update() then
        return true
    end

    if not mb_IsDrinking() and mb_shouldFollow then
        FollowByName(commander, true)
    end

    if mb_UseConsumableFromQueue() then
        return true
    end

    return false
end

mb_lastHandleThrottledSharedBehaviour = 0
function mb_HandleThrottledSharedBehaviour(commander)
    if mb_lastHandleThrottledSharedBehaviour + 1 > mb_GetTime() then
        return false
    end
    mb_lastHandleThrottledSharedBehaviour = mb_GetTime()

    if mb_isReadyChecking then
        mb_HandleReadyCheck()
        mb_isReadyChecking = false
    end

    if mb_isTrading then
        AcceptTrade()
    end

    if mb_isGossiping then
        mb_HandleGossiping()
        return true
    end

    if mb_HandleMassCommandRequests() then
        return true
    end

    if mb_createClassSyncDataFunction ~= nil and mb_classSyncData == nil then
        local request = REQUEST_CLASS_SYNC
        request.type = max_GetClass("player") .. "Sync"
        mb_MakeThrottledRequest(request, "needSync", REQUEST_PRIORITY.CLASS_SYNC)
    end

    AcceptGuild()
    AcceptGroup()
    RetrieveCorpse()
    ConfirmAcceptQuest()
    ConfirmSummon()
    AcceptQuest()

    if UnitIsDeadOrGhost("player") and not max_hasBuff("player", BUFF_TEXTURE_FEIGN_DEATH) then
        AcceptResurrect()
        mb_RequestResurrection()
        FollowByName(commander, true)
        return true
    end

    mb_HandleQueuedSharedRequests()

    if not mb_IsInCombat() then
        mb_CheckAndRequestBuffs()
    end

    if GetTrackingTexture() == nil then
        if max_HasSpell("Find Minerals") then
            CastSpellByName("Find Minerals")
            return true
        elseif max_HasSpell("Find Herbs") then
            CastSpellByName("Find Herbs")
            return true
        end
    end

    return false
end

function mb_AcquireOffensiveTarget(rangeCheckSpell)
    if mb_shouldAutoTarget then
        if max_HasValidOffensiveTarget(rangeCheckSpell) and UnitAffectingCombat("target") then
            return true
        end
        TargetNearestEnemy()
        if max_HasValidOffensiveTarget(rangeCheckSpell) and UnitAffectingCombat("target") then
            return true
        end
        return false
    end
    max_AssistByPlayerName(mb_GetMyCommanderName())
    return max_HasValidOffensiveTarget(rangeCheckSpell)
end

function mb_HandleMassCommandRequests()
    if mb_shouldReloadUi and not mb_IsInCombat() then
        mb_shouldReloadUi = false
        ReloadUI()
        return true
    end
    if mb_shouldHearthstone then
        mb_shouldHearthstone = false
        if not mb_HasItem("Hearthstone") then
            max_SayRaid("Uh guys? I don't have a Hearthstone...")
        elseif mb_IsItemOnCooldown("Hearthstone") then
            max_SayRaid("My Hearthstone is on cooldown.")
        else
            mb_UseItem("Hearthstone")
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
        if request.type == "trademegoodies" then
            mb_tradeGoodiesTarget = request.body
            mb_RequestCompleted(request)
        elseif request.type == "inventoryDump" then
            InitiateTrade(max_GetUnitForPlayerName(request.body))
            mb_RequestCompleted(request)
        elseif request.type == "goldDistribution" then
            if not mb_isTrading then
                InitiateTrade(max_GetUnitForPlayerName(mb_GetMyCommanderName()))
                return
            end
            if GetMoney() < 200000 then
                local moneyNeeded = (200000 - GetMoney()) / 10000
                moneyNeeded = moneyNeeded + 10 -- get 10g more than the lower limit
                max_SayRaid("I need " .. moneyNeeded .. "g.")
            elseif GetMoney() > 400000 then
                local moneyToBeTraded = GetMoney() - 400000
                SetTradeMoney(moneyToBeTraded + 100000) -- trade 10g more than the upper limit
            end
            mb_RequestCompleted(request)
        end
    end
end

function mb_DoTradeGoodies()
    if not mb_isTrading then
        if not CheckInteractDistance(max_GetUnitForPlayerName(mb_tradeGoodiesTarget), 2) then
            mb_tradeGoodiesTarget = nil
            return
        end
        mb_StartTradeThrottled(max_GetUnitForPlayerName(mb_tradeGoodiesTarget))
        return
    end
    local found, bag, slot = mb_GetTradeableItem()
    if found and not mb_IsItemSoulbound(bag, slot) then
        local lastTradeSlot = GetTradePlayerItemLink(6)
        if lastTradeSlot == nil then
            PickupContainerItem(bag, slot)
            DropItemOnUnit(max_GetUnitForPlayerName(mb_tradeGoodiesTarget))
            ClearCursor()
            return
        end
    end
    mb_tradeGoodiesTarget = nil
end

function mb_CheckAndRequestBuffs()
    if not mb_shouldRequestBuffs then
        return
    end
    for i = 1, max_GetTableSize(mb_desiredBuffs) do
        if not max_HasBuffWithMultipleTextures("player", mb_desiredBuffs[i].textures) then
            mb_MakeThrottledRequest(mb_desiredBuffs[i], UnitName("player"), REQUEST_PRIORITY.BUFF)
        end
    end
end

function mb_CheckAndRequestDispels()
    return -- Disabled for now
    --[[for i = 1, MAX_DEBUFFS do
        local debuffTexture, debuffApplications, debuffDispelType = UnitDebuff("player", i)
        if debuffDispelType ~= nil then
            if debuffDispelType == "Magic" then
                mb_MakeThrottledRequest(REQUEST_REMOVE_MAGIC, UnitName("player"), REQUEST_PRIORITY.DISPEL)
            elseif debuffDispelType == "Curse" then
                mb_MakeThrottledRequest(REQUEST_REMOVE_CURSE, UnitName("player"), REQUEST_PRIORITY.DISPEL)
            elseif debuffDispelType == "Disease" then
                mb_MakeThrottledRequest(REQUEST_REMOVE_DISEASE, UnitName("player"), REQUEST_PRIORITY.DISPEL)
            elseif debuffDispelType == "Poison" then
                mb_MakeThrottledRequest(REQUEST_REMOVE_POISON, UnitName("player"), REQUEST_PRIORITY.DISPEL)
            end
        end
    end]]
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

function mb_RemoveDesiredBuff(buff)
    for i = 1, max_GetTableSize(mb_desiredBuffs) do
        if mb_desiredBuffs[i].type == buff.type then
            table.remove(mb_desiredBuffs, i)
            return
        end
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
        return REQUEST_PRIORITY.RESURRECT_RESURRECTER
    end
    if myClass == "ROGUE" or myClass == "WARRIOR" then
        return REQUEST_PRIORITY.RESURRECT_MELEE
    end
    return REQUEST_PRIORITY.RESURRECT_CASTER
end

mb_throttleData = {}
function mb_MakeThrottledRequest(request, requestBody, requestPriority)
    if mb_throttleData[request.type] == nil then
        mb_MakeRequest(request.type, requestBody, requestPriority)
        mb_throttleData[request.type] = {}
        mb_throttleData[request.type].nextRequestTime = mb_GetTime() + UNACCEPTED_REQUEST_THROTTLE
        mb_throttleData[request.type].acceptedThrottle = request.throttle
    elseif mb_throttleData[request.type].nextRequestTime < mb_GetTime() then
        mb_MakeRequest(request.type, requestBody, requestPriority)
        mb_throttleData[request.type].nextRequestTime = mb_GetTime() + UNACCEPTED_REQUEST_THROTTLE
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

mb_lastBasicCasterLogicTime = 0
mb_lastBasicCasterLogicReturn = false
function mb_DoBasicCasterLogicThrottled()
    if mb_lastBasicCasterLogicTime + 1 > mb_GetTime() then
        return mb_lastBasicCasterLogicReturn
    end
    mb_lastBasicCasterLogicTime = mb_GetTime()
    if mb_IsDrinking() then
        if max_GetManaPercentage("player") < 95 then
            mb_lastBasicCasterLogicReturn = true
            return true
        else
            SitOrStand()
        end
    end

    if max_GetManaPercentage("player") < 60 then
        if mb_DrinkIfPossible() then
            mb_lastBasicCasterLogicReturn = true
            return true
        end
    end

    if not mb_IsInCombat() then
        if mb_GetWaterCount() < 10 and max_GetClass("player") ~= "MAGE" then
            mb_MakeThrottledRequest(REQUEST_WATER, UnitName("player"), REQUEST_PRIORITY.WATER)
        end
    end

    mb_lastBasicCasterLogicReturn = false
    return false
end

mb_saidQuestCompleteHelpMessageTime = 0
function mb_HandleGossiping()
    local _, gossip1, _, gossip2, _, gossip3, _, gossip4, _, gossip5 = GetGossipOptions()
    local topGossipText = GetGossipText()
    if topGossipText ~= nil then
        if string.find(topGossipText, "The fabric of which") then
            SelectGossipOption(1)
            return
        end
        if string.find(topGossipText, "Greetings") and gossip1 == "vendor" then
            SelectGossipOption(1)
            return
        end
    end
    -- QuestHaste addon takes care of accepting/completing of quests.
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
        mb_shouldTrainSpells = false
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
            --RepairAllItems()
        end
        CloseMerchant()
    end
end

mb_watchedReagents = {}
-- Adds an item-name together with a minimum count that the player will warn when repairing if it has too few of
function mb_AddReagentWatch(itemName, minimumCount)
    local reagent = {}
    reagent.itemName = itemName
    reagent.minimumCount = minimumCount
    table.insert(mb_watchedReagents, reagent)
end

function mb_WarnForWatchedReagents()
    for i = 1, max_GetTableSize(mb_watchedReagents) do
        local itemCount = mb_GetItemCount(mb_watchedReagents[i].itemName)
        if itemCount < mb_watchedReagents[i].minimumCount then
            max_SayRaid("I'm down to " .. itemCount .. " " .. mb_watchedReagents[i].itemName .. ". I would like another " .. mb_watchedReagents[i].minimumCount - itemCount)
        end
    end
end

function mb_IsClassLeader()
    return mb_GetMyClassOrder() == 1
end

mb_myClassOrderCached = nil
function mb_GetMyClassOrder()
    if mb_myClassOrderCached ~= nil then
        return mb_myClassOrderCached
    end
    local classMates = mb_GetClassMates(max_GetClass("player"))
    for i = 1, max_GetTableSize(classMates) do
        if classMates[i] == UnitName("player") then
            mb_myClassOrderCached = i
            return mb_myClassOrderCached
        end
    end
    max_SayRaid("Error, couldn't get my class order.")
end

function mb_GetBuffWithType(type)
    for k, v in pairs(All_BUFFS) do
        if type == v.type then
            return v
        end
    end
    return nil
end

-- Buffs the player with the buff if it can, returns true if it buffs
function mb_CompleteStandardBuffRequest(request)
    local buff = mb_GetBuffWithType(request.type)
    if buff == nil then
        return false
    end
    if mb_IsOnGCD() or mb_IsCasting() then
        return true
    end
    mb_RequestCompleted(request)
    if not max_HasBuffWithMultipleTextures(max_GetUnitForPlayerName(request.body), buff.textures) then
        if buff.groupWideSpellName ~= nil and mb_ShouldBuffGroupWide(request.body, buff, buff.unitFilter) then
            max_CastSpellOnRaidMemberByPlayerName(buff.groupWideSpellName, request.body)
        else
            max_CastSpellOnRaidMemberByPlayerName(buff.spellName, request.body)
        end
        return true
    end
end

function mb_HandleStandardBuffRequest(request)
    local buff = mb_GetBuffWithType(request.type)
    if buff.groupWideSpellName ~= nil then
        if not max_HasSpell(buff.groupWideSpellName) then
            return
        end
        if buff.reagent ~= nil then
            if mb_GetItemCount(buff.reagent) == 0 then
                max_SayRaid("I'm completely out of " .. buff.reagent)
                return
            end
        end
    end
    if mb_CanBuffUnitWithSpell(max_GetUnitForPlayerName(request.body), buff.spellName) then
        mb_AcceptRequest(request)
    end
end

function mb_RegisterForStandardBuffRequest(buff)
    mb_RegisterForRequest(buff.type, mb_HandleStandardBuffRequest)
    mb_RegisterFriendlyRangeCheckSpell(buff.spellName)
end

function mb_HandleSharedBehaviourOnLogin(playerClass)
    mb_RegisterSharedRequestHandlers(playerClass)
end

mb_lastReadyCheck = 0
function mb_HandleReadyCheck()
    mb_lastReadyCheck = mb_GetTime()
    local isReady = true

    local lowestDurability = mb_GetLowestDurabilityPercentage()
    if lowestDurability < 10 then
        max_SayRaid("I'm at " .. lowestDurability .. "% durability.")
        isReady = false
    end

    if mb_CancelExpiringBuffs(8) then
        isReady = false
    end

    local playerClass = max_GetClass("player")
    if playerClass == "DRUID" then
    elseif playerClass == "HUNTER" then
        if not mb_Hunter_IsReady() then
            isReady = false
        end
    elseif playerClass == "MAGE" then
        if not mb_Mage_IsReady() then
            isReady = false
        end
    elseif playerClass == "PALADIN" then
    elseif playerClass == "PRIEST" then
        if not mb_Priest_IsReady() then
            isReady = false
        end
    elseif playerClass == "ROGUE" then
    elseif playerClass == "WARLOCK" then
        if not mb_Warlock_IsReady() then
            isReady = false
        end
    elseif playerClass == "WARRIOR" then
    end

    if playerClass ~= "ROGUE" and playerClass ~= "WARRIOR" then
        if max_GetManaPercentage("player") < 95 then
            mb_DrinkIfPossible()
            isReady = false
        end
    end

    if isReady then
        ConfirmReadyCheck(1)
    else
        ConfirmReadyCheck(nil)
    end
end

function mb_CancelExpiringBuffs(minutes)
    local didCancel = false
    for _, buff in pairs(All_BUFFS) do
        for _, buffTexture in pairs(buff.textures) do
            if max_CancelBuffWithRemainingDurationLessThan(buffTexture, minutes * 60) then
                didCancel = true
            end
        end
    end
    return didCancel
end

mb_lastFailedCleanseCheck = 0
function mb_CleanseRaidMemberThrottled(spellName, debuffType1, debuffType2, debuffType3, unitFilter, ignoreShoulds)
    if mb_lastFailedCleanseCheck + 1.2 > mb_GetTime() then
        return false
    end
    if not ignoreShoulds then
        if not mb_shouldDecurse then
            local type = "Curse"
            if debuffType1 == type then
                debuffType1 = nil
            end
            if debuffType2 == type then
                debuffType2 = nil
            end
            if debuffType3 == type then
                debuffType3 = nil
            end
        end
        if not mb_shouldDepoison then
            local type = "Poison"
            if debuffType1 == type then
                debuffType1 = nil
            end
            if debuffType2 == type then
                debuffType2 = nil
            end
            if debuffType3 == type then
                debuffType3 = nil
            end
        end
        if not mb_shouldDispel then
            local type = "Magic"
            if debuffType1 == type then
                debuffType1 = nil
            end
            if debuffType2 == type then
                debuffType2 = nil
            end
            if debuffType3 == type then
                debuffType3 = nil
            end
        end
    end
    local debuffTarget = mb_GetDebuffedRaidMember(spellName, debuffType1, debuffType2, debuffType3, unitFilter)
    if debuffTarget ~= nil then
        max_CastSpellOnRaidMember(spellName, debuffTarget)
        return true
    end
    mb_lastFailedCleanseCheck = mb_GetTime()
    return false
end

function mb_IsFreeToAcceptRequest()
    if UnitIsDead("player") then
        return false
    end
    if mb_CrowdControlModule_IsAssignedToCrowdControl() then
        return false
    end
    if mb_IsDrinking() then
        return false
    end
    return true
end

mb_lastTemporaryWeaponEnchantCheck = 0
function mb_ApplyTemporaryWeaponEnchantsThrottled(mainHandItemName, offHandItemName)
    if mb_lastTemporaryWeaponEnchantCheck + 3 > mb_GetTime() then
        return false
    end
    mb_lastTemporaryWeaponEnchantCheck = mb_GetTime()

    local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo()
    if mainHandItemName ~= nil and mb_ApplyWeaponEnchantIfNeeded(mainHandItemName, 16, hasMainHandEnchant, mainHandExpiration, mainHandCharges) then
        return true
    end
    if offHandItemName ~= nil and mb_ApplyWeaponEnchantIfNeeded(offHandItemName, 17, hasOffHandEnchant, offHandExpiration, offHandCharges) then
        return true
    end
    return false
end

function mb_ApplyWeaponEnchantIfNeeded(itemName, slotNumber, hasEnchant, expiration, charges)
    if mb_lastReadyCheck + 30 > mb_GetTime() then -- If there's been less than 30 seconds since last ready-check overwrite enchants with less than 5 minutes or less than 20 charges
        if hasEnchant == nil or expiration <= 300000 or (charges ~= nil and charges ~= 0 and charges <= 20) then
            return mb_ApplyWeaponEnchant(itemName, slotNumber)
        end
    end
    if hasEnchant == nil then
        return mb_ApplyWeaponEnchant(itemName, slotNumber)
    end
    return false
end

function mb_ApplyWeaponEnchant(itemName, slotNumber)
    if mb_GetItemCount(itemName) == 0 then
        max_SayRaid("I'm out of " .. itemName)
        return false
    end
    mb_UseItem(itemName)
    PickupInventoryItem(slotNumber)
    ReplaceEnchant()
    ClearCursor()
    return true
end

mb_queuedUseConsumables = {}
function mb_QueueUseConsumable(itemName)
    table.insert(mb_queuedUseConsumables, itemName)
end

function mb_UseConsumableFromQueue()
    if mb_IsCasting() then
        return false
    end
    local itemName = table.remove(mb_queuedUseConsumables, 1)
    if itemName == nil then
        return false
    end
    local itemCount = mb_GetItemCount(itemName)
    if itemCount > 0 then
        mb_UseItem(itemName)
        return true
    else
        max_SayRaid("I'm completely out of " .. itemName)
    end
    return false
end