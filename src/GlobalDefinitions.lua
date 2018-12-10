MAX_BUFFS = 32
MAX_DEBUFFS = 16

UNACCEPTED_REQUEST_THROTTLE = 2

--- Buff textures
BUFF_TEXTURE_POWER_WORD_FORTITUDE = "Interface\\Icons\\Spell_Holy_WordFortitude"
BUFF_TEXTURE_DIVINE_SPIRIT = "Interface\\Icons\\Spell_Holy_DivineSpirit"
BUFF_TEXTURE_INNER_FIRE = "Interface\\Icons\\Spell_Holy_InnerFire"
BUFF_TEXTURE_SHADOW_PROTECTION = "Interface\\Icons\\Spell_Shadow_AntiShadow"
BUFF_TEXTURE_RENEW = "Interface\\Icons\\Spell_Holy_Renew"
BUFF_TEXTURE_SPIRIT_OF_REDEMPTION = "Interface\\Icons\\Spell_Holy_GreaterHeal"
BUFF_TEXTURE_ABOLISH_DISEASE = "Interface\\Icons\\Spell_Nature_NullifyDisease"
BUFF_TEXTURE_ARCANE_INTELLECT = "Interface\\Icons\\Spell_Holy_MagicalSentry"
BUFF_TEXTURE_BLESSING_OF_WISDOM = "Interface\\Icons\\Spell_Holy_SealOfWisdom"
BUFF_TEXTURE_BLESSING_OF_MIGHT = "Interface\\Icons\\Spell_Holy_FistOfJustice"
BUFF_TEXTURE_BLESSING_OF_KINGS = "Interface\\Icons\\Spell_Magic_MageArmor"
BUFF_TEXTURE_BLESSING_OF_LIGHT = "Interface\\Icons\\Spell_Holy_PrayerOfHealing02"
BUFF_TEXTURE_BLESSING_OF_SANCTUARY = "Interface\\Icons\\Spell_Nature_LightningShield"
BUFF_TEXTURE_BLESSING_OF_SALVATION = "Interface\\Icons\\Spell_Holy_SealOfSalvation"
BUFF_TEXTURE_DRINK = "Interface\\Icons\\INV_Drink_07"
BUFF_TEXTURE_ICE_ARMOR = "Interface\\Icons\\Spell_Frost_FrostArmor02"
BUFF_TEXTURE_DEMON_ARMOR = "Interface\\Icons\\Spell_Shadow_RagingScream"

--- Debuff textures
DEBUFF_TEXTURE_WEAKENED_SOUL = "Interface\\Icons\\Spell_Holy_AshesToAshes"

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
BUFF_ARCANE_INTELLECT = {
    requestType = "buffArcaneIntellect",
    texture = BUFF_TEXTURE_ARCANE_INTELLECT,
    throttle = 10
}
BUFF_POWER_WORD_FORTITUDE = {
    requestType = "buffPowerWordFortitude",
    texture = BUFF_TEXTURE_POWER_WORD_FORTITUDE,
    throttle = 10
}
BUFF_DIVINE_SPIRIT = {
    requestType = "buffDivineSpirit",
    texture = BUFF_TEXTURE_DIVINE_SPIRIT,
    throttle = 10
}
BUFF_BLESSING_OF_WISDOM = {
    requestType = "buffBlessingOfWisdom",
    texture = BUFF_TEXTURE_BLESSING_OF_WISDOM,
    throttle = 10
}
BUFF_BLESSING_OF_MIGHT = {
    requestType = "buffBlessingOfMight",
    texture = BUFF_TEXTURE_BLESSING_OF_MIGHT,
    throttle = 10
}
BUFF_BLESSING_OF_KINGS = {
    requestType = "buffBlessingOfKings",
    texture = BUFF_TEXTURE_BLESSING_OF_KINGS,
    throttle = 10
}
BUFF_BLESSING_OF_LIGHT = {
    requestType = "buffBlessingOfLight",
    texture = BUFF_TEXTURE_BLESSING_OF_LIGHT,
    throttle = 10
}
BUFF_BLESSING_OF_SANCTUARY = {
    requestType = "buffBlessingOfSanctuary",
    texture = BUFF_TEXTURE_BLESSING_OF_SANCTUARY,
    throttle = 10
}
BUFF_BLESSING_OF_SALVATION = {
    requestType = "buffBlessingOfSalvation",
    texture = BUFF_TEXTURE_BLESSING_OF_SALVATION,
    throttle = 10
}
REQUEST_RESURRECT = {
    requestType = "resurrect",
    throttle = 12
}
REQUEST_WATER = {
    requestType = "water",
    throttle = 10
}

--- Items
ITEMS_WATER = {
    "Conjured Water",
    "Conjured Fresh Water",
    "Conjured Purified Water",
    "Conjured Spring Water",
    "Conjured Mineral Water"
}
ITEMS_MANA_GEM = {
    "Mana Agate",
    "Mana Jade"
}