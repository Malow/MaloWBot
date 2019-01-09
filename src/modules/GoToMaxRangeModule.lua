
mb_GoToMaxRangeModule_shouldGoToMaxRange = false
mb_GoToMaxRangeModule_hasMovedOutOfRange = false
mb_GoToMaxRangeModule_spellName = nil
function mb_GoToMaxRangeModule_RegisterMaxRangeSpell(spellName)
    mb_RegisterForRequest("goToMaxRange", mb_GoToMaxRangeModule_RequestHandler)
    mb_GoToMaxRangeModule_spellName = spellName
end

function mb_GoToMaxRangeModule_RequestHandler(request)
    mb_GoToMaxRangeModule_shouldGoToMaxRange = true
    mb_GoToMaxRangeModule_hasMovedOutOfRange = false
end

function mb_GoToMaxRangeModule_RebindMovementKeyIfNeeded()
    if not mb_GoToMaxRangeModule_shouldGoToMaxRange then
        return false
    end
    if mb_GoToMaxRangeModule_hasMovedOutOfRange then
        if mb_IsSpellInRange(mb_GoToMaxRangeModule_spellName, "target") then
            mb_GoToMaxRangeModule_shouldGoToMaxRange = false
            mb_GoToMaxRangeModule_hasMovedOutOfRange = false
            return false
        else
            mb_BindKey("9", "MOVEFORWARD")
            return true
        end
    else
        if mb_IsSpellInRange(mb_GoToMaxRangeModule_spellName, "target") then
            mb_BindKey("9", "MOVEBACKWARD")
            return true
        else
            mb_GoToMaxRangeModule_hasMovedOutOfRange = true
            mb_BindKey("9", "MOVEFORWARD")
            return true
        end
    end
end