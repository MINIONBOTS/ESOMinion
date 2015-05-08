eso_quest_helpers = {}

function eso_quest_helpers.ModuleInit()
	--set questmanager callbacks
	QuestManager.GetNearestObjectiveCallback = eso_quest_helpers.GetNearestQuestObjective

	--add tasks for quest objectives
	QuestManager.AddObjectiveTask("MAP_PIN_TYPE_QUEST_OFFER", 								eso_task_quest_start.Create)
	QuestManager.AddObjectiveTask("QUEST_CONDITION_TYPE_INTERACT_MONSTER", 					eso_task_quest_condition_interact.Create)
	QuestManager.AddObjectiveTask("QUEST_CONDITION_TYPE_INTERACT_OBJECT", 					eso_task_quest_condition_interact.Create)
	QuestManager.AddObjectiveTask("QUEST_CONDITION_TYPE_INTERACT_OBJECT_IN_STATE", 			eso_task_quest_condition_interact.Create)
	QuestManager.AddObjectiveTask("QUEST_CONDITION_TYPE_INTERACT_SIMPLE_OBJECT", 			eso_task_quest_condition_interact.Create)
	QuestManager.AddObjectiveTask("QUEST_CONDITION_TYPE_INTERACT_SIMPLE_OBJECT_IN_STATE", 	eso_task_quest_condition_interact.Create)
	QuestManager.AddObjectiveTask("QUEST_CONDITION_TYPE_TALK_TO", 							eso_task_quest_condition_talkto.Create)
	QuestManager.AddObjectiveTask("QUEST_CONDITION_TYPE_SCRIPT_ACTION", 					eso_task_quest_condition_talkto.Create)
	QuestManager.AddObjectiveTask("QUEST_CONDITION_TYPE_COLLECT_ITEM", 						eso_task_quest_condition_collectitem.Create)
	QuestManager.AddObjectiveTask("QUEST_CONDITION_TYPE_GOTO_POINT", 						eso_task_moveto.Create)
end

function eso_quest_helpers.GetNearestQuestObjective()
	local nearestObjective = nil
	local nearestDistance = 9999999999
	local playerPos = ml_global_information.Player_Position
	
	--start with quest conditions
	local objective = eso_quest_helpers.GetNearestQuestCondition()
	if(ValidTable(objective)) then
		objective.type = eso_quest_helpers.ConditionTypes[objective.type]
		nearestObjective = objective
		nearestDistance = Distance2D(playerPos.x, playerPos.y, playerPos.z, objective.pos.x, objective.pos.y, objective.pos.z)
	end
	
	--check offer pins
	local offerPin = eso_quest_helpers.GetNearestOfferPin()
	if(ValidTable(offerPin)) then
		local distance = Distance2D(playerPos.x, playerPos.y, playerPos.z, offerPin.pos.x, offerPin.pos.y, offerPin.pos.z)
		if(distance < nearestDistance) then
			offerPin.type = eso_quest_helpers.PinTypes[offerPin.type]
			nearestObjective = offerPin
			nearestDistance = distance
		end
	end
	
	--check ending pins
	local endingPin = eso_quest_helpers.GetNearestEndingPin()
	if(ValidTable(endingPin)) then
		local distance = Distance2D(playerPos.x, playerPos.y, playerPos.z, endingPin.pos.x, endingPin.pos.y, endingPin.pos.z)
		if(distance < nearestDistance) then
			endingPin.type = eso_quest_helpers.PinTypes[endingPin.type]
			nearestObjective = endingPin
			nearestDistance = distance
		end
	end
	
	if(ValidTable(nearestObjective)) then
		local oPos = nearestObjective.pos
		local oType = nearestObjective.type
		d("Found objective of type "..tostring(oType).." at ("..tostring(oPos.x)..","..tostring(oPos.y)..","..tostring(oPos.z)..")")
		return nearestObjective
	else
		d("No suitable quest objective found")
	end
