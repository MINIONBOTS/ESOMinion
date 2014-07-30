
ai_gathermode = inheritsFrom(ml_task)
ai_gathermode.name = "GatherMode"

function ai_gathermode.Create()
	local newinst = inheritsFrom(ai_gathermode)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
	
    return newinst
end



function ai_gathermode:Init()

	-- Dead?
	self:add(ml_element:create( "Dead", c_dead, e_dead, 300 ), self.process_elements)
	
	-- LootAll
	self:add(ml_element:create( "LootAll", c_LootAll, e_LootAll, 275 ), self.process_elements)	
	
	-- Aggro
	self:add(ml_element:create( "Aggro", c_Aggro, e_Aggro, 250 ), self.process_elements) --reactive queue
			
	-- Resting
	self:add(ml_element:create( "Resting", c_resting, e_resting, 225 ), self.process_elements)	

	--Vendoring
	self:add(ml_element:create( "Vendor", c_Vendor, e_Vendor, 200 ), self.process_elements)
	
	-- Looting
	self:add(ml_element:create( "Loot", c_Loot, e_Loot, 175 ), self.process_elements)
	
	-- Gathering
	self:add(ml_element:create( "Gathering", c_gatherTask, e_gatherTask, 125 ), self.process_elements)
	
	-- Gather Marker
	self:add( ml_element:create( "GatherMarker", c_MoveToGatherMarker, e_MoveToGatherMarker, 100 ), self.process_elements)

	-- Move to a Randompoint if there is nothing to gather around us
	self:add( ml_element:create( "MoveToRandomPoint", c_MoveToRandomPoint, e_MoveToRandomPoint, 50 ), self.process_elements)
		
    self:AddTaskCheckCEs()
end

function ai_gathermode:task_complete_eval()	
	return false
end
function ai_gathermode:task_complete_execute()
    
end
if ( ml_global_information.BotModes ) then
	ml_global_information.BotModes[GetString("gatherMode")] = ai_gathermode
end


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
		
	-- LootAll
	self:add(ml_element:create( "LootAll", c_LootAll, e_LootAll, 275 ), self.process_elements)		
	
	-- Resting
	self:add(ml_element:create( "Resting", c_resting, e_resting, 145 ), self.process_elements)
	
	-- Gathering
	self:add(ml_element:create( "Gathering", c_Gathering, e_Gathering, 65 ), self.process_elements)
		
    self:AddTaskCheckCEs()
end
function ai_gatherTask:task_complete_eval()	
	if ( c_dead:evaluate() or c_Aggro:evaluate() or ml_global_information.Player_InventoryFull) then 
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
c_gatherTask.target = nil
function c_gatherTask:evaluate()
	if ( gGather == "1" and not ml_global_information.Player_InventoryFull) then
		-- If gatherMarkers are added, you need to add logic to not try to reach a gatherable outside of the marker radius!!!
		if ( gBotMode == GetString("gatherMode") ) then
			local gatherable = eso_gathermanager.NearestGatherable()
			if ValidTable(gatherable) then
				c_gatherTask.target = gatherable
				return true
			end
		else
			if ( not ml_global_information.Player_InCombat and TableSize(EntityList("nearest,alive,attackable,targetable,maxdistance=45,onmesh")) == 0 ) then
				local gatherable = eso_gathermanager.NearestGatherable()
				if ValidTable(gatherable) then
					if gatherable.distance < 20 then
						c_gatherTask.target = gatherable
						return true
					end
				end
			end	
		end
	end
	c_gatherTask.target = nil
	return false
