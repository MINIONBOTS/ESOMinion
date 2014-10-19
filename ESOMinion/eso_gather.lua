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
	newinst.node = nil
	newinst.nodepos = nil
	newinst.interacting = false
	
    return newinst
end

--:======================================================================================================================================================================
--: gathertask init
--:======================================================================================================================================================================

function eso_gathertask:Init()

	--overwatch_elements
	--self:add(ml_element:create( "gatherupdate", c_gatherupdate, e_gatherupdate, 10 ), self.overwatch_elements)
	self:add(ml_element:create( "gatherwindow", c_gatherwindow, e_gatherwindow, 5 ), self.overwatch_elements)
	
	--process_elements
	self:add(ml_element:create( "gathernode", c_gathernode, e_gathernode, 100 ), self.process_elements)
	--self:add(ml_element:create( "betternode", c_betternode, e_betternode, 90 ), self.process_elements)
	self:add(ml_element:create( "movetonode", c_movetonode, e_movetonode, 75 ), self.process_elements)
	self:add(ml_element:create( "movetonodepos", c_movetonodepos, e_movetonodepos, 50 ), self.process_elements)
	
    self:AddTaskCheckCEs()
end

--:======================================================================================================================================================================
--: gathertask eval
--:======================================================================================================================================================================

eso_gathertask.newnode = false

function eso_gathertask:task_complete_eval()

	--check if player is dead
	if (e("IsUnitDead(player)")) then
		d("eso_gathertask -> task_complete_eval (player dead)")
		eso_gathertask.newnode = false
		return true
	end

	--check if aggro
	if (c_Aggro:evaluate()) then
		d("eso_gathertask -> task_complete_eval (aggro)")
		eso_gathertask.newnode = false
		return true
	end

	--check if players inventory is full
	if (e("CheckInventorySpaceSilently(1)") == false) then
		d("eso_gathertask -> task_complete_eval (no bagspace)")
		eso_gathertask.newnode = false
		return true
	end
	
	--check if node gathered
	if (ml_task_hub:CurrentTask().node) then
		local node = EntityList:Get(ml_task_hub:CurrentTask().node.id)
		
		if (node == nil) then
			local ppos = Player.pos
			local npos = ml_task_hub:CurrentTask().nodepos
			local distance = Distance3D(ppos.x,ppos.y,ppos.z,npos.x,npos.y,npos.z)
			
			if (distance < ml_global_information.gatherdistance) then
				d("eso_gathertask -> task_complete_eval (node gathered)")
				eso_gathertask.newnode = true
				return true
			end
		end
	end
	
	--check if node expired
	if (ml_task_hub:CurrentTask().node) then
		local node = EntityList:Get(ml_task_hub:CurrentTask().node.id)
		
		if (node) then
			local distance = node.distance
			
			if (distance < ml_global_information.gatherdistance) then
				if (ml_task_hub:CurrentTask().interacting) then
					if (not ml_task_hub:CurrentTask().maxtime) then
						ml_task_hub:CurrentTask().maxtime = ml_global_information.Now + 7500
					end
					
					if (ml_global_information.Now > ml_task_hub:CurrentTask().maxtime) then
						d("eso_gathertask -> task_complete_eval (node time expired)")
						EntityList:AddToBlacklist(node.id, 60000)
						eso_gathertask.newnode = true
						return true
					end
				end
			end
		end
	end

	--players around node
	if (not ml_task_hub:CurrentTask().interacting) then
		local node = eso_gather_manager.ClosestNode()
		if (node and node.pathdistance <= 10) then
			local players = EntityList("alive,nocritter,friendly,maxdistance=10")
			if (players) then
				local index,player = next(players)
					if (index and player and player.type == g("UNIT_TYPE_PLAYER")) then
					d("eso_gathertask -> task_complete_eval (node occupied)")
					EntityList:AddToBlacklist(node.id, 60000)
					eso_gathertask.newnode = true
					return true
				end
			end
		end
	end
	
	eso_gathertask.newnode = false
	return false
end

function eso_gathertask:task_complete_execute()

	--try to get a new node, before ending the task
	if (eso_gathertask.newnode) then
		local node = eso_gather_manager.ClosestNode()
		
		if (ValidTable(node)) then
			d("e_gather:execute -> task_complete_execute, new node: ("..node.name..") -> distance: ("..math.floor(node.pathdistance)..")")
			ml_task_hub:CurrentTask().node = node
			ml_task_hub:CurrentTask().nodepos = node.pos
			ml_task_hub:CurrentTask().maxtime = nil
			ml_task_hub:CurrentTask().interacting = false
			
			eso_gathertask.newnode = false
			return
		end
	end
	
	if (ml_global_information.Player_Sprinting) then e("OnSpecialMoveKeyUp(1)") end
	eso_gathertask.newnode = false
	self.completed = true
