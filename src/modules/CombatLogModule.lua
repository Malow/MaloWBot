local f = CreateFrame("frame", "MaloWBotCombatLogModuleFrame", UIParent)
f:Show()

mb_CombatLogModule_DTPSEnabled = false
mb_CombatLogModule_FriendlyGainsEnabled = false
mb_CombatLogModule_damageTakenLog = {}
function mb_CombatLogModule_OnEvent()
    if event == "PLAYER_REGEN_DISABLED" then
        mb_CombatLogModule_damageTakenLog = {}
    elseif event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS" or event == "CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE" or event == "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE" then
        mb_CombatLogModule_damageTakenLog[GetTime()] = mb_CombatLogModule_ExtractDamage(arg1)
    elseif event == "CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS" or event == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS" then
        local spellName = mb_CombatLogModule_ExtractFriendlyGainsName(arg1)
        if spellName ~= nil then
            -- Maybe do something in the future
        end
    else
        mb_Print("Error in CombatLogModule, missed event: " .. event .. " (" .. arg1 .. ")")
    end
end
f:SetScript("OnEvent", mb_CombatLogModule_OnEvent)

function mb_CombatLogModule_ExtractDamage(str)
    local start = string.find(arg1, "for %d+") -- Hits you for X
    if start == nil then
        start = string.find(arg1, "fer %d+") -- You suffer X
        if start == nil then
            return 0
        end
    end
    local firstPartRemoved = string.sub(str, start + 4)
    local stop = string.find(firstPartRemoved, "[ .]")
    return tonumber(string.sub(firstPartRemoved, 1, stop))
end

function mb_CombatLogModule_ExtractFriendlyGainsName(str)
    local start = string.find(arg1, "gain %a+") -- You gain
    if start == nil then
        start = string.find(arg1, "ains %a+") -- X gains
        if start == nil then
            return 0
        end
    end
    local firstPartRemoved = string.sub(str, start + 5)
    return string.sub(firstPartRemoved, 1, string.len(firstPartRemoved) - 1)
end

function mb_CombatLogModule_GetDTPS(averageOverPastSeconds)
    local damageTaken = 0
    local now = GetTime()
    for k, v in pairs(mb_CombatLogModule_damageTakenLog) do
        if k > now - averageOverPastSeconds then
            damageTaken = damageTaken + v
        end
    end
    return damageTaken / averageOverPastSeconds
end

function mb_CombatLogModule_EnableDTPS()
    if mb_CombatLogModule_DTPSEnabled then
        return
    end
    f:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS")
    f:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE")
    f:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")
    f:RegisterEvent("PLAYER_REGEN_DISABLED")
    mb_CombatLogModule_DTPSEnabled = true
end

function mb_CombatLogModule_EnableFriendlyGainsTracker()
    if mb_CombatLogModule_FriendlyGainsEnabled then
        return
    end
    f:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS")
    f:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
    mb_CombatLogModule_FriendlyGainsEnabled = true
end
