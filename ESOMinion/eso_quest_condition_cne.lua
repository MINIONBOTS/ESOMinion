c_interact = ml_cause.Create()
e_interact = ml_effect.Create()
function c_interact:evaluate()
	local target = nil
	local range = 3
	local dataTable = self.task:GetData()
	if(ValidTable(dataTable)) then
		if(dataTable["id"]) then
			target = EntityList:Get(dataTable["id"])
		end
		
		if(dataTable["range"]) then
			range = dataTable["range"]
		end
	else
		local elist = EntityList("nearest,friendly,interacttype=2")
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
function e_interact:execute()	
	Player:Interact(self.element.targetid)
end

c_interactitem = ml_cause.Create()
e_interactitem = ml_effect.Create()
function c_interactitem:evaluate()
	local target = nil
	local range = 3
	local dataTable = self.task:GetData()
	if(ValidTable(dataTable)) then
		if(dataTable["id"]) then
			target = EntityList:Get(dataTable["id"])
		end
		
		if(dataTable["range"]) then
			range = dataTable["range"]
		end
	elseif(ValidTable(self.task.paramsTable)) then
		local paramsTable = self.task.paramsTable
		if(paramsTable["id"]) then
			target = EntityList:Get(paramsTable["id"])
		end
		
		if(paramsTable["radius"]) then
			range = paramsTable["radius"]
		end
	else
		local elist = EntityList("nearest,friendly,type=3,questinteraction,maxdistance="..tostring(range))
		if(elist) then
			_, target = next(elist)
		end
	end
		
	if(ValidTable(target)) then
		self.element.targetid = target.id
		return true
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

