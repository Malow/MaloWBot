MCLD_COMBAT_EVENTS = {
	"CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS",
	"CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES",
	"CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS",
	"CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES",
	"CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS",
	"CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES",
	"CHAT_MSG_COMBAT_FACTION_CHANGE",
	"CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS",
	"CHAT_MSG_COMBAT_FRIENDLYPLAYER_MISSES",
	"CHAT_MSG_COMBAT_FRIENDLY_DEATH",
	"CHAT_MSG_COMBAT_HONOR_GAIN",
	"CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS",
	"CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES",
	"CHAT_MSG_COMBAT_HOSTILE_DEATH",
	"CHAT_MSG_COMBAT_MISC_INFO",
	"CHAT_MSG_COMBAT_PARTY_HITS",
	"CHAT_MSG_COMBAT_PARTY_MISSES",
	"CHAT_MSG_COMBAT_PET_HITS",
	"CHAT_MSG_COMBAT_PET_MISSES",
	"CHAT_MSG_COMBAT_SELF_HITS",
	"CHAT_MSG_COMBAT_SELF_MISSES",
	"CHAT_MSG_COMBAT_XP_GAIN",
	"CHAT_MSG_MONSTER_EMOTE",
	"CHAT_MSG_MONSTER_SAY",
	"CHAT_MSG_MONSTER_WHISPER",
	"CHAT_MSG_MONSTER_YELL",
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"CHAT_MSG_SPELL_AURA_GONE_OTHER",
	"CHAT_MSG_SPELL_AURA_GONE_SELF",
	"CHAT_MSG_SPELL_BREAK_AURA",
	"CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF",
	"CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE",
	"CHAT_MSG_SPELL_CREATURE_VS_PARTY_BUFF",
	"CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE",
	"CHAT_MSG_SPELL_CREATURE_VS_SELF_BUFF",
	"CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE",
	"CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS",
	"CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF",
	"CHAT_MSG_SPELL_FAILED_LOCALPLAYER",
	"CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF",
	"CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE",
	"CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF",
	"CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE",
	"CHAT_MSG_SPELL_ITEM_ENCHANTMENTS",
	"CHAT_MSG_SPELL_PARTY_BUFF",
	"CHAT_MSG_SPELL_PARTY_DAMAGE",
	"CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS",
	"CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE",
	"CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS",
	"CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE",
	"CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS",
	"CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE",
	"CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS",
	"CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE",
	"CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS",
	"CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE",
	"CHAT_MSG_SPELL_PET_BUFF",
	"CHAT_MSG_SPELL_PET_DAMAGE",
	"CHAT_MSG_SPELL_SELF_BUFF",
	"CHAT_MSG_SPELL_SELF_DAMAGE",
	"CHAT_MSG_SPELL_TRADESKILLS"
}

local MY_NAME = "MaloWCombatLogDebugger"
local MY_ABBREVIATION = "MCLD"

-- Frame setup for update
local lastUpdate = GetTime()
local function mcld_update()
	if GetTime() >= lastUpdate + 0.4 then
		lastUpdate = GetTime()
		mcld_onUpdate()
    end
end
local f = CreateFrame("frame", MY_NAME .. "Frame", UIParent)
f:SetScript("OnUpdate", mcld_update)
f:Show()

-- Cmds
SlashCmdList[MY_ABBREVIATION .. "COMMAND"] = function(msg)
	mcld_OnCommand(msg)
end 
SLASH_MCLDCOMMAND1 = "/" .. MY_ABBREVIATION;

-- Prints message in chatbox
function mcld_print(msg)
	ChatFrame1:AddMessage(MY_ABBREVIATION .. ": " .. tostring(msg))
end

-- Events
local hasLoaded = false
function mcld_onEvent()
	if event == "ADDON_LOADED" then
		if arg1 == MY_NAME then
			hasLoaded = true
		end
	else
		for _, v in pairs(MCLD_COMBAT_EVENTS) do
			if v == event then
				mcld_OnCombatEvent(event, arg1)
			end
		end
	end
end
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", mcld_onEvent)

mcld_enabled = false
mcld_strings = {}
mcld_recordedEvents = {}

-- OnUpdate
function mcld_onUpdate()
end

-- OnCommand
function mcld_OnCommand(msg)
	if string.find(msg, "register") then
		local s = max_SplitString(msg, " ")[2]
		table.insert(mcld_strings, s)
		if not mcld_enabled then
			for _, v in pairs(MCLD_COMBAT_EVENTS) do
				MaloWCombatLogDebuggerFrame:RegisterEvent(v)
			end
		end
		mcld_print(s .. " registered")
		mcld_enabled = true
	elseif msg == "off" then
		if mcld_enabled then
			for _, v in pairs(MCLD_COMBAT_EVENTS) do
				MaloWCombatLogDebuggerFrame:UnregisterEvent(v)
			end
		end
		mcld_enabled = false
	elseif msg == "print" then
		local e = table.remove(mcld_recordedEvents, 1)
		if e == nil then
			mcld_print("No more events")
		else
			mcld_print(e.event)
			mcld_print(e.arg1)
			mcld_print("")
		end
	end
end

function mcld_OnCombatEvent(event, arg1)
	local found = false
	for k, v in pairs(mcld_strings) do
		if string.find(arg1, v) then
			found = true
		end
	end
	if not found then
		return
	end
	local e = {}
	e.event = event
	e.arg1 = arg1
	table.insert(mcld_recordedEvents, e)
end