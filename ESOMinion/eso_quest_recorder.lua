eso_quest_recorder = {}
eso_quest_recorder.lastNpcId = 0
eso_quest_recorder.lastMobId = 0
eso_quest_recorder.lastObjectId = 0

function eso_quest_recorder.ModuleInit()
	RegisterForEvent("EVENT_QUEST_ADDED", true)
	RegisterEventHandler("GAME_EVENT_QUEST_ADDED",
		function (eventCode, _, journalIndex, questName, objectiveName)
			d("EVENT_QUEST_ADDED")
			d("eventCode: "..eventCode)
			d("journalIndex: "..journalIndex)
			d("questName: "..questName)
			d("objectiveName: "..objectiveName)
		end	)
	
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
	
	RegisterForEvent("EVENT_OBJECTIVE_COMPLETED", true)
	RegisterEventHandler("GAME_EVENT_OBJECTIVE_COMPLETED", handle_objective_completed)
	
	RegisterForEvent("EVENT_QUEST_POSITION_REQUEST_COMPLETE", true)
	RegisterEventHandler("GAME_EVENT_QUEST_POSITION_REQUEST_COMPLETE",
		function (eventCode, _, taskId, pinType, x, y, areaRadius, insideCurrentMapWorld, isBreadcrumb)
			d("eventCode: "..tostring(eventCode))
			d("taskId: "..tostring(taskId))
			d("pinType: "..tostring(pinType))
			d("x: "..tostring(x))
			d("y: "..tostring(y))
			d("areaRadius: "..tostring(areaRadius))
			d("insideCurrentMapWorld: "..tostring(insideCurrentMapWorld))
			d("isBreadcrumb: "..tostring(isBreadcrumb))
		end
	)
end

function handle_quest_added(eventCode, _, journalIndex, questName, objectiveName)
	d("EVENT_QUEST_ADDED")
	d("eventCode: "..eventCode)
	d("journalIndex: "..journalIndex)
	d("questName: "..questName)
	d("objectiveName: "..objectiveName)
end

function handle_quest_advanced(eventCode, _, journalIndex, questName, isPushed, isComplete, mainStepChanged)
	d("EVENT_QUEST_ADVANCED")
	d("eventCode: "..eventCode)
	d("journalIndex: "..journalIndex)
	d("questName: "..questName)
	d("isPushed: "..tostring(isPushed))
	d("isComplete: "..tostring(isComplete))
	d("mainStepChanged: "..tostring(mainStepChanged))
end

function handle_quest_complete(	eventCode, _, 
								questName,
								level,
								previousXP,
								currentXP,
								rank,
								previousPoints,
								currentPoints)
	
	d("EVENT_QUEST_COMPLETE")
	d("eventCode: "..eventCode)
	d("questName: "..questName)
	d("level: "..level)
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
	
	d("EVENT_QUEST_CONDITION_COUNTER_CHANGED")
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
	d("isStepHidden: "..tostring(isStepHidden))
end

function handle_quest_offered(eventCode)
	d("EVENT_QUEST_OFFERED")
end

function handle_objectives_updated(eventCode)
	d("EVENT_QUEST_OBJECTIVES_UPDATED")
end

function handle_objective_completed(eventCode, _, 
									zoneIndex,
									poiIndex,
									level,
									previousXP,
									currentXP,
									rank,
									previousPoints,
									currentPoints)
	
	d("EVENT_OBJECTIVE_COMPLETED")
	d("eventCode: "..eventCode)
	d("zoneIndex: "..zoneIndex)
	d("poiIndex: "..poiIndex)
	d("level: "..level)
end

RegisterEventHandler("Module.Initalize",eso_quest_recorder.ModuleInit)