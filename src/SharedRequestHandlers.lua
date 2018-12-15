function mb_RegisterSharedRequestHandlers()
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
end

function mb_ReloadRequestHandler(request)
    if request.from ~= UnitName("player") then
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
    if request.from == mb_GetConfig()["followTarget"] then
        mb_shouldFollow = request.body == "on"
    end
end

function mb_RequestBuffsModeRequestHandler(request)
    mb_shouldRequestBuffs = request.body == "on"
end