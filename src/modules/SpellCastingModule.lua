mb_SpellCastingModule_Frame = CreateFrame("frame", "MaloWBotSpellCastingModuleFrame", UIParent)
mb_SpellCastingModule_Frame:Show()

mb_isCasting = false
function mb_SpellCastingModule_OnEvent()
    if event == "SPELLCAST_START" or event == "SPELLCAST_CHANNEL_START" then
        mb_isCasting = true
        if mb_lastAttemptedCast ~= nil then
            mb_lastAttemptedCast.startCastTime = mb_GetTime()
            if mb_lastAttemptedCast.onStartCallback ~= nil then
                mb_lastAttemptedCast.onStartCallback(mb_lastAttemptedCast)
            end
        end
    elseif event == "SPELLCAST_STOP" or event == "SPELLCAST_CHANNEL_STOP" or event == "SPELLCAST_INTERRUPTED" or event == "SPELLCAST_FAILED" then
        mb_isCasting = false
        if event == "SPELLCAST_INTERRUPTED" or event == "SPELLCAST_FAILED" then
            if mb_lastAttemptedCast ~= nil and mb_lastAttemptedCast.onFailCallback ~= nil then
                mb_lastAttemptedCast.onFailCallback(mb_lastAttemptedCast)
            end
        end
        mb_lastAttemptedCast = nil
    end
end
mb_SpellCastingModule_Frame:SetScript("OnEvent", mb_SpellCastingModule_OnEvent)
mb_SpellCastingModule_Frame:RegisterEvent("SPELLCAST_START")
mb_SpellCastingModule_Frame:RegisterEvent("SPELLCAST_CHANNEL_START")
mb_SpellCastingModule_Frame:RegisterEvent("SPELLCAST_STOP")
mb_SpellCastingModule_Frame:RegisterEvent("SPELLCAST_CHANNEL_STOP")
mb_SpellCastingModule_Frame:RegisterEvent("SPELLCAST_INTERRUPTED")
mb_SpellCastingModule_Frame:RegisterEvent("SPELLCAST_FAILED")

function mb_IsCasting()
    if mb_isCasting then
        return true
    end
    if mb_stoppedCastingTime + 0.35 > mb_GetTime() then
        return true
    end
    if mb_lastAttemptedCast ~= nil and mb_lastAttemptedCast.attemptTime + 0.3 > mb_GetTime() then
        return true
    end
    return false
end

mb_lastAttemptedCast = nil
function mb_CastSpellByNameOnTargetWithCallbacks(spellName, callbacks)
    if mb_IsCasting() then
        return
    end
    mb_lastAttemptedCast = {}
    mb_lastAttemptedCast.spellName = spellName
    mb_lastAttemptedCast.attemptTime = mb_GetTime()
    mb_lastAttemptedCast.onStartCallback = callbacks.onStart
    mb_lastAttemptedCast.onFailCallback = callbacks.onFail
    CastSpellByName(spellName, false)
end

function mb_CastSpellByNameOnRaidMemberWithCallbacks(spellName, target, callbacks)
    if mb_IsCasting() then
        return
    end
    local retarget = false
    if UnitIsFriend("player", "target") then
        ClearTarget()
        retarget = true
    end
    mb_lastAttemptedCast = {}
    mb_lastAttemptedCast.spellName = spellName
    mb_lastAttemptedCast.attemptTime = mb_GetTime()
    mb_lastAttemptedCast.onStartCallback = callbacks.onStart
    mb_lastAttemptedCast.onFailCallback = callbacks.onFail
    mb_lastAttemptedCast.target = target
    CastSpellByName(spellName, false)
    SpellTargetUnit(target)
    SpellStopTargeting()
    if retarget then
        TargetLastTarget()
    end
end

mb_stoppedCastingTime = 0
function mb_StopCasting()
    if mb_IsCasting() then
        SpellStopCasting()
        mb_stoppedCastingTime = mb_GetTime()
        mb_isCasting = false
        return true
    end
    return false
end

function mb_StopCastingIfNeeded(stopCastingFunction)
    if mb_lastAttemptedCast == nil or mb_lastAttemptedCast.startCastTime == nil then
        return false
    end
    if mb_stoppedCastingTime + 0.3 > mb_GetTime() then
        return true
    end
    if stopCastingFunction(mb_lastAttemptedCast) then
        mb_StopCasting()
        return true
    end
    return false
end