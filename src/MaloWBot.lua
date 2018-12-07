local MY_NAME = "MaloWBot"
local MY_ABBREVIATION = "MB"

-- Frame setup for update
local lastUpdate = GetTime()
local function mb_Update()
	if GetTime() >= lastUpdate + 0.1 then
		lastUpdate = GetTime()
		mb_OnUpdate()
    end
end
local f = CreateFrame("frame", MY_NAME .. "Frame", UIParent)
f:SetScript("OnUpdate", mb_Update)
f:Show()

-- Cmds
SlashCmdList[MY_ABBREVIATION .. "COMMAND"] = function(msg)
	SetCVar("autoSelfCast", 0)
	mb_OnCmd(msg)
end 
SLASH_MBCOMMAND1 = "/" .. MY_ABBREVIATION;

-- Prints message in chatbox
function mb_Print(msg)
	ChatFrame1:AddMessage(MY_ABBREVIATION .. ": " .. tostring(msg))
end

-- Events
local hasLoaded = false
function mb_OnEvent(self, event, arg1, arg2, arg3, ...)
	if event == "ADDON_LOADED" and arg1 == MY_NAME then
		hasLoaded = true
	end
end
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", mb_OnEvent)

-- OnUpdate
function mb_OnUpdate()

end

-- OnCmd
function mb_OnCmd(msg)
	local playerClass = max_GetClass("player")
	if playerClass == "DRUID" then
		mb_Druid(msg)
	elseif playerClass == "HUNTER" then
		mb_Hunter(msg)
	elseif playerClass == "MAGE" then
		mb_Mage(msg)
	elseif playerClass == "PALADIN" then
		mb_Paladin(msg)
	elseif playerClass == "PRIEST" then
		mb_Priest(msg)
	elseif playerClass == "ROGUE" then
		mb_Rogue(msg)
	elseif playerClass == "WARLOCK" then
		mb_Warlock(msg)
	elseif playerClass == "WARRIOR" then
		mb_Warrior(msg)
	else
		mb_Print("Error, playerClass " .. tostring(playerClass) .. " not supported")
	end
end












--- GOOD TO HAVE STUFF BELOW HERE


-- 1.12 API: http://wowwiki.wikia.com/wiki/World_of_Warcraft_API?oldid=303849
-- Range checker for PoH: http://www.wowwiki.com/API_CheckInteractDistance
-- to find out if ur oom: http://www.wowwiki.com/API_IsUsableSpell
-- spell cooldown: http://www.wowwiki.com/API_GetSpellCooldown?oldid=26192 OR http://www.wowwiki.com/API_GetSpellCooldown?direction=next&oldid=101273/ http://www.wowwiki.com/API_GetActionCooldown
-- buffs: http://www.wowwiki.com/API_GetPlayerBuff / http://www.wowwiki.com/API_GetPlayerBuffName / http://www.wowwiki.com/API_GetPlayerBuffTimeLeft / http://www.wowwiki.com/API_UnitBuff / http://www.wowwiki.com/API_UnitDebuff
-- get time to calc with durations etc: http://www.wowwiki.com/API_GetTime
-- Buffname list: http://www.wowwiki.com/index.php?title=Queriable_buff_effects&oldid=277417






-- In game macros:
-- List all buffs and debuffs:
-- /run for i = 1, 32 do local b = UnitBuff("player", i); if b then ChatFrame1:AddMessage("Buff: " .. b); end local d = UnitDebuff("player", i); if d then ChatFrame1:AddMessage("Debuff: " .. d); end end
--
-- List all buffs ids:
-- /run for i = 1, 32 do local a,b,c,d,e,f,g,h,i,j,k = UnitBuff("player", i); if k then ChatFrame1:AddMessage("Buff: " .. k); end end
--
-- List all spells you know and their IDs:
-- /run for i = 1, 1000 do local s = GetSpellName(i, "BOOKTYPE_SPELL"); if s then ChatFrame1:AddMessage(i .. " - " .. s); end end
--
-- Get cooldown left for spellid:
-- /run local s, d = GetSpellCooldown(76, "BOOKTYPE_SPELL"); if d ~= 0 then c = d - (GetTime() - s); ChatFrame1:AddMessage(c); else ChatFrame1:AddMessage("0"); end
--
-- Print which is your current action:
-- /run for i = 1, 1000 do if IsCurrentAction(i) then ChatFrame1:AddMessage(i .. " is current action"); end end
--

--
--
--
-- tons of macros: http://www.wow-one.com/forum/topic/14546-warrior-tanking-macro-priest-heal-multiboxing-macro/page__hl__%2Bbuff+%2Bduration__fromsearch__1

--/run
--	a = UseAction a(43)a(44)a(45)a(46)U=IsAutoRepeatAction ub=UnitBuff ud=UnitDebuff WS="WHISPER" ue=UnitExists uf=UnitIsFriend
--	GAC=GetActionCooldown gt=GetTime sc1,sc2,sc3,sc4,sc5,sc6,tg12,tg34,tg56=0,0,0,0,0,0,0,0,0 bsT=105 saT=23 hmsT=12
--
--/run UIErrorsFrame:Hide() UIErrorsFrame:Clear() c=CastSpellByName u=IsCurrentAction s=SpellStopCasting um=UnitMana UM=UnitManaMax
--	m=SendChatMessage uh=UnitHealth UH=UnitHealthMax p="player" t="target" d=CheckInteractDistance PT="Kokkolarp"
--
--/run
--	sc6 = GetTime()
--  local qwe = 0
--if qwe == 1 then
--	CastSpellByName("Hamstring")
--end
--	a(33)
--	tg56 = sc6-sc5
--	if UnitExists(t) and not UnitIsFriend(p, t) and CheckInteractDistance(t, 3) and x1 == 0 and (hmsD == 0 or tg56 > hmsT) and um(p) >= 10 then
--		sc5 = GetTime()
--		CastSpellByName(hms)
--	end