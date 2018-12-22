MAX_BUFFS = 32
MAX_DEBUFFS = 16

UNACCEPTED_REQUEST_THROTTLE = 2

--- Buff/Debuff textures
-- Misc
BUFF_TEXTURE_DRINK = "Interface\\Icons\\INV_Drink_07"
BUFF_TEXTURE_DRINK_2 = "Interface\\Icons\\INV_Drink_18"
-- Druid
BUFF_TEXTURE_REJUVENATION = "Interface\\Icons\\Spell_Nature_Rejuvenation"
BUFF_TEXTURE_REGROWTH = "Interface\\Icons\\Spell_Nature_ResistNature"
BUFF_TEXTURE_MARK_OF_THE_WILD = "Interface\\Icons\\Spell_Nature_Regeneration"
BUFF_TEXTURE_GIFT_OF_THE_WILD = "Interface\\Icons\\Spell_Nature_Regeneration"
-- Hunter
BUFF_TEXTURE_ASPECT_OF_THE_HAWK = "Interface\\Icons\\Spell_Nature_RavenForm"
BUFF_TEXTURE_TRUESHOT_AURA = "Interface\\Icons\\Ability_TrueShot"
DEBUFF_TEXTURE_HUNTERS_MARK = "Interface\\Icons\\Ability_Hunter_SniperShot"
-- Mage
BUFF_TEXTURE_ARCANE_INTELLECT = "Interface\\Icons\\Spell_Holy_MagicalSentry"
BUFF_TEXTURE_ICE_ARMOR = "Interface\\Icons\\Spell_Frost_FrostArmor02"
BUFF_TEXTURE_MAGE_ARMOR = "Interface\\Icons\\Spell_MageArmor"
-- Paladin
BUFF_TEXTURE_SEAL_OF_LIGHT = "Interface\\Icons\\Spell_Holy_HealingAura"
BUFF_TEXTURE_SEAL_OF_WISDOM = "Interface\\Icons\\Spell_Holy_RighteousnessAura"
BUFF_TEXTURE_DEVOTION_AURA = "Interface\\Icons\\Spell_Holy_DevotionAura"
BUFF_TEXTURE_FIRE_RESISTANCE_AURA = "Interface\\Icons\\Spell_Fire_SealOfFire"
BUFF_TEXTURE_BLESSING_OF_WISDOM = "Interface\\Icons\\Spell_Holy_SealOfWisdom"
BUFF_TEXTURE_GREATER_BLESSING_OF_WISDOM = "Interface\\Icons\\Spell_Holy_GreaterBlessingofWisdom"
BUFF_TEXTURE_BLESSING_OF_MIGHT = "Interface\\Icons\\Spell_Holy_FistOfJustice"
BUFF_TEXTURE_GREATER_BLESSING_OF_MIGHT = "Interface\\Icons\\Spell_Holy_GreaterBlessingofKings"
BUFF_TEXTURE_BLESSING_OF_KINGS = "Interface\\Icons\\Spell_Magic_MageArmor"
BUFF_TEXTURE_GREATER_BLESSING_OF_KINGS = "Interface\\Icons\\Spell_Magic_GreaterBlessingofKings"
BUFF_TEXTURE_BLESSING_OF_LIGHT = "Interface\\Icons\\Spell_Holy_PrayerOfHealing02"
BUFF_TEXTURE_GREATER_BLESSING_OF_LIGHT = "Interface\\Icons\\Spell_Holy_GreaterBlessingofLight"
BUFF_TEXTURE_BLESSING_OF_SANCTUARY = "Interface\\Icons\\Spell_Nature_LightningShield"
BUFF_TEXTURE_GREATER_BLESSING_OF_SANCTUARY = "Interface\\Icons\\Spell_Holy_GreaterBlessingofSanctuary"
BUFF_TEXTURE_BLESSING_OF_SALVATION = "Interface\\Icons\\Spell_Holy_SealOfSalvation"
BUFF_TEXTURE_GREATER_BLESSING_OF_SALVATION = "Interface\\Icons\\Spell_Holy_GreaterBlessingofSalvation"
DEBUFF_TEXTURE_JUDGEMENT_OF_LIGHT = ""
DEBUFF_TEXTURE_JUDGEMENT_OF_WISDOM = ""
-- Priest
BUFF_TEXTURE_POWER_WORD_FORTITUDE = "Interface\\Icons\\Spell_Holy_WordFortitude"
BUFF_TEXTURE_PRAYER_OF_FORTITUDE = "Interface\\Icons\\Spell_Holy_PrayerOfFortitude"
BUFF_TEXTURE_DIVINE_SPIRIT = "Interface\\Icons\\Spell_Holy_DivineSpirit"
BUFF_TEXTURE_PRAYER_OF_SPIRIT = "Interface\\Icons\\Spell_Holy_PrayerofSpirit"
BUFF_TEXTURE_INNER_FIRE = "Interface\\Icons\\Spell_Holy_InnerFire"
BUFF_TEXTURE_SHADOW_PROTECTION = "Interface\\Icons\\Spell_Shadow_AntiShadow"
BUFF_TEXTURE_PRAYER_OF_SHADOW_PROTECTION = "Interface\\Icons\\Spell_Holy_PrayerofShadowProtection"
BUFF_TEXTURE_RENEW = "Interface\\Icons\\Spell_Holy_Renew"
BUFF_TEXTURE_SPIRIT_OF_REDEMPTION = "Interface\\Icons\\Spell_Holy_GreaterHeal"
BUFF_TEXTURE_ABOLISH_DISEASE = "Interface\\Icons\\Spell_Nature_NullifyDisease"
DEBUFF_TEXTURE_WEAKENED_SOUL = "Interface\\Icons\\Spell_Holy_AshesToAshes"
-- Rogue
BUFF_TEXTURE_SLICE_AND_DICE = "Interface\\Icons\\Ability_Rogue_SliceDice"
-- Warlock
BUFF_TEXTURE_DEMON_ARMOR = "Interface\\Icons\\Spell_Shadow_RagingScream"
BUFF_TEXTURE_SACRIFICED_SUCCUBUS = "Interface\\Icons\\Spell_Shadow_PsychicScream"
DEBUFF_TEXTURE_CURSE_OF_SHADOW = "Interface\\Icons\\Spell_Shadow_CurseOfAchimonde"
DEBUFF_TEXTURE_CURSE_OF_THE_ELEMENTS = "Interface\\Icons\\Spell_Shadow_ChillTouch"
DEBUFF_TEXTURE_CURSE_OF_RECKLESSNESS = "Interface\\Icons\\Spell_Shadow_UnholyStrength"
DEBUFF_TEXTURE_CURSE_OF_WEAKNESS = "Interface\\Icons\\Spell_Shadow_CurseOfMannoroth"
-- Warrior
BUFF_TEXTURE_BATTLE_SHOUT = "Interface\\Icons\\Ability_Warrior_BattleShout"
DEBUFF_TEXTURE_SUNDER_ARMOR = "Interface\\Icons\\Ability_Warrior_Sunder"
DEBUFF_TEXTURE_DEMORALIZING_SHOUT = "Interface\\Icons\\Ability_Warrior_WarCry"
DEBUFF_TEXTURE_THUNDER_CLAP = "Interface\\Icons\\Spell_Nature_ThunderClap"

