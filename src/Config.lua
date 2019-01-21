--- Default values, do not change these unless you want them to apply to everyone
--- If you want to change them just for yourself add them to the PersonalizedConfig.lua instead.
function mb_GetConfig()
    local config = mb_GetPersonalizedConfig()
    if config["followTarget"] == nil then
        config["followTarget"] = "targetThatCantBeFound"
    end
    if config["personalizedCommander"] == nil then
        config["personalizedCommander"] = {}
    end
    if config["autoLearnTalents"] == nil then
        config["autoLearnTalents"] = false
    end
    if config["autoTrainSpells"] == nil then
        config["autoTrainSpells"] = true -- Automatically train all class and profession skills when Gossip-panel is opened for an NPC that can teach you something.
    end
    if config["groupConfiguration"] == nil then
        config["groupConfiguration"] = mb_GetGroupConfiguration()
    end
    config["specs"] = {}
    config["specs"]["Kaladin"] = "LightHoly" --"RetLight"
    config["specs"]["Malow"] = "SanctuarySalvation"
    config["specs"]["Rosita"] = "KingsJudge"
    config["specs"]["Madeleina"] = "Wisdom"
    config["specs"]["Skyler"] = "MightJudge"
    config["specs"]["Hardrac"] = "Holy"
    config["specs"]["Bondrin"] = "Holy"
    config["specs"]["Silmelin"] = "Holy"
    config["specs"]["Noldralda"] = "Disc"
    config["specs"]["Devun"] = "WarrTank"
	config["specs"]["Garret"] = "WarrTank"
	config["specs"]["Elery"] = "WarrTank"
	config["specs"]["Kalman"] = "WarrTank"
	config["specs"]["Verne"] = "Fury"
	config["specs"]["Hammond"] = "Fury"
	config["specs"]["Davrice"] = "Fury"
    config["specs"]["Trudy"] = "DeepFire"
    config["specs"]["Connie"] = "DeepFire"
    config["specs"]["Gaily"] = "DeepFire"
    config["specs"]["Kimmy"] = "DeepFire"
    config["specs"]["Kita"] = "DeepFire"
    config["specs"]["Clemidge"] = "DeepFire"
    config["specs"]["Ticey"] = "DeepFire"
    config["specs"]["Nell"] = "DeepFire"
    config["specs"]["Tinuviel"] = "MM"
    config["specs"]["Laurelia"] = "MM"
    config["specs"]["Elleni"] = "MMFullHM"
    return config
end

function mb_GetMySpecName()
    return mb_GetConfig()["specs"][UnitName("player")]
end

function mb_GetMyCommanderName()
    if mb_GetConfig()["personalizedCommander"][UnitName("player")] ~= nil then
        return mb_GetConfig()["personalizedCommander"][UnitName("player")]
    end
    return mb_GetConfig()["followTarget"]
end

function mb_GetGroupConfiguration()
    local groups = {}
    local group = {}
    table.insert(group, "Malow")
    table.insert(group, "Devun")
    table.insert(group, "Garret")
    table.insert(group, "Maligna")
    table.insert(group, "Bondrin")
    table.insert(groups, group)
    group = {}
    table.insert(group, "Charnel")
    table.insert(group, "Hardrac")
    table.insert(group, "Skyler")
    table.insert(group, "Kalman")
    table.insert(group, "Elery")
    table.insert(groups, group)
    group = {}
    table.insert(group, "Tinuviel")
    table.insert(group, "Kaladin")
    table.insert(group, "Carin")
    table.insert(group, "Davrice")
    table.insert(group, "Amorine")
    table.insert(groups, group)
    group = {}
    table.insert(group, "Villetta")
    table.insert(group, "Gwethriel")
    table.insert(group, "Elleni")
    table.insert(group, "Hammond")
    table.insert(group, "Thana")
    table.insert(groups, group)
    group = {}
    table.insert(group, "Elbereth")
    table.insert(group, "Emilee")
    table.insert(group, "Verne")
    table.insert(group, "Laurelia")
    table.insert(group, "Robbin")
    table.insert(groups, group)
    group = {}
    table.insert(group, "Kimmy")
    table.insert(group, "Rosita")
    table.insert(group, "Noldralda")
    table.insert(group, "Necria")
    table.insert(group, "Clemidge")
    table.insert(groups, group)
    group = {}
    table.insert(group, "Trudy")
    table.insert(group, "Kita")
    table.insert(group, "Nell")
    table.insert(group, "Odia")
    table.insert(group, "Silmelin")
    table.insert(groups, group)
    group = {}
    table.insert(group, "Gaily")
    table.insert(group, "Connie")
    table.insert(group, "Arethel")
    table.insert(group, "Madeleina")
    table.insert(group, "Ticey")
    table.insert(groups, group)
    return groups
end