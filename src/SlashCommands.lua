
function mb_HandleSpecialSlashCommand(msg)
    if msg == "r" then
        mb_MakeRequest("reload", "reload")
        ReloadUI()
    elseif msg == "trademegreys" then
        mb_MakeRequest("trademegreys", UnitName("player"))
    elseif msg == "trademegoodies" then
        mb_MakeRequest("trademegoodies", UnitName("player"))
    elseif msg == "train" then
        mb_TrainAll()
    elseif msg == "summon" then
        mb_MakeRequest("summon", UnitName("target"))
    elseif msg == "hearthstone" then
        mb_MakeRequest("hearthstone", "hearthstone")
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