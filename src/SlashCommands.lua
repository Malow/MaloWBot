function mb_HandleSpecialSlashCommand(msg)
    if msg == "r" then
        mb_MakeRequest("reload", "reload", 10)
        ReloadUI()
    elseif msg == "trademegoodies" or msg == "tradeMeGoodies" then
        mb_MakeRequest("trademegoodies", UnitName("player"), 10)
    elseif msg == "inventoryDump" then
        mb_MakeRequest("inventoryDump", UnitName("player"), 10)
    elseif msg == "summon" then
        mb_MakeRequest("summon", UnitName("target"), 10)
    elseif msg == "soulstone" then
        mb_MakeRequest("soulstone", UnitName("target"), 10)
    elseif msg == "hearthstone" then
        mb_MakeRequest("hearthstone", "hearthstone", 10)
    elseif msg == "mount" then
        mb_MakeRequest("mount", "mount", 10)
    elseif msg == "releaseCorpse" then
        mb_MakeRequest("releaseCorpse", "releaseCorpse", 10)
    elseif string.find(msg, "haveQuest") then
        local questLogId = GetQuestLogSelection()
        local questName = GetQuestLogTitle(questLogId)
        mb_MakeRequest("haveQuest", questName, 10)
    elseif string.find(msg, "aoe") then
        local mode = max_SplitString(msg, " ")[2]
        mb_areaOfEffectMode = mode == "on"
        mb_MakeRequest("areaOfEffectMode", mode, 10)
    elseif string.find(msg, "doesNotHaveQuest") then
        local questLogId = GetQuestLogSelection()
        local questName = GetQuestLogTitle(questLogId)
        mb_MakeRequest("doesNotHaveQuest", questName, 10)
    elseif string.find(msg, "follow") then
        local mode = max_SplitString(msg, " ")[2]
        mb_shouldFollow = mode == "on"
        mb_MakeRequest("followMode", mode, 10)
    elseif string.find(msg, "requestBuffs") then
        local mode = max_SplitString(msg, " ")[2]
        mb_shouldFollow = mode == "on"
        mb_MakeRequest("requestBuffsMode", mode, 10)
    elseif msg == "fixraidgroup" or msg == "fixRaidGroup" then
        if not IsPartyLeader() then
            mb_MakeRequest("promoteLeader", "promoteLeader", 10)
        else
            local members = max_GetNumPartyOrRaidMembers()
            for i = 1, members do
                local unit = max_GetUnitFromPartyOrRaidIndex(i)
                PromoteToAssistant(UnitName(unit))
            end
        end
        for i = 1, 40 do
            local name, rank, rankIndex, level, class, zone, group, note, officernote, online = GetGuildRosterInfo(i)
            if name ~= nil then
                InviteByName(name)
            end
        end
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