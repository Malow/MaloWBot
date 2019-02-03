function mb_BossModule_Azuregos_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_Azuregos_Unload
    mb_currentBossModule.priestLogic = mb_BossModule_Azuregos_PriestLogic
    mb_currentBossModule.paladinLogic = mb_BossModule_Azuregos_PaladinLogic
    mb_shouldDispel = false
    mb_warriorShouldAutomaticallyTaunt = false
    mb_MakeRequest("palaAura", "frost", REQUEST_PRIORITY.COMMAND)
end
mb_RegisterBossModule("azuregos", mb_BossModule_Azuregos_Load)

function mb_BossModule_Azuregos_Unload()
    mb_shouldDispel = true
    mb_warriorShouldAutomaticallyTaunt = true
end

function mb_BossModule_Azuregos_PriestLogic()
    if mb_CleanseRaidMemberThrottled("Dispel Magic", "Magic", nil, nil, UNIT_FILTER_DOES_NOT_HAVE_MANA, true) then
        return true
    end
    return false
end

function mb_BossModule_Azuregos_PaladinLogic()
    if mb_CleanseRaidMemberThrottled("Cleanse", "Magic", "Poison", "Disease", UNIT_FILTER_DOES_NOT_HAVE_MANA, true) then
        return true
    end
    return false
end