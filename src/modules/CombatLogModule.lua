mb_CombatLogModule_Frame = CreateFrame("frame", "MaloWBotCombatLogModuleFrame", UIParent)
mb_CombatLogModule_Frame:Show()

mb_CombatLogModule_callbacks = {}
function mb_CombatLogModule_OnEvent()
    if mb_CombatLogModule_callbacks[event] ~= nil then
        for k, v in pairs(mb_CombatLogModule_callbacks[event]) do
            v(arg1)
        end
    end
end
mb_CombatLogModule_Frame:SetScript("OnEvent", mb_CombatLogModule_OnEvent)

function mb_CombatLogModule_AddCallback(eventName, func)
    if mb_CombatLogModule_callbacks[eventName] == nil then
        mb_CombatLogModule_callbacks[eventName] = {}
        mb_CombatLogModule_Frame:RegisterEvent(eventName)
    end
    table.insert(mb_CombatLogModule_callbacks[eventName], func)
end

--- Extractors, extracts a specific part of a string
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

function mb_CombatLogModule_ExtractGainsSpellName(str)
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