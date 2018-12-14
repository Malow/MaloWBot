function mb_Rogue(commander)
    AssistByName(commander)
    CastSpellByName("attack")
	if GetComboPoints() == 4 then
	    CastSpellByName("Slice and Dice")
		return
	end
    CastSpellByName("Sinister Strike")
end

function mb_Rogue_OnLoad()
    mb_Rogue_AddDesiredTalents()
    mb_AddDesiredBuff(BUFF_MARK_OF_THE_WILD)
    mb_AddDesiredBuff(BUFF_POWER_WORD_FORTITUDE)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_MIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_KINGS)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_LIGHT)
    mb_AddDesiredBuff(BUFF_BLESSING_OF_SALVATION)
end

function mb_Rogue_AddDesiredTalents()
    if UnitLevel("player") == 60 then
        -- Raiding Spec
        mb_AddDesiredTalent(1, 1, 2) --Imp. Evisc
        mb_AddDesiredTalent(1, 3, 5) -- Malice
        mb_AddDesiredTalent(1, 4, 3) -- Ruthlessness
        mb_AddDesiredTalent(1, 5, 2) -- Murder
        mb_AddDesiredTalent(1, 6, 3) -- Imp. SnD
        mb_AddDesiredTalent(1, 7, 1) -- Relentless Strikes
        mb_AddDesiredTalent(1, 9, 3) -- Lethality 3/5
        mb_AddDesiredTalent(2, 2, 2) -- Imp. Sinister Strike
        mb_AddDesiredTalent(2, 3, 5) -- Dodge
        mb_AddDesiredTalent(2, 6, 5) -- 5% Hit
        mb_AddDesiredTalent(2, 7, 2) -- Endurance
        mb_AddDesiredTalent(2, 9, 1) -- Imp. Sprint
        mb_AddDesiredTalent(2, 12, 5) -- Imp. Dual-Wield
        mb_AddDesiredTalent(2, 14, 1) -- Blade Flurry
        mb_AddDesiredTalent(2, 15, 5) -- Sword Spec
        mb_AddDesiredTalent(2, 17, 2) -- Expertise
        mb_AddDesiredTalent(2, 18, 3) -- Aggression
        mb_AddDesiredTalent(2, 19, 1) -- Adrenaline Rush
    else
        -- Leveling Spec
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
end