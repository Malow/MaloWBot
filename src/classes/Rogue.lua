function mb_Rogue(commander)
    AssistByName(commander)
    CastSpellByName("attack")
    CastSpellByName("Hemorrhage")
end
 
function mb_Rogue_OnLoad()
	mb_Rogue_AddDesiredTalent()
    table.insert(mb_desiredBuffs, BUFF_POWER_WORD_FORTITUDE)
    --table.insert(mb_desiredBuffs, BUFF_MARK_OF_THE_WILD)
    --table.insert(mb_desiredBuffs, BUFF_BLESSING_OF_MIGHT)
end

function mb_Rogue_AddDesiredTalents()
    mb_AddDesiredTalent(3, 1, 5) -- Master of Deception 5
    mb_AddDesiredTalent(3, 3, 2) -- Sleight of Hand 7
    mb_AddDesiredTalent(3, 4, 2) -- Elusiveness 9
    mb_AddDesiredTalent(3, 5, 5) -- Camouflage 14
    mb_AddDesiredTalent(3, 7, 1) -- Ghostly Strike 15
    mb_AddDesiredTalent(3, 9, 3) -- Setup 18
    mb_AddDesiredTalent(3, 11, 3) -- Serrated Blades 21
    mb_AddDesiredTalent(3, 15, 1) -- Hemorrhage 22
    mb_AddDesiredTalent(1, 3, 5) -- Malice 27
    mb_AddDesiredTalent(1, 5, 2) -- Murder 29
    mb_AddDesiredTalent(1, 6, 3) -- Imp. Slice and Dice 32
    mb_AddDesiredTalent(1, 8, 3) -- Imp. Expose Armor 35
end