end

--:======================================================================================================================================================================
--: gather
--:======================================================================================================================================================================

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
		local task = eso_gathertask.Create()
		task.node = c_gather.node
		task.nodepos = c_gather.node.pos
		d("e_gather:execute -> adding new node: ("..c_gather.node.name..") -> distance: ("..math.floor(c_gather.node.pathdistance)..")")
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
	ml_log("e_gatherwindow ")
	e("LootAll()")
	ml_global_information.Wait(250)	
	return ml_log(true)
end

--:======================================================================================================================================================================
--: 
--:======================================================================================================================================================================

--self:add(ml_element:create( "gathernode", c_gathernode, e_gathernode, 100 ), self.process_elements)
c_gathernode = inheritsFrom(ml_cause)
e_gathernode = inheritsFrom(ml_effect)

function c_gathernode:evaluate()
	if (ml_task_hub:CurrentTask().node) then
		local node = EntityList:Get(ml_task_hub:CurrentTask().node.id)
		if (node) then
			if (node.pathdistance <= 2.5) then
				return true
			end
		end
	end
	return false
end

function e_gathernode:execute()
	ml_log("e_gathernode ")
	if (ml_task_hub:CurrentTask().node) then
		local node = EntityList:Get(ml_task_hub:CurrentTask().node.id)
		if (node and node.pathdistance <= 2.5) then
			if (not e("IsPlayerInteractingWithObject()")) then
				ml_task_hub:CurrentTask().maxtime = ml_global_information.Now + 7500
				ml_task_hub:CurrentTask().interacting = true
				Player:Interact(node.id)
				ml_global_information.Wait(500)	
			end
			return ml_log(true)
		end
	end
	return ml_log(false)
end

--self:add(ml_element:create( "movetonode", c_movetonode, e_movetonode, 75 ), self.process_elements)
c_movetonode = inheritsFrom(ml_cause)
e_movetonode = inheritsFrom(ml_effect)

function c_movetonode:evaluate()
	if (ml_task_hub:CurrentTask().node) then
		local node = EntityList:Get(ml_task_hub:CurrentTask().node.id)
		if (node and node.pathdistance > 2.5) then
			return true
		end
	end
	return false
end

function e_movetonode:execute()
	ml_log("e_movetonode ")
	if (ml_task_hub:CurrentTask().node) then
		local node = EntityList:Get(ml_task_hub:CurrentTask().node.id)
		if (node and node.pathdistance > 2.5) then
			Sprint()
			local navresult = tostring(Player:MoveTo(node.pos.x,node.pos.y,node.pos.z,2,false,true,false))
			if (tonumber(navresult) >= 0) then
				return ml_log(true)
			end
			return ml_log(false)
		end
	end
	return ml_log(false)
end

--self:add(ml_element:create( "movetonodepos", c_movetonodepos, e_movetonodepos, 50 ), self.process_elements)
c_movetonodepos = inheritsFrom(ml_cause)
e_movetonodepos = inheritsFrom(ml_effect)

function c_movetonodepos:evaluate()
	if (ml_task_hub:CurrentTask().nodepos) then
		local ppos = Player.pos
		local npos = ml_task_hub:CurrentTask().nodepos
		local dist = Distance3D(ppos.x,ppos.y,ppos.z,npos.x,npos.y,npos.z)
		if (dist and dist > 2.5) then
			return true
		end
	end
	return false
end

function e_movetonodepos:execute()
	ml_log("e_movetonodepos ")
	if (ml_task_hub:CurrentTask().nodepos) then
		local ppos = Player.pos
		local npos = ml_task_hub:CurrentTask().nodepos
		local dist = Distance3D(ppos.x,ppos.y,ppos.z,npos.x,npos.y,npos.z)
		if (dist and dist > 2.5) then
			Sprint()
			local navresult = tostring(Player:MoveTo(npos.x,npos.y,npos.z,2,false,true,false))
			if (tonumber(navresult) >= 0) then
				return ml_log(true)
			end
			return ml_log(false)
		end
	end
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
