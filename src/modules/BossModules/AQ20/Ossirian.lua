function mb_BossModule_Ossirian_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_Ossirian_Unload
    mb_currentBossModule.warriorTankLogic = mb_BossModule_Ossirian_WarriorTankLogic
    mb_HealingModule_overhealCoef = 0.2
    mb_warlockIsCursingElements = false
    mb_warlockIsCursingShadow = false
    mb_warlockIsCursingRecklessness = true
    if max_GetClass("player") == "PALADIN" then
        mb_Paladin_CastAura("ret")
    end
end
mb_RegisterBossModule("ossirian", mb_BossModule_Ossirian_Load)

function mb_BossModule_Ossirian_Unload()
    mb_HealingModule_overhealCoef = 1.0
end

function mb_BossModule_Ossirian_WarriorTankLogic()
    if max_GetActiveStance() == 2 then
        if not max_IsSpellNameOnCooldown("Shield Block") then
            CastSpellByName("Shield Block")
            return true
        end
    end
    return false
end