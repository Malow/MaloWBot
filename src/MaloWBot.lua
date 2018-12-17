local MY_NAME = "MaloWBot"
local MY_ABBREVIATION = "MB"

-- Frame setup for update
local lastUpdate = GetTime()
local function mb_Update()
	if GetTime() >= lastUpdate + 0.5 then
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
mb_gcdSpells = {}
mb_queuedRequests = {}
mb_areaOfEffectMode = false
mb_isAutoAttacking = false
mb_isAutoShooting = false
function mb_OnEvent()
	if event == "ADDON_LOADED" and arg1 == MY_NAME then
		if mb_SV == nil then
			mb_SV = {}
		end
		mb_OnLoad()
	elseif event == "PLAYER_LOGIN" then
		mb_OnPostLoad()
	elseif event == "ZONE_CHANGED_NEW_AREA" then
		if GetRealZoneText() == "Ironforge" or GetRealZoneText() == "Stormwind" then
			mb_shouldRequestBuffs = false
		end
	elseif event == "SPELLCAST_START" or event == "SPELLCAST_CHANNEL_START" then
		mb_isCasting = true
		mb_castStartedTime = GetTime()
	elseif event == "SPELLCAST_STOP" or event == "SPELLCAST_CHANNEL_STOP" or event == "SPELLCAST_INTERRUPTED" or event == "SPELLCAST_FAILED" then
		mb_isCasting = false
	elseif event == "CHAT_MSG_ADDON" and arg1 == "MB" then
        mb_HandleMBCommunication(arg2, arg3, arg4)
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
	elseif event == "START_AUTOREPEAT_SPELL" then
		mb_isAutoShooting = true
	elseif event == "STOP_AUTOREPEAT_SPELL" then
		mb_isAutoShooting = false
	elseif event == "PLAYER_ENTER_COMBAT" then
		mb_isAutoAttacking = true
	elseif event == "PLAYER_LEAVE_COMBAT" then
		mb_isAutoAttacking = false
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
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("TRADE_CLOSED")
f:RegisterEvent("TRADE_SHOW")
f:RegisterEvent("MERCHANT_CLOSED")
f:RegisterEvent("MERCHANT_SHOW")
f:RegisterEvent("GOSSIP_SHOW") -- GOSSIP_CLOSE fires when clicking on a quest, using time-based logic for deciding when gossip is really closed
f:RegisterEvent("TRAINER_CLOSED")
f:RegisterEvent("TRAINER_SHOW")
f:RegisterEvent("START_AUTOREPEAT_SPELL")
f:RegisterEvent("STOP_AUTOREPEAT_SPELL")
f:RegisterEvent("PLAYER_ENTER_COMBAT")
f:RegisterEvent("PLAYER_LEAVE_COMBAT")
f:SetScript("OnEvent", mb_OnEvent)



mb_queuedIncomingRequests = {}
function mb_HandleMBCommunication(arg2, arg3, arg4)
    local channel = arg3
    local from = arg4
    --local requestId, requestType, requestBody = string.match(arg2, "(%d+):(%a+):(.*)") -- string.match doesn't exist in 1.12, use this if you implement it yourself
    local strings = max_SplitString(arg2, ":")
    local messageType = strings[1]
    if messageType == "request" then
        local request = {}
        request.id = strings[2]
        request.type = strings[3]
        request.body = strings[4]
        request.priority = tonumber(strings[5])
        request.from = from
        if mb_registeredRequestsHandlers[request.type] ~= nil then
			if max_GetTableSize(mb_queuedIncomingRequests) > 20 then
				mb_queuedIncomingRequests = {} -- If bot is not running then prevent thousands of requests from queueing up.
			end
			table.insert(mb_queuedIncomingRequests, request)
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
            return
        end

        -- Check if the request was made by me
        local pendingRequest = mb_myPendingRequests[requestId]
        if pendingRequest ~= nil then
            local playerName = strings[3]
            pendingRequest.acceptedBy = playerName
            mb_MyPendingRequestWasAccepted(pendingRequest)
            mb_myPendingRequests[requestId] = nil
            return
        end
    end
