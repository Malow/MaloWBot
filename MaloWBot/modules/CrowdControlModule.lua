
mb_CrowdControlModule_myCrowdControlTarget = nil
mb_CrowdControlModule_myCrowdControlSpellName = nil
mb_CrowdControlModule_myCrowdControlDebuffTexture = nil
function mb_CrowdControlModule_RegisterTarget(spellName, debuffTexture)
    mb_CrowdControlModule_myCrowdControlTarget = GetRaidTargetIndex("target")
    if mb_CrowdControlModule_myCrowdControlTarget == nil then
        max_SayRaid("Warning, you tried to assign Crowd-Control-target without a raid-marker, it will not work.")
        return
    end

    mb_CrowdControlModule_myCrowdControlSpellName = spellName
    mb_CrowdControlModule_myCrowdControlDebuffTexture = debuffTexture

    max_SayRaid("I will be Crowd-Controlling " .. UnitName("target") .. " with marker " .. max_RaidTargetIndexToName(mb_CrowdControlModule_myCrowdControlTarget))
end

mb_CrowdControlModule_lastCrowdControlCast = 0
function mb_CrowdControlModule_Run()
    if mb_CrowdControlModule_myCrowdControlTarget == nil then
        return false
    end

    if not UnitExists("target") or not UnitIsVisible("target") or UnitIsDeadOrGhost("target") then
        mb_CrowdControlModule_StopCrowdControllingTarget()
        return false
    end

    if GetRaidTargetIndex("target") ~= mb_CrowdControlModule_myCrowdControlTarget then
        mb_CrowdControlModule_StopCrowdControllingTarget()
        return false
    end

    if not UnitAffectingCombat("target") then
        return true
    end

    if not mb_IsSpellInRangeOnEnemy(mb_CrowdControlModule_myCrowdControlSpellName) then
        max_SayRaid("I'm not in range to CC " .. UnitName("target"))
        return true
    end

    if not max_HasDebuff("target", mb_CrowdControlModule_myCrowdControlDebuffTexture) then
        CastSpellByName(mb_CrowdControlModule_myCrowdControlSpellName)
        return true
    end

    if max_GetManaPercentage("player") > 99 then
        CastSpellByName(mb_CrowdControlModule_myCrowdControlSpellName)
        return true
    end

    return true
end

function mb_CrowdControlModule_IsAssignedToCrowdControl()
    return mb_CrowdControlModule_myCrowdControlTarget ~= nil
end

function mb_CrowdControlModule_StopCrowdControllingTarget()
    mb_CrowdControlModule_myCrowdControlTarget = nil
    max_SayRaid("Stopping Crowd-Control on " .. UnitName("target"))
end

function mb_CrowdControlModule_OnSelfDeath()
    if mb_CrowdControlModule_IsAssignedToCrowdControl() then
        if not UnitExists("target") or GetRaidTargetIndex("target") ~= mb_CrowdControlModule_myCrowdControlTarget then
            TargetLastEnemy()
        end
        if UnitExists("target") and GetRaidTargetIndex("target") == mb_CrowdControlModule_myCrowdControlTarget then
            mb_MakeRequest(REQUEST_CROWD_CONTROL.type, "crowdControl", REQUEST_PRIORITY.COMMAND)
            max_SayRaid("I died while being assigned to Crowd-Control " .. UnitName("target") .. " (" .. max_RaidTargetIndexToName(mb_CrowdControlModule_myCrowdControlTarget) .. "). Sent request for someone else to take over.")
        else
            max_SayRaid("I died while being assigned to Crowd-Control " .. max_RaidTargetIndexToName(mb_CrowdControlModule_myCrowdControlTarget) .. ", but I was unable to target it so I couldn't send a request for someone else to take over.")
        end
        mb_CrowdControlModule_myCrowdControlTarget = nil
    end
end