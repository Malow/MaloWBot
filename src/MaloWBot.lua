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

-- Commands hook
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
mb_isTrading = false
mb_isVendoring = false
mb_isGossiping = false
mb_gossipOpenedTime = 0
mb_isTraining = false
mb_registeredRequestsHandlers = {}
mb_myAcceptedRequests = {}
mb_myPendingRequests = {}
mb_gcdSpell = {}
mb_queuedRequests = {}
mb_areaOfEffectMode = false
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
		if messageType == "request" and max_GetTableSize(mb_queuedRequests) == 0 then
			local requestId = strings[2]
			local requestType = strings[3]
			local requestBody = strings[4]
			if mb_registeredRequestsHandlers[requestType] ~= nil then
				mb_registeredRequestsHandlers[requestType](requestId, requestType, requestBody, from)
			end
		elseif messageType == "acceptRequest" then
			local requestId = strings[2]

			-- Check if the request was one that I accepted, and if then I was the first to accept it
			local request = mb_myAcceptedRequests[requestId]
			if request ~= nil then
				local playerName = strings[3]
				if playerName == UnitName("player") then
					table.insert(mb_queuedRequests, request)
				end
				mb_myAcceptedRequests[requestId] = nil
			end

			-- Check if the request was made by me
			local pendingRequest = mb_myPendingRequests[requestId]
			if pendingRequest ~= nil then
				local playerName = strings[3]
				pendingRequest.acceptedBy = playerName
				mb_MyPendingRequestWasAccepted(pendingRequest)
				mb_myPendingRequests[requestId] = nil
			end
		end
	elseif event == "TRADE_CLOSED" then
		mb_isTrading = false
	elseif event == "TRADE_SHOW" then
		mb_isTrading = true
	elseif event == "MERCHANT_CLOSED" then
		mb_isVendoring = false
	elseif event == "MERCHANT_SHOW" then
		mb_isVendoring = true
	elseif event == "GOSSIP_SHOW" then
		mb_gossipOpenedTime = GetTime()
		mb_isGossiping = true
	elseif event == "TRAINER_CLOSED" then
		mb_isTraining = false
	elseif event == "TRAINER_SHOW" then
		mb_isTraining = true
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
f:RegisterEvent("TRADE_CLOSED")
f:RegisterEvent("TRADE_SHOW")
f:RegisterEvent("MERCHANT_CLOSED")
f:RegisterEvent("MERCHANT_SHOW")
f:RegisterEvent("GOSSIP_SHOW") -- GOSSIP_CLOSE fires when clicking on a quest, using time-based logic for deciding when gossip is really closed
f:RegisterEvent("TRAINER_CLOSED")
f:RegisterEvent("TRAINER_SHOW")
f:SetScript("OnEvent", mb_OnEvent)


-- OnLoad, when the addon has loaded. Some external things might not be available here
function mb_OnLoad()
end

-- OnPostLoad, called when macros etc. are available
function mb_OnPostLoad()
	mb_CreateMBMacro()
	mb_RegisterMassCommandRequestHandlers()
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
	mb_CreateMacro("MB_Main", "/mb " .. mb_GetConfig()["followTarget"], 37, "7", "MULTIACTIONBAR4BUTTON1")
	mb_CreateMacro("MB_ZoomIn", "/run SetView(3); CameraZoomIn(2);", 38, "8", "MULTIACTIONBAR4BUTTON2")
end

function mb_CreateMacro(name, body, actionSlot, bindingKey, bindingName)
	local macroId = GetMacroIndexByName(name)
	if macroId > 0 then
		EditMacro(macroId, name, 12, body, 1, 1)
	else
		macroId = CreateMacro(name, 12, body, 1, 1)
	end
	PickupMacro(macroId)
	PlaceAction(actionSlot)
	ClearCursor()
	SetBinding(bindingKey, bindingName)
end

-- OnUpdate
function mb_OnUpdate()
	if mb_isGossiping and mb_gossipOpenedTime + 5 < GetTime() then
		mb_isGossiping = false
	end
end

-- OnCmd
function mb_OnCmd(msg)
	if mb_HandleSpecialSlashCommand(msg) then
		return
	end

	mb_RunBot(msg)
end

function mb_RunBot(commander)
	if mb_HandleSharedBehaviour(commander) then
		return
	end

	local playerClass = max_GetClass("player")
	if playerClass == "DRUID" then
		mb_Druid(commander)
	elseif playerClass == "HUNTER" then
		mb_Hunter(commander)
	elseif playerClass == "MAGE" then
		mb_Mage(commander)
	elseif playerClass == "PALADIN" then
		mb_Paladin(commander)
	elseif playerClass == "PRIEST" then
		mb_Priest(commander)
	elseif playerClass == "ROGUE" then
		mb_Rogue(commander)
	elseif playerClass == "WARLOCK" then
		mb_Warlock(commander)
	elseif playerClass == "WARRIOR" then
		mb_Warrior(commander)
	else
		mb_Print("Error, playerClass " .. tostring(playerClass) .. " not supported")
	end
end

function mb_MakeRequest(requestType, requestBody)
	local requestId = tostring(math.random(9999999999))
	SendAddonMessage("MB", "request:" .. requestId .. ":" .. requestType .. ":" .. requestBody, "RAID")
	local request = {}
	request.requestType = requestType
	request.requestBody = requestBody
	mb_myPendingRequests[requestId] = request
end

function mb_RegisterForRequest(requestType, func)
	mb_registeredRequestsHandlers[requestType] = func
end

function mb_AcceptRequest(requestId, requestType, requestBody)
	local request = {}
	request.requestType = requestType
	request.requestBody = requestBody
	mb_myAcceptedRequests[requestId] = request
	SendAddonMessage("MB", "acceptRequest:" .. requestId .. ":" .. UnitName("player"), "RAID")
end

function mb_HasQueuedRequestOfType(requestType)
	for i = 1, max_GetTableSize(mb_queuedRequests) do
		if mb_queuedRequests[i].type == requestType then
			return true
		end
	end
	return false
end



-- TODO:
--- Test out LogOut() to remove /follow, works in combat? works while casting?
--- On ready-check click away buffs with less than 8 minute duration
--- If a trade window is open stop assisting cuz it breaks trade
--- Make accepted requests time out if their throttleTime - 1 has passed
--- Figure out a way to clear up pending requests list, it will grow forever atm
--- Think about only allowing 1 request at a time, is it smart? Prevents for example mage water from accepting too many, but also might not be efficient.
---	Add healing-code. When you start healing someone with a cast-time announce that you're doing so and then listen to announces.
---		Add the announced heals to the targets current health until you see your own announcement, then decide if you want to cancel your cast or not.
---		Also scan the target for current health and hots and other stuff to decide if you should cancel.
---	Owners request buffs for their pets
---	Reagent watch
--- Proper range-check of spells
---	Add GCD-checks for buffing requests
---	Decursing + Dispelling + Depoisoning + Dediseasing
--- Double-request handling can happen if the propose happens for 1 guy after the accept has already been sent.
--- Add ressing prio, other ressers first
---	AOE mode on/off
--- Prioritize ressing over buffs, maybe prio wisdom over ressing?
--- Automatic Gold-spreading
---	Sit/stand logic based on error-messages, see RogueSpam addon.
---	Warlock:
---		Healthstone
---		Pets
---		Curses
---		Soulstone request
---
---





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