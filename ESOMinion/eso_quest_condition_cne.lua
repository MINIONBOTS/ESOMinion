c_interact = ml_cause.Create()
e_interact = ml_effect.Create()
function c_interact:evaluate()
	local target = nil
	local range = 5
	local dataTable = self.task:GetData()
	if(ValidTable(dataTable)) then
		if(dataTable["id"]) then
			target = EntityList:Get(dataTable["id"])
		end
		
		if(dataTable["range"]) then
			range = dataTable["range"]
		end
	else
		local questid = self.task.queryTable.questID
		if(questid) then
			target = eso_quest_helpers.GetNearestQuestEntity(questid)
		else --backup, just try to find a nearby interactable entity
			local elist = EntityList("nearest,friendly,interacttype=2")
			if(elist) then
				_, target = next(elist)
			end
		end
	end
		
	if(ValidTable(target)) then
		if(target.distance < range) then
			self.element.targetid = target.id
			return true
		end
	end
	
	return false
end
function e_interact:execute()	
	Player:Interact(self.element.targetid)
end

c_interactitem = ml_cause.Create()
e_interactitem = ml_effect.Create()
function c_interactitem:evaluate()
	local target = nil
	local range = 5
	local dataTable = self.task:GetData()
	if(ValidTable(dataTable)) then	--dataTable comes from static data
		if(dataTable["id"]) then
			target = EntityList:Get(dataTable["id"])
		end
		
		if(dataTable["range"]) then
			range = dataTable["range"]
		end
	elseif(ValidTable(self.task.paramsTable)) then --paramsTable comes from dynamic data
		local paramsTable = self.task.paramsTable
		if(paramsTable["id"]) then
			target = EntityList:Get(paramsTable["id"])
		end
		
		if(paramsTable["radius"]) then
			range = paramsTable["radius"]
		end
	end
	
	local target = nil
	local questid = self.task.queryTable.questID
	if(questid) then
		target = eso_quest_helpers.GetNearestQuestEntity(questid)
	else
		local elist = EntityList("nearest,friendly,type=3,questinteraction,maxdistance="..tostring(range))
		if(elist) then
			_, target = next(elist)
		end
	end
		
	if(ValidTable(target)) then
		if(target.distance < range) then
			self.element.targetid = target.id
			return true
		end
	end
	
	return false
end
function e_interactitem:execute()	
	Player:Interact(self.element.targetid)
end

-- for now simply run through first choice always
-- eventually create a chatter task that pulls static data choices
c_chatter = ml_cause.Create()
e_chatter = ml_effect.Create()
function c_chatter:evaluate()
	return tonumber(e("GetChatterOptionCount()")) > 0
end
function e_chatter:execute()	
	e("SelectChatterOption(1)")
end

c_acceptquest = ml_cause.Create()
e_acceptquest = ml_effect.Create()
function c_acceptquest:evaluate()
	-- check for both event and offered quest info
	
	return 
		eso_quest_event_queue["offered"] and
		e("GetOfferedQuestInfo()") ~= nil
end
function e_acceptquest:execute()	
	e("AcceptOfferedQuest()")
end

c_completequest = ml_cause.Create()
e_completequest = ml_effect.Create()
function c_completequest:evaluate()
	return eso_quest_event_queue.completedialog[self.task.paramsTable.journalindex] 
end
function e_completequest:execute()	
	e("CompleteQuest()")
end

-- sometimes map pins are placed at exits for enclosed areas such as dungeons
-- this cne is a fallback that will use the map marker and wipe the current task
-- if it cannot find anything at the map pin to do. when the bot enters the new 
-- area it will re-find the closest objective and create a new task
c_pinoffmap = ml_cause.Create()
e_pinoffmap = ml_effect.Create()
function c_pinoffmap:evaluate()
	if(self.task.destMapID and self.task.destMapID ~= ml_global_information.CurrentMapID) then
		return false
	end
	
	local pos = ml_global_information.Player_Position
	local map_marker = ml_marker_mgr.GetClosestMarker(pos.x, pos.y, pos.z, 5, GetStringML("mapMarker"))
	if(ValidTable(map_marker)) then
		self.task.map_marker = map_marker
		return true
	end
end
function e_pinoffmap:execute()	
	local newTask = eso_task_moveto_map.Create()
	newTask.destMapID = self.task.map_marker:GetFieldValue(GetStringML("destMapID"))
	newTask.origMapID = ml_global_information.CurrentMapID

	ml_task_hub:Add(newTask, REACTIVE_GOAL, TP_ASAP)
	self.task:Terminate()
end






