-- Grind
ai_grind = inheritsFrom(ml_task)
ai_grind.name = "GrindMode"

function ai_grind.Create()
	local newinst = inheritsFrom(ai_grind)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
	
    return newinst
end

function ai_grind:Init()
   -- ml_log("combatAttack_Init->")
	
	-- Dead?
	--self:add(ml_element:create( "Dead", c_dead, e_dead, 225 ), self.process_elements)
			
	-- Aggro
	self:add(ml_element:create( "Aggro", c_Aggro, e_Aggro, 250 ), self.process_elements) --reactive queue
			
	-- Resting
	self:add(ml_element:create( "Resting", c_resting, e_resting, 225 ), self.process_elements)	

	-- Looting
	self:add(ml_element:create( "Loot", c_Loot, e_Loot, 175 ), self.process_elements)
	
	-- Gathering
	self:add(ml_element:create( "Gathering", c_gatherTask, e_gatherTask, 125 ), self.process_elements)
	
	-- Check for Targets
	self:add(ml_element:create( "GetNextTarget", c_CombatTask, e_CombatTask, 75 ), self.process_elements)
		
	
    self:AddTaskCheckCEs()
end

function ai_grind:task_complete_eval()	
	return false
end
function ai_grind:task_complete_execute()
    
end





function ai_grind.moduleinit()
	
	
end
if ( ml_global_information.BotModes) then
	ml_global_information.BotModes[GetString("grindMode")] = ai_grind
end
RegisterEventHandler("Module.Initalize",ai_grind.moduleinit)
