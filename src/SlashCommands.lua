function mb_HandleSpecialSlashCommand(msg)
    if msg == "r" then
        mb_MakeRequest("reload", "reload", REQUEST_PRIORITY.COMMAND)
        ReloadUI()
    elseif msg == "trademegoodies" or msg == "tradeMeGoodies" then
        mb_MakeRequest("trademegoodies", UnitName("player"), REQUEST_PRIORITY.COMMAND)
    elseif msg == "inventoryDump" then
        mb_MakeRequest("inventoryDump", UnitName("player"), REQUEST_PRIORITY.COMMAND)
    elseif msg == "summon" then
        mb_MakeRequest("summon", UnitName("target"), REQUEST_PRIORITY.COMMAND)
    elseif msg == "soulstone" then
        mb_MakeRequest("soulstone", UnitName("target"), REQUEST_PRIORITY.COMMAND)
    elseif msg == "healthstone" then
        mb_MakeRequest("healthstone", UnitName("target"), REQUEST_PRIORITY.COMMAND)
    elseif msg == "hearthstone" then
        mb_MakeRequest("hearthstone", "hearthstone", REQUEST_PRIORITY.COMMAND)
    elseif msg == "mount" then
        mb_MakeRequest("mount", "mount", REQUEST_PRIORITY.COMMAND)
    elseif msg == "releaseCorpse" then
        mb_MakeRequest("releaseCorpse", "releaseCorpse", REQUEST_PRIORITY.COMMAND)
    elseif msg == "haveQuest" then
        mb_MakeRequest("haveQuest", GetQuestLogTitle(GetQuestLogSelection()), REQUEST_PRIORITY.COMMAND)
    elseif msg == "doesNotHaveQuest" then
        mb_MakeRequest("doesNotHaveQuest", GetQuestLogTitle(GetQuestLogSelection()), REQUEST_PRIORITY.COMMAND)
    elseif msg == "goldDistribution" then
        mb_MakeRequest("goldDistribution", "goldDistribution", REQUEST_PRIORITY.COMMAND)
    elseif msg == "fearWard" then
        mb_MakeRequest("fearWard", UnitName("target"), REQUEST_PRIORITY.COMMAND)
    elseif msg == "interrupt" then
        mb_MakeRequest(REQUEST_INTERRUPT.type, "interrupt", REQUEST_PRIORITY.COMMAND)
    elseif msg == "fuckOff" then
        local target = UnitName("target")
        if UnitIsEnemy("player", "target") then
            target = UnitName("targettarget")
        end
        mb_MakeRequest("fuckOff", target, REQUEST_PRIORITY.COMMAND)
    elseif string.find(msg, "aoe") then
        local mode = max_SplitString(msg, " ")[2]
        mb_areaOfEffectMode = mode == "on"
        mb_MakeRequest("areaOfEffectMode", mode, REQUEST_PRIORITY.COMMAND)
    elseif string.find(msg, "moveOutModule") then
        local mode = max_SplitString(msg, " ")[2]
        if mode == "on" then
            mb_MoveOutModule_Enable()
        else
            mb_MoveOutModule_Disable()
        end
        mb_MakeRequest("moveOutModule", mode, REQUEST_PRIORITY.COMMAND)
    elseif string.find(msg, "follow") then
        local mode = max_SplitString(msg, " ")[2]
        mb_shouldFollow = mode == "on"
        local requestBody = mode
        if UnitExists("target") then
            if max_GetRaidIndexForPlayerName(UnitName("target")) ~= nil then
                requestBody = requestBody .. "/" .. UnitName("target")
            end
        end
        mb_MakeRequest("followMode", requestBody, REQUEST_PRIORITY.COMMAND)
    elseif string.find(msg, "requestBuffs") then
        local mode = max_SplitString(msg, " ")[2]
        mb_shouldRequestBuffs = mode == "on"
        mb_MakeRequest("requestBuffsMode", mode, REQUEST_PRIORITY.COMMAND)
    elseif msg == "fixraidgroup" or msg == "fixRaidGroup" then
        mb_FixRaidGroup()
    elseif msg == "debugRequests" then
        mb_Print("Queued Requests: " .. max_GetTableSize(mb_queuedRequests) .. "x")
        for k, v in pairs(mb_queuedRequests) do
            mb_Print("    " .. v.type .. " by " .. v.from .. " with priority " .. v.priority .. " and body " .. v.body )
        end
        mb_Print("Outgoing Accepts: " .. max_GetTableSize(mb_myAcceptedRequests) .. "x")
        for k, v in pairs(mb_myAcceptedRequests) do
            mb_Print("    " .. v.type .. " by " .. v.from .. " with priority " .. v.priority .. " and body " .. v.body )
        end
        mb_Print("Incoming Accepted Confirmed Queued Requests: " .. max_GetTableSize(mb_queuedIncomingRequests) .. "x")
        for k, v in pairs(mb_queuedIncomingRequests) do
            mb_Print("    " .. v.type .. " by " .. v.from .. " with priority " .. v.priority .. " and body " .. v.body )
        end
        mb_Print("Pending Outgoing Queued Requests: " .. max_GetTableSize(mb_myPendingRequests) .. "x")
        for k, v in pairs(mb_myPendingRequests) do
            mb_Print("    " .. v.type .. " with priority " .. v.priority .. " and body " .. v.body .. ". Sent at " .. v.sentTime)
        end
    else
        return false
    end
    return true
end

function mb_FixRaidGroup()
    if not IsPartyLeader() then
        mb_MakeRequest("promoteLeader", "promoteLeader", REQUEST_PRIORITY.COMMAND)
        return
    end
    local members = max_GetNumPartyOrRaidMembers()
    for i = 1, members do
        local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i)
        if rank == 0 then
            local unit = max_GetUnitFromPartyOrRaidIndex(i)
            PromoteToAssistant(UnitName(unit))
        end
    end
    if members < 40 then
        for i = 1, 100 do
            local name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i)
            if name ~= nil and online == 1 then
                InviteByName(name)
            end
        end
        return
    end

    for i = 1, members do
        local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i)
        local desiredSubgroup = mb_GetDesiredSubgroupForPlayerName(name)
        if desiredSubgroup == nil then
            max_SayRaid("Error, couldn't find desired subgroup for player: " .. name)
            return
        end
        if desiredSubgroup ~= subgroup then
            local swapTargets = max_GetPlayerNamesInSubgroup(desiredSubgroup)
            for k, swapName in pairs(swapTargets) do
                if mb_GetDesiredSubgroupForPlayerName(swapName) ~= desiredSubgroup then
                    SwapRaidSubgroup(max_GetRaidIndexForPlayerName(name), max_GetRaidIndexForPlayerName(swapName))
                    return
                end
            end
        end
    end
end

function mb_GetDesiredSubgroupForPlayerName(playerName)
    local groupNumber = 1
    for k, group in pairs(mb_GetConfig()["groupConfiguration"]) do
        for k, name in pairs(group) do
            if name == playerName then
                return groupNumber
            end
        end
        groupNumber = groupNumber + 1
    end
    return nil
end