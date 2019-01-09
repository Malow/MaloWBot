function mb_RegisterSharedRequestHandlers(playerClass)
    mb_RegisterForRequest("reload", mb_ReloadRequestHandler)
    mb_RegisterForRequest("trademegoodies", mb_TradeMeGoodiesRequestHandler)
    mb_RegisterForRequest("inventoryDump", mb_InventoryDumpRequestHandler)
    mb_RegisterForRequest("promoteLeader", mb_PromoteLeaderRequestHandler)
    mb_RegisterForRequest("hearthstone", mb_HearthstoneRequestHandler)
    mb_RegisterForRequest("mount", mb_MountRequestHandler)
    mb_RegisterForRequest("releaseCorpse", mb_ReleaseCorpseRequestHandler)
    mb_RegisterForRequest("haveQuest", mb_HaveQuestRequestHandler)
    mb_RegisterForRequest("doesNotHaveQuest", mb_DoesNotHaveQuestRequestHandler)
    mb_RegisterForRequest("areaOfEffectMode", mb_AreaOfEffectModeRequestHandler)
    mb_RegisterForRequest("followMode", mb_FollowModeRequestHandler)
    mb_RegisterForRequest("requestBuffsMode", mb_RequestBuffsModeRequestHandler)
    mb_RegisterForRequest("goldDistribution", mb_GoldDistributionRequestHandler)
    mb_RegisterForRequest("moveOutModule", mb_MoveOutModuleRequestHandler)
    mb_RegisterForRequest("fuckOff", mb_FuckOffRequestHandler)
    mb_RegisterForRequest(playerClass .. "Sync", mb_ClassSyncRequestHandler)
    mb_RegisterForRequest("remoteExecute", mb_RemoteExecuteRequestHandler)
    mb_RegisterForRequest("repairReport", mb_RepairReportRequestHandler)
end

function mb_ReloadRequestHandler(request)
    if request.from ~= UnitName("player") and request.from == mb_GetMyCommanderName() then
        mb_shouldReloadUi = true
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
        PromoteByName(mb_GetMyCommanderName())
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

function mb_FollowModeRequestHandler(request)
    if request.from == mb_GetMyCommanderName() then
        local parts = max_SplitString(request.body, "/")
        if max_GetTableSize(parts) > 1 then
            if UnitName("player") ~= parts[2] then
                return
            end
        end
        mb_shouldFollow = parts[1] == "on"
    end
end

function mb_RequestBuffsModeRequestHandler(request)
    mb_shouldRequestBuffs = request.body == "on"
end

function mb_GoldDistributionRequestHandler(request)
    if request.from == UnitName("player") then
        return
    end
    if request.from ~= mb_GetMyCommanderName() then
        return
    end
    if not CheckInteractDistance(max_GetUnitForPlayerName(request.from), 2) then
        return
    end
    if GetMoney() > 400000 then
        mb_AcceptRequest(request)
    end
    if GetMoney() < 200000 then
        mb_AcceptRequest(request)
    end
end

function mb_MoveOutModuleRequestHandler(request)
    if request.from == mb_GetMyCommanderName() then
        local parts = max_SplitString(request.body, "/")
        if parts[1] == "on" then
            mb_MoveOutModule_Enable()
        else
            mb_MoveOutModule_Disable()
        end
    end
end

function mb_FuckOffRequestHandler(request)
    if request.body == UnitName("player") then
        mb_shouldFuckOffAt = mb_GetTime()
        mb_shouldFollow = false
        max_SayRaid("I'm fucking off!")
    end
end

mb_createClassSyncDataFunction = nil
mb_classSyncDataReceivedFunction = nil
function mb_RegisterClassSyncDataFunctions(createDataFunction, syncDataReceivedFunction)
    mb_createClassSyncDataFunction = createDataFunction
    mb_classSyncDataReceivedFunction = syncDataReceivedFunction
end

function mb_ClassSyncRequestHandler(request)
    if request.from == UnitName("player") then
        return
    end
    if mb_IsClassLeader() then
        if mb_createClassSyncDataFunction == nil then
            mb_classSyncData = ""
        else
            mb_classSyncData = mb_createClassSyncDataFunction()
            mb_classSyncDataReceivedFunction()
        end
        mb_MakeRequest(max_GetClass("player") .. "Sync", mb_classSyncData, REQUEST_PRIORITY.CLASS_SYNC)
    elseif request.body ~= "needSync" then
        mb_classSyncData = request.body
        if mb_classSyncDataReceivedFunction ~= nil then
            mb_classSyncDataReceivedFunction()
        end
    end
end

function mb_RemoteExecuteRequestHandler(request)
    if request.from == mb_GetMyCommanderName() then
        local code = request.body
        local func = loadstring(code)
        if func == nil then
            max_SayRaid("Bad Code: " .. code)
        else
            func()
        end
    end
end

function mb_RepairReportRequestHandler(request)
    local requiredPercentage = tonumber(request.body)
    local lowestDurability = mb_GetLowestDurabilityPercentage()
    if lowestDurability < requiredPercentage then
        max_SayRaid("I'm at " .. lowestDurability .. "% durability.")
    end
end

function mb_GetDurabilityPercentageForItemSlot(itemSlot)
    MaloWBotToolTip:SetOwner(UIParent, "ANCHOR_NONE")
    MaloWBotToolTip:ClearLines()
    MaloWBotToolTip:SetInventoryItem("player", itemSlot)
    for i = 1, 10 do
        local line = getglobal("MaloWBotToolTipTextLeft" .. i):GetText()
        if line ~= nil then
            local percentage = mb_GetDurabilityPercentageFromLine(line)
            if percentage ~= nil then
                return percentage
            end
        end
    end
    return nil
end

function mb_GetDurabilityPercentageFromLine(line)
    local start = string.find(line, "Durability %d+ / %d+")
    if start == nil then
        return nil
    end
    line = string.sub(line, 12)
    local slashPos = string.find(line, "/")
    local firstPart = string.sub(line, 1, slashPos - 1)
    local secondPart = string.sub(line, slashPos + 2, string.len(line))
    return (tonumber(firstPart) / tonumber(secondPart)) * 100
end