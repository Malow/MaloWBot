mb_SpellCastingModule_Frame = CreateFrame("frame", "MaloWBotSpellCastingModuleFrame", UIParent)
mb_SpellCastingModule_Frame:Show()

mb_castStartedTime = nil
mb_isCasting = false
function mb_SpellCastingModule_OnEvent()
    if event == "SPELLCAST_START" or event == "SPELLCAST_CHANNEL_START" then
        mb_isCasting = true
        if mb_lastAttemptedCast ~= nil and mb_lastAttemptedCast.onStartCallback ~= nil then
            mb_lastAttemptedCast.onStartCallback(mb_lastAttemptedCast)
        end
        mb_castStartedTime = mb_GetTime()
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

mb_lastAttemptedCast = nil
function mb_CastSpellByNameOnTargetWithCallbacks(spellName, target, callbacks)
    mb_lastAttemptedCast = {}
    mb_lastAttemptedCast.spellName = spellName
    mb_lastAttemptedCast.startTime = mb_GetTime()
    mb_lastAttemptedCast.target = target
    mb_lastAttemptedCast.onStartCallback = callbacks.onStart
    mb_lastAttemptedCast.onFailCallback = callbacks.onFail
    CastSpellByName(spellName, false)
end

function mb_CastSpellByNameOnRaidMemberWithCallbacks(spellName, target, callbacks)
    local retarget = false
    if UnitIsFriend("player", "target") then
        ClearTarget()
        retarget = true
    end
    mb_CastSpellByNameOnTargetWithCallbacks(spellName, target, callbacks)
    SpellTargetUnit(target)
    SpellStopTargeting()
    if retarget then
        TargetLastTarget()
    end
end

function mb_IsCasting()
    return mb_isCasting
end

function mb_StopCasting()
    if mb_IsCasting() then
        SpellStopCasting()
        mb_isCasting = false
        return true
    end
    return false
end