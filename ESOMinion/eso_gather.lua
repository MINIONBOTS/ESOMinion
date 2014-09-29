--:======================================================================================================================================================================
--: eso_gather
--:======================================================================================================================================================================
--: added 9.7.2014
--: gathering botmode and associated cne's

eso_gather = inheritsFrom(ml_task)
eso_gather.name = "eso_gather"

function eso_gather.Create()

	local newinst = inheritsFrom(eso_gather)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {}
	
	--eso_gather members
	newinst.currentMarker = nil
	
    return newinst
end

function eso_gather:Init()

	--process_elements
	self:add(ml_element:create( "Dead", c_dead, e_dead, 300 ), self.process_elements)
	self:add(ml_element:create( "LootAll", c_LootAll, e_LootAll, 275 ), self.process_elements)	
	self:add(ml_element:create( "Aggro", c_Aggro, e_Aggro, 250 ), self.process_elements) --reactive queue
	self:add(ml_element:create( "Resting", c_resting, e_resting, 225 ), self.process_elements)	
	self:add(ml_element:create( "Vendor", c_Vendor, e_Vendor, 200 ), self.process_elements)
	self:add(ml_element:create( "Loot", c_Loot, e_Loot, 175 ), self.process_elements)
	self:add(ml_element:create( "Gather", c_gather, e_gather, 125 ), self.process_elements)
	self:add( ml_element:create( "GatherMarker", c_MoveToGatherMarker, e_MoveToGatherMarker, 100 ), self.process_elements)
	self:add( ml_element:create( "movetorandom", c_movetorandom, e_movetorandom, 50 ), self.process_elements)
		
    self:AddTaskCheckCEs()
end

function eso_gather:task_complete_eval()	
	return false
end

function eso_gather:task_complete_execute()
    
end

if ( ml_global_information.BotModes ) then
	ml_global_information.BotModes[GetString("gatherMode")] = eso_gather
end

--:======================================================================================================================================================================
--: gathertask create
--:======================================================================================================================================================================

eso_gathertask = inheritsFrom(ml_task)
eso_gathertask.name = "eso_gathertask"

function eso_gathertask.Create()

	local newinst = inheritsFrom(eso_gathertask)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {} 

	--eso_gather members
	newinst.pos = {}
	newinst.nodename = ""
	newinst.checkforplayers = true
	
    return newinst
end

--:======================================================================================================================================================================
--: gathertask init
--:======================================================================================================================================================================

function eso_gathertask:Init()

	--overwatch_elements
	self:add(ml_element:create( "gatherwindow", c_gatherwindow, e_gatherwindow, 25 ), self.overwatch_elements)
	
	--process_elements
	self:add(ml_element:create( "gathertask", c_gathertask, e_gathertask, 100 ), self.process_elements)
	
    self:AddTaskCheckCEs()
end

--:======================================================================================================================================================================
--: gathertask eval
--:======================================================================================================================================================================

function eso_gathertask:task_complete_eval()
	if (e("IsUnitDead(player)") or e("CheckInventorySpaceSilently(1)") == false or c_Aggro:evaluate()) then
		return true
	end

	return false
end

function eso_gathertask:task_complete_execute()
	if (ml_global_information.Player_Sprinting) then e("OnSpecialMoveKeyUp(1)") end
	self.completed = true
end

--:======================================================================================================================================================================
--: gather
--:======================================================================================================================================================================
--: adds the gather task to reactive queue
--: this should only be used in gather mode, there is a seperate "add task function" for grind mode

c_gather = inheritsFrom( ml_cause )
e_gather = inheritsFrom( ml_effect )
c_gather.throttle = 2500
c_gather.node = nil

function c_gather:evaluate()
	if (not ml_global_information.Player_InventoryFull) then
		local node = eso_gather_manager.ClosestNode()
		
		if (ValidTable(node)) then
			c_gather.node = node
			return true
		end
	end
	
	c_gather.node = nil
	return false
end

function e_gather:execute()
	if (c_gather.node) then
		ml_log("e_gather ")
		d("eso_gather -> creating new gather task for " .. c_gather.node.name)
		
		local task = eso_gathertask.Create()
		task.pos = c_gather.node.pos
		task.nodename = c_gather.node.name
		ml_task_hub:Add(task.Create(), REACTIVE_GOAL, TP_ASAP)
		
		return ml_log(true)
	end
	
	return ml_log(false)
end

--:======================================================================================================================================================================
--: gatherwindow
--:======================================================================================================================================================================
--: todo: add advanced looting from gatherwindow (ignore junk)

c_gatherwindow = inheritsFrom(ml_cause)
e_gatherwindow = inheritsFrom(ml_effect)

function c_gatherwindow:evaluate()
	return (e("GetNumLootItems()") > 0 or e("GetLootMoney()") > 0)
end

function e_gatherwindow:execute()
	ml_log("e_gatherwindow, looting (" .. ml_task_hub:CurrentTask().nodename .. ") -> ")
	e("LootAll()")
	ml_global_information.Wait(250)	
	return ml_log(true)
end

--:======================================================================================================================================================================
--: gathertask
--:======================================================================================================================================================================

c_gathertask = inheritsFrom(ml_cause)
e_gathertask = inheritsFrom(ml_effect)

function c_gathertask:evaluate()
	if (ValidTable(ml_task_hub:CurrentTask().pos)) then
		return true
	end

	ml_task_hub:CurrentTask().completed = true
	return false
end

function e_gathertask:execute()
	if (ValidTable(ml_task_hub:CurrentTask().pos)) then
		local ppos = Player.pos
		local tpos = ml_task_hub:CurrentTask().pos
		local dist = Distance3D(ppos.x,ppos.y,ppos.z,tpos.x,tpos.y,tpos.z)
			
		--already in gathering range
		if (dist <= ml_global_information.gatherdistance) then
			ml_log("e_gathertask: interacting with (" .. ml_task_hub:CurrentTask().nodename .. ") -> ")
			local node = eso_gather_manager.ClosestNode()
			if (ValidTable(node)) then
				if (node.distance <= ml_global_information.gatherdistance) then
					if (not e("IsPlayerInteractingWithObject()")) then
						ml_task_hub:CurrentTask().checkforplayers = false
						Player:Interact(node.id)
						ml_global_information.Wait(500)	
					end
					return ml_log(true)
				end
			end
			
		--move into gathering range
		elseif (dist > ml_global_information.gatherdistance) then

			--playercheck
			local playerfound = false
			local players = EntityList("player,alive,friendly,maxdistance=15")
			if (players) then
				local index,player = next(players)
				if (index and player) then
					if (player.type == g("UNIT_TYPE_PLAYER")) then
						local apos = player.pos
						local pdist = Distance3D(apos.x,apos.y,apos.z,tpos.x,tpos.y,tpos.z)
						if (pdist <= 10) then
							playerfound = true
						end
					end
				end
			end
			
			if (not playerfound) then
				ml_log("e_gathertask: moving to (" .. ml_task_hub:CurrentTask().nodename .. ") distance (" .. math.floor(dist) .. ") -> ")
				Sprint()
				local navresult = tostring(Player:MoveTo(tpos.x,tpos.y,tpos.z,ml_global_information.gatherdistance-0.5,false,true,false))
				if (tonumber(navresult) >= 0) then
					return ml_log(true)
				end
				return ml_log(false)
			else
				d("playerfound")
			end
		end
	end

	ml_task_hub:CurrentTask().completed = true
	return ml_log(false)
end

--:======================================================================================================================================================================
--: gathermarker (need/want to redo this asap)
--:======================================================================================================================================================================

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
			Sprint()			
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
