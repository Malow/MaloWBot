function mb_HandleSpecialSlashCommand(msg)
    if msg == "r" then
        mb_MakeRequest("reload", "reload")
        ReloadUI()
    elseif msg == "trademegreys" then
        mb_MakeRequest("trademegreys", UnitName("player"))
    elseif msg == "trademegoodies" then
        mb_MakeRequest("trademegoodies", UnitName("player"))
    elseif msg == "inventoryDump" then
        mb_MakeRequest("inventoryDump", UnitName("player"))
    elseif msg == "summon" then
        mb_MakeRequest("summon", UnitName("target"))
    elseif msg == "hearthstone" then
        mb_MakeRequest("hearthstone", "hearthstone")
    elseif msg == "mount" then
        mb_MakeRequest("mount", "mount")
    elseif msg == "releaseCorpse" then
        mb_MakeRequest("releaseCorpse", "releaseCorpse")
    elseif string.find(msg, "haveQuest") then
        local questLogId = GetQuestLogSelection()
        local questName = GetQuestLogTitle(questLogId)
        mb_MakeRequest("haveQuest", questName)
    elseif string.find(msg, "aoe") then
        local mode = max_SplitString(msg, " ")[2]
        mb_areaOfEffectMode = mode == "on"
        mb_MakeRequest("areaOfEffectMode", mode)
    elseif string.find(msg, "doesNotHaveQuest") then
        local questLogId = GetQuestLogSelection()
        local questName = GetQuestLogTitle(questLogId)
        mb_MakeRequest("doesNotHaveQuest", questName)
    elseif msg == "fixraidgroup" then
        if not IsPartyLeader() then
            mb_MakeRequest("promoteLeader", "promoteLeader")
        end
        for i = 1, 40 do
            local name, rank, rankIndex, level, class, zone, group, note, officernote, online = GetGuildRosterInfo(i)
            if name ~= nil then
                InviteByName(name)
            end
        end
    else
        return false
    end
    return true
end