end
function e_gatherTask:execute()
	ml_log("e_gatherTask ")
	Player:Stop()
	local newTask = ai_gatherTask.Create()
	
	if ( c_gatherTask.target ~= nil ) then		
		newTask.tPos = c_gatherTask.target.pos		
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
	
		local gatherable = eso_gathermanager.NearestGatherable()
		if ValidTable(gatherable) then
			ml_task_hub:CurrentTask().tPos = gatherable.pos
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
ml_global_information.Player_Sprinting = false
ml_global_information.Player_SprintingRecharging = false 
function e_Gathering:execute()
	ml_log("e_Gathering ")
	if ( TableSize(ml_task_hub:CurrentTask().tPos) > 0 ) then
		local pPos = Player.pos
		local tPos = ml_task_hub:CurrentTask().tPos
		local dist = Distance3D(tPos.x, tPos.y, tPos.z, pPos.x, pPos.y, pPos.z)
		
		if gUseMount == "1" and tonumber(gUseMountRange) <= dist then
			ai_mount:Mount()
		elseif gUseMount == "1" and dist <= 5 then
			ai_mount:Dismount()
		end
		
		if (dist > 2) then
			-- MoveIntoInteractRange
			if ( tPos ) then			
				if (gSprint == "1") then
					if (ml_global_information.Player_Sprinting == false and ml_global_information.Player_Stamina.percent > tonumber(gSprintStopThreshold) and not ml_global_information.Player_SprintingRecharging) then
						--e("OnSpecialMoveKeyUp(1)")
						e("OnSpecialMoveKeyDown(1)")
						ml_global_information.Player_Sprinting = true
					elseif (ml_global_information.Player_Stamina.percent > 99 and ml_global_information.Player_SprintingRecharging) then
						ml_global_information.Player_SprintingRecharging = false
					elseif (ml_global_information.Player_Stamina.percent < tonumber(gSprintStopThreshold) and not ml_global_information.Player_SprintingRecharging) then
						e("OnSpecialMoveKeyUp(1)")
						ml_global_information.Player_SprintingRecharging = true
						ml_global_information.Player_Sprinting = false
					end
				elseif (ml_global_information.Player_Sprinting == true) then
					e("OnSpecialMoveKeyUp(1)")
					ml_global_information.Player_SprintingRecharging = false
					ml_global_information.Player_Sprinting = false 
				end
        
			local rndPath = false
			if (dist>20) then rndPath = true else rndPath = false end
        
				local navResult = tostring(Player:MoveTo(tPos.x,tPos.y,tPos.z,1.5,false,rndPath,false))
				if (tonumber(navResult) < 0) then
					d("e_Gathering.MoveIntoRange result: "..tonumber(navResult))
				end
				if ( ml_global_information.Now - e_Gathering.tmr > e_Gathering.threshold ) then
					e_Gathering.tmr = ml_global_information.Now
					e_Gathering.threshold = math.random(1000,3000)
					eso_skillmanager.Heal( Player.id )
				end
				ml_log("MoveToGatherable..")
				return true
			end
		else
			-- Grab that thing			
			--local GList = EntityList("onmesh,nearest,gatherable,maxdistance=5")

			local gatherable = eso_gathermanager.NearestGatherable()
			if ValidTable(gatherable) then
				ml_task_hub:CurrentTask().tPos = gatherable.pos
			end
			
			if ValidTable(gatherable) then

				-- another check if we may picked up a different gatherable/old one is gone meanwhile
				local tPos = gatherable.pos
				local dist = Distance3D(tPos.x, tPos.y, tPos.z, pPos.x, pPos.y, pPos.z)
			
				if (dist > 2) then
					-- set new gatherable position
					d("Different gatherable found, setting new position..")
					ml_task_hub:CurrentTask().tPos = tPos
					ml_task_hub:CurrentTask().timestarted = nil
					return ml_log(true)
				end
				
				if not ml_task_hub:CurrentTask().timestarted then
					ml_task_hub:CurrentTask().timestarted = ml_global_information.Now
				end
			
				local timediff = ml_global_information.Now - ml_task_hub:CurrentTask().timestarted
				local playerfound = nil
				local timeexpired = nil
				
				local players = EntityList("player,alive,friendly,maxdistance=5")
				if players then
					local index,player = next(players)
					if index and player then
						if player.type == g("UNIT_TYPE_PLAYER") then
							playerfound = true
						end
					end
				end
				
				if timediff > 10000 then	
					timeexpired = true
				end
				
				if playerfound or timeexpired then
					d("Blacklisting Gatherable " .. gatherable.id)
					EntityList:AddToBlacklist(gatherable.id, 300000)
					ml_task_hub:CurrentTask().timestarted = nil
					ml_task_hub:CurrentTask().completed = true
					return ml_log(false)
				end		
				
				if ( not e("IsPlayerInteractingWithObject()") ) then
					Player:Interact( gatherable.id )
					ml_log("Gathering Node..")
					ml_global_information.Wait(500)					
				end

				return ml_log(true)
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

