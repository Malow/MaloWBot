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

function mb_DebugPrint(msg)
    if max_GetClass("player") == "PRIEST" then
        mb_Print("Debug: " .. tostring(msg))
    end
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
mb_isReadyChecking = false
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
		if mb_lastAttemptedCast ~= nil and mb_lastAttemptedCast.onStartCallback ~= nil then
			mb_lastAttemptedCast.onStartCallback(mb_lastAttemptedCast)
		end
		mb_castStartedTime = GetTime()
	elseif event == "SPELLCAST_STOP" or event == "SPELLCAST_CHANNEL_STOP" or event == "SPELLCAST_INTERRUPTED" or event == "SPELLCAST_FAILED" then
		mb_isCasting = false
		if event == "SPELLCAST_INTERRUPTED" or event == "SPELLCAST_FAILED" then
			if mb_lastAttemptedCast ~= nil and mb_lastAttemptedCast.onFailCallback ~= nil then
				mb_lastAttemptedCast.onFailCallback(mb_lastAttemptedCast)
			end
		end
		mb_lastAttemptedCast = nil
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
	elseif event == "PLAYER_DEAD" then
		mb_areaOfEffectMode = false
		if mb_GetMyCommanderName() == UnitName("player") then
			mb_shouldRequestBuffs = false
			mb_MakeRequest("requestBuffsMode", "off", REQUEST_PRIORITY.COMMAND)
		end
	elseif event == "READY_CHECK" then
		mb_isReadyChecking = true
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
f:RegisterEvent("PLAYER_DEAD")
f:RegisterEvent("READY_CHECK")
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
	SetBinding("0","TURNORACTION")
	local playerClass = max_GetClass("player")
	mb_HandleSharedBehaviourPostLoad(playerClass)
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

	mb_OriginalOnUIErrorEventFunction = UIErrorsFrame_OnEvent
	UIErrorsFrame_OnEvent = mb_OnUIErrorEvent

	mb_Print("Loaded")
end

function mb_CreateMBMacros()
	mb_CreateMacro("MB_Main", "/mb " .. mb_GetMyCommanderName(), 37, "7", "MULTIACTIONBAR4BUTTON1")
	mb_CreateMacro("MB_ZoomIn", "/run SetView(3); CameraZoomIn(2);", 38, "8", "MULTIACTIONBAR4BUTTON2")
	if mb_GetMyCommanderName() ~= UnitName("player") then
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
	mb_RebindMovementKeyIfNeeded()
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
	if request.priority == nil then
		mb_Print(request.type)
		mb_Print(request.from)
		return
	end
	if request.priority > 100 then
		return true
	end
    local highestPriorityRequest = mb_GetQueuedRequest()
	if highestPriorityRequest == nil then
		return true
	end
    if request.priority > highestPriorityRequest.priority then
        return true
    end
    if max_GetTableSize(mb_queuedRequests) > 0 then
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
			max_SayRaid("Warning, request of type " .. highestPriorityRequest.type .. " from " .. highestPriorityRequest.from .. " has been attempted " .. highestPriorityRequest.attempts .. " times.")
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

mb_lastAttemptedCast = nil
function mb_CastSpellByNameWithCallbacks(spellName, target, callbacks)
	mb_lastAttemptedCast = {}
	mb_lastAttemptedCast.spellName = spellName
	mb_lastAttemptedCast.startTime = GetTime()
	mb_lastAttemptedCast.target = target
	if callbacks ~= nil then
		mb_lastAttemptedCast.onStartCallback = callbacks.onStart
		mb_lastAttemptedCast.onFailCallback = callbacks.onFail
	end
	CastSpellByName(spellName, false)
end

function mb_CastSpellByNameOnRaidMemberWithCallbacks(spellName, target, callbacks)
	local retarget = false
	if UnitIsFriend("player", "target") then
		ClearTarget()
		retarget = true
	end
	mb_CastSpellByNameWithCallbacks(spellName, target, callbacks)
	SpellTargetUnit(target)
	SpellStopTargeting()
	if retarget then
		TargetLastTarget()
	end
end