--- Unit filters
UNIT_FILTER_HAS_MANA = {
    name = "UNIT_FILTER_HAS_MANA"
}
UNIT_FILTER_DOES_NOT_HAVE_DEBUFF = {
    name = "UNIT_FILTER_DOES_NOT_HAVE_DEBUFF",
    debuff = "TO-BE-SET"
}
UNIT_FILTER_DOES_NOT_HAVE_BUFF = {
    name = "UNIT_FILTER_DOES_NOT_HAVE_BUFF",
    buff = "TO-BE-SET"
}

--- Requests
REQUEST_CLASS_SYNC = {
    type = "TO-BE-SET",
    throttle = 10
}
REQUEST_RESURRECT = {
    type = "resurrect",
    throttle = 12
}
REQUEST_WATER = {
    type = "water",
    throttle = 10
}
REQUEST_REMOVE_MAGIC = {
    type = "removeMagic",
    throttle = 10
}
REQUEST_REMOVE_CURSE = {
    type = "removeCurse",
    throttle = 10
}
REQUEST_REMOVE_POISON = {
    type = "removePoison",
    throttle = 10
}
REQUEST_REMOVE_DISEASE = {
    type = "removeDisease",
    throttle = 10
}

--- Buff Requests
BUFF_ARCANE_INTELLECT = {
    type = "buffArcaneIntellect",
    textures = { BUFF_TEXTURE_ARCANE_INTELLECT },
    throttle = 10,
    spellName = "Arcane Intellect"
}
BUFF_POWER_WORD_FORTITUDE = {
    type = "buffPowerWordFortitude",
    textures = { BUFF_TEXTURE_POWER_WORD_FORTITUDE, BUFF_TEXTURE_PRAYER_OF_FORTITUDE },
    throttle = 10,
    spellName = "Power Word: Fortitude",
    groupWideSpellName = "Prayer of Fortitude"
}
BUFF_DIVINE_SPIRIT = {
    type = "buffDivineSpirit",
    textures = { BUFF_TEXTURE_DIVINE_SPIRIT, BUFF_TEXTURE_PRAYER_OF_SPIRIT },
    throttle = 10,
    spellName = "Divine Spirit",
    groupWideSpellName = "Prayer of Spirit"
}
BUFF_BLESSING_OF_WISDOM = {
    type = "buffBlessingOfWisdom",
    textures = { BUFF_TEXTURE_BLESSING_OF_WISDOM, BUFF_TEXTURE_GREATER_BLESSING_OF_WISDOM },
    throttle = 10,
    spellName = "Greater Blessing of Wisdom"
}
BUFF_BLESSING_OF_MIGHT = {
    type = "buffBlessingOfMight",
    textures = { BUFF_TEXTURE_BLESSING_OF_MIGHT, BUFF_TEXTURE_GREATER_BLESSING_OF_MIGHT },
    throttle = 10,
    spellName = "Greater Blessing of Might"
}
BUFF_BLESSING_OF_KINGS = {
    type = "buffBlessingOfKings",
    textures = { BUFF_TEXTURE_BLESSING_OF_KINGS, BUFF_TEXTURE_GREATER_BLESSING_OF_KINGS },
    throttle = 10,
    spellName = "Greater Blessing of Kings"
}
BUFF_BLESSING_OF_LIGHT = {
    type = "buffBlessingOfLight",
    textures = { BUFF_TEXTURE_BLESSING_OF_LIGHT, BUFF_TEXTURE_GREATER_BLESSING_OF_LIGHT },
    throttle = 10,
    spellName = "Greater Blessing of Light"
}
BUFF_BLESSING_OF_SANCTUARY = {
    type = "buffBlessingOfSanctuary",
    textures = { BUFF_TEXTURE_BLESSING_OF_SANCTUARY, BUFF_TEXTURE_GREATER_BLESSING_OF_SANCTUARY },
    throttle = 10,
    spellName = "Greater Blessing of Sanctuary"
}
BUFF_BLESSING_OF_SALVATION = {
    type = "buffBlessingOfSalvation",
    textures = { BUFF_TEXTURE_BLESSING_OF_SALVATION, BUFF_TEXTURE_GREATER_BLESSING_OF_SALVATION },
    throttle = 10,
    spellName = "Greater Blessing of Salvation"
}
BUFF_MARK_OF_THE_WILD = {
    type = "buffMarkOfTheWild",
    textures = { BUFF_TEXTURE_MARK_OF_THE_WILD, BUFF_TEXTURE_GIFT_OF_THE_WILD },
    throttle = 10,
    spellName = "Mark of the Wild",
    groupWideSpellName = "Gift of the Wild"
}
BUFF_SHADOW_PROTECTION = {
    type = "buffShadowProtection",
    textures = { BUFF_TEXTURE_SHADOW_PROTECTION, BUFF_TEXTURE_PRAYER_OF_SHADOW_PROTECTION },
    throttle = 10,
    spellName = "Shadow Protection",
    groupWideSpellName = "Prayer of Shadow Protection"
}

