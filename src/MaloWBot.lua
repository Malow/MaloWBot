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
mb_castStartedTime = nil
mb_isCasting = false
mb_registeredProposedRequestsHandlers = {}
mb_registeredAcceptedRequestsHandlers = {}
mb_myAcceptedRequests = {}
mb_gcdSpell = {}
function mb_OnEvent()
	if event == "ADDON_LOADED" and arg1 == MY_NAME then
		mb_OnLoad()
	elseif event == "PLAYER_LOGIN" then
		mb_OnPostLoad()
	elseif event == "SPELLCAST_START" or event == "SPELLCAST_CHANNEL_START" then
		mb_isCasting = true
		mb_castStartedTime = GetTime()
	elseif event == "SPELLCAST_STOP" or event == "SPELLCAST_CHANNEL_STOP" or event == "SPELLCAST_INTERRUPTED" or event == "SPELLCAST_FAILED" then
		mb_isCasting = false
	elseif event == "CHAT_MSG_ADDON" and arg1 == "MB" then
		local channel = arg3
		local from = arg4
		--local requestId, requestType, requestBody = string.match(arg2, "(%d+):(%a+):(.*)") -- string.match doesn't exist in 1.12, use this if you implement it yourself
		local strings = max_SplitString(arg2, ":")
		local messageType = strings[1]
		if messageType == "request" then
			local requestId = strings[2]
			local requestType = strings[3]
			local requestBody = strings[4]
			if mb_registeredProposedRequestsHandlers[requestType] ~= nil then
				mb_registeredProposedRequestsHandlers[requestType](requestId, requestType, requestBody, from)
			end
		elseif messageType == "acceptRequest" then
			local requestId = strings[2]
			local request = mb_myAcceptedRequests[requestId]
			if request ~= nil then
				local playerName = strings[3]
				if playerName == UnitName("player") then
					if mb_registeredAcceptedRequestsHandlers[request.requestType] ~= nil then
						mb_registeredAcceptedRequestsHandlers[request.requestType](request)
					else
						SendChatMessage("Kinda serious error over here, CTRL+F for: 892459824", "RAID", "Common")
					end
				else
					mb_myAcceptedRequests[requestId] = nil
				end
			end
		end
	end
end
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("SPELLCAST_START")
f:RegisterEvent("SPELLCAST_CHANNEL_START")
f:RegisterEvent("SPELLCAST_STOP")
f:RegisterEvent("SPELLCAST_CHANNEL_STOP")
f:RegisterEvent("SPELLCAST_INTERRUPTED")
f:RegisterEvent("SPELLCAST_FAILED")
f:RegisterEvent("CHAT_MSG_ADDON")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", mb_OnEvent)


-- OnLoad, when the addon has loaded. Some external things might not be available here
function mb_OnLoad()
end

-- OnPostLoad, called when macros are available
function mb_OnPostLoad()
	mb_CreateMBMacro()
	mb_CreateTrainMacro()
	mb_RegisterSharedRequestHandlers()
	local playerClass = max_GetClass("player")
	if playerClass == "DRUID" then
		mb_Druid_OnLoad()
	elseif playerClass == "HUNTER" then
		mb_Hunter_OnLoad()
	elseif playerClass == "MAGE" then
		mb_Mage_OnLoad()
	elseif playerClass == "PALADIN" then
		mb_Paladin_OnLoad()
	elseif playerClass == "PRIEST" then
		mb_Priest_OnLoad()
	elseif playerClass == "ROGUE" then
		mb_Rogue_OnLoad()
	elseif playerClass == "WARLOCK" then
		mb_Warlock_OnLoad()
	elseif playerClass == "WARRIOR" then
		mb_Warrior_OnLoad()
	else
		mb_Print("Error, playerClass " .. tostring(playerClass) .. " not supported")
	end

	mb_Print("Loaded")
end

function mb_CreateMBMacro()
	local macroId = GetMacroIndexByName("MB")
	if macroId > 0 then
		EditMacro(macroId, "MB", 12, "/mb " .. mb_GetConfig()["followTarget"], 1, 1)
	else
		macroId = CreateMacro("MB", 12, "/mb " .. mb_GetConfig()["followTarget"], 1, 1)
	end
	PickupMacro(macroId)
	PlaceAction(37) -- RightActionBarSlot1
	ClearCursor()
	SetBinding("7","MULTIACTIONBAR4BUTTON1")
end

function mb_CreateTrainMacro()
	local macroId = GetMacroIndexByName("MBtrain")
	if macroId > 0 then
		EditMacro(macroId, "MBtrain", 11, "/mb train", 1, 1)
	else
		macroId = CreateMacro("MBtrain", 11, "/mb train", 1, 1)
	end
	PickupMacro(macroId)
	PlaceAction(1)
	ClearCursor()
end

-- OnUpdate
function mb_OnUpdate()
end

-- OnCmd
function mb_OnCmd(msg)
	if mb_HandleSpecialSlashCommand(msg) then
		return
	end

	mb_RunBot(msg)
end

function mb_RunBot(followTarget)
	if mb_HandleSharedBehaviour() then
		return
	end

	local playerClass = max_GetClass("player")
	if playerClass == "DRUID" then
		mb_Druid(followTarget)
	elseif playerClass == "HUNTER" then
		mb_Hunter(followTarget)
	elseif playerClass == "MAGE" then
		mb_Mage(followTarget)
	elseif playerClass == "PALADIN" then
		mb_Paladin(followTarget)
	elseif playerClass == "PRIEST" then
		mb_Priest(followTarget)
	elseif playerClass == "ROGUE" then
		mb_Rogue(followTarget)
	elseif playerClass == "WARLOCK" then
		mb_Warlock(followTarget)
	elseif playerClass == "WARRIOR" then
		mb_Warrior(followTarget)
	else
		mb_Print("Error, playerClass " .. tostring(playerClass) .. " not supported")
	end
end

function mb_MakeRequest(requestType, requestBody)
	local requestId = math.random(9999999999)
	SendAddonMessage("MB", "request:" .. requestId .. ":" .. requestType .. ":" .. requestBody, "RAID")
end

function mb_RegisterForProposedRequest(requestType, func)
	mb_registeredProposedRequestsHandlers[requestType] = func
end

function mb_RegisterForAcceptedRequest(requestType, func)
	mb_registeredAcceptedRequestsHandlers[requestType] = func
end

function mb_AcceptRequest(requestId, requestType, requestBody)
	local request = {}
	request.requestType = requestType
	request.requestBody = requestBody
	mb_myAcceptedRequests[requestId] = request
	SendAddonMessage("MB", "acceptRequest:" .. requestId .. ":" .. UnitName("player"), "RAID")
end



-- TODO:
-- Test out LogOut() to remove /follow, works in combat? works while casting?
-- On ready-check click away buffs with less than 8 minute duration
-- If a trade window is open stop assisting cuz it breaks trade


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