end

-- OnLoad, when the addon has loaded. Some external things might not be available here
function mb_OnLoad()
end

mb_classSpecificRunFunction = nil
-- OnPostLoad, called when macros etc. are available
function mb_OnPostLoad()
	mb_CreateMBMacros()
	local playerClass = max_GetClass("player")
	mb_RegisterSharedRequestHandlers(playerClass)
	if playerClass == "DRUID" then
		mb_Druid_OnLoad()
		mb_classSpecificRunFunction = mb_Druid
	elseif playerClass == "HUNTER" then
		mb_Hunter_OnLoad()
		mb_classSpecificRunFunction = mb_Hunter
	elseif playerClass == "MAGE" then
		mb_Mage_OnLoad()
		mb_classSpecificRunFunction = mb_Mage
	elseif playerClass == "PALADIN" then
		mb_Paladin_OnLoad()
		mb_classSpecificRunFunction = mb_Paladin
	elseif playerClass == "PRIEST" then
		mb_Priest_OnLoad()
		mb_classSpecificRunFunction = mb_Priest
	elseif playerClass == "ROGUE" then
		mb_Rogue_OnLoad()
		mb_classSpecificRunFunction = mb_Rogue
	elseif playerClass == "WARLOCK" then
		mb_Warlock_OnLoad()
		mb_classSpecificRunFunction = mb_Warlock
	elseif playerClass == "WARRIOR" then
		mb_Warrior_OnLoad()
		mb_classSpecificRunFunction = mb_Warrior
	else
		mb_Print("Error, playerClass " .. tostring(playerClass) .. " not supported")
	end

	if GetRealZoneText() == "Ironforge" or GetRealZoneText() == "Stormwind" then
		mb_shouldRequestBuffs = false
	end
	mb_Print("Loaded")
end

function mb_CreateMBMacros()
	mb_CreateMacro("MB_Main", "/mb " .. mb_GetConfig()["followTarget"], 37, "7", "MULTIACTIONBAR4BUTTON1")
	mb_CreateMacro("MB_ZoomIn", "/run SetView(3); CameraZoomIn(2);", 38, "8", "MULTIACTIONBAR4BUTTON2")
	if not mb_GetConfig()["followTarget"] == UnitName("player") then
		mb_CreateMacro("MB_DE", "/cast Disenchant", 39, "1", "MULTIACTIONBAR4BUTTON3")
	end
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
	-- Clean up unaccepted pending requests
	local toBeRemovedIds = {}
	for k, v in pairs(mb_myPendingRequests) do
		if v.sentTime + 5 < GetTime() then
			table.insert(toBeRemovedIds, v.id)
		end
	end
	for k, v in pairs(toBeRemovedIds) do
		mb_myPendingRequests[v] = nil
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
	mb_HandleQueuedIncomingRequests()

	if mb_HandleSharedBehaviour(commander) then
		return
	end

	mb_classSpecificRunFunction(commander)
end

function mb_HandleQueuedIncomingRequests()
	for k, v in pairs(mb_queuedIncomingRequests) do
		if mb_ShouldAddRequestToQueue(v) then
			mb_registeredRequestsHandlers[v.type](v)
		end
	end
	mb_queuedIncomingRequests = {}
end

function mb_MakeRequest(requestType, requestBody, requestPriority)
	local requestId = tostring(math.random(9999999999))
	SendAddonMessage("MB", "request:" .. requestId .. ":" .. requestType .. ":" .. requestBody .. ":" .. requestPriority, "RAID")
	local request = {}
	request.type = requestType
	request.body = requestBody
	request.priority = requestPriority
    request.id = requestId
	request.sentTime = GetTime()
	mb_myPendingRequests[requestId] = request
end

function mb_RegisterForRequest(requestType, func)
	mb_registeredRequestsHandlers[requestType] = func
end

function mb_AcceptRequest(request)
	mb_myAcceptedRequests[request.id] = request
	SendAddonMessage("MB", "acceptRequest:" .. request.id .. ":" .. UnitName("player"), "RAID")
end

