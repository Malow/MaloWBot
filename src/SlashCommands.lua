function mb_HandleSpecialSlashCommand(msg)
    if msg == "r" then
        mb_MakeRequest("reload", "reload", REQUEST_PRIORITY.COMMAND)
        ReloadUI()
    elseif msg == "trademegoodies" or msg == "tradeMeGoodies" then
        if mb_isTrading then
            AcceptTrade()
        else
            mb_MakeRequest("trademegoodies", UnitName("player"), REQUEST_PRIORITY.COMMAND)
        end
    elseif msg == "inventoryDump" then
        if mb_isTrading then
            if GetTradePlayerItemLink(1) ~= nil then
                AcceptTrade()
            else
                local count = 0
                for bag = 0, 4 do
                    for slot = 1, GetContainerNumSlots(bag) do
                        local t = GetContainerItemInfo(bag, slot)
                        if t ~= nil then
                            UseContainerItem(bag, slot)
                            count = count + 1
                            if count == 6 then
                                return
                            end
                        end
                    end
                end
            end
        else
            mb_MakeRequest("inventoryDump", UnitName("player"), REQUEST_PRIORITY.COMMAND)
        end
    elseif msg == "summon" then
        mb_MakeRequest("summon", UnitName("target"), REQUEST_PRIORITY.COMMAND)
    elseif msg == "soulstone" then
        mb_MakeRequest("soulstone", UnitName("target"), REQUEST_PRIORITY.COMMAND)
    elseif msg == "healthstone" then
        if UnitExists("target") then
            if max_GetRaidIndexForPlayerName(UnitName("target")) ~= nil then
                mb_MakeRequest("healthstone", UnitName("target"), REQUEST_PRIORITY.COMMAND)
            end
        end
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
        local target = UnitName("player")
        if UnitExists("target") and not UnitIsUnit("player", "target") then
            if max_GetRaidIndexForPlayerName(UnitName("target")) ~= nil then
                target = UnitName("target")
            end
        end
        mb_MakeRequest("fearWard", target, REQUEST_PRIORITY.COMMAND)
    elseif msg == "interrupt" then
        mb_MakeRequest(REQUEST_INTERRUPT.type, "interrupt", REQUEST_PRIORITY.COMMAND)
    elseif msg == "crowdControl" then
        mb_MakeRequest(REQUEST_CROWD_CONTROL.type, "crowdControl", REQUEST_PRIORITY.COMMAND)
    elseif msg == "tranquilize" then
        mb_MakeThrottledRequest(REQUEST_TRANQUILIZING_SHOT, "tranqItYoBeastBeCrazy", REQUEST_PRIORITY.COMMAND)
    elseif msg == "goToMaxRange" then
        mb_MakeRequest("goToMaxRange", "goToMaxRange", REQUEST_PRIORITY.COMMAND)
    elseif msg == "useConsumable" then
        mb_MakeRequest("useConsumable", "useConsumable", REQUEST_PRIORITY.COMMAND)
    elseif msg == "berserkerRage" then
        mb_MakeRequest("berserkerRage", "berserkerRage", REQUEST_PRIORITY.COMMAND)
    elseif string.find(msg, "bossModule") then
        local module = max_SplitString(msg, " ")[2]
        mb_MakeRequest("bossModule", tostring(module), REQUEST_PRIORITY.COMMAND)
    elseif string.find(msg, "consumablesLevel") then
        local level = max_SplitString(msg, " ")[2]
        mb_MakeRequest("consumablesLevel", tostring(level), REQUEST_PRIORITY.COMMAND)
    elseif string.find(msg, "usePoison") then
        local mode = max_SplitString(msg, " ")[2]
        mb_areaOfEffectMode = mode == "on"
        mb_MakeRequest("usePoison", mode, REQUEST_PRIORITY.COMMAND)
    elseif string.find(msg, "palaAura") then
        local aura = max_SplitString(msg, " ")[2]
        mb_MakeRequest("palaAura", aura, REQUEST_PRIORITY.COMMAND)
    elseif string.find(msg, "repairReport") then
        local percentage = max_SplitString(msg, " ")[2]
        if percentage == nil then
            percentage = 100
        end
        mb_MakeRequest("repairReport", percentage, REQUEST_PRIORITY.COMMAND)
        mb_DoRepairReport(tonumber(percentage))
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
        if UnitExists("target") and not UnitIsUnit("player", "target") then
            if max_GetRaidIndexForPlayerName(UnitName("target")) ~= nil then
                requestBody = requestBody .. "/" .. UnitName("target")
            end
        end
        mb_MakeRequest("followMode", requestBody, REQUEST_PRIORITY.COMMAND)
    elseif string.find(msg, "requestBuffs") then
        local mode = max_SplitString(msg, " ")[2]
        mb_shouldRequestBuffs = mode == "on"
        mb_MakeRequest("requestBuffsMode", mode, REQUEST_PRIORITY.COMMAND)
    elseif string.find(msg, "remoteExecute") then
        local code = string.sub(msg, 15)
        mb_MakeRequest("remoteExecute", code, REQUEST_PRIORITY.COMMAND)
    elseif msg == "fixraidgroup" or msg == "fixRaidGroup" then
        mb_FixRaidGroup()
    elseif msg == "debugRequests" then
        mb_Print("Queued confirmed requests: " .. max_GetTableSize(mb_queuedRequests) .. "x")
        for k, v in pairs(mb_queuedRequests) do
            mb_Print("    " .. tostring(v.type) .. " by " .. tostring(v.from) .. " with priority " .. tostring(v.priority) .. " and body " .. tostring(v.body))
        end
        mb_Print("Requests that I've accepted but not yet confirmed: " .. max_GetTableSize(mb_myAcceptedRequests) .. "x")
        for k, v in pairs(mb_myAcceptedRequests) do
            mb_Print("    " .. tostring(v.type) .. " by " .. tostring(v.from) .. " with priority " .. tostring(v.priority) .. " and body " .. tostring(v.body))
        end
        mb_Print("Incoming MB-Comms: " .. max_GetTableSize(mb_queuedIncomingComms) .. "x")
        for k, v in pairs(mb_queuedIncomingComms) do
            mb_Print("    " .. tostring(v.type) .. " by " .. tostring(v.from) .. " with priority " .. tostring(v.priority) .. " and body " .. tostring(v.body))
        end
        mb_Print("Pending outgoing requests: " .. max_GetTableSize(mb_myPendingRequests) .. "x")
        for k, v in pairs(mb_myPendingRequests) do
            mb_Print("    " .. tostring(v.type) .. " with priority " .. tostring(v.priority) .. " and body " .. tostring(v.body) .. ". Sent at " .. tostring(v.sentTime))
        end
    else
        mb_Print("Command \"" .. msg .. "\" not recognized.")
        return false
    end
    return true
end

function mb_FixRaidGroup()
    local members = max_GetNumPartyOrRaidMembers()
    if members < 40 then
        for i = 1, 100 do
            local name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i)
            if name ~= nil and online == 1 then
                InviteByName(name)
                if members == 0 then
                    return
                end
            end
        end
        return
    end
    if not IsPartyLeader() then
        mb_MakeRequest("promoteLeader", "promoteLeader", REQUEST_PRIORITY.COMMAND)
    else
        if not UnitInRaid("player") then
            ConvertToRaid()
            return
        end
        SetLootMethod("freeforall")
        for i = 1, members do
            local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i)
            if rank == 0 then
                local unit = max_GetUnitFromPartyOrRaidIndex(i)
                PromoteToAssistant(UnitName(unit))
            end
        end
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