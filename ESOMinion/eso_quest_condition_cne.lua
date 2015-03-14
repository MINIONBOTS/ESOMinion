c_interact = ml_cause.Create()
e_interact = ml_effect.Create()
function c_interact:evaluate()
	local dataTable = self:GetData()
	if(ValidTable(dataTable)) then
		local target = nil
		if(dataTable["id"]) then
			target = EntityList:Get(dataTable["id"])
		else
			target = EntityList("nearest,npc,friendly")
		end
		
		if(ValidTable(target)) then
			local range = dataTable["range"] or 3
			if(target.distance < range) then
				self.targetid = target.id
				return true
			end
		end
	end
	
	return false
end
function e_interact:execute()	
	Player:Interact(self.targetid)
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
		TableSize(eso_quest_event_queue["offered"]) > 0 and
		e("GetOfferedQuestInfo()")
end
function e_acceptquest:execute()	
	e("AcceptOfferedQuest()")
end