function mb_HasQueuedRequestOfType(requestType)
	for i = 1, max_GetTableSize(mb_queuedRequests) do
		if mb_queuedRequests[i].type == requestType then
			return true
		end
	end
	return false
end

function mb_AddGCDCheckSpell(spellName)
	table.insert(mb_gcdSpells, max_GetSpellbookId(spellName))
end

function mb_IsOnGCD()
	local numberOfGCDSpells = max_GetTableSize(mb_gcdSpells)
	if numberOfGCDSpells == 0 then
		max_SayRaid("Serious error, I'm trying to check GCD but have not added any GCD-spells")
		return false
	end
	for i = 1, numberOfGCDSpells do
		if not max_IsSpellbookIdOnCooldown(mb_gcdSpells[i]) then
			return false
		end
	end
	return true
end

function mb_ShouldAddRequestToQueue(request)
    local highestPriorityRequest = mb_GetQueuedRequest()
	if highestPriorityRequest == nil then
		return true
	end
    if request.priority > highestPriorityRequest.priority then
        return true
    end
    if max_GetTableSize(mb_queuedRequests) > 2 then
        return false
    end
    return true
end

function mb_GetQueuedRequest(countAttempts)
    local queuedRequestSize = max_GetTableSize(mb_queuedRequests)
	if queuedRequestSize == 0 then
		return nil
	end
    local highestPriorityRequest = nil
	for k, v in pairs(mb_queuedRequests) do
		if highestPriorityRequest == nil then
			highestPriorityRequest = v
		elseif v.priority > highestPriorityRequest.priority then
			highestPriorityRequest = v
		end
	end
	if countAttempts then
		if highestPriorityRequest.attempts == nil then
			highestPriorityRequest.attempts = 1
		else
			highestPriorityRequest.attempts = highestPriorityRequest.attempts + 1
		end
		if highestPriorityRequest.attempts > 100 then
			max_SayRaid("Warning, request of type " .. highestPriorityRequest.type .. " has been attempted " .. highestPriorityRequest.attempts .. " times.")
		end
	end
    return highestPriorityRequest
end

function mb_RequestCompleted(request)
    local queuedRequestSize = max_GetTableSize(mb_queuedRequests)
    for i = 1, queuedRequestSize do
        if mb_queuedRequests[i].id == request.id then
            table.remove(mb_queuedRequests, i)
            return
        end
    end
end

function mb_GetMySpecName()
	return mb_GetConfig()["specs"][UnitName("player")]
end