mb_lastFacingWrongWayTime = 0
function mb_OnUIErrorEvent(event, message, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
	if message == "Target needs to be in front of you" then
		mb_lastFacingWrongWayTime = GetTime()
	end
	mb_OriginalOnUIErrorEventFunction(event, message, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
end

mb_shouldFuckOffAt = 0
function mb_RebindMovementKeyIfNeeded()
	if mb_shouldFuckOffAt + 3 > GetTime() then
		SetBinding("9", "MOVEFORWARD")
		return
	end
	if mb_lastFacingWrongWayTime + 0.5 > GetTime() then
		SetBinding("9", "TURNLEFT")
		return
	end
	SetBinding("9", nil)
end


-- TODO:
--- Test out LogOut() to remove /follow, works in combat? works while casting? If so use it before casting important spells like Evocation
--- On ready-check click away buffs with less than 8 minute duration (don't forget class specific buffs like Ice Armor or sacrificed succubus.
---		Also decline ready-checks if missing buffs or mana or items (healthstone) (and say so in raid)
---		Also check durability is above 10% in all slots, otherwise decline and announce in raid
---	Owners request buffs for their pets
--- Double-request handling can happen if the propose reaches 1 guy after the accept has already been sent. Shouldn't happen though
--- Automatic Gold-spreading to one guy, automatic reagent-spreading from one guy, one guy is enough to open reagent vendor to buy everything the whole raid needs.
---		Need a new type of request for this where he asks for orders, waits 1 sec, and then buys everything, and then he automatically trades it when possible
---	Sit/stand logic based on error-messages, see RogueSpam addon.
---	Implement CD-usage-logic, use CD's on CD? Or use some sort of request system?
--- Expire queued accepted requests if they've been in queue their entire throttle time?
---	Warlock:
---		Pets, 2 modes, imp-bitch or succu-sacc, swap for each warlock (using target and commands), also a pet-stay command.
---		Deathcoil? Is Drain Life even worth it?
---		Spellstones? 1% crit if nothing better, use for 900 spell absorb too
---		Hellfire during AoE? Probably not while we're progressing fire-instances. Maybe in a max-burn AoE mode.
---	Mage:
---     Polymorph requests
---     Counterspell, might be hard, gotta scan combat log for % begins casting %, check libcast in PFUI. Better as request?
---		Wand if oom
---		Fire/Frost ward
---		Cold snap
--- Priest:
---     PW:S if below X health or tank below % HP
---     Can swap groups in combat? If so priests could be spamming PoH with swapping people in who need it.
---		Do abolish disease, check mana costs of the 2 versions, though it's kinda messy since you can't just spam do it since it's a buff, so multiple druids can hit the same target...
---		Wand instead of attack if ranged, (does wand cause GCD?)
---		On aggro cast Fade
--- Druids:
---     Tranquility like PoH in priest
---     Swiftmend
---		Add logic for Feral DPS and Feral tank
---		Do abolish poison, though it's kinda messy since you can't just spam do it since it's a buff, so multiple druids can hit the same target...
---		Innervate, who is it best on? Priests? Use requests?
---		Combat ress
---			Also need to implement rebuffing after combat ress then kinda
---	Paladins:
---		request specific auras
---		Add logic for ret pal
---		Add holy shock for the few that has it
---		Consecration in a max-burn AoE mode?
---		Divine Favor
--- Hunter:
---		Pet-logic (reagent food, auto-feed, auto-call/revive, attacking, mend pet)
---			All-in-one pet macro:     /run local c=CastSpellByName if UnitExists("pet") then if UnitHealth("pet")==0 then c("Revive Pet") elseif GetPetHappiness()~=nil and GetPetHappiness()~=3 then c("Feed Pet") PickupContainerItem(0, 13) else c("Dismiss Pet") end else c("Call Pet") end
---		Add Aimed-shot to the rotation, maybe see https://github.com/Geigerkind/OneButtonHunter/blob/master/OneButtonHunter.lua, though it seems to be bugged
---		Make them melee-hit with Raptor strike and mongoose bite if in melee range?
---	Warrior:
---		Battle-shout, make it smart so that it rebuffs party mates within range if needed and not only self. Also make non-tanking tanks refresh it when it has like 5 sec duration left to prevent tanking tanks from wasting the rage
---		Prot:
---			Mocking blow taunt if Taunt is on CD
---			Is rend ever worth using as prot?
---			Intercept/charge, gonna make picking shit up way easier if they actually charge their targets, intercept too for resisted taunts so the mob runs away
---			Dual-tank mode, use cleave then and swap between both targets and check actual threat.
---			Berserker rage zerk stance dance? Both as fear ward kinda and to increase rage.
--- Say raid, "I am literally out of X" when out of reagents and trying to buff with them.
--- Rename followTarget to commander
--- Performance:
--- 	Don't need to check for buffs every frame
---		Don't need to request water every frame
---	Repair-report, Should be able to report lowest item % in /raid
---	Bag-space report, each responds with how many bag spaces free, not as SayRaid but by responding to the request kinda and then the guy requesting sees the printout.
--- Blacklist LoS targets when using mb_IsSpellInRange for 1 sec, use the Rogue-Spam way to detect error message of LoS
--- IsActionInRange fails for resses, spend some more time looking into it to see if we can fix it
---	Manual-playing mode where the bot doesn't play by itself, but it still makes broadcasts and requests stuff. (kinda hard due to for example warrior DTPS broad-casting is deep in the class-specific function)
--- Enable/disable healthstone trades modes?
--- Consumables
---		Add a watch for it.
---		Add them to be ignored for trade over a certain quantity (don't want them to trade all their pots when they're inventory dumpers)
---		"Try-hard mode" on/off, which uses flasks and shit, and potions in combat.
--- Crown-control
---		Request target to be CCd, people the raid will automatically accept depending on what kind of target it is and if they can CC.
---			No such thing as focus, gonna need to either TargetNearestEnemy (only works in cone in front) or use TargetLastTarget/Enemy and then like after every assist and using DPS spell doing that to retarget the CC target.
---	iscasting logic is a mess, mb_isCasting, started cast etc. Then also "lastAttemptedSpell", clear it up
---	Auto-target mode. TargetNearestEnemy spam and just attack whatever is possible. For DPS maybe 1 person should be the "leader" and set skull, and the rest should follow that.
---		Tanks should automatically pick up untanked targets with this
---	Don't DPS if you risk overthreat, use KLM API? Need a way to disable it for solo/5-mans
---
---	Heal-visualizer, shows each broadcasted heal from each healer in a list and their target.
--- Enemy-target logic, frame that displays enemy targets and who "has" that target (tank or CC)
---		Automatic marking of raid-symbol and a commander does "/mb target tank" or "/mb target cc"
---		Automatic DPSing of these targets in order, using assist on the tank who has it, or on the guy who CCs it.
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