function mb_BossModule_Lucifron_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_Lucifron_Unload
    mb_currentBossModule.priestLogic = mb_BossModule_Lucifron_PriestLogic
    mb_currentBossModule.paladinLogic = mb_BossModule_Lucifron_PaladinLogic
    if max_GetClass("player") == "PALADIN" then
        mb_Paladin_CastAura("devo")
    end
end
mb_RegisterBossModule("lucifron", mb_BossModule_Lucifron_Load)

function mb_BossModule_Lucifron_Unload()

end

function mb_BossModule_Lucifron_PriestLogic()
    local unit = mb_BossModule_Lucifron_FindMindControlledUnit()
    if unit ~= nil then
        max_CastSpellOnRaidMember("Dispel Magic", unit)
        return true
    end
    return false
end

function mb_BossModule_Lucifron_PaladinLogic()
    local unit = mb_BossModule_Lucifron_FindMindControlledUnit()
    if unit ~= nil then
        max_CastSpellOnRaidMember("Cleanse", unit)
        return true
    end
    return false
end

function mb_BossModule_Lucifron_FindMindControlledUnit()
    local members = max_GetNumPartyOrRaidMembers()
    for i = 1, members do
        local unit = max_GetUnitFromPartyOrRaidIndex(i)
        if max_CanAttackUnit(unit) then
            return unit
        end
    end
    return nil
end