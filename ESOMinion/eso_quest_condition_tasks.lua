eso_task_quest_condition = inheritsFrom(ml_data_task)
eso_task_quest_condition.name = "QUEST_CONDITION"

function eso_task_quest_condition.Create()
    local newinst = inheritsFrom(eso_task_quest_condition)
    
	--ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.auxiliary = false
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
	
    --eso_task_quest_condition members
    newinst.name = "QUEST_CONDITION"
    
    return newinst
end

function eso_task_quest_condition:Init()
	-- add task complete/fail cnes
	self:AddTaskCheckCEs()
end

function eso_task_quest_condition:task_complete_eval()
	local conditionTable = eso_quest_event_queue["conditioncounterchanged"]
	if(TableSize(conditionTable) > 0) then
		local questTable = QuestManager:Get(self.queryTable.questID)
		if(ValidTable(questTable)) then
			if(conditionTable[questTable.name]) then
				self.questname = questTable.name
				return true
			end
		end
	end
	
	return false
end

function eso_task_quest_condition:task_complete_execute()
	local conditionTable = eso_quest_event_queue["conditioncounterchanged"]
	conditionTable[self.questname] = nil
	
	local interactionType = e("GetInteractionType()")
	if(interactionType) then
		e("EndInteraction("..tostring(interactionType)..")")
	end
	
    self.completed = true
end

eso_task_quest_condition_moveto = inheritsFrom(eso_task_quest_condition)
eso_task_quest_condition_moveto.name = "QUEST_CONDITION_MOVETO"

function eso_task_quest_condition_moveto.Create()
    local newinst = inheritsFrom(eso_task_quest_condition_moveto)
    
	--ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.auxiliary = false
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
	
    --eso_task_quest_condition members
    newinst.name = "QUEST_CONDITION_MOVETO"
	newinst.pos = nil
    
    return newinst
end

function eso_task_quest_condition:Init()
	-- add task complete/fail cnes
	self:AddTaskCheckCEs()
	
	
end

eso_task_quest_condition_collectitem = inheritsFrom(eso_task_quest_condition)
eso_task_quest_condition_collectitem.name = "QUEST_CONDITION_COLLECTITEM"
function eso_task_quest_condition_collectitem.Create()
    local newinst = inheritsFrom(eso_task_quest_condition_collectitem)
    
	--ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.auxiliary = false
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
	
    --eso_task_quest_condition_collectitem members
    newinst.name = "QUEST_CONDITION_COLLECTITEM"
    
    return newinst
end

function eso_task_quest_condition_collectitem:Init()	
	-- add task complete/fail cnes
	self:AddTaskCheckCEs()

	-- now init class cnes
	local ke_movetointeract = ml_element:create( "MoveToInteract", c_movetointeract, e_movetointeract, 25 )
    self:add( ke_movetointeract, self.process_elements)
	
	local ke_interactitem = ml_element:create( "InteractItem", c_interactitem, e_interactitem, 20 )
    self:add( ke_interactitem, self.process_elements)
end

eso_task_quest_condition_interact = inheritsFrom(eso_task_quest_condition)
eso_task_quest_condition_interact.name = "QUEST_CONDITION_INTERACT"
function eso_task_quest_condition_interact.Create()
    local newinst = inheritsFrom(eso_task_quest_condition_interact)
    
	--ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.auxiliary = false
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
	
    --eso_task_quest_condition_interact members
    newinst.name = "QUEST_CONDITION_INTERACT"
    
    return newinst
end

function eso_task_quest_condition_interact:Init()	
	-- add task complete/fail cnes
	self:AddTaskCheckCEs()

	-- now init class cnes
	local ke_movetointeract = ml_element:create( "MoveToInteract", c_movetointeract, e_movetointeract, 25 )
    self:add( ke_movetointeract, self.process_elements)
	
	local ke_interact = ml_element:create( "Interact", c_interact, e_interact, 20 )
    self:add( ke_interact, self.process_elements)
end

eso_task_quest_condition_talkto = inheritsFrom(eso_task_quest_condition_interact)
eso_task_quest_condition_talkto.name = "QUEST_CONDITION_TALKTO"
function eso_task_quest_condition_talkto.Create()
    local newinst = inheritsFrom(eso_task_quest_condition_talkto)
    
	--ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.auxiliary = false
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
	
    --eso_task_quest_condition_talkto members
    newinst.name = "QUEST_CONDITION_TALKTO"
    
    return newinst
end

function eso_task_quest_condition_talkto:Init()	
	-- add task complete/fail cnes
	self:AddTaskCheckCEs()

	-- now init class cnes
	local ke_movetointeract = ml_element:create( "MoveToInteract", c_movetointeract, e_movetointeract, 25 )
    self:add( ke_movetointeract, self.process_elements)
	
	local ke_interact = ml_element:create( "Interact", c_interact, e_interact, 20 )
    self:add( ke_interact, self.process_elements)
	
	local ke_chatter = ml_element:create( "Chatter", c_chatter, e_chatter, 20 )
    self:add( ke_chatter, self.process_elements)
end

eso_task_quest_start = inheritsFrom(eso_task_quest_condition_talkto)
eso_task_quest_start.name = "QUEST_START"
function eso_task_quest_start.Create()
    local newinst = inheritsFrom(eso_task_quest_start)
    
	--ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.auxiliary = false
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
	
    --eso_task_quest_start members
    newinst.name = "QUEST_START"

    return newinst
end

function eso_task_quest_start:Init()
	-- add task complete/fail cnes
	self:AddTaskCheckCEs()

	-- now init class cnes
	local ke_movetointeract = ml_element:create( "MoveToInteract", c_movetointeract, e_movetointeract, 25 )
    self:add( ke_movetointeract, self.process_elements)
	
	local ke_interact = ml_element:create( "Interact", c_interact, e_interact, 15 )
    self:add( ke_interact, self.process_elements)
	
	local ke_chatter = ml_element:create( "Chatter", c_chatter, e_chatter, 20 )
    self:add( ke_chatter, self.process_elements)
	
	local ke_acceptquest = ml_element:create( "AcceptQuest", c_acceptquest, e_acceptquest, 30 )
    self:add( ke_acceptquest, self.process_elements)
	
	--clear out the quest event queue for offered/added if it wasn't cleared properly earlier
	eso_quest_event_queue["offered"] = false
	eso_quest_event_queue["added"] = {}
end

function eso_task_quest_start:task_complete_eval()
	return TableSize(eso_quest_event_queue["added"]) > 0
end

function eso_task_quest_start:task_complete_execute()
	eso_quest_event_queue["offered"] = false
	eso_quest_event_queue["added"] = {}
	
	self.completed = true
end