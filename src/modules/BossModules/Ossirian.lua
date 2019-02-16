function mb_BossModule_Ossirian_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_Ossirian_Unload
    mb_currentBossModule.warriorTankLogic = mb_BossModule_Ossirian_WarriorTankLogic
    mb_HealingModule_overhealCoef = 0.3
end
mb_RegisterBossModule("ossirian", mb_BossModule_Ossirian_Load)

function mb_BossModule_Ossirian_Unload()
    mb_HealingModule_overhealCoef = 1.0
end

function mb_BossModule_Ossirian_WarriorTankLogic()
    if not max_IsSpellNameOnCooldown("Shield Block") then
        CastSpellByName("Shield Block")
        return true
    end
    return false
end