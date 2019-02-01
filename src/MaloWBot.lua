function mb_OnLuaErrorEvent(event, message, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
	max_SayRaid("I received lua-error: " .. tostring(event))
	mb_OriginalLuaErrorMessageFunction(event, message, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
end
mb_OriginalLuaErrorMessageFunction = _ERRORMESSAGE
mb_OriginalLuaMessageFunction = message
_ERRORMESSAGE = mb_OnLuaErrorEvent
message = mb_OnLuaErrorEvent
-- Above we're setting the lua-error redirects so that chars print in raid if they get a lua error on load. This has to be at the very top

local MY_NAME = "MaloWBot"
local MY_ABBREVIATION = "MB"

-- Frame setup for update
local lastUpdate = 0
local function mb_Update()
    mb_cachedTime = GetTime()
	if mb_cachedTime >= lastUpdate + 1 then
		lastUpdate = mb_cachedTime
		mb_OnUpdate()
    end
end
local f = CreateFrame("frame", MY_NAME .. "Frame", UIParent)
f:SetScript("OnUpdate", mb_Update)
f:Show()

-- Commands hook
SlashCmdList[MY_ABBREVIATION .. "COMMAND"] = function(msg)
	mb_OnCmd(msg)
end
SLASH_MBCOMMAND1 = "/" .. MY_ABBREVIATION

SlashCmdList[MY_ABBREVIATION .. "R" .. "COMMAND"] = function(msg)
	mb_OnRun()
end
SLASH_MBRCOMMAND1 = "/" .. MY_ABBREVIATION .. "R"

-- Prints message in chatbox
function mb_Print(msg)
	ChatFrame1:AddMessage(MY_ABBREVIATION .. ": " .. tostring(msg))
end

function mb_DebugPrint(msg)
    if max_GetClass("player") == "PRIEST" then
        mb_Print("Debug: " .. tostring(msg))
    end
end

mb_toolTip = CreateFrame("GameTooltip", "MaloWBotToolTip", UIParent, "GameTooltipTemplate")

mb_cachedTime = 0
function mb_GetTime()
    return mb_cachedTime
end

-- Events
mb_isTrading = false
mb_isVendoring = false
mb_isGossiping = false
mb_gossipOpenedTime = 0
mb_isTraining = false
mb_registeredRequestsHandlers = {}
mb_myAcceptedRequests = {}
mb_myPendingRequests = {}
mb_queuedIncomingComms = {}
mb_gcdSpells = {}
mb_queuedRequests = {}
mb_areaOfEffectMode = false
mb_isAutoAttacking = false
mb_isAutoShooting = false
mb_isReadyChecking = false
mb_combatStartedTime = 0
mb_currentBossModule = {}
mb_shouldDecurse = true
mb_shouldDepoison = true
mb_shouldDispel = true
mb_consumablesLevel = 0
mb_shouldDotRepair = false
mb_shouldAutoTurnToFace = true
function mb_OnEvent()
	if event == "CHAT_MSG_ADDON" and arg1 == "MB" then
		if max_GetTableSize(mb_queuedIncomingComms) > 30 then
			mb_queuedIncomingComms = {} -- If bot is not running or if we're lagging then prevent thousands of requests from queueing up.
		end
		local mbCom = {}
		mbCom.msg = arg2
		mbCom.from = arg4
		table.insert(mb_queuedIncomingComms, mbCom)
	elseif event == "START_AUTOREPEAT_SPELL" then
		mb_isAutoShooting = true
	elseif event == "STOP_AUTOREPEAT_SPELL" then
		mb_isAutoShooting = false
	elseif event == "PLAYER_ENTER_COMBAT" then
		mb_isAutoAttacking = true
	elseif event == "PLAYER_LEAVE_COMBAT" then
		mb_isAutoAttacking = false
	elseif event == "ADDON_LOADED" and arg1 == MY_NAME then
		if mb_SV == nil then
			mb_SV = {}
		end
		mb_OnLoad()
	elseif event == "PLAYER_LOGIN" then
		mb_OnLogin()
	elseif event == "ZONE_CHANGED_NEW_AREA" then
		if GetRealZoneText() == "Ironforge" or GetRealZoneText() == "Stormwind" then
			mb_shouldRequestBuffs = false
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
		mb_gossipOpenedTime = mb_GetTime()
		mb_isGossiping = true
	elseif event == "TRAINER_CLOSED" then
		mb_isTraining = false
	elseif event == "TRAINER_SHOW" then
		mb_isTraining = true
	elseif event == "PLAYER_REGEN_ENABLED" then
		mb_queuedUseConsumables = {}
		mb_consumablesLevel = 0
	elseif event == "PLAYER_REGEN_DISABLED" then
		mb_combatStartedTime = mb_GetTime()
	elseif event == "PLAYER_DEAD" then
		mb_CrowdControlModule_OnSelfDeath()
		mb_queuedUseConsumables = {}
		mb_areaOfEffectMode = false
        mb_shouldRequestBuffs = false
		if mb_GetMyCommanderName() == UnitName("player") then
			mb_shouldRequestBuffs = false
			mb_MakeRequest("requestBuffsMode", "off", REQUEST_PRIORITY.COMMAND)
		end
	elseif event == "READY_CHECK" then
		mb_isReadyChecking = true
	elseif event == "PLAYER_ALIVE" or event == "PLAYER_UNGHOST" then
		mb_shouldDotRepair = true
	end
end
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("CHAT_MSG_ADDON")
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
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_ALIVE")
f:RegisterEvent("PLAYER_UNGHOST")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", mb_OnEvent)

function mb_HandleMBCommunication(msg, from)
    --local requestId, requestType, requestBody = string.match(arg2, "(%d+):(%a+):(.*)") -- string.match doesn't exist in 1.12, use this if you implement it yourself
    local strings = max_SplitString(msg, ":")
    local messageType = strings[1]
    if messageType == "request" then
        local request = {}
        request.id = strings[2]
        request.type = strings[3]
        request.body = strings[4]
        request.priority = tonumber(strings[5])
        request.from = from
        if mb_registeredRequestsHandlers[request.type] ~= nil then
			if mb_ShouldHandleRequest(request) then
				mb_registeredRequestsHandlers[request.type](request)
			end
        end
    elseif messageType == "acceptRequest" then
        local requestId = strings[2]

        -- Check if the request was one that I accepted, and if then I was the first to accept it
        local request = mb_myAcceptedRequests[requestId]
        if request ~= nil then
            local playerName = from
            if playerName == UnitName("player") then
                table.insert(mb_queuedRequests, request)
            end
            mb_myAcceptedRequests[requestId] = nil
            return
        end

        -- Check if the request was made by me
        local pendingRequest = mb_myPendingRequests[requestId]
        if pendingRequest ~= nil then
            local playerName = from
            pendingRequest.acceptedBy = playerName
            mb_MyPendingRequestWasAccepted(pendingRequest)
            mb_myPendingRequests[requestId] = nil
            return
        end
    end
end

-- OnLoad, when the addon has loaded. Some external things might not be available here
function mb_OnLoad()
	mb_OriginalOnUIErrorEventFunction = UIErrorsFrame_OnEvent
	UIErrorsFrame_OnEvent = mb_OnGameErrorEvent
end

-- OnLogin, when all addons are finished loading
function mb_OnLogin()
	mb_HandleSharedBehaviourOnLogin(max_GetClass("player"))

	ChatFrame1.editBox.stickyType = "GUILD" -- Automatically set /g as default chat channel
	ChatFrame1.editBox.chatType = "GUILD" -- Automatically set /g as default chat channel
	SetCVar("autoSelfCast", 0)
	mb_CreateMBMacros()
	mb_BindKey("0","TURNORACTION")

	SetBinding("V", nil)
	SetBinding("SHIFT-V", nil)
	SetBinding("CTRL-V", nil)
	SetBinding("ALT-V", nil)
	SetBinding("F5", nil)
	SetBinding("F6", nil)
	SetBinding("F7", nil)
	SetBinding("F8", nil)
	SetBinding("F9", nil)
	SetBinding("F10", nil)
	SetBinding("F11", nil)
	SetBinding("F12", nil)
	mb_Print("Loaded")
end

mb_classSpecificRunFunction = nil
-- OnPostLoad, called the first time the bot is run, everything should be available then.
function mb_OnPostLoad()
	local playerClass = max_GetClass("player")
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

	ConsoleExec("targetNearestDistance 50")
end

-- Runs the first time the actual bot is run (7 is pressed).
function mb_OnFirstRun()
	mb_OnPostLoad()
	mb_CheckForProfessionCooldown()
end

function mb_CheckForProfessionCooldown()
	if max_HasSpell("Alchemy") then
		mb_CheckForAlchemyCooldowns()
	end
	if max_HasSpell("Tailoring") then
		CastSpellByName("Tailoring")
		for i = 1, 200 do
			local name =  GetTradeSkillInfo(i)
			if name == "Mooncloth" then
				local cooldownLeft = GetTradeSkillCooldown(i)
				if cooldownLeft == nil or cooldownLeft < 1 then
					max_SayGuild("My " .. name .. " is ready.")
				end
			end
		end
		CloseTradeSkill()
	end
	if max_HasSpell("Leatherworking") then
		mb_AddReagentWatch("Deeprock salt", 10)
		local shakerName = "Salt Shaker"
			if not mb_HasItem(shakerName) then
			max_SayGuild("I don't have a " .. shakerName)
		elseif not mb_IsItemOnCooldown(shakerName) then
			max_SayGuild("My " .. shakerName .. " is ready.")
		end
	end
end

function mb_CheckForAlchemyCooldowns()
	CastSpellByName("Alchemy")

	for i = 1, 200 do
		local name = GetTradeSkillInfo(i)
		if name == "Transmute: Undeath to Water" then
			mb_AddReagentWatch("Essence of Undeath", 10)
			local cooldownLeft = GetTradeSkillCooldown(i)
			if cooldownLeft == nil or cooldownLeft < 1 then
				max_SayGuild("My " .. name .. " is ready.")
			end
			CloseTradeSkill()
			return
		end
	end

	for i = 1, 200 do
		local name = GetTradeSkillInfo(i)
		if name == "Transmute: Arcanite" then
			mb_AddReagentWatch("Thorium Bar", 5)
			mb_AddReagentWatch("Arcane Crystal", 5)
			local cooldownLeft = GetTradeSkillCooldown(i)
			if cooldownLeft == nil or cooldownLeft < 1 then
				max_SayGuild("My " .. name .. " is ready.")
			end
			CloseTradeSkill()
			return
		end
	end
	CloseTradeSkill()
end

function mb_CreateMBMacros()
	mb_CreateMacro("MB_Main", "/mbr", 37, "7", "MULTIACTIONBAR4BUTTON1")
	mb_CreateMacro("MB_ZoomIn", "/run SetView(3); CameraZoomIn(2);", 38, "8", "MULTIACTIONBAR4BUTTON2")
	if mb_GetMyCommanderName() ~= UnitName("player") then
		mb_CreateMacro("MB_DE", "/cast Disenchant", 39, "1", "MULTIACTIONBAR4BUTTON3")
	end
end

function mb_BindKey(bind, action)
	SetBinding(bind, action)
	SetBinding("CTRL-" .. bind, action)
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
	mb_BindKey(bindingKey, bindingName)
end

-- OnUpdate
function mb_OnUpdate()
	if mb_isGossiping and mb_gossipOpenedTime + 5 < mb_GetTime() then
		mb_isGossiping = false
	end
	if mb_shouldDotRepair then
		if not UnitIsDead("player") then
			if UnitIsUnit("player", "targettarget") then
				max_SayRaid(".repair")
				mb_shouldDotRepair = false
			else
				TargetUnit("player")
			end
		end
	end
	-- Clean up unaccepted pending requests
	local toBeRemovedIds = {}
	for k, v in pairs(mb_myPendingRequests) do
		if v.sentTime + 5 < mb_GetTime() then
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
end

mb_hasStartedRunning = false
-- OnRun
function mb_OnRun()
	if GetFramerate() < 5 then
		if mb_IsInCombat() then
			max_SayRaid("Warning, I have lower than 5 FPS, skipped running to prevent freezing.")
		end
		return
	end

	if not mb_hasStartedRunning then
		mb_OnFirstRun()
		mb_hasStartedRunning = true
	end

	mb_RunBot(mb_GetMyCommanderName())
end

mb_isInCombat = false
function mb_IsInCombat()
	return mb_isInCombat
end

function mb_RunBot(commander)
	mb_isInCombat = UnitAffectingCombat("player") == 1

	mb_HandleQueuedIncomingComms()

	if mb_currentBossModule.preRun ~= nil then
		if mb_currentBossModule.preRun() then
			return
		end
	end

	mb_RebindMovementKeyIfNeeded()

	if mb_HandleSharedBehaviour(commander) then
		return
	end

	mb_classSpecificRunFunction(commander)
end

function mb_HandleQueuedIncomingComms()
	for k, v in pairs(mb_queuedIncomingComms) do
		mb_HandleMBCommunication(v.msg, v.from)
	end
	mb_queuedIncomingComms = {}
end

function mb_MakeRequest(requestType, requestBody, requestPriority)
	local requestId = tostring(math.random(9999999999))
	SendAddonMessage("MB", "request:" .. requestId .. ":" .. requestType .. ":" .. requestBody .. ":" .. requestPriority, "RAID")
	local request = {}
	request.type = requestType
	request.body = requestBody
	request.priority = requestPriority
    request.id = requestId
	request.sentTime = mb_GetTime()
	mb_myPendingRequests[requestId] = request
end

function mb_RegisterForRequest(requestType, func)
	mb_registeredRequestsHandlers[requestType] = func
end

function mb_AcceptRequest(request)
	mb_myAcceptedRequests[request.id] = request
	SendAddonMessage("MB", "acceptRequest:" .. request.id, "RAID")
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

function mb_ShouldHandleRequest(request)
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

mb_lastTimeMoving = 0
mb_lastFacingWrongWayTime = 0
function mb_OnGameErrorEvent(event, message, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
	if message == "Target needs to be in front of you" and mb_shouldAutoTurnToFace and mb_GetConfig()["autoTurnToFaceTarget"] == true then
		mb_lastFacingWrongWayTime = mb_GetTime()
	elseif message == "Can't do that while moving" then
		mb_lastTimeMoving = mb_GetTime()
	end
	mb_OriginalOnUIErrorEventFunction(event, message, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
end

function mb_IsMoving()
	return mb_lastTimeMoving + 0.5 > mb_GetTime()
end

function mb_IsFacingWrongWay()
	return mb_lastFacingWrongWayTime + 0.5 > mb_GetTime()
end

function mb_IsFuckingOff()
	return mb_shouldFuckOffAt + 4.5 > mb_GetTime()
end

mb_shouldFuckOffAt = 0
function mb_RebindMovementKeyIfNeeded()
	if mb_IsFuckingOff() then
		mb_BindKey("9", "MOVEFORWARD")
		return
	end
	if mb_IsFacingWrongWay() then
		mb_BindKey("9", "TURNLEFT")
		return
	end
	if mb_GoToMaxRangeModule_RebindMovementKeyIfNeeded() then
		return
	end
	mb_BindKey("9", nil)
end

function mb_GetTimeInCombat()
	if not mb_IsInCombat() then
		return 0
	end
	return mb_GetTime() - mb_combatStartedTime
end

function mb_RegisterBossModule(name, loadFunction)
	if mb_registeredBossModules == nil then
		mb_registeredBossModules = {}
	end
	mb_registeredBossModules[name] = loadFunction
end



-- TODO:
---
--- Stop following, rebind 9 to movefoward for 1 frame, before casting important spells like evocation
--- On ready-check check durability is above 10% in all slots, otherwise decline and announce in raid
--- Automatic Gold-spreading to one guy, automatic reagent-spreading from one guy, one guy is enough to open reagent vendor to buy everything the whole raid needs.
---		Need a new type of request for this where he asks for orders, waits 1 sec, and then buys everything, and then he automatically trades it when possible
---	Sit/stand logic based on error-messages, see RogueSpam addon.
--- Expire queued accepted requests if they've been in queue their entire throttle time?
---	Warlock:
---		Pets, 2 modes, imp-bitch or succu-sacc, swap for each warlock (using target and commands), also a pet-stay command.
---		Spellstones? 1% crit if nothing better, use for 900 spell absorb too
---		Hellfire during AoE? Probably not while we're progressing fire-instances. Maybe in a max-burn AoE mode.
---	Mage:
---		Wand if oom
---		Fire/Frost ward
---		Have a think about Dampen / Amplify, if it should be used ever, and if they should be specced in it then.
---		Click away PoM if combat ends with PoM up
--- Priest:
---     Can swap groups in combat? If so priests could be spamming PoH with swapping people in who need it.
---		Do abolish disease, check mana costs of the 2 versions, though it's kinda messy since you can't just spam do it since it's a buff, so multiple druids can hit the same target...
---		Wand instead of attack if ranged, (does wand cause GCD?)
---		On aggro cast Fade
---		PW:S usage can probably be improved. Current issues are that it selects the raid member at lowest current health, and checks if it has less than 50% health.
---			That means that tanks that are at 3k health (less than half) could get lower prio than mages who are at 90% health, and therefor no PW:S at all is cast.
--- Druids:
---     Swiftmend
---		Add logic for Feral DPS and Feral tank
---		Do abolish poison, though it's kinda messy since you can't just spam do it since it's a buff, so multiple druids can hit the same target...
---		Combat ress
---			Also need to implement rebuffing after combat ress then kinda
---	Paladins:
---		Add logic for ret pal
---		Add holy shock for the few that has it
---		Consecration in a max-burn AoE mode?
---		Blessing of Protection (request re-bless after?)
---		Lay on hands buff rotation on try-hard tries
---		Hammer of Wrath?
--- Hunter:
---		Pet-logic (reagent food, auto-feed, auto-call/revive, attacking, mend pet)
---			Owners request buffs for their pets
---			All-in-one pet macro:     /run local c=CastSpellByName if UnitExists("pet") then if UnitHealth("pet")==0 then c("Revive Pet") elseif GetPetHappiness()~=nil and GetPetHappiness()~=3 then c("Feed Pet") PickupContainerItem(0, 13) else c("Dismiss Pet") end else c("Call Pet") end
---		Feign Death
---			To remove threat
---			To be able to trap in combat?
---			To enable a third trinket in combat?
---			To drink?
---		Make them melee-hit with Raptor strike and mongoose bite if in melee range?
---		Deterrence on Melee hit
---		Automatic Tranq based on "x gains Frenzy" combat text
---	Warrior:
---		Battle-shout, make it smart so that it rebuffs party mates within range if needed and not only self. Also make non-tanking tanks refresh it when it has like 5 sec duration left to prevent tanking tanks from wasting the rage
---		Prot:
---			Mocking blow taunt if Taunt is on CD
---			Is rend ever worth using as prot?
---			Intercept/charge, gonna make picking shit up way easier if they actually charge their targets, intercept too for resisted taunts so the mob runs away
---			Dual-tank mode, use cleave then and swap between both targets and check actual threat.
---			Berserker rage zerk stance dance? Both as fear ward kinda and to increase rage.
---			Auto-taunt off other tanks if they have MS or other nasty debuff
---		Single-target salv for DPS warriors
--- Rename followTarget to commander
---	Bag-space report, each responds with how many bag spaces free, not as SayRaid but by responding to the request kinda and then the guy requesting sees the printout.
--- Blacklist LoS targets when using mb_IsSpellInRange for 1 sec, use the Rogue-Spam way to detect error message of LoS
--- IsActionInRange fails for resses, spend some more time looking into it to see if we can fix it
---	Manual-playing mode where the bot doesn't play by itself, but it still makes broadcasts and requests stuff. (kinda hard due to for example warrior DTPS broad-casting is deep in the class-specific function)
--- Enable/disable healthstone trades modes?
--- Consumables
---		Add a watch for it.
---		Add them to be ignored for trade over a certain quantity (don't want them to trade all their pots when they're inventory dumpers)
---		"Try-hard mode" on/off, which uses flasks and weapon enchants and foodbuffs, and potions in combat.
--- Crowd-control people should be DPSing between re-cc's, the problem is re-aquiring CC target, targetlastenemy/targetnearestenemy/assist every1 in raid, and if still cant find say in raid so commander needs to target manually?
---	Don't DPS if you risk overthreat, use KTM API? Need a way to disable it for solo/5-mans
---	Add a command /mb readyCheck that initates a normal ready-check and runs mb_HandleReadyCheck() for self
---
---
---
---	Heal-visualizer, shows each broadcasted heal from each healer in a list and their target.
--- Enemy-target logic, frame that displays enemy targets and who "has" that target (tank or CC)
---		Automatic marking of raid-symbol and a commander does "/mb target tank" or "/mb target cc"
---		Automatic DPSing of these targets in order, using assist on the tank who has it, or on the guy who CCs it.
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
--	sc6 = mb_GetTime()
--  local qwe = 0
--if qwe == 1 then
--	CastSpellByName("Hamstring")
--end
--	a(33)
--	tg56 = sc6-sc5
--	if UnitExists(t) and not UnitIsFriend(p, t) and CheckInteractDistance(t, 3) and x1 == 0 and (hmsD == 0 or tg56 > hmsT) and um(p) >= 10 then
--		sc5 = mb_GetTime()
--		CastSpellByName(hms)
--	end