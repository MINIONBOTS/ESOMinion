eso_quest_helpers = {}

function eso_quest_helpers.GetNearestQuestObjective()
	local nearestObjective = nil
	local nearestDistance = 9999999999
	local playerPos = ml_global_information.Player_Position
	
	--start with quest conditions
	local objective = eso_quest_helpers.GetNearestQuestCondition()
	if(ValidTable(objective)) then
		nearestObjective = {["type"] = "QUEST_CONDITION", ["objective"] = objective}
		nearestDistance = Distance2D(playerPos.x, playerPos.y, playerPos.z, objective.pos.x, objective.pos.y, objective.pos.z)
	end
	
	--check offer pins
	local offerPin = eso_quest_helpers.GetNearestOfferPin()
	if(ValidTable(offerPin)) then
		local distance = Distance2D(playerPos.x, playerPos.y, playerPos.z, offerPin.pos.x, offerPin.pos.y, offerPin.pos.z)
		if(distance < nearestDistance) then
			nearestObjective = {["type"] = "QUEST_OFFER", ["objective"] = offerPin}
			nearestDistance = distance
		end
	end
	
	--check ending pins
	local endingPin = eso_quest_helpers.GetNearestEndingPin()
	if(ValidTable(endingPin)) then
		local distance = Distance2D(playerPos.x, playerPos.y, playerPos.z, endingPin.pos.x, endingPin.pos.y, endingPin.pos.z)
		if(distance < nearestDistance) then
			nearestObjective = {["type"] = "QUEST_ENDING", ["objective"] = endingPin}
			nearestDistance = distance
		end
	end
	
	if(ValidTable(nearestObjective)) then
		local oPos = nearestObjective.objective.pos
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
		d(cVals)
		local condition = QuestManager:GetQuestCondition(cVals.JournalIndex, cVals.StepIndex, cVals.ConditionIndex)
		--if GetQuestCondition does not return a table then the quest is complete - it will be picked up by the GetNearestPin functions
		if(ValidTable(condition)) then
			--if(NavigationManager:IsOnMesh(condition.pos)) then
				d("Nearest quest condition at ("..tostring(condition.pos.x)..","..tostring(condition.pos.y)..","..tostring(condition.pos.z)..")")
				return condition
			--end
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

QuestManager.GetNearestObjectiveCallback = eso_quest_helpers.GetNearestQuestObjective