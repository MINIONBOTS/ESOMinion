eso_quest_event_queue = {}

-- these two do not pass event data so they must be used as booleans and cleared afterwards
eso_quest_event_queue["offered"] = false
eso_quest_event_queue["objectivesupdated"] = false

-- these pass event data and so can be indexed in a useful manner
eso_quest_event_queue["added"] = {}
eso_quest_event_queue["advanced"] = {}
eso_quest_event_queue["conditioncounterchanged"] = {}

function handle_quest_offered(eventCode)
	d("EVENT_QUEST_OFFERED")
	
	eso_quest_event_queue["offered"] = true
end

function handle_objectives_updated(eventCode)
	--d("EVENT_QUEST_OBJECTIVES_UPDATED")
	
		eso_quest_event_queue["objectivesupdated"] = true
end

function handle_quest_added(eventCode, _, journalIndex, questName, objectiveName)
	--d("EVENT_QUEST_ADDED")
	--d("eventCode: "..eventCode)
	--d("journalIndex: "..journalIndex)
	--d("questName: "..questName)
	--d("objectiveName: "..objectiveName)
	
	local addedTable = eso_quest_event_queue["added"]
	addedTable[questName] = 
	{	
		["eventCode"] = eventCode,
		["journalIndex"] = journalIndex,
		["objectiveName"] = objectiveName,
		["questName"] = questName,
	}
end

function handle_quest_advanced(eventCode, _, journalIndex, questName, isPushed, isComplete, mainStepChanged)
	--d("EVENT_QUEST_ADVANCED")
	--d("eventCode: "..eventCode)
	--d("journalIndex: "..journalIndex)
	--d("questName: "..questName)
	--d("isPushed: "..tostring(isPushed))
	--d("isComplete: "..tostring(isComplete))
	--d("mainStepChanged: "..tostring(mainStepChanged))
	
	local addedTable = eso_quest_event_queue["advanced"]
	addedTable[questName] = 
	{	
		["eventCode"] = eventCode,
		["journalIndex"] = journalIndex,
		["questName"] = questName,
		["objectiveName"] = objectiveName,
		["isPushed"] = isPushed,
		["isComplete"] = isComplete,
		["mainStepChanged"] = mainStepchanged,
	}
end

function handle_quest_complete(	eventCode, _, 
								questName,
								level,
								previousXP,
								currentXP,
								rank,
								previousPoints,
								currentPoints)
	
	--d("EVENT_QUEST_COMPLETE")
	--d("eventCode: "..eventCode)
	--d("questName: "..questName)
	--d("level: "..level)
	
	local addedTable = eso_quest_event_queue["complete"]
	addedTable[questName] = 
	{	
		["eventCode"] = eventCode,
		["questName"] = questName,
		["level"] = level,
		["previousXP"] = previousXP,
		["currentXP"] = currentXP,
		["rank"] = rank,
		["previousPoints"] = previousPoints,
		["currentPoints"] = currentPoints,		
	}
end

function handle_quest_condition_counter_changed(	eventCode, _, 
													journalIndex, 
													questName, 
													conditionText, 
													conditionType, 
													currConditionVal, 
													newConditionVal, 
													conditionMax, 
													isFailCondition,
													stepOverrideText,
													isPushed,
													isComplete,
													isConditionComplete,
													isStepHidden)
	
	--[[d("EVENT_QUEST_CONDITION_COUNTER_CHANGED")
	d("eventCode: "..eventCode)
	d("journalIndex: "..journalIndex)
	d("questName: "..questName)
	d("conditionText: "..conditionText)
	d("conditionType: "..conditionType)
	d("currConditionVal: "..currConditionVal)
	d("newConditionVal: "..newConditionVal)
	d("conditionMax: "..conditionMax)
	d("isFailCondition: "..tostring(isFailCondition))
	d("stepOverrideText: "..stepOverrideText)
	d("isPushed: "..tostring(isPushed))
	d("isComplete: "..tostring(isComplete))
	d("isConditionComplete: "..tostring(isConditionComplete))
	d("isStepHidden: "..tostring(isStepHidden))]]
	
	local addedTable = eso_quest_event_queue["conditioncounterchanged"]
	addedTable[questName] = 
	{
		["eventCode"] = eventCode,
		["journalIndex"] = journalIndex, 
		["questName"] = questName, 
		["conditionText"] = conditionText, 
		["conditionType"] = conditionType, 
		["currConditionVal"] = currentConditionVal, 
		["newConditionVal"] = newConditionVal, 
		["conditionMax"] = conditionMax, 
		["isFailCondition"] = isFailCondition,
		["stepOverrideText"] = stepOverrideText,
		["isPushed"] = isPushed,
		["isComplete"] = isComplete,
		["isConditionComplete"] = isConditionComplete,
		["isStepHidden"] = isStepHidden,
	}
end

function eso_quest_event_queue.ModuleInit()
	RegisterForEvent("EVENT_QUEST_ADDED", true)
	RegisterEventHandler("GAME_EVENT_QUEST_ADDED", handle_quest_added)
	
	RegisterForEvent("EVENT_QUEST_ADVANCED", true)
	RegisterEventHandler("GAME_EVENT_QUEST_ADVANCED", handle_quest_advanced)
	
	RegisterForEvent("EVENT_QUEST_COMPLETE", true)
	RegisterEventHandler("GAME_EVENT_QUEST_COMPLETE", handle_quest_complete)
	
	RegisterForEvent("EVENT_QUEST_CONDITION_COUNTER_CHANGED", true)
	RegisterEventHandler("GAME_EVENT_QUEST_CONDITION_COUNTER_CHANGED", handle_quest_condition_counter_changed)
	
	RegisterForEvent("EVENT_QUEST_OFFERED", true)
	RegisterEventHandler("GAME_EVENT_QUEST_OFFERED", handle_quest_offered)
	
	RegisterForEvent("EVENT_OBJECTIVES_UPDATED", true)
	RegisterEventHandler("GAME_EVENT_OBJECTIVES_UPDATED", handle_objectives_updated)
end

RegisterEventHandler("Module.Initalize",eso_quest_event_queue.ModuleInit)