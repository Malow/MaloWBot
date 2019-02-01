
mb_toolTip = CreateFrame("GameTooltip", "MaloWBotToolTip", UIParent, "GameTooltipTemplate")

function mb_GetToolTipLineContaining(searchText, baseTextObject)
    for i = 1, 10 do
        local line = getglobal(baseTextObject .. i):GetText()
        if line ~= nil and string.find(line, searchText) then
            return line
        end
    end
    return nil
end

function mb_IsItemSoulbound(bag, slot)
    MaloWBotToolTip:SetOwner(UIParent, "ANCHOR_NONE")
    MaloWBotToolTip:ClearLines()
    MaloWBotToolTip:SetBagItem(bag, slot)
    if mb_GetToolTipLineContaining("Soulbound", "MaloWBotToolTipTextLeft") ~= nil then
        return true
    end
    return false
end

function mb_IsItemQuestItem(bag, slot)
    MaloWBotToolTip:SetOwner(UIParent, "ANCHOR_NONE")
    MaloWBotToolTip:ClearLines()
    MaloWBotToolTip:SetBagItem(bag, slot)
    if mb_GetToolTipLineContaining("Quest Item", "MaloWBotToolTipTextLeft") ~= nil then
        return true
    end
    return false
end

function mb_GetSpellRange(actionSlot)
    MaloWBotToolTip:SetOwner(UIParent, "ANCHOR_NONE")
    MaloWBotToolTip:ClearLines()
    MaloWBotToolTip:SetAction(actionSlot)
    local line = mb_GetToolTipLineContaining("yd range", "MaloWBotToolTipTextRight")
    if line ~= nil then
        local spacePos = string.find(line, " ")
        local range = tonumber(string.sub(line, 1, spacePos - 1))
        return range
    end
    return nil
end

function mb_GetDurabilityPercentageFromLine(line)
end

function mb_GetLowestDurabilityPercentage()
    local durabilitySlots = { 1, 3, 5, 6, 7, 8, 9, 10, 16, 17, 18 }
    local lowestDurability = 100
    for _, v in pairs(durabilitySlots) do
        local percentage = mb_GetDurabilityPercentageForItemSlot(v)
        if percentage ~= nil then
            if percentage < lowestDurability then
                lowestDurability = percentage
            end
        end
    end
    return lowestDurability
end

function mb_GetDurabilityPercentageForItemSlot(itemSlot)
    MaloWBotToolTip:SetOwner(UIParent, "ANCHOR_NONE")
    MaloWBotToolTip:ClearLines()
    MaloWBotToolTip:SetInventoryItem("player", itemSlot)
    local line = mb_GetToolTipLineContaining("Durability %d+ / %d+", "MaloWBotToolTipTextLeft")
    if line ~= nil then
        line = string.sub(line, 12)
        local slashPos = string.find(line, "/")
        local firstPart = string.sub(line, 1, slashPos - 1)
        local secondPart = string.sub(line, slashPos + 2, string.len(line))
        return (tonumber(firstPart) / tonumber(secondPart)) * 100
    end
    return nil
end