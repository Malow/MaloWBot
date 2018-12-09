MAX_BUFFS = 32
MAX_DEBUFFS = 16

--- Buff textures
BUFF_TEXTURE_POWER_WORD_FORTITUDE = "Interface\\Icons\\Spell_Holy_WordFortitude"
BUFF_TEXTURE_DIVINE_SPIRIT = "Interface\\Icons\\Spell_Holy_DivineSpirit"
BUFF_TEXTURE_INNER_FIRE = "Interface\\Icons\\Spell_Holy_InnerFire"
BUFF_TEXTURE_SHADOW_PROTECTION = "Interface\\Icons\\Spell_Shadow_AntiShadow"
BUFF_TEXTURE_RENEW = "Interface\\Icons\\Spell_Holy_Renew"
BUFF_TEXTURE_SPIRIT_OF_REDEMPTION = "Interface\\Icons\\Spell_Holy_GreaterHeal"
BUFF_TEXTURE_ABOLISH_DISEASE = "Interface\\Icons\\Spell_Nature_NullifyDisease"
BUFF_TEXTURE_ARCANE_INTELLECT = "Interface\\Icons\\Spell_Holy_MagicalSentry"
BUFF_DRINK = "Interface\\Icons\\INV_Drink_07"
BUFF_ICE_ARMOR = "Interface\\Icons\\Spell_Frost_FrostArmor02"

--- Debuff textures
DEBUFF_TEXTURE_WEAKENED_SOUL = "Interface\\Icons\\Spell_Holy_AshesToAshes"

--- Unit filters
UNIT_FILTER_HAS_MANA = "UNIT_FILTER_HAS_MANA"


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
REQUEST_RESURRECT = {
    requestType = "resurrect",
    throttle = 20
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
    "Conjured Spring Water"
}
ITEMS_MANA_GEM = {
    "Mana Agate"
}