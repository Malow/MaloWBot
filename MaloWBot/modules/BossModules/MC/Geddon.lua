DEBUFF_TEXTURE_GEDDON_LIVING_BOMB = "Inv_enchant_essenceastralsmall"

function mb_BossModule_Geddon_Load()
    mb_currentBossModule.unloadFunction = mb_BossModule_Geddon_Unload
    mb_currentBossModule.priestLogic = mb_BossModule_Geddon_PriestLogic
    mb_currentBossModule.paladinLogic = mb_BossModule_Geddon_PaladinLogic
    mb_currentBossModule.mageLogic = mb_BossModule_Geddon_MageLogic
    mb_MoveOutModule_RegisterAutomaticFuckOffDebuffSpell("Living Bomb")
    if max_GetClass("player") == "PALADIN" then
        mb_Paladin_CastAura("fire")
    end
end
mb_RegisterBossModule("geddon", mb_BossModule_Geddon_Load)

function mb_BossModule_Geddon_Unload()
    mb_MoveOutModule_Disable()
end

function mb_BossModule_Geddon_PriestLogic()
    if max_IsSpellNameOnCooldown("Power Word: Shield") then
        return false
    end

    local members = max_GetNumPartyOrRaidMembers()
    for i = 1, members do
        local unit = max_GetUnitFromPartyOrRaidIndex(i)
        if max_HasDebuff(unit, DEBUFF_TEXTURE_GEDDON_LIVING_BOMB) then
            if not max_HasDebuff(unit, DEBUFF_TEXTURE_WEAKENED_SOUL) then
                if mb_IsUnitValidFriendlyTarget(unit, "Power Word: Shield") then
                    max_CastSpellOnRaidMember("Power Word: Shield", unit)
                    return true
                end
            end
        end
    end
    return false
end

function mb_BossModule_Geddon_PaladinLogic()
    if max_HasDebuff("player", DEBUFF_TEXTURE_GEDDON_LIVING_BOMB) then
        if not mb_IsFuckingOff() then
            if max_GetPlayerDebuffTimeLeft(DEBUFF_TEXTURE_GEDDON_LIVING_BOMB) < 1 then
                if max_CastSpellIfReady("Divine Shield") then
                    return true
                end
            end
        end
    end
    return false
end

function mb_BossModule_Geddon_MageLogic()
    if max_HasDebuff("player", DEBUFF_TEXTURE_GEDDON_LIVING_BOMB) then
        if max_HasBuff("player", BUFF_TEXTURE_ICE_BLOCK) then
            return true
        end
        if max_IsSpellNameOnCooldown("Ice Block") then
            if max_CastSpellIfReady("Fire Ward") then
                return true
            end
            if mb_Mage_HasIceBarrier() then
                if max_CastSpellIfReady("Ice Barrier") then
                    return true
                end
            end
        elseif not mb_IsFuckingOff() then
            if max_GetPlayerDebuffTimeLeft(DEBUFF_TEXTURE_GEDDON_LIVING_BOMB) < 1 then
                if max_CastSpellIfReady("Ice Block") then
                    return true
                end
            end
        end
    end
    if max_HasBuff("player", BUFF_TEXTURE_ICE_BLOCK) then
        max_CancelBuff(BUFF_TEXTURE_ICE_BLOCK)
    end
    return false
end
