-- Handles Looting, Gathering and so on

-- Gather Task
ai_gatherTask = inheritsFrom(ml_task)
ai_gatherTask.name = "Gathering"
function ai_gatherTask.Create()
    --ml_log("combatAttack:Create")
	local newinst = inheritsFrom(ai_gatherTask)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {} 
	newinst.tPos = {}
    return newinst
end
function ai_gatherTask:Init()
		
	-- Aggro
	-- Cant add aggro since gather task is also in reactive queue like aggro
	
	-- Resting
	self:add(ml_element:create( "Resting", c_resting, e_resting, 145 ), self.process_elements)
	
	-- Gathering
	self:add(ml_element:create( "Gathering", c_Gathering, e_Gathering, 65 ), self.process_elements)
		
    self:AddTaskCheckCEs()
end
function ai_gatherTask:task_complete_eval()	
	if ( c_dead:evaluate() or ( c_Aggro:evaluate() and Player.hp.percent < 95) ) then 
		Player:Stop()
		return true
	end
	return false
end
function ai_gatherTask:task_complete_execute()
   self.completed = true
end

------------
c_gatherTask = inheritsFrom( ml_cause )
e_gatherTask = inheritsFrom( ml_effect )
c_gatherTask.throttle = 2500
function c_gatherTask:evaluate()
   -- ml_log("c_gatherTask")
    return (gGather == "1" and TableSize(EntityList("onmesh,nearest,gatherable")) > 0)
end
function e_gatherTask:execute()
	ml_log("e_gatherTask ")
	Player:Stop()
	local newTask = ai_gatherTask.Create()
	local GList = EntityList("onmesh,nearest,gatherable")
	if ( TableSize(GList)>0) then
		local id,gatherable = next(GList)
		if ( gatherable ) then
			newTask.tPos = gatherable.pos
		else
			ml_error("gatherable not in list..")
		end
	else
		ml_error("Bug: GList in e_gatherTask is empty!?")
	end
	ml_task_hub:Add(newTask.Create(), REACTIVE_GOAL, TP_ASAP)
	return ml_log(true)	
end


---
c_Gathering = inheritsFrom( ml_cause )
e_Gathering = inheritsFrom( ml_effect )
function c_Gathering:evaluate()
		
	if ( TableSize(ml_task_hub:CurrentTask().tPos) == 0 ) then
		local _,gatherable = next(EntityList("onmesh,nearest,gatherable,maxdistance=50"))
		if (gatherable) then
			local gPos = gatherable.pos
			if ( TableSize(gPos) > 0 ) then
				ml_task_hub:CurrentTask().tPos = gatherable.pos
			end
		end
	else		
		return true
	end
	
	-- no gatherable nearby and our current one is gathered, ending task
	ml_task_hub:CurrentTask().completed = true
	return false
end

e_Gathering.tmr = 0
e_Gathering.threshold = 500
function e_Gathering:execute()
	ml_log("e_Gathering ")
	if ( TableSize(ml_task_hub:CurrentTask().tPos) > 0 ) then
		local pPos = Player.pos
		local tPos = ml_task_hub:CurrentTask().tPos
		local dist = Distance3D(tPos.x, tPos.y, tPos.z, pPos.x, pPos.y, pPos.z)
		if (dist > 2) then
			-- MoveIntoInteractRange
			if ( tPos ) then
				
				local navResult = tostring(Player:MoveTo(tPos.x,tPos.y,tPos.z,0.5,false,true,true))
				if (tonumber(navResult) < 0) then
					d("e_Gathering.MoveIntoRange result: "..tonumber(navResult))
				end
				if ( ml_global_information.Now - e_Gathering.tmr > e_Gathering.threshold ) then
					e_Gathering.tmr = ml_global_information.Now
					e_Gathering.threshold = math.random(1000,3000)
					eso_skillmanager.HealMe()
				end
				ml_log("MoveToGatherable..")
				return true
			end
		else
			-- Grab that thing			
			local GList = EntityList("onmesh,nearest,gatherable,maxdistance=10")
			if ( TableSize(GList)>0) then
				local _,gatherable = next(GList)				
				if (gatherable) then
					local gPos = gatherable.pos
					Player:Interact( gatherable.id )
					ml_log("Gathering..")
					ml_global_information.Wait(500)					
					
					return ml_log(true)
					
				else
					d("No gatherable nearby anymore, finishing gathertask")
					ml_task_hub:CurrentTask().tPos = {}
					return ml_log(true)
				end
			else
				d("No gatherable nearby anymore, finishing gather task")
				ml_task_hub:CurrentTask().tPos = {}
				return ml_log(true)
			end
		end
	end
	ml_error("Bug in e_Gathering() , no case that handled our situation")
	ml_task_hub:CurrentTask().tPos = {}
	return ml_log(false)
end


------------
c_Loot = inheritsFrom( ml_cause )
e_Loot = inheritsFrom( ml_effect )
function c_Loot:evaluate()
    return TableSize(EntityList("nearest,lootable,onmesh,maxdistance=50")) > 0
end
function e_Loot:execute()
	ml_log("e_Loot")
	local CharList = EntityList("lootable,shortestpath,onmesh")
	if ( TableSize(CharList) > 0 ) then
		local id,entity = next (CharList)
		if ( id and entity ) then
			local tPos = entity.pos
			
			if ( entity.distance > 2) then
				-- MoveIntoInteractRange				
				if ( tPos ) then					
					local navResult = tostring(Player:MoveTo(tPos.x,tPos.y,tPos.z,0.5,false,true,true))		
					if (tonumber(navResult) < 0) then
						d("e_Loot.MoveIntoCombatRange result: "..tonumber(navResult))					
					end
					ml_log("MoveToLootable..")
					return ml_log(true)
				end
			else
				-- Grab that thing
				Player:Stop()				
				Player:Interact( entity.id )
				ml_log("Looting..")
				ml_global_information.Wait(500)
				return ml_log(true)
			end
		end
	end
	return ml_log(false)	
end