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
	self:add(ml_element:create( "Dead", c_dead, e_dead, 300 ), self.process_elements)
	
	-- LootAll
	self:add(ml_element:create( "LootAll", c_LootAll, e_LootAll, 275 ), self.process_elements)	
			
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
		
	-- Goto random point on mesh (for now, use markers later)
	self:add(ml_element:create( "GotoRandomPoint", c_randomPt, e_randomPt, 50 ), self.process_elements)
	
    self:AddTaskCheckCEs()
end

function ai_grind:task_complete_eval()	
	return false
end
function ai_grind:task_complete_execute()
    
end


-- Move to a random point on the mesh ..for now
c_randomPt = inheritsFrom( ml_cause )
e_randomPt = inheritsFrom( ml_effect )
function c_randomPt:evaluate()
	if ( not Player:IsMoving() ) then
		return true
	end
	return false
end
function e_randomPt:execute()
	ml_log("e_randomPt.. ")
	local ppos = Player.pos
	if ( TableSize(ppos)>0)then
		local p = NavigationManager:GetRandomPointOnCircle(ppos.x,ppos.y,ppos.z,30,5000)
		if ( p) then
			tb_xPos = tostring(p.x)
			tb_yPos = tostring(p.y)
			tb_zPos = tostring(p.z)				
			tb_xdist = Distance3D(p.x,p.y,p.z,ppos.x,ppos.y,ppos.z)
			if ( tb_xdist > 15 ) then
				local navResult = tostring(Player:MoveTo(p.x,p.y,p.z,0.5,false,true,false))
				if (tonumber(navResult) < 0) then
					ml_log("CombatMovement result: "..tostring(navResult))
					return ml_log(false)
				end				
				return ml_log(true)
			end
		end
	end
	return ml_log(false)
end





function ai_grind.moduleinit()
	
	
end
if ( ml_global_information.BotModes) then
	ml_global_information.BotModes[GetString("grindMode")] = ai_grind
end
RegisterEventHandler("Module.Initalize",ai_grind.moduleinit)
