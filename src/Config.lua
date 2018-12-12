--- Default values, do not change these unless you want them to apply to everyone
--- If you want to change them just for yourself add them to the PersonalizedConfig.lua instead.
function mb_GetConfig()
    local config = mb_GetPersonalizedConfig()
    if config["followTarget"] == nil then
        config["followTarget"] = "Malow"
    end
    if config["autoLearnTalents"] == nil then
        config["autoLearnTalents"] = false
    end
    if config["autoTrainSpells"] == nil then
        config["autoTrainSpells"] = true -- Automatically train all class and profession skills when Gossip-panel is opened for an NPC that can teach you something.
    end
    config["specs"] = {}
    config["specs"]["Kaladin"] = "RetLight"
    config["specs"]["Malow"] = "SanctuarySalvation"
    config["specs"]["Rosita"] = "KingsJudge"
    config["specs"]["Madeleina"] = "Wisdom"
    config["specs"]["Skyler"] = "MightJudge"
    config["specs"]["Hardrac"] = "Holy"
    config["specs"]["Bondrin"] = "Holy"
    config["specs"]["Silmelin"] = "Holy"
    config["specs"]["Noldralda"] = "Disc"
    return config
end