c_MoveToGatherMarker = inheritsFrom( ml_cause )
e_MoveToGatherMarker = inheritsFrom( ml_effect )
e_MoveToGatherMarker.reached = false
e_MoveToGatherMarker.returned = false

function c_MoveToGatherMarker:evaluate()
	
	local needmarker = false
	
	-- haven't reached, or reached and did not return to the marker
	if (ml_task_hub:CurrentTask().currentMarker and (not e_MoveToGatherMarker.reached or not e_MoveToGatherMarker.returned)) then
		return true
	end
	
	-- already reached and returned to the marker once
	if (ml_task_hub:CurrentTask().currentMarker and (e_MoveToGatherMarker.reached or e_MoveToGatherMarker.returned)) then
		needmarker = true
	end
	
	--check the timer
	local timeexpired = false
	if (ml_task_hub:CurrentTask().currentMarker) then
		if (ml_task_hub:CurrentTask().currentMarker:GetTime() and ml_task_hub:CurrentTask().currentMarker:GetTime() ~= 0) then
			if (TimeSince(ml_task_hub:CurrentTask().markerTime) > ml_task_hub:CurrentTask().currentMarker:GetTime() * 1000) then
				needmarker = true
			end
		end
	end
	
	--get a marker, if needed (and available)
	if (ml_task_hub:CurrentTask().currentMarker == nil or needmarker == true) then
		local newmarker = ml_marker_mgr.GetNextMarker("GatherMarker", false)
		if ValidTable(newmarker) then
			d("new marker")
			ml_task_hub:CurrentTask().currentMarker = newmarker
			ml_task_hub:CurrentTask().markerTime = ml_global_information.Now
			ml_global_information.MarkerTime = ml_global_information.Now
			e_MoveToGatherMarker.reached = false
			e_MoveToGatherMarker.returned = false
			return true
		end
	end

	return false
end

function e_MoveToGatherMarker:execute()
	ml_log(" e_MoveToGatherMarker ")

	if (ml_task_hub:CurrentTask().currentMarker ~= false and ml_task_hub:CurrentTask().currentMarker ~= nil) then
		
		local pos = ml_task_hub:CurrentTask().currentMarker:GetPosition()
		local dist = Distance2D(ml_global_information.Player_Position.x, ml_global_information.Player_Position.z, pos.x, pos.z)

		if gUseMount == "1" and tonumber(gUseMountRange) <= dist then
			ai_mount:Mount()
		elseif gUseMount == "1" and tonumber(gUseMountRange) > dist then
			ai_mount:Dismount()
		end
		
		if  ( dist < 10 ) then
			if not e_MoveToGatherMarker.reached then
				e_MoveToGatherMarker.reached = true
			elseif e_MoveToGatherMarker.reached then
				if not e_MoveToGatherMarker.returned then
					e_MoveToGatherMarker.returned = true
				end
			end
			d("Reached current Marker...")
			return ml_log(true)		
		else
			-- We need to reach our Marker yet			
			local navResult = tostring(Player:MoveTo(pos.x,pos.y,pos.z,10,false,true,false))
			if (tonumber(navResult) < 0) then
				ml_log("e_MoveToMarker result: "..tostring(navResult))
				return ml_log(false)
			end
			return ml_log(true)
		end
	end
	return ml_log(false)
end