All_BUFFS = {
    BUFF_ARCANE_INTELLECT,
    BUFF_POWER_WORD_FORTITUDE,
    BUFF_DIVINE_SPIRIT,
    BUFF_BLESSING_OF_WISDOM,
    BUFF_BLESSING_OF_MIGHT,
    BUFF_BLESSING_OF_KINGS,
    BUFF_BLESSING_OF_LIGHT,
    BUFF_BLESSING_OF_SANCTUARY,
    BUFF_BLESSING_OF_SALVATION,
    BUFF_MARK_OF_THE_WILD
}

--- Items
ITEMS_WATER = {
    "Conjured Water",
    "Conjured Fresh Water",
    "Conjured Purified Water",
    "Conjured Spring Water",
    "Conjured Mineral Water",
    "Conjured Sparkling Water",
    "Conjured Crystal Water"
}
ITEMS_MANA_GEM = {
    "Mana Agate",
    "Mana Jade",
    "Mana Citrine",
    "Mana Ruby"
}

--- Request priorities
REQUEST_PRIORITY = {
    COMMAND = 101,
    TANKING_BROADCAST = 101,
    HEALING_OVER_TIME = 101,
    HEALER_MODULE_DATA = 101,
    CLASS_SYNC = 101,
    -- Anything with over 100 priority is never skipped
    DISPEL = 80,
    RESURRECT_RESURRECTER = 70,
    RESURRECT_CASTER = 60,
    RESURRECT_MELEE = 50,
    WATER = 20,
    BUFF = 10
}