-- TODO:
--- Test out LogOut() to remove /follow, works in combat? works while casting? If so use it before casting important spells like Evocation
--- On ready-check click away buffs with less than 8 minute duration (don't forget class specific buffs like Ice Armor or sacrificed succubus.
---		Also decline ready-checks if missing buffs or mana or items (healthstone) (and say so in raid)
---		Also check durability is above 10% in all slots, otherwise decline and announce in raid
--- If a trade window is open stop assisting cuz it breaks trade
--- Make accepted requests time out if their throttleTime - 1 has passed
--- Figure out a way to clear up pending requests list, it will grow forever atm
---	Add proper healing-code. When you start healing someone with a cast-time announce that you're doing so and then listen to announces.
---		Add the announced heals to the targets current health until you see your own announcement, then decide if you want to cancel your cast or not.
---		Also scan the target for current health and hots and other stuff to decide if you should cancel.
---	Owners request buffs for their pets
--- Double-request handling can happen if the propose reaches 1 guy after the accept has already been sent. Shouldn't happen though
--- Automatic Gold-spreading
---	Sit/stand logic based on error-messages, see RogueSpam addon.
---	Implement CD-usage-logic, use CD's on CD? Or use some sort of request system?
--- Expire queued accepted requests if they've been in queue their entire throttle time?
---	Warlock:
---		Healthstone, need some specific mode for this, don't wanna use up tons of soulshards or random shitty instances
---		Pets, 2 modes, imp-bitch or succu-sacc, swap for each warlock (using target and commands), also a pet-stay command.
---		Deathcoil? Is Drain Life even worth it?
---		Spellstones? 1% crit if nothing better, use for 900 spell absorb too
---		Hellfire during AoE? Probably not while we're progressing fire-instances. Maybe in a max-burn AoE mode.
---	Mage:
---     Polymorph requests
---     Counterspell, might be hard, gotta scan combat log for % begins casting %, check libcast in PFUI
---		Wand if oom
---		Fire/Frost ward
--- Priest:
---     Buff shadow protection
---     Holy should be casting/stop-casting greater heals (ranked depending on incoming damage) on tanks
---     Disc priest will probably have little to do, should be a bit more aggressive with renewing raid I guess
---     All priests should be keeping renew up 24/7 on tanking tanks
---     PW:S if below X health or tank below % HP
---     Can swap groups in combat? If so priests could be spamming PoH with swapping people in who need it.
---		Do abolish disease, check mana costs of the 2 versions
---		Fear ward request
---		Wand instead of attack if ranged, (does wand cause GCD?)
--- Druids:
---     Tranquility like PoH in priest
---     Rejuvenation and Regrowth on tanking tanks 24/7
---     Swiftmend
---     Cast/Stop-cast HT/Regrowth spam on tanks? Rejuvenation on raid?
---		Add logic for Feral DPS and Feral tank
---		Tank VS DPS VS Healer distinction for Sanctuary/Salvation
---		Do abolish poison, check mana costs of the 2 versions
---		Innervate, who is it best on? Priests? Use requests?
---		Combat ress
---			Also need to implement rebuffing after combat ress then kinda
---	Paladins:
---		request auras
---		Add logic for ret pal
---		Add holy shock for the few that has it
---		Consecration in a max-burn AoE mode?
---		Divine Favor
--- Hunter:
---		Pet-logic (reagent food, auto-feed, auto-call/revive, attacking, mend pet)
---			All-in-one pet macro:     /run local c=CastSpellByName if UnitExists("pet") then if UnitHealth("pet")==0 then c("Revive Pet") elseif GetPetHappiness()~=nil and GetPetHappiness()~=3 then c("Feed Pet") PickupContainerItem(0, 13) else c("Dismiss Pet") end else c("Call Pet") end
---		Add Aimed-shot to the rotation, maybe see https://github.com/Geigerkind/OneButtonHunter/blob/master/OneButtonHunter.lua, though it seems to be bugged
---		Make them melee-hit with Raptor strike if in melee range.
--- Say raid, "I am literally out of X" when out of reagents and trying to buff with them.
--- Rename followTarget to commander
--- Performance:
--- 	Don't need to check for buffs every frame
---		Don't need to request water every frame
---	Repair-report, Should be able to report lowest item % in /raid
--- Blacklist LoS targets when using mb_IsSpellInRange for 1 sec, use the Rogue-Spam way to detect error message of LoS
---
---
---
---
---
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
-- Tooltip scraping: https://github.com/Geigerkind/OneButtonHunter/blob/master/OneButtonHunter.lua
--		It scrapes both %atk speed on quiver item and which action slot that is "Aimed shot"





-- In game macros:
-- List all buffs and debuffs:
-- /run for i = 1, 32 do local b = UnitBuff("player", i); if b then ChatFrame1:AddMessage("Buff: " .. b); end local d = UnitDebuff("player", i); if d then ChatFrame1:AddMessage("Debuff: " .. d); end end
--
-- List all spells you know and their IDs:
-- /run for i = 1, 1000 do local s, r = GetSpellName(i, "BOOKTYPE_SPELL"); if s then ChatFrame1:AddMessage(i .. " - " .. s .. " - " .. tostring(r)); end end
--
-- Get cooldown left for spellbookId:
-- /run local s, d = GetSpellCooldown(76, "BOOKTYPE_SPELL"); if d ~= 0 then c = d - (GetTime() - s); ChatFrame1:AddMessage(c); else ChatFrame1:AddMessage("0"); end

-- Is spellbookId spell on cooldown:
-- /run local s, d = GetSpellCooldown(31, "BOOKTYPE_SPELL"); if d ~= 0 then ChatFrame1:AddMessage("true"); else ChatFrame1:AddMessage("false"); end
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