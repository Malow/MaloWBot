function mb_BossModule_Jeklik_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_Jeklik_Unload
    mb_currentBossModule.mageLogic = mb_BossModule_Jeklik_MageLogic
    if max_GetClass("player") == "PALADIN" then
        mb_Paladin_CastAura("fire")
    end
end
mb_RegisterBossModule("jeklik", mb_BossModule_Jeklik_Load)

function mb_BossModule_Jeklik_Unload()
end

function mb_BossModule_Jeklik_MageLogic()
    if UnitClassification("target") == "worldboss" then
        if max_GetHealthPercentage("target") < 50 then
            if max_CastSpellIfReady("Fire Ward") then
                return true
            end
        end
    end
    return false
end