end

function eso_quest_helpers.GetNearestQuestCondition()
	--first get the nearest quest condition from the client
	local cVals = QuestManager:GetNearestQuestCondition()
	if(ValidTable(cVals)) then
		--d(cVals)
		local condition = QuestManager:GetQuestCondition(cVals.JournalIndex, cVals.StepIndex, cVals.ConditionIndex)
		--if GetQuestCondition does not return a table then the quest is complete - it will be picked up by the GetNearestPin functions
		if(ValidTable(condition)) then
			if(NavigationManager:IsOnMesh(condition.pos)) then
				d("Nearest quest condition at ("..tostring(condition.pos.x)..","..tostring(condition.pos.y)..","..tostring(condition.pos.z)..")")
				
				--build query table, this will be used to check for available static data
				local questid = QuestManager:GetQuestId(cVals.JournalIndex)
				condition["queryTable"] = {["questid"] = questid, ["conditionid"] = condition.id}
				condition.paramsTable = {}
				condition.paramsTable.journalindex = cVals.JournalIndex
				condition.paramsTable.stepindex = cVals.StepIndex
				condition.paramsTable.conditionindex = cVals.ConditionIndex
				condition.paramsTable.type = condition.type
				condition.paramsTable.radius = condition.radius
				
				return condition
			end
		end
	end
	
	d("No valid quest condition found")
	return nil
end

function eso_quest_helpers.GetNearestOfferPin()
	local pl = PinList("nearest,onmesh,type="..tostring(g("MAP_PIN_TYPE_QUEST_OFFER")))
	if ( pl ) then
		local p = pl[1]
		if(ValidTable(p)) then
			d("Nearest quest offer at ("..tostring(p.pos.x)..","..tostring(p.pos.y)..","..tostring(p.pos.z)..")")
			return p
		else
			d("No valid quest offer pins found")
			return nil
		end
	end
end

function eso_quest_helpers.GetNearestEndingPin()
	--have to check both MAP_PIN_TYPE_ASSISTED_QUEST_ENDING and MAP_PIN_TYPE_TRACKED_QUEST_ENDING
	local nearestEndingPos = nil
	local nearestDistance = 0.0
	local nearestEndingPin = nil
	local playerPos = ml_global_information.Player_Position
	--have to check both MAP_PIN_TYPE_ASSISTED_QUEST_ENDING and MAP_PIN_TYPE_TRACKED_QUEST_ENDING
	local pl = PinList("nearest,onmesh,type="..tostring(g("MAP_PIN_TYPE_ASSISTED_QUEST_ENDING")))
	if ( pl ) then
		local p = pl[1]
		if(ValidTable(p)) then
			nearestEndingPos = p.pos
			nearestEndingPin = p
			nearestDistance = Distance2D(playerPos.x, playerPos.y, playerPos.z, nearestEndingPos.x, nearestEndingPos.y, nearestEndingPos.z)
		end  
	end
	
	pl = PinList("nearest,onmesh,type="..tostring(g("MAP_PIN_TYPE_TRACKED_QUEST_ENDING")))
		if ( pl ) then
		local p = pl[1]
		if(ValidTable(p)) then
			local distance = Distance2D(playerPos.x, playerPos.y, playerPos.z, p.pos.x, p.pos.y, p.pos.z)
			if(distance < nearestDistance or nearestDistance == 0.0) then
				nearestEndingPos = p.pos
				nearestEndingPin = p
				nearestDistance = distance
			end
		end  
	end
	
	if(ValidTable(nearestEndingPin)) then
		d("Nearest quest ending at ("..tostring(nearestEndingPos.x)..","..tostring(nearestEndingPos.y)..","..tostring(nearestEndingPos.z)..")")
	else
		d("No valid quest ending pins found")
	end
	
	return nearestEndingPin
end

--extend the QuestManager here for now
function QuestManager:IsComplete(journalIndex)
	return e("GetJournalQuestIsComplete("..tostring(journalIndex)..")")
end

RegisterEventHandler("Module.Initalize",eso_quest_helpers.ModuleInit)

eso_quest_helpers.ConditionTypes = {}
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_ABILITY_TYPE_USED_ON_NPC")] = 					"QUEST_CONDITION_TYPE_ABILITY_TYPE_USED_ON_NPC"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_ABILITY_TYPE_USED_ON_TABLE")] = 				"QUEST_CONDITION_TYPE_ABILITY_TYPE_USED_ON_TABLE"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_ABILITY_USED_ON_NPC")] = 						"QUEST_CONDITION_TYPE_ABILITY_USED_ON_NPC"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_ABILITY_USED_ON_TABLE")] = 					"QUEST_CONDITION_TYPE_ABILITY_USED_ON_TABLE"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_ADVANCE_COMPLETABLE_SIBLINGS")] = 				"QUEST_CONDITION_TYPE_ADVANCE_COMPLETABLE_SIBLINGS"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_ARTIFACT_CAPTURED")] = 						"QUEST_CONDITION_TYPE_ARTIFACT_CAPTURED"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_ARTIFACT_RETURNED")] = 						"QUEST_CONDITION_TYPE_ARTIFACT_RETURNED"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_CAPTURE_KEEP_TYPE")] = 						"QUEST_CONDITION_TYPE_CAPTURE_KEEP_TYPE"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_CAPTURE_SPECIFIC_KEEP")] = 					"QUEST_CONDITION_TYPE_CAPTURE_SPECIFIC_KEEP"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_COLLECT_ITEM")] = 								"QUEST_CONDITION_TYPE_COLLECT_ITEM"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_CRAFT_ITEM")] = 								"QUEST_CONDITION_TYPE_CRAFT_ITEM"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_DECONSTRUCT_ITEM")] = 							"QUEST_CONDITION_TYPE_DECONSTRUCT_ITEM"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_DEPRECATED1")] = 								"QUEST_CONDITION_TYPE_DEPRECATED1"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_ENTER_SUBZONE")] = 							"QUEST_CONDITION_TYPE_ENTER_SUBZONE"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_EQUIP_ITEM")] = 								"QUEST_CONDITION_TYPE_EQUIP_ITEM"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_EVENT_FAIL")] = 								"QUEST_CONDITION_TYPE_EVENT_FAIL"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_EVENT_SUCCESS")] = 							"QUEST_CONDITION_TYPE_EVENT_SUCCESS"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_EXIT_SUBZONE")] = 								"QUEST_CONDITION_TYPE_EXIT_SUBZONE"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_FOLLOWER_GAINED")] = 							"QUEST_CONDITION_TYPE_FOLLOWER_GAINED"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_FOLLOWER_LOST")] = 							"QUEST_CONDITION_TYPE_FOLLOWER_LOST"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_GATHER_ITEMS")] = 								"QUEST_CONDITION_TYPE_GATHER_ITEMS"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_GIVE_ITEM")] = 								"QUEST_CONDITION_TYPE_GIVE_ITEM"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_GOTO_POINT")] = 								"QUEST_CONDITION_TYPE_GOTO_POINT"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_HAS_ITEM")] = 									"QUEST_CONDITION_TYPE_HAS_ITEM"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_INTERACT_MONSTER")] = 							"QUEST_CONDITION_TYPE_INTERACT_MONSTER"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_INTERACT_OBJECT")] = 							"QUEST_CONDITION_TYPE_INTERACT_OBJECT"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_INTERACT_OBJECT_IN_STATE")] = 					"QUEST_CONDITION_TYPE_INTERACT_OBJECT_IN_STATE"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_INTERACT_SIMPLE_OBJECT")] = 					"QUEST_CONDITION_TYPE_INTERACT_SIMPLE_OBJECT"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_INTERACT_SIMPLE_OBJECT_IN_STATE")] = 			"QUEST_CONDITION_TYPE_INTERACT_SIMPLE_OBJECT_IN_STATE"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_KILL_ENEMY_GUARDS")] = 						"QUEST_CONDITION_TYPE_KILL_ENEMY_GUARDS"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_KILL_ENEMY_PLAYERS")] = 						"QUEST_CONDITION_TYPE_KILL_ENEMY_PLAYERS"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_KILL_ENEMY_PLAYERS_OF_CLASS")] = 				"QUEST_CONDITION_TYPE_KILL_ENEMY_PLAYERS_OF_CLASS"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_KILL_ENEMY_PLAYERS_WHILE_DEFENDING_KEEP")] =	"QUEST_CONDITION_TYPE_KILL_ENEMY_PLAYERS_WHILE_DEFENDING_KEEP"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_KILL_MONSTER")] = 								"QUEST_CONDITION_TYPE_KILL_MONSTER"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_LEAVE_REVIVE_COUNTER_LIST")] = 				"QUEST_CONDITION_TYPE_LEAVE_REVIVE_COUNTER_LIST"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_NPC_GOAL")] = 									"QUEST_CONDITION_TYPE_NPC_GOAL"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_NPC_GOAL_FAIL")] = 							"QUEST_CONDITION_TYPE_NPC_GOAL_FAIL"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_PLAYER_DEATH")] = 								"QUEST_CONDITION_TYPE_PLAYER_DEATH"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_PLAYER_LOGOUT")] = 							"QUEST_CONDITION_TYPE_PLAYER_LOGOUT"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_SCRIPT_ACTION")] = 							"QUEST_CONDITION_TYPE_SCRIPT_ACTION"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_TALK_TO")] = 									"QUEST_CONDITION_TYPE_TALK_TO"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_TIMER")] = 									"QUEST_CONDITION_TYPE_TIMER"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_TRANSITION_INTERACT_OBJECT")] = 				"QUEST_CONDITION_TYPE_TRANSITION_INTERACT_OBJECT"
eso_quest_helpers.ConditionTypes[g("QUEST_CONDITION_TYPE_USE_QUEST_ITEM")] = 							"QUEST_CONDITION_TYPE_USE_QUEST_ITEM"

eso_quest_helpers.PinTypes = {}
eso_quest_helpers.PinTypes[g("MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION")] = 			"MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION"
eso_quest_helpers.PinTypes[g("MAP_PIN_TYPE_ASSISTED_QUEST_ENDING")]	= 				"MAP_PIN_TYPE_ASSISTED_QUEST_ENDING"
eso_quest_helpers.PinTypes[g("MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION")] =	"MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION"
eso_quest_helpers.PinTypes[g("MAP_PIN_TYPE_QUEST_COMPLETE")] = 						"MAP_PIN_TYPE_QUEST_COMPLETE"
eso_quest_helpers.PinTypes[g("MAP_PIN_TYPE_QUEST_INTERACT")] = 						"MAP_PIN_TYPE_QUEST_INTERACT"
eso_quest_helpers.PinTypes[g("MAP_PIN_TYPE_QUEST_OFFER")] = 						"MAP_PIN_TYPE_QUEST_OFFER"
eso_quest_helpers.PinTypes[g("MAP_PIN_TYPE_QUEST_TALK_TO")] = 						"MAP_PIN_TYPE_QUEST_TALK_TO"
eso_quest_helpers.PinTypes[g("MAP_PIN_TYPE_TRACKED_QUEST_CONDITION")] = 			"MAP_PIN_TYPE_TRACKED_QUEST_CONDITION"
eso_quest_helpers.PinTypes[g("MAP_PIN_TYPE_TRACKED_QUEST_ENDING")] = 				"MAP_PIN_TYPE_TRACKED_QUEST_ENDING"
eso_quest_helpers.PinTypes[g("MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION")] = 	